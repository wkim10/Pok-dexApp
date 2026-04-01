//
//  PokemonDetailView.swift
//  PokédexApp
//
//  Created by Won Kim on 3/24/26.
//

import SwiftUI

struct PokemonDetailView: View {
    let pokemon: PokemonResult
    
    @State private var details: PokemonDetail?
    
    var body: some View {
        VStack(spacing: 20) {
            
            AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.id).png")) { phase in
                switch phase {
                case.empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                case .failure(_):
                    Image(systemName: "xmark.octagon")
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 150, height: 150)
            
            Text(pokemon.name.capitalized)
                .font(.largeTitle)
                .bold()
            
            Text("#\(pokemon.id)")
                .font(.title2)
                .foregroundColor(.gray)
            
            if let details = details {
                HStack {
                    ForEach(details.types, id: \.type.name) { entry in
                        Text(entry.type.name.capitalized)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(colorForType(entry.type.name).opacity(0.2))
                            .cornerRadius(10)
                    }
                }
            } else {
                ProgressView()
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            fetchDetails()
        }
    }
    
    func fetchDetails() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemon.id)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(PokemonDetail.self, from: data) {
                    DispatchQueue.main.async {
                        self.details = decoded
                    }
                }
            }
        }.resume()
    }
    
    func colorForType(_ type: String) -> Color {
        switch type.lowercased() {
        case "normal": return Color.gray
        case "fire": return Color.red
        case "water": return Color.blue
        case "grass": return Color.green
        case "electric": return Color.yellow
        case "ice": return Color.cyan
        case "fighting": return Color.orange
        case "poison": return Color.purple
        case "ground": return Color.brown
        case "flying": return Color.indigo
        case "psychic": return Color.pink
        case "bug": return Color.green.opacity(0.7)
        case "rock": return Color.gray.opacity(0.7)
        case "ghost": return Color.purple.opacity(0.7)
        case "dragon": return Color.indigo.opacity(0.8)
        case "dark": return Color.black
        case "steel": return Color.gray.opacity(0.5)
        case "fairy": return Color.pink.opacity(0.5)
        default: return Color.gray
        }
    }
}
