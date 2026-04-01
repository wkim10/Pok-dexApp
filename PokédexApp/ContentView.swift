//
//  ContentView.swift
//  PokédexApp
//
//  Created by Won Kim on 3/24/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = PokemonViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.pokemon, id: \.name) { pokemon in
                NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                    Text(pokemon.name.capitalized)
                        .onAppear {
                            if pokemon == viewModel.pokemon.last {
                                viewModel.fetchPokemon()
                            }
                        }
                }
            }
            .navigationTitle("Pokédex")
            .onAppear {
                viewModel.fetchPokemon()
            }
        }
    }
}

#Preview {
    ContentView()
}
