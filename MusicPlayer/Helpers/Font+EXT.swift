//
//  Font+EXT.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/20/25.
//

import SwiftUI

struct FontView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            VStack(spacing: 10) {
                Text("Name Font")
                    .nameFont()
                Text("Artist Font")
                    .artistFont()
                Text("Song Time 03:45 ")
                    .songTimeFont()
                Text("Song Timer for player - 00:00 - 03:45")
                    .durationFont()
            }
        }
    }
}

#Preview {
    FontView()
        .preferredColorScheme(.dark)
}

extension Text {
    func nameFont() -> some View {
        self.foregroundStyle(.white)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
    }
    
    func artistFont() -> some View {
        self.foregroundStyle(.white)
            .font(.system(size: 14, weight: .light, design: .rounded))
    }
    
    func songTimeFont() -> some View {
        self.foregroundStyle(.white)
            .font(.system(size: 12, weight: .medium, design: .rounded))
    }
}

struct DurationViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.white)
            .font(.system(size: 14, weight: .light, design: .rounded))
    }
}

extension View {
    func durationFont() -> some View {
        self.modifier(DurationViewModifier())
    }
}
