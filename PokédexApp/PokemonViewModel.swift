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

    // fetch a paginated batch of pokemon (used for infinite scroll)
    func fetchPokemon() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?offset=\(offset)&limit=\(limit)")
        else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(PokemonListResponse.self, from: data)
            pokemon.append(contentsOf: decoded.results)
            offset += limit
        } catch {
            print("fetchPokemon error:", error)
        }
    }

    // fetch all pokemon at once (used for search and generation filtering)
    func fetchAllPokemon() async {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=10000")
        else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(PokemonListResponse.self, from: data)
            allPokemon = decoded.results
        } catch {
            print("fetchAllPokemon error:", error)
        }
    }
    
    // fetch and cache types for a single pokemon by id
    func fetchTypes(for id: Int) async {
        if pokemonTypes[id] != nil { return }
        
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)")
        else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(PokemonDetail.self, from: data)
            pokemonTypes[id] = decoded.types.map { $0.type.name }
        } catch {
            print("fetchTypes error:", error)
        }
    }
}
