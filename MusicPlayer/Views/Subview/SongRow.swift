//
//  SongRow.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/21/25.
//


import SwiftUI

struct SongRow: View {
    let song: Song

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .frame(width: 60, height: 60)
            VStack(alignment: .leading) {
                
                Text(song.name).nameFont()
                Text(song.artist ?? "Unknown Artist").artistFont()
            }
            
            Spacer()
            
            Text("\(song.duration ?? 0)").songTimeFont()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}

#Preview {
    SongRow(song: Song(name: "Natural", data: Data(), artist: "Imagine Dragon", coverImage: Data(), duration: 0))
}
