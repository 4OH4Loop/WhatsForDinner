//
//  SearchView.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var viewModel: RecipesViewModel
    @State private var searchText = ""
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search recipes...", text: $searchText)
                        .onSubmit {
                            if !searchText.isEmpty {
                                isSearching = true
                                Task {
                                    await viewModel.searchRecipes(query: searchText)
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
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Searching...")
                    Spacer()
                } else if isSearching && viewModel.searchResults.isEmpty {
                    Spacer()
                    Text("No recipes found matching '\(searchText)'")
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    // Search Results
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.searchResults, id: \.id) { recipe in
                                SearchResultRow(recipe: recipe, viewModel: viewModel)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Search Recipes")
            .navigationBarItems(leading: Button("Back") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SearchResultRow: View {
    let recipe: Recipe
    @State var viewModel: RecipesViewModel
    @State private var showingDetail = false
    
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
                                .aspectRatio(contentMode: .fill)
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
                    if viewModel.isFavorite(recipe: recipe) {
                        viewModel.removeFromFavorites(recipe: recipe)
                    } else {
                        viewModel.addToFavorites(recipe: recipe)
                    }
                }) {
                    Image(systemName: viewModel.isFavorite(recipe: recipe) ? "heart.fill" : "heart")
                        .foregroundColor(viewModel.isFavorite(recipe: recipe) ? .red : .gray)
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
            RecipeDetailView(recipe: recipe, viewModel: viewModel)
        }
    }
}

#Preview {
    SearchView(viewModel: RecipesViewModel())
}
