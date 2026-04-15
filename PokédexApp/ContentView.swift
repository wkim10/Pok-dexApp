import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = PokemonViewModel()
    @State private var searchText = ""
    @State private var selectedGeneration: Int? = nil

    func generationRange(for gen: Int) -> ClosedRange<Int> {
        switch gen {
        case 1: return 1...151
        case 2: return 152...251
        case 3: return 252...386
        case 4: return 387...493
        case 5: return 494...649
        case 6: return 650...721
        case 7: return 722...809
        case 8: return 810...905
        case 9:
            let maxID = viewModel.allPokemon.map { $0.id }.max() ?? 1025
            return 906...maxID
        default:
            let maxID = viewModel.allPokemon.map { $0.id }.max() ?? 1025
            return 1...1010
        }
    }

    var filteredPokemon: [PokemonResult] {
        var results = viewModel.allPokemon
        
        results = results.filter { $0.id <= 1025 }

        if !searchText.isEmpty {
            results = results.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                "\($0.id)".contains(searchText)
            }
        }

        if let gen = selectedGeneration {
            let range = generationRange(for: gen)
            results = results.filter { range.contains($0.id) }
        }

        return results
    }

    func filterButton(title: String, generation: Int?) -> some View {
        Button {
            selectedGeneration = generation
        } label: {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    selectedGeneration == generation
                    ? Color.blue.opacity(0.25)
                    : Color(.systemGray6)
                )
                .foregroundColor(
                    selectedGeneration == generation ? .blue : .primary
                )
                .cornerRadius(10)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        filterButton(title: "All", generation: nil)

                        ForEach(1...9, id: \.self) { gen in
                            filterButton(title: "Gen \(gen)", generation: gen)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGroupedBackground))

                ScrollViewReader { proxy in
                    ScrollView {

                        LazyVStack(spacing: 8) {

                            Color.clear
                                .frame(height: 1)
                                .id("top")

                            ForEach(filteredPokemon, id: \.name) { pokemon in
                                PokemonRowView(
                                    pokemon: pokemon,
                                    types: viewModel.pokemonTypes[pokemon.id]
                                )
                                .onAppear {
                                    viewModel.fetchTypes(for: pokemon.id)
                                }
                                .padding(.horizontal, 12)
                            }

                            if searchText.isEmpty,
                               selectedGeneration == nil,
                               !viewModel.isLoading {

                                ProgressView()
                                    .padding()
                                    .onAppear {
                                        viewModel.fetchPokemon()
                                    }
                            }
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                    .searchable(text: $searchText, prompt: "Search Pokémon")

                    .onChange(of: selectedGeneration) { _ in
                        DispatchQueue.main.async {
                            withAnimation {
                                proxy.scrollTo("top", anchor: .top)
                            }
                        }
                    }

                    .onChange(of: searchText) { _ in
                        DispatchQueue.main.async {
                            withAnimation {
                                proxy.scrollTo("top", anchor: .top)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pokédex")
            .onAppear {
                if viewModel.allPokemon.isEmpty {
                    viewModel.fetchAllPokemon()
                }
                if viewModel.pokemon.isEmpty {
                    viewModel.fetchPokemon()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
