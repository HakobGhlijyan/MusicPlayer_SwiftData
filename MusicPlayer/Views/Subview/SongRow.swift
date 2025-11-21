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
            Group {
                if let data = song.coverImage, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .clipShape(.rect(cornerRadius: 10, style: .continuous))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .foregroundStyle(.gray)
                        Image(systemName: "music.note")
                            .foregroundStyle(.white)
                            .font(.system(size: 30))
                    }
                }
            }
            .frame(width: 60, height: 60)
              
            VStack(alignment: .leading) {
                
                Text(song.name).nameFont()
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
