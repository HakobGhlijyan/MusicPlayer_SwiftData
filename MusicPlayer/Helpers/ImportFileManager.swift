//
//  ImportFileManager.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/21/25.
//

//Version For Tutorial
/*
 import SwiftUI
 import AVKit
 internal import UniformTypeIdentifiers

 struct ImportFileManager: UIViewControllerRepresentable {
     @Binding var songs: [Song]
     
     func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
         let docPicker =  UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
         docPicker.allowsMultipleSelection = false //select only one file
 //        docPicker.allowsMultipleSelection = true //select only more file
         docPicker.shouldShowFileExtensions = true //see file extension
         docPicker.delegate = context.coordinator
         return docPicker
     }
     
     func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) { }
     
     func makeCoordinator() -> Coordinator {
         return Coordinator(parent: self)
     }
     
     class Coordinator: NSObject, UIDocumentPickerDelegate {
         var parent: ImportFileManager
         
         init(parent: ImportFileManager) {
             self.parent = parent
         }
         
         //Func Call for User select MP3 File
         func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
             guard
                 let url = urls.first,
                 url.startAccessingSecurityScopedResource()           //Start open secure for use file manager
             else { return }
             
             defer { url.stopAccessingSecurityScopedResource() }      //Stop secure for use file manager
             
             do {
                 let document = try Data(contentsOf: url)
                 let asset = AVAsset(url: url)
                 var song = Song(name: url.lastPathComponent, data: document)
                 
                 let metadata = asset.metadata
                 
                 for item in metadata {
                     guard let key = item.commonKey?.rawValue, let value = item.value else { continue }
                     
                     switch key {
                     case AVMetadataKey.commonKeyTitle.rawValue: song.name = value as? String ?? "unknown"
                     case AVMetadataKey.commonKeyArtist.rawValue: song.artist = value as? String
                     case AVMetadataKey.commonKeyArtwork.rawValue: song.coverImage = value as? Data
                     default: break
                     }
                 }
                 
                 song.duration = CMTimeGetSeconds(asset.duration)
                 
                 if !self.parent.songs.contains(where: { $0.name == song.name }) {
                     DispatchQueue.main.async {
                         self.parent.songs.append(song)
                     }
                 } else {
                     print("Error: \(#function) Song with the some name is already exists")
                 }
             } catch {
                 print("Error: \(#function) - \(error.localizedDescription)")
             }
         }
     }
 }

 */

//Universal version
/*
 import SwiftUI
 import AVKit
 import UniformTypeIdentifiers

 /// A wrapper around `UIDocumentPickerViewController` that allows selecting audio files
 /// and importing them into the app.
 /// — Обёртка над `UIDocumentPickerViewController`, позволяющая выбирать аудиофайлы
 /// и импортировать их в приложение.
 struct ImportFileManager: UIViewControllerRepresentable {

     /// A binding to the list of imported songs.
     /// The picker appends newly selected audio files here.
     /// — Привязка к списку импортированных песен.
     /// Пикер добавляет сюда выбранные пользователем аудиофайлы.
     @Binding var songs: [Song]

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
         Coordinator(parent: self)
     }

     /// A delegate class responsible for handling user interactions
     /// with the document picker.
     /// — Класс-делегат, отвечающий за обработку взаимодействия пользователя
     /// с документ-пикером.
     class Coordinator: NSObject, UIDocumentPickerDelegate {

         /// Reference to the parent representable.
         /// — Ссылка на родительскую структуру.
         let parent: ImportFileManager

         /// Initializes the coordinator with a reference to the parent.
         /// — Инициализирует координатор с привязкой к родителю.
         init(parent: ImportFileManager) {
             self.parent = parent
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

         /// Processes a selected file URL by reading its data, extracting metadata,
         /// and appending the resulting `Song` to the parent binding.
         /// — Обрабатывает выбранный файл: читает данные, извлекает метаданные
         /// и добавляет полученную `Song` в список родителя.
         private func process(url: URL) {

             /// Begin accessing a security-scoped resource (required in sandbox)
             /// — Начинаем доступ к защищённому ресурсу (обязательно в sandbox)
             guard url.startAccessingSecurityScopedResource() else { return }
             defer { url.stopAccessingSecurityScopedResource() }

             do {
                 /// Load the audio file into memory
                 /// — Загружаем аудиофайл в память
                 let data = try Data(contentsOf: url)

                 /// Create an AVAsset to extract metadata such as title and artist
                 /// — Создаём `AVAsset` для извлечения метаданных (название, артист)
                 let asset = AVAsset(url: url)

                 /// Initialize a Song model with fallback name
                 /// — Инициализируем модель Song с именем по умолчанию
                 var song = Song(name: url.lastPathComponent, data: data)

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

                 /// Avoid adding duplicate entries by name
                 /// — Предотвращаем добавление дубликатов по имени
                 guard !parent.songs.contains(where: { $0.name == song.name }) else {
                     print("⚠️ Duplicate skipped: \(song.name)")
                     return
                 }

                 /// Update the UI on the main thread
                 /// — Обновляем UI на главном потоке
                 DispatchQueue.main.async {
                     self.parent.songs.append(song)
                 }

             } catch {
                 /// Handle loading failure
                 /// — Обработка ошибок загрузки файла
                 print("❌ Failed to load file: \(error.localizedDescription)")
             }
         }
     }
 }
 */

//Universal version + Realm DB
import SwiftUI
import AVKit
import UniformTypeIdentifiers
import RealmSwift

/// A wrapper around `UIDocumentPickerViewController` that allows selecting audio files
/// and importing them into the app.
/// — Обёртка над `UIDocumentPickerViewController`, позволяющая выбирать аудиофайлы
/// и импортировать их в приложение.
struct ImportFileManager: UIViewControllerRepresentable {
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
        Coordinator(parent: self)
    }

    /// A delegate class responsible for handling user interactions
    /// with the document picker.
    /// — Класс-делегат, отвечающий за обработку взаимодействия пользователя
    /// с документ-пикером.
    class Coordinator: NSObject, UIDocumentPickerDelegate {

        /// Reference to the parent representable.
        /// — Ссылка на родительскую структуру.
        let parent: ImportFileManager

        /// - DB For Realm
        @ObservedResults(Song.self) var songsDB
        
        /// Initializes the coordinator with a reference to the parent.
        /// — Инициализирует координатор с привязкой к родителю.
        init(parent: ImportFileManager) {
            self.parent = parent
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

        /// Processes a selected file URL by reading its data, extracting metadata,
        /// and appending the resulting `Song` to the parent binding.
        /// — Обрабатывает выбранный файл: читает данные, извлекает метаданные
        /// и добавляет полученную `Song` в список родителя.
        private func process(url: URL) {

            /// Begin accessing a security-scoped resource (required in sandbox)
            /// — Начинаем доступ к защищённому ресурсу (обязательно в sandbox)
            guard url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }

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

                /// Avoid adding duplicate entries by name - Realm DB
                /// — Предотвращаем добавление дубликатов по имени
                guard !songsDB.contains(where: { $0.name == song.name && $0.artist == song.artist }) else {
                    print("⚠️ Duplicate skipped: \(song.name)")
                    return
                }

                /// Update the UI on the main thread
                /// — Обновляем UI на главном потоке
                DispatchQueue.main.async {
                    self.$songsDB.append(song)
                }

            } catch {
                /// Handle loading failure
                /// — Обработка ошибок загрузки файла
                print("❌ Failed to load file: \(error.localizedDescription)")
            }
        }
    }
}
