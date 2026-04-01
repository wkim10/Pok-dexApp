//
//  PokemonViewModel.swift
//  PokédexApp
//
//  Created by Won Kim on 3/24/26.
//

import Foundation
import Combine

@MainActor
class PokemonViewModel: ObservableObject {
    @Published var pokemon: [PokemonResult] = []
    private var offset = 0
    private let limit = 50
    
    func fetchPokemon() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?offset=\(offset)&limit=\(limit)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(PokemonListResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.pokemon.append(contentsOf: decoded.results)
                        self.offset += self.limit
                    }
                }
            }
        }.resume()
    }
}
