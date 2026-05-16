//
//  EvolutionChainView.swift
//  PokédexApp
//
//  Created by Won Kim on 5/15/26.
//

import SwiftUI

struct EvolutionChainView: View {
    let evolutionChain: [NamedAPIResource]
    let branchingStartIndex: Int
    let secondBranchingStartIndex: Int
    let currentPokemonName: String

    var body: some View {
        VStack(spacing: 10) {
            Text("Evolution Chain")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(evolutionChain.enumerated()), id: \.offset) { index, species in
                        let speciesID = PokemonResult(name: species.name, url: species.url).id

                        VStack(spacing: 4) {
                            AsyncImage(
                                url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(speciesID).png")
                            ) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().scaledToFit()
                                default:
                                    ProgressView()
                                }
                            }
                            .frame(width: 60, height: 60)

                            Text(species.name.capitalized)
                                .font(.caption)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .frame(width: 60)
                        }
                        .opacity(species.name == currentPokemonName ? 1.0 : 0.6)

                        if index < evolutionChain.count - 1 {
                            if shouldShowChevron(at: index) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 5)
    }

    func shouldShowChevron(at index: Int) -> Bool {
        if branchingStartIndex == -1 {
            return true
        } else if branchingStartIndex == 0 && secondBranchingStartIndex > 0 {
            return index == 0 || index == secondBranchingStartIndex
        } else if branchingStartIndex == 0 {
            return index == 0
        } else {
            return index < branchingStartIndex
        }
    }
}
