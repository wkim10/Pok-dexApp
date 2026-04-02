//
//  ContentView.swift
//  PokédexApp
//
//  Created by Won Kim on 3/24/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = PokemonViewModel()
    @State private var searchText = ""
    
    var filteredPokemon: [PokemonResult] {
        if searchText.isEmpty {
            return viewModel.pokemon
        } else {
            return viewModel.allPokemon.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                "\($0.id)".contains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredPokemon, id: \.name) { pokemon in
                    ZStack {
                        PokemonRowView(pokemon: pokemon)
                        
                        NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                            EmptyView()
                        }
                        .opacity(0)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .onAppear {
                        if searchText.isEmpty && pokemon == viewModel.pokemon.last {
                            viewModel.fetchPokemon()
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Pokédex")
            .searchable(text: $searchText, prompt: "Search Pokémon")
            .onAppear {
                if viewModel.pokemon.isEmpty {
                    viewModel.fetchPokemon()
                    viewModel.fetchAllPokemon()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
