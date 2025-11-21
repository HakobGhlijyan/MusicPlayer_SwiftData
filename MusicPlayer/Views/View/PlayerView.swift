//
//  PlayerView.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/20/25.
//

import SwiftUI

struct PlayerView: View {
    @StateObject private var viewModel = PlayerViewModel()
    @State private var showFileManager: Bool = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            List {
                ForEach(viewModel.songs) { song in
                    SongRow(song: song, durationFormatted: viewModel.durationFormatted)
                }
            }
            .listStyle(.plain)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showFileManager.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }
        }
        .sheet(isPresented: $showFileManager) {
            ImportFileManager(songs: $viewModel.songs)
        }
        .navigationTitle("Music Player")
        .embedNavigation()
    }
}
 
#Preview {
    PlayerView()
}
