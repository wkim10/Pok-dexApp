//
//  FavoritesView.swift
//  PokédexApp
//
//  Created by Won Kim on 5/14/26.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Query(sort: \FavoritePokemon.pokemonID) private var favorites: [FavoritePokemon]
    
    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No favorites yet")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Tap the heart on any Pokémon to save it here.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(favorites, id: \.pokemonID) { favorite in
                            let pokemon = PokemonResult(
                                name: favorite.name,
                                url: "https://pokeapi.co/api/v2/pokemon/\(favorite.pokemonID)/"
                            )
                            NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                                HStack {
                                    AsyncImage(
                                        url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(favorite.pokemonID).png")
                                    ) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable().scaledToFit()
                                        default:
                                            ProgressView()
                                        }
                                    }
                                    .frame(width: 50, height: 50)
                                    
                                    VStack(alignment: .leading) {
                                        Text(favorite.name.capitalized)
                                            .font(.headline)
                                        Text("#\(favorite.pokemonID)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}
