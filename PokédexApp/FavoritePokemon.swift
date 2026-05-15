//
//  FavoritePokemon.swift
//  PokédexApp
//
//  Created by Won Kim on 5/14/26.
//

import SwiftData
import Foundation

@Model
class FavoritePokemon {
    var pokemonID: Int
    var name: String
    
    init(pokemonID: Int, name: String) {
        self.pokemonID = pokemonID
        self.name = name
    }
}
