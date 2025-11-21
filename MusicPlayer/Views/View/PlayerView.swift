//
//  PlayerView.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/20/25.
//

import SwiftUI

struct PlayerView: View {
    @StateObject private var viewModel = PlayerViewModel()
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            List {
                ForEach(viewModel.songs) { song in
                    SongRow(song: song)
                }
            }
            .listStyle(.plain)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }
        }
        .navigationTitle("Music Player")
        .embedNavigation()
    }
}
 
#Preview {
    PlayerView()
}
