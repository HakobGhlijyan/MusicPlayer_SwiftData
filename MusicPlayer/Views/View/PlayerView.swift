//
//  PlayerView.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/20/25.
//

import SwiftUI

struct PlayerView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            
            List {
                SongRow()
            }
            .listStyle(.plain)
        }
    }
}

#Preview {
    PlayerView()
}

struct SongRow: View {
//    let song: Song

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .frame(width: 60, height: 60)
            VStack(alignment: .leading) {
                
                Text("Hunt").nameFont()
                Text("Jonny Cash").artistFont()
            }
            
            Spacer()
            
            Text("03:48").songTimeFont()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
