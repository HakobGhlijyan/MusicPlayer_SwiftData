//
//  View+EXT.swift
//  MusicPlayer
//
//  Created by Hakob Ghlijyan on 11/21/25.
//

import SwiftUI

extension View {
    @ViewBuilder func embedNavigation() -> some View {
        if #available(iOS 16, *) {
            NavigationStack { self }
        } else {
            NavigationView { self }
        }
    }
}
