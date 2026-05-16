//
//  PokemonAPIModels.swift
//  PokédexApp
//
//  Created by Won Kim on 3/24/26.
//

import Foundation
import SwiftUI

// MARK: - List API

struct PokemonListResponse: Decodable {
    let results: [PokemonResult]
}

struct PokemonResult: Decodable, Equatable {
    let name: String
    let url: String

    var id: Int {
        let trimmed = url.trimmingCharacters(
            in: CharacterSet(charactersIn: "/")
        )
        let parts = trimmed.split(separator: "/")
        return Int(parts.last ?? "") ?? 0
    }

    static func == (lhs: PokemonResult, rhs: PokemonResult) -> Bool {
        return lhs.url == rhs.url
    }
}

// MARK: - Detail API

struct PokemonDetail: Decodable {
    let id: Int
    let name: String
    let types: [PokemonTypeEntry]
    let height: Int
    let weight: Int
    let stats: [PokemonStat]
}

struct PokemonTypeEntry: Decodable {
    let type: PokemonType
}

struct PokemonType: Decodable {
    let name: String
}

struct PokemonStat: Decodable {
    let base_stat: Int
    let stat: StatInfo
}

struct StatInfo: Decodable {
    let name: String
}

// MARK: - Species API

struct PokemonSpecies: Decodable {
    let flavor_text_entries: [FlavorTextEntry]
    let varieties: [PokemonVariety]
    let evolution_chain: EvolutionChainReference
}

struct EvolutionChainReference: Decodable {
    let url: String
}

struct FlavorTextEntry: Decodable {
    let flavor_text: String
    let language: Language
}

struct Language: Decodable {
    let name: String
}

struct PokemonVariety: Decodable {
    let is_default: Bool
    let pokemon: NamedAPIResource
}

struct NamedAPIResource: Decodable {
    let name: String
    let url: String
}

// MARK: - Type Styling

extension String {
    func typeColor() -> Color {
        switch self.lowercased() {
        case "normal": return .gray
        case "fire": return .red
        case "water": return .blue
        case "grass": return .green
        case "electric": return .yellow
        case "ice": return .cyan
        case "fighting": return .orange
        case "poison": return .purple
        case "ground": return .brown
        case "flying": return .indigo
        case "psychic": return .pink
        case "bug": return .green.opacity(0.7)
        case "rock": return Color(red: 0.73, green: 0.67, blue: 0.40)
        case "ghost": return .purple.opacity(0.7)
        case "dragon": return .indigo.opacity(0.8)
        case "dark": return .black
        case "steel": return .gray.opacity(0.5)
        case "fairy": return .pink.opacity(0.5)
        default: return .gray
        }
    }
}

// MARK: - Evolution Chain API

struct EvolutionChainResponse: Decodable {
    let chain: ChainLink
}

struct ChainLink: Decodable {
    let species: NamedAPIResource
    let evolves_to: [ChainLink]
}

// MARK: - Evolution Chain Helpers

// returns (chain, branchingStartIndex) where branchingStartIndex is the index
// after which siblings appear. -1 means no branching.
func relevantChainWithFlag(_ chain: ChainLink, for name: String) -> ([NamedAPIResource], Int, Int) {
    // case 1: current pokemon is the base and has multiple direct evolutions
    if chain.species.name == name && chain.evolves_to.count > 1 {
        let directEvolutions = chain.evolves_to.map { $0.species }
        let finalEvolutions = chain.evolves_to.flatMap { $0.evolves_to.map { $0.species } }

        if finalEvolutions.isEmpty {
            return ([chain.species] + directEvolutions, 0, -1)
        } else {
            let result = [chain.species] + directEvolutions + finalEvolutions
            return (result, 0, directEvolutions.count)
        }
    }

    // case 2: current pokemon is the base with one evolution
    if chain.species.name == name {
        if let next = chain.evolves_to.first {
            if next.evolves_to.count > 1 {
                let branches = next.evolves_to.map { $0.species }
                let result = [chain.species, next.species] + branches
                return (result, 2, -1)
            }
            var result = [chain.species]
            result += linearChain(next)
            return (result, -1, -1)
        }
        return ([chain.species], -1, -1)
    }

    // case 3: current pokemon is deeper in the chain
    if let (path, branchIdx) = findLinearPathWithBranchIndex(chain, target: name) {
        return (path, branchIdx, -1)
    }

    return (linearChain(chain), -1, -1)
}

// follows the first evolution at each stage to build a linear chain
func linearChain(_ chain: ChainLink) -> [NamedAPIResource] {
    var result = [chain.species]
    if let next = chain.evolves_to.first {
        result += linearChain(next)
    }
    return result
}

// finds the full path from base to target, tracking where branching occurs
func findLinearPathWithBranchIndex(_ chain: ChainLink, target: String) -> ([NamedAPIResource], Int)? {
    if chain.species.name == target {
        if chain.evolves_to.count > 1 {
            let result = [chain.species] + chain.evolves_to.map { $0.species }
            return (result, 1)
        }
        return (linearChain(chain), -1)
    }
    for next in chain.evolves_to {
        if let (path, branchIdx) = findLinearPathWithBranchIndex(next, target: target) {
            let adjustedBranchIdx = branchIdx == -1 ? -1 : branchIdx + 1
            return ([chain.species] + path, adjustedBranchIdx)
        }
    }
    return nil
}
