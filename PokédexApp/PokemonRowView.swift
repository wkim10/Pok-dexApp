//
//  PokemonRowView.swift
//  PokédexApp
//
//  Created by Won Kim on 4/1/26.
//

import SwiftUI

struct PokemonRowView: View {
    let pokemon: PokemonResult
    let types: [String]?
    
    var body: some View {
        let gradientColors: [Color] = {
            guard let types = types, !types.isEmpty else {
                return [Color.gray.opacity(0.2), Color.gray.opacity(0.05)]
            }
            
            if types.count == 1 {
                let color = types[0].typeColor()
                return [color.opacity(0.3), color.opacity(0.05)]
            } else {
                let color1 = types[0].typeColor()
                let color2 = types[1].typeColor()
                return [
                    color1.opacity(0.25),
                    color2.opacity(0.25)
                ]
            }
        }()
        
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
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(types?.first?.typeColor().opacity(0.3) ?? .clear, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            // Name + ID + Types
            VStack(alignment: .leading, spacing: 6) {
                Text(pokemon.name.capitalized)
                    .font(.headline)
                
                Text("#\(pokemon.id)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let types = types {
                    HStack {
                        ForEach(types, id: \.self) { type in
                            Text(type.capitalized)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(type.typeColor().opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
