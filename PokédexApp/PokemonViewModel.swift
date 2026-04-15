//
//  PokemonViewModel.swift
//  PokédexApp
//
//  Created by Won Kim on 3/24/26.
//

import Combine
import Foundation

@MainActor
class PokemonViewModel: ObservableObject {
    @Published var pokemon: [PokemonResult] = []
    @Published var allPokemon: [PokemonResult] = []
    @Published var pokemonTypes: [Int: [String]] = [:]
    @Published var isLoading = false
    private var offset = 0
    private let limit = 50

    func fetchPokemon() {
        guard !isLoading else { return }
        isLoading = true

        guard
            let url = URL(
                string:
                    "https://pokeapi.co/api/v2/pokemon?offset=\(offset)&limit=\(limit)"
            )
        else {
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            defer { DispatchQueue.main.async { self.isLoading = false } }

            if let data = data,
                let decoded = try? JSONDecoder().decode(
                    PokemonListResponse.self,
                    from: data
                )
            {
                DispatchQueue.main.async {
                    self.pokemon.append(contentsOf: decoded.results)
                    self.offset += self.limit
                }
            }
        }.resume()
    }

    func fetchAllPokemon() {
        guard
            let url = URL(
                string: "https://pokeapi.co/api/v2/pokemon?limit=10000"
            )
        else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(
                    PokemonListResponse.self,
                    from: data
                ) {
                    DispatchQueue.main.async {
                        self.allPokemon = decoded.results
                    }
                }
            }
        }.resume()
    }

    func fetchTypes(for id: Int) {
        if pokemonTypes[id] != nil { return }

        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)")
        else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(
                    PokemonDetail.self,
                    from: data
                ) {
                    let types = decoded.types.map { $0.type.name }

                    DispatchQueue.main.async {
                        self.pokemonTypes[id] = types
                    }
                }
            }
        }
        .resume()
    }
}
