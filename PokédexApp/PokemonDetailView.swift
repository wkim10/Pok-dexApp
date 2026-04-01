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
    @State private var species: PokemonSpecies?
    
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
                // TYPES
                HStack {
                    ForEach(details.types, id: \.type.name) { entry in
                        Text(entry.type.name.capitalized)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(colorForType(entry.type.name).opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                
                // HEIGHT + WEIGHT
                HStack(spacing: 40) {
                    VStack {
                        Text("Height")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(Double(details.height) / 10, specifier: "%.1f") m")
                            .font(.headline)
                    }
                    
                    VStack {
                        Text("Weight")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("\(Double(details.height) / 10, specifier: "%.1f") kg")
                            .font(.headline)
                    }
                }
                
                // FLAVOR TEXT
                if let species = species,
                   let entry = species.flavor_text_entries.first(where: { $0.language.name == "en" }) {
                    
                    let cleanedText = entry.flavor_text
                        .replacingOccurrences(of: "\n", with: " ")
                        .replacingOccurrences(of: "\u{000C}", with: " ")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    Text(cleanedText)
                        .italic()
                        .padding(.vertical, 5)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                
                // STATS
                VStack(alignment: .leading, spacing: 10) {
                    Text("Stats")
                        .font(.headline)
                    
                    let primaryTypeColor = details.types.first.map { colorForType($0.type.name) } ?? Color.gray
                    
                    ForEach(details.stats, id: \.stat.name) { stat in
                        HStack {
                            Text(stat.stat.name.replacingOccurrences(of: "-", with: " ").capitalized)
                                .frame(width: 100, alignment: .leading)
                            
                            Text("\(stat.base_stat)")
                            
                            ProgressView(value: Double(stat.base_stat), total: 150)
                                .frame(height: 8)
                                .accentColor(primaryTypeColor)
                        }
                    }
                    
                    let totalStats = details.stats.reduce(0) { $0 + $1.base_stat }
                    
                    HStack {
                        Text("Total")
                            .frame(width: 100, alignment: .leading)
                        Text("\(totalStats)")
                    }
                }
                .padding(.top, 5)
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
                    
                    fetchSpecies(for: decoded.id)
                }
            }
        }.resume()
    }
    
    func fetchSpecies(for id: Int) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(id)/") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(PokemonSpecies.self, from: data) {
                    DispatchQueue.main.async {
                        self.species = decoded
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
