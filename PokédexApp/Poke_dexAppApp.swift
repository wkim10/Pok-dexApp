//
//  Poke_dexAppApp.swift
//  PokédexApp
//
//  Created by Won Kim on 3/24/26.
//

import SwiftUI
import CoreData

@main
struct Poke_dexAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
