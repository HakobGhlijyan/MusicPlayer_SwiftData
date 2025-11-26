//
//  ImportFileManager.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/21/25.
//  SwiftData + ExternalStorage Example
//

import SwiftUI
import SwiftData
import AVKit
import UniformTypeIdentifiers

/// A wrapper around `UIDocumentPickerViewController` that allows selecting audio files
/// and importing them into the app.
/// — Обёртка над `UIDocumentPickerViewController`, позволяющая выбирать аудиофайлы
/// и импортировать их в приложение.
struct ImportFileManager: UIViewControllerRepresentable {
    @Environment(\.modelContext) private var context

    /// Controls selection behavior:
    /// - `true` — user can choose only **one** audio file per picker session
    /// - `false` — user is allowed to select **multiple** files at once
    /// — Управляет режимом выбора:
    /// - `true` — пользователь может выбрать только **один** файл за раз
    /// - `false` — разрешён выбор **нескольких** файлов одновременно
    var singleSelection: Bool = true

    /// Creates and configures the underlying `UIDocumentPickerViewController`.
    /// — Создаёт и настраивает `UIDocumentPickerViewController`.
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio])

        /// If singleSelection is true → do NOT allow multiple selection
        /// — Если singleSelection равен true → запрещаем множественный выбор
        picker.allowsMultipleSelection = !singleSelection

        /// Display file extensions like .mp3, .wav, etc.
        /// — Показывать расширения файлов, например .mp3, .wav
        picker.shouldShowFileExtensions = true

        /// Assign the coordinator as delegate to receive picker callbacks
        /// — Назначаем координатор делегатом для получения событий
        picker.delegate = context.coordinator

        return picker
    }

    /// Required by `UIViewControllerRepresentable`, but unused.
    /// — Обязательный метод для протокола, но здесь не используется.
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) { }

    /// Creates the coordinator that handles picker delegate callbacks.
    /// — Создаёт координатор, обрабатывающий события документа-пикера.
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, modelContext: context)
    }

    /// A delegate class responsible for handling user interactions
    /// with the document picker.
    /// — Класс-делегат, отвечающий за обработку взаимодействия пользователя
    /// с документ-пикером.
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let modelContext: ModelContext

        /// Reference to the parent representable.
        /// — Ссылка на родительскую структуру.
        let parent: ImportFileManager
        
        /// Initializes the coordinator with a reference to the parent.
        /// — Инициализирует координатор с привязкой к родителю.
        init(parent: ImportFileManager, modelContext: ModelContext) {
            self.parent = parent
            self.modelContext = modelContext
        }

        /// Called when the user selects one or more documents.
        /// — Вызывается, когда пользователь выбирает один или несколько файлов.
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {

            /// If single selection is enabled, only process the first file
            /// — Если включён режим одиночного выбора, обрабатываем только первый URL
            if parent.singleSelection {
                guard let url = urls.first else { return }
                process(url: url)
            } else {
                /// Otherwise process all selected files
                /// — Иначе обрабатываем все выбранные файлы
                for url in urls {
                    process(url: url)
                }
            }
        }

        /// Imports a selected audio file, extracts metadata asynchronously,
        /// and saves it into SwiftData avoiding duplicates.
        ///
        /// — Импортирует выбранный аудиофайл, асинхронно извлекает метаданные
        /// и сохраняет в SwiftData, предотвращая дубликаты.
        private func process(url: URL) {

            /// Begin secure access for sandbox-protected external file URLs.
            /// — Начинаем безопасный доступ к файлу вне sandbox.
            guard url.startAccessingSecurityScopedResource() else { return }

            /// Always release access when function completes.
            /// — Гарантированно освобождаем доступ при выходе из функции.
            defer { url.stopAccessingSecurityScopedResource() }

            /// Perform heavy work off the main thread using Swift Concurrency.
            /// — Выполняем тяжёлую работу вне главного потока с помощью Swift Concurrency.
            Task.detached { [weak self] in

                /// Prevent work if coordinator was deallocated.
                /// — Прекращаем выполнение, если объект был освобождён.
                guard let self else { return }

                do {
                    // MARK: - 1) Load File + Metadata (Background)

                    /// Read the audio file into memory.
                    /// Can throw if the URL is invalid or unreadable.
                    /// — Читаем аудиофайл в память.
                    /// Может вызвать ошибку, если URL недействителен.
                    let data = try Data(contentsOf: url)

                    /// Create AVAsset for loading metadata such as title, artist and duration.
                    /// — Создаём AVAsset для получения метаданных: название, артист, длительность.
                    let asset = AVAsset(url: url)

                    /// Load duration using modern async API (iOS 16+).
                    /// Replaces deprecated synchronous `.duration`.
                    /// — Загружаем длительность через современный async API (iOS 16+).
                    /// Заменяет устаревший синхронный `.duration`.
                    let duration = try await asset.load(.duration)

                    /// Convert CMTime to seconds.
                    /// — Переводим CMTime в секунды.
                    let seconds = CMTimeGetSeconds(duration)

                    /// Load metadata asynchronously (replaces deprecated `.metadata`).
                    /// — Асинхронно загружаем метаданные (вместо устаревшего `.metadata`).
                    let metadata = try await asset.load(.metadata)

                    /// Default values extracted before parsing metadata.
                    /// — Значения по умолчанию до обработки метаданных.
                    var title = url.lastPathComponent
                    var artist: String?
                    var artwork: Data?

                    /// Iterate through metadata items and extract only supported ones.
                    /// — Перебираем все элементы метаданных и получаем только нужные.
                    for item in metadata {
                        switch item.commonKey?.rawValue {

                        case AVMetadataKey.commonKeyTitle.rawValue:
                            /// Attempt to load track title.
                            /// — Пытаемся загрузить название трека.
                            title = (try? await item.load(.value) as? String) ?? title

                        case AVMetadataKey.commonKeyArtist.rawValue:
                            /// Attempt to load artist name.
                            /// — Пытаемся загрузить имя исполнителя.
                            artist = try? await item.load(.value) as? String

                        case AVMetadataKey.commonKeyArtwork.rawValue:
                            /// Attempt to load album artwork image.
                            /// — Пытаемся загрузить обложку альбома.
                            artwork = try? await item.load(.value) as? Data

                        default:
                            /// Ignore unsupported metadata types.
                            /// — Пропускаем неподдерживаемые типы метаданных.
                            break
                        }
                    }

                    /// Store extracted metadata in a lightweight struct.
                    /// — Сохраняем извлечённые данные во временную структуру.
                    let info = ImportedSongInfo(
                        name: title,
                        artist: artist,
                        cover: artwork,
                        duration: seconds,
                        data: data
                    )


                    // MARK: - 2) Save to SwiftData (MainActor)

                    /// Switch to main thread for SwiftData operations.
                    /// — Переключаемся на главный поток для операций SwiftData.
                    await MainActor.run {

                        /// Fetch existing songs to compare against duplicates.
                        /// — Получаем существующие записи для проверки дубликатов.
                        let existing = try? self.modelContext.fetch(FetchDescriptor<Song>())

                        /// Skip if song already exists by name + artist.
                        /// — Пропускаем, если такая песня уже есть (name + artist).
                        if existing?.contains(where: {
                            $0.name == info.name &&
                            ($0.artist ?? "") == (info.artist ?? "")
                        }) == true {
                            print("⚠️ Duplicate skipped: \(info.name)")
                            return
                        }

                        /// Create a new Song only on the main thread.
                        /// — Создаём Song только на главном потоке.
                        let song = Song(
                            name: info.name,
                            data: info.data,
                            artist: info.artist,
                            coverImage: info.cover,
                            duration: info.duration
                        )

                        /// Insert into SwiftData storage.
                        /// — Вставляем в базу SwiftData.
                        self.modelContext.insert(song)

                        /// Log success for debugging purposes.
                        /// — Логируем успешное сохранение для отладки.
                        print("✅ Saved: \(song.name)")
                    }

                } catch {
                    /// Handle any thrown errors gracefully.
                    /// — Корректно обрабатываем любые возникшие ошибки.
                    print("❌ Import failed: \(error.localizedDescription)")
                }
            }
        }
        /*
        private func process(url: URL) {
            /// Begin accessing a security-scoped resource (required in sandbox)
            /// — Начинаем доступ к защищённому ресурсу (обязательно в sandbox)
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    /// Load the audio file into memory
                    /// — Загружаем аудиофайл в память
                    let data = try Data(contentsOf: url)

                    /// Create an AVAsset to extract metadata such as title and artist
                    /// — Создаём `AVAsset` для извлечения метаданных (название, артист)
                    let asset = AVAsset(url: url)

                    /// Initialize a Song model with fallback name
                    /// — Инициализируем модель Song с именем по умолчанию
                    let song = Song(name: url.lastPathComponent, data: data)

                    /// Iterate through metadata items and assign supported values
                    /// — Перебираем метаданные и сохраняем поддерживаемые значения
                    for item in asset.metadata {
                        guard
                            let key = item.commonKey?.rawValue,
                            let value = item.value
                        else { continue }

                        switch key {
                        case AVMetadataKey.commonKeyTitle.rawValue:
                            /// Set song title if available
                            /// — Устанавливаем название песни, если найдено
                            song.name = value as? String ?? "unknown"

                        case AVMetadataKey.commonKeyArtist.rawValue:
                            /// Set artist name
                            /// — Устанавливаем имя исполнителя
                            song.artist = value as? String

                        case AVMetadataKey.commonKeyArtwork.rawValue:
                            /// Set cover image data
                            /// — Устанавливаем обложку трека (если есть)
                            song.coverImage = value as? Data

                        default:
                            break
                        }
                    }

                    /// Convert duration to seconds
                    /// — Конвертируем длительность трека в секунды
                    song.duration = CMTimeGetSeconds(asset.duration)

                    DispatchQueue.main.async {
                        // ✅ duplicate check for SwiftData
                        if let existing = try? self.modelContext.fetch(
                            FetchDescriptor<Song>()
                        ), existing.contains(where: {
                            $0.name == song.name &&
                            ($0.artist ?? "") == (song.artist ?? "")
                        }) {
                            print("⚠️ Duplicate skipped: \(song.name)")
                            return
                        }

                        /// Update the UI on the main thread
                        /// — Обновляем UI на главном потоке
                        self.modelContext.insert(song)
                        print("✅ Saved with externalStorage: \(song.name)")
                    }

                } catch {
                    /// Handle loading failure
                    /// — Обработка ошибок загрузки файла
                    print("❌ Failed to load file: \(error.localizedDescription)")
                }
            }
        }
         */
    }
}

fileprivate struct ImportedSongInfo {
    let name: String
    let artist: String?
    let cover: Data?
    let duration: Double
    let data: Data
}
