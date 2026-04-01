//
//  PokemonAPIModels.swift
//  PokédexApp
//
//  Created by Won Kim on 3/24/26.
//

import Foundation

// MARK: - List API

struct PokemonListResponse: Decodable {
    let results: [PokemonResult]
}

struct PokemonResult: Decodable, Equatable {
    let name: String
    let url: String
    
    var id: Int {
        let trimmed = url.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
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
}

struct FlavorTextEntry: Decodable {
    let flavor_text: String
    let language: Language
}

struct Language: Decodable {
    let name: String
}
