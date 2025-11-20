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
            VStack {
                Text("Name Font")
                    .nameFont()
                Text("Artist Font")
                    .artistFont()
                Text("Song Time - 03:45")
                    .songTimeFont()
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
        self.foregroundStyle(.appTextPrimary)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
    }
    
    func artistFont() -> some View {
        self.foregroundStyle(.appTextSecondary)
            .font(.system(size: 14, weight: .light, design: .rounded))
    }
    
    func songTimeFont() -> some View {
        self.foregroundStyle(.appTextSecondary)
            .font(.system(size: 12, weight: .medium, design: .rounded))
    }
}
