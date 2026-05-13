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
    @State private var forms: [PokemonResult] = []

    var body: some View {
        ZStack {
            if let primaryTypeColor = details?.types.first?.type.name
                .typeColor()
            {
                LinearGradient(
                    colors: [
                        primaryTypeColor.opacity(0.25),
                        Color(.systemBackground),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }

            ScrollView {
                VStack(spacing: 20) {

                    AsyncImage(
                        url: URL(
                            string:
                                "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemon.id).png"
                        )
                    ) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable().scaledToFit()
                        case .failure(_):
                            Image(systemName: "xmark.octagon")
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 150, height: 150)

                    VStack(spacing: 8) {
                        Text("#\(pokemon.id)")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Text(pokemon.name.capitalized)
                            .font(.system(size: 32, weight: .bold))
                    }

                    // FORMS
                    if forms.count > 0 {
                        VStack(spacing: 10) {
                            Text("Forms")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .center)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(forms, id: \.id) { form in
                                        NavigationLink(
                                            destination: PokemonDetailView(
                                                pokemon: form
                                            )
                                        ) {
                                            VStack {
                                                AsyncImage(
                                                    url: URL(
                                                        string:
                                                            "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(form.id).png"
                                                    )
                                                ) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        ProgressView()
                                                    case .success(let image):
                                                        image.resizable()
                                                            .scaledToFit()
                                                    case .failure(_):
                                                        Image(
                                                            systemName:
                                                                "xmark.octagon"
                                                        )
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                                .frame(width: 70, height: 70)

                                                Text(
                                                    form.name
                                                        .replacingOccurrences(
                                                            of: "-",
                                                            with: " "
                                                        )
                                                        .capitalized
                                                )
                                                .font(.caption)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                            }
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .scaleEffect(0.95)
                        .frame(maxWidth: .infinity)
                    }

                    if let details = details {
                        // TYPES
                        HStack {
                            ForEach(details.types, id: \.type.name) { entry in
                                Text(entry.type.name.capitalized)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        entry.type.name.typeColor().opacity(0.2)
                                    )
                                    .cornerRadius(10)
                            }
                        }

                        // HEIGHT + WEIGHT
                        HStack(spacing: 40) {
                            VStack {
                                Text("Height")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(
                                    "\(Double(details.height) / 10, specifier: "%.1f") m"
                                )
                                .font(.headline)
                            }

                            VStack {
                                Text("Weight")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(
                                    "\(Double(details.weight) / 10, specifier: "%.1f") kg"
                                )
                                .font(.headline)
                            }
                        }

                        // FLAVOR TEXT
                        if let species = species,
                            let entry = species.flavor_text_entries.first(
                                where: {
                                    $0.language.name == "en"
                                })
                        {

                            let cleanedText = entry.flavor_text
                                .replacingOccurrences(of: "\n", with: " ")
                                .replacingOccurrences(of: "\u{000C}", with: " ")
                                .trimmingCharacters(in: .whitespacesAndNewlines)

                            Text(cleanedText)
                                .italic()
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: 300)
                        }

                        // STATS
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Stats")
                                .font(.headline)

                            let primaryTypeColor =
                                details.types.first?.type.name.typeColor()
                                ?? .gray

                            ForEach(details.stats, id: \.stat.name) { stat in
                                HStack {
                                    Text(statLabel(stat.stat.name))
                                        .frame(width: 90, alignment: .leading)

                                    Text("\(stat.base_stat)")

                                    ProgressView(
                                        value: Double(stat.base_stat),
                                        total: 150
                                    )
                                    .frame(height: 8)
                                    .accentColor(primaryTypeColor)
                                }
                            }

                            let totalStats = details.stats.reduce(0) {
                                $0 + $1.base_stat
                            }

                            HStack {
                                Text("Total")
                                    .frame(width: 90, alignment: .leading)
                                Text("\(totalStats)")
                            }
                        }
                        .padding(.top, 5)
                    } else {
                        ProgressView()
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(
                            color: .black.opacity(0.08),
                            radius: 10,
                            x: 0,
                            y: 5
                        )
                )
                .padding(.horizontal)
            }
            .onAppear {
                Task {
                    await fetchDetails()
                }
            }
        }
    }

    func fetchDetails() async {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemon.id)")
        else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(PokemonDetail.self, from: data)
            details = decoded
            await fetchSpecies(for: decoded.id)
        } catch {
            print("fetchDetails error:", error)
        }
    }

    func fetchSpecies(for id: Int) async {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(id)/")
        else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(PokemonSpecies.self, from: data)
            species = decoded
            forms = extractForms(from: decoded)
        } catch {
            print("fetchSpecies error:", error)
        }
    }

    func extractForms(from species: PokemonSpecies) -> [PokemonResult] {
        species.varieties
            .filter { !$0.is_default }
            .map {
                PokemonResult(name: $0.pokemon.name, url: $0.pokemon.url)
            }
    }

    func extractID(from url: String) -> Int? {
        let components = url.split(separator: "/")
        return components.last.flatMap { Int($0) }
    }
    
    func statLabel(_ name: String) -> String {
        switch name {
        case "special-attack": return "Sp. Atk"
        case "special-defense": return "Sp. Def"
        case "attack": return "Atk"
        case "defense": return "Def"
        case "speed": return "Speed"
        case "hp": return "HP"
        default: return name.capitalized
        }
    }
}
