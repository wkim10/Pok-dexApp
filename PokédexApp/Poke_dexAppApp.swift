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
            ContentView()
        }
        .modelContainer(for: FavoritePokemon.self)
    }
}
