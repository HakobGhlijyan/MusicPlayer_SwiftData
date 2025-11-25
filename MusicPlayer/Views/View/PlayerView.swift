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
                MusicListView()
                //PLAYER
                if viewModel.currentSong != nil {
                    MusicPlayerView()
                        .frame(height: showFullPlayer ? SizeConstants.fullPlayerSize : SizeConstants.miniPlayerSize)
                        .onTapGesture {
                            withAnimation(.spring) {
                                showFullPlayer.toggle()
                            }
                        }
                        .padding(.bottom)
                }
            }
        }
        .sheet(isPresented: $showFileManager) {
            ImportFileManager(songs: $viewModel.songs)
        }
        .navigationBarTitleDisplayMode(.inline)
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

            ToolbarItem(placement: .principal) {
                Text("Music Player")
                    .font(.title3).fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
        .embedNavigation()
    }
        
    @ViewBuilder private func MusicPlayerView() -> some View {
        VStack {
            MusicPlayerMiniView()
            MusicPlayerFullView()
        }
    }
    
    @ViewBuilder private func MusicListView() -> some View {
        List {
            ForEach(viewModel.songs) { song in
                SongRow(song: song, durationFormatted: viewModel.durationFormatted)
                    .onTapGesture {
                        viewModel.playAudio(song: song)
                    }
            }
            .onDelete(perform: viewModel.delete)
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder private func MusicPlayerMiniView() -> some View {
        //Mini Player
        HStack {
            SongImageView(imageData: viewModel.currentSong?.coverImage, size: frameImage)
    
            if !showFullPlayer {
                SongDescription(.leading)
                
                Spacer()
                
                CustomButton(image: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill", size: .largeTitle) {
                    viewModel.playPause()
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

    }
    
    @ViewBuilder private func MusicPlayerFullView() -> some View {
        Group {
            //Full Player
            if showFullPlayer {
                SongDescription()
                    .padding(.top)
                
                VStack {
                    HStack {
                        Text(viewModel.durationFormatted(duration: viewModel.currentTime))
                        Spacer()
                        Text(viewModel.durationFormatted(duration: viewModel.totalTime))
                    }
                    .durationFont()
                    .padding()
                    
                    Slider(value: $viewModel.currentTime, in: 0...viewModel.totalTime) { editing in
                        if !editing { viewModel.seekTime(time: viewModel.currentTime) }
                    }
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                            viewModel.updateProgress()
                        }
                    }
                    .padding(.top).tint(.white)
                    
                    HStack(spacing: 40) {
                        CustomButton(image: "backward.end.fill", size: .title) {
                            viewModel.backward()
                        }
                        CustomButton(image: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill", size: .largeTitle) {
                            viewModel.playPause()
                        }
                        .matchedGeometryEffect(id: "playButton", in: playerAnimation)

                        CustomButton(image: "forward.end.fill", size: .title) {
                            viewModel.forward()
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white)
                    .padding(.top)
                }
                .padding(.horizontal, 40)
            }
        }
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
    
    @ViewBuilder private func SongDescription(_ alignment: HorizontalAlignment = .center) -> some View {
        VStack(alignment: alignment) {
            Text(viewModel.currentSong?.name ?? "unknown name")
                .nameFont()
                .lineLimit(1)
                .matchedGeometryEffect(id: "name", in: playerAnimation)
                
            Text(viewModel.currentSong?.artist ?? "unknown artist")
                .artistFont()
                .matchedGeometryEffect(id: "artist", in: playerAnimation)
        }
        .frame(width: 230)
        .compositingGroup()
    }
}
 
#Preview {
    PlayerView()
//        .preferredColorScheme(.dark)
}
