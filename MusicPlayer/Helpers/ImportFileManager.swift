//
//  ImportFileManager.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/21/25.
//

import SwiftUI
import AVKit
internal import UniformTypeIdentifiers

struct ImportFileManager: UIViewControllerRepresentable {
    @Binding var songs: [Song]
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let docPicker =  UIDocumentPickerViewController(forOpeningContentTypes: [.audio])
        
        docPicker.allowsMultipleSelection = false //select only one file
        docPicker.shouldShowFileExtensions = true //see file extension
        docPicker.delegate = context.coordinator
        
        return docPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        
    }
    
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
