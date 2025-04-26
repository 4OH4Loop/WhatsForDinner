//
//  SearchView.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var searchResults: [Recipe] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search recipes...", text: $searchText)
                        .keyboardType(.default)
                        .submitLabel(.search)
                        .onSubmit {
                            if !searchText.isEmpty {
                                Task {
                                    await searchRecipes()
                                }
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                if isLoading {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else if !searchText.isEmpty && searchResults.isEmpty {
                    Spacer()
                    Text("No recipes found matching '\(searchText)'")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    // Search Results
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(searchResults) { recipe in
                                SearchResultRow(recipe: recipe)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Search Recipes")
            .navigationBarItems(leading: Button("Back") {
                dismiss()
            })
            .alert(item: $alertItem) { alertItem in
                Alert(
                    title: Text(alertItem.title),
                    message: Text(alertItem.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func searchRecipes() async {
        isLoading = true
        searchResults = []
        
        var components = URLComponents(string: "https://api.spoonacular.com/recipes/complexSearch")!
        
        components.queryItems = [
            URLQueryItem(name: "apiKey", value: APIKeys.spoonacularKey),
            URLQueryItem(name: "query", value: searchText),
            URLQueryItem(name: "addRecipeInformation", value: "true"),
            URLQueryItem(name: "number", value: "10")
        ]
        
        guard let url = components.url else {
            isLoading = false
            alertItem = AlertItem(
                title: "Error",
                message: "Could not create URL for search."
            )
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let response = try? JSONDecoder().decode(SearchResponse.self, from: data) else {
                isLoading = false
                alertItem = AlertItem(
                    title: "Error",
                    message: "Could not decode search results."
                )
                return
            }
            
            // Process results and check against DB
            var newResults: [Recipe] = []
            
            for apiRecipe in response.results {
                // Check if recipe already exists in database
                let fetchDescriptor = FetchDescriptor<Recipe>(
                    predicate: #Predicate<Recipe> {
                        if let id = $0.id {
                            return id == apiRecipe.id
                        }
                        else {
                            return false
                        }
                    })
                
                if let existingRecipe = try? modelContext.fetch(fetchDescriptor).first {
                    // Use existing recipe
                    newResults.append(existingRecipe)
                } else {
                    // Create new recipe
                    let newRecipe = Recipe(
                        id: apiRecipe.id,
                        title: apiRecipe.title,
                        image: apiRecipe.image,
                        servings: apiRecipe.servings,
                        readyInMinutes: apiRecipe.readyInMinutes,
                        dairyFree: apiRecipe.dairyFree, glutenFree: apiRecipe.glutenFree,
                        vegetarian: apiRecipe.vegetarian,
                        vegan: apiRecipe.vegan
                    )
                    
                    modelContext.insert(newRecipe)
                    newResults.append(newRecipe)
                }
            }
            
            searchResults = newResults
            isLoading = false
            
        } catch {
            isLoading = false
            alertItem = AlertItem(
                title: "Error",
                message: "Failed to search recipes: \(error.localizedDescription)"
            )
        }
    }
    
    // Alert handling
    @State private var alertItem: AlertItem?
    
    struct AlertItem: Identifiable {
        var id = UUID()
        var title: String
        var message: String
    }
    
    // API Response Structure
    struct SearchResponse: Codable {
        var results: [SearchResult]
        var offset: Int
        var number: Int
        var totalResults: Int
    }
    
    struct SearchResult: Codable {
        var id: Int
        var title: String
        var image: String?
        var servings: Int?
        var readyInMinutes: Int?
        var glutenFree: Bool?
        var dairyFree: Bool?
        var vegetarian: Bool?
        var vegan: Bool?
    }
}

struct SearchResultRow: View {
    let recipe: Recipe
    @State private var showingDetail = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack(spacing: 16) {
                // Recipe Image
                if let imageURL = recipe.image {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 70, height: 70)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                
                // Recipe Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        if let readyInMinutes = recipe.readyInMinutes {
                            Label("\(readyInMinutes) min", systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let healthScore = recipe.healthScore {
                            Label("\(Int(healthScore))", systemImage: "heart")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                // Favorite Button
                Button(action: {
                    recipe.isFavorite.toggle()
                }) {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(recipe.isFavorite ? .red : .gray)
                        .font(.system(size: 22))
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            RecipeDetailView(recipe: recipe)
        }
    }
}

#Preview {
    SearchView()
        .modelContainer(Recipe.preview)
}
