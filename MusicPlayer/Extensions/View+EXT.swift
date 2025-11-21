//
//  View+EXT.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/21/25.
//

import SwiftUI

extension View {
    @ViewBuilder func embedNavigation() -> some View {
        if #available(iOS 17, *) {
            NavigationStack { self.toolbarTitleDisplayMode(.inlineLarge) }
        } else if #available(iOS 16, *) {
            NavigationStack { self }
        } else {
            NavigationView { self }
        }
    }
}
