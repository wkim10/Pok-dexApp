//
//  Poke_dexAppApp.swift
//  PokédexApp
//
//  Created by Won Kim on 3/24/26.
//

import SwiftUI
import SwiftData

@main
struct Poke_dexAppApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .tabItem {
                        Label("Pokédex", systemImage: "list.bullet")
                    }
                
                FavoritesView()
                    .tabItem {
                        Label("Favorites", systemImage: "heart.fill")
                    }
            }
        }
        .modelContainer(for: FavoritePokemon.self)
    }
}
