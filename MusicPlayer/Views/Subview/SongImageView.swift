//
//  SongImageView.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/25/25.
//

import SwiftUI

struct SongImageView: View {
    let imageData: Data?
    let size: CGFloat
    var body: some View {
        Group {
            if let data = imageData, let uiImage = UIImage(data: data) {
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
                        .font(.system(size: size / 2))
                }
            }
        }
        .frame(width: size, height: size)
    }
}
