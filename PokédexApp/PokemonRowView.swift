//
//  PokemonRowView.swift
//  PokédexApp
//
//  Created by Won Kim on 4/1/26.
//

import SwiftUI

struct PokemonRowView: View {
    let pokemon: PokemonResult
    
    var body: some View {
        HStack(spacing: 15) {
            
            // Image
            AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.id).png")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure(_):
                    Image(systemName: "xmark.octagon")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 70, height: 70)
            .background(
                LinearGradient(
                    colors: [Color.white, Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Name + ID
            VStack(alignment: .leading, spacing: 5) {
                Text(pokemon.name.capitalized)
                    .font(.headline)
                
                Text("#\(pokemon.id)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
