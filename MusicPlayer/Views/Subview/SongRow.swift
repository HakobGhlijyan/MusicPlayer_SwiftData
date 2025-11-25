//
//  SongRow.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/21/25.
//

import SwiftUI

struct SongRow: View {
    let song: Song
    let durationFormatted: (TimeInterval) -> String
    
    var body: some View {
        HStack {
            SongImageView(imageData: song.coverImage, size: 60)
            
            VStack(alignment: .leading) {
                
                Text(song.name).nameFont()
                    .lineLimit(1)
                Text(song.artist ?? "Unknown Artist").artistFont()
            }
            
            Spacer()
            
            Text(durationFormatted(song.duration ?? 0)).songTimeFont()
//            Text(song.duration?.mmSS ?? "0:00").songTimeFont()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
