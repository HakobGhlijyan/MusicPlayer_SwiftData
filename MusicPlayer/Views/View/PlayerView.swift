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
    @State private var showFullPlayer: Bool = false
    @Namespace private var playerAnimation
    private var frameImage: CGFloat { showFullPlayer ? 320 : 50 }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                //Music List
                List {
                    ForEach(viewModel.songs) { song in
                        SongRow(song: song, durationFormatted: viewModel.durationFormatted)
                            .onTapGesture {
                                viewModel.playAudio(song: song)
                            }
                    }
                }
                .listStyle(.plain)
                
                VStack {
                    //Mini Player
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .foregroundStyle(.gray)
                            Image(systemName: "music.note")
                                .foregroundStyle(.white)
                                .font(.system(size: 20))
                        }
                        .frame(width: frameImage, height: frameImage)

                        if !showFullPlayer {
                            VStack(alignment: .leading) {
                                Text("song.name").nameFont()
                                Text("song.artist").artistFont()
                            }
                            .compositingGroup()
                            .matchedGeometryEffect(id: "info", in: playerAnimation)

                            Spacer()
                            
                            CustomButton(image: "play.circle.fill", size: .largeTitle) {
                                
                            }
                            .matchedGeometryEffect(id: "playButton", in: playerAnimation)
                        }
                    }
                    .padding()
                    .background(
                        showFullPlayer ? Color.clear : Color.primary.opacity(0.3),
                        in: .rect(cornerRadius: 12, style: .continuous)
                    )
                    .padding()
                    
                    //Full Player
                    if showFullPlayer {
                        VStack {
                            Text("song.name").nameFont()
                            Text("song.artist").artistFont()
                        }
                        .compositingGroup()
                        .matchedGeometryEffect(id: "info", in: playerAnimation)
                        .padding(.top)
                        
                        VStack {
                            HStack {
                                Text("00:00")
                                Spacer()
                                Text("03:23")
                            }
                            .durationFont()
                            .padding()
                            
                            HStack(spacing: 40) {
                                CustomButton(image: "backward.end.fill", size: .title3) {
                                    
                                }
                                CustomButton(image: "play.circle.fill", size: .largeTitle) {
                                    
                                }
                                .matchedGeometryEffect(id: "playButton", in: playerAnimation)
                                
                                CustomButton(image: "forward.end.fill", size: .title3) {
                                    
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 40)
                    }
                }
                .frame(height: showFullPlayer ? SizeConstants.fullPlayerSize : SizeConstants.miniPlayerSize)
                .onTapGesture {
                    withAnimation(.spring) {
                        showFullPlayer.toggle()
                    }
                }
                .padding(.bottom)
            }
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
    
    @ViewBuilder private func CustomButton(
        image: String,
        size: Font,
        action: @escaping () -> ()
    ) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: image)
                .font(size)
                .foregroundStyle(.white)
        }
    }
}
 
#Preview {
    PlayerView()
}
