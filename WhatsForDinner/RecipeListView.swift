//
//  RecipeListView.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import SwiftUI

struct RecipeListView: View {
    @State private var recipesVM = RecipesViewModel()
    @State private var showingFilters = false
    @State private var showingSearch = false
    @State private var showingFavorites = false
    @State private var showingAddRecipe = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Header
                    Text("What's for Dinner?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // Random Recipe Card
                    if recipesVM.isLoading {
                        ProgressView("Finding your dinner...")
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let recipe = recipesVM.randomRecipe {
                        RecipeCard(recipe: recipe, viewModel: recipesVM)
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 70))
                                .foregroundColor(.secondary)
                            Text("Tap the button below to find a random dinner recipe")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                Task {
                                    await recipesVM.fetchRandomRecipe()
                                }
                            }) {
                                Text("Find Random Dinner")
                                    .fontWeight(.semibold)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Filter indicators
                    if !recipesVM.selectedMainIngredient.isEmpty || !recipesVM.selectedCuisine.isEmpty ||
                       !recipesVM.selectedDietaryRestrictions.isEmpty || recipesVM.selectedMaxPrepTime != nil {
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                if !recipesVM.selectedMainIngredient.isEmpty {
                                    FilterTag(text: recipesVM.selectedMainIngredient)
                                }
                                
                                if !recipesVM.selectedCuisine.isEmpty {
                                    FilterTag(text: recipesVM.selectedCuisine)
                                }
                                
                                if let time = recipesVM.selectedMaxPrepTime {
                                    FilterTag(text: "Under \(time) min")
                                }
                                
                                ForEach(recipesVM.selectedDietaryRestrictions, id: \.self) { restriction in
                                    FilterTag(text: restriction)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Bottom menu
                    HStack {
                        Button(action: {
                            showingSearch = true
                        }) {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 24))
                                Text("Search")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {
                            Task {
                                await recipesVM.fetchRandomRecipe()
                            }
                        }) {
                            VStack {
                                Image(systemName: "dice")
                                    .font(.system(size: 24))
                                Text("Random")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {
                            showingFilters = true
                        }) {
                            VStack {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 24))
                                Text("Filters")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {
                            showingFavorites = true
                        }) {
                            VStack {
                                Image(systemName: "heart")
                                    .font(.system(size: 24))
                                Text("Favorites")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {
                            showingAddRecipe = true
                        }) {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 24))
                                Text("Add Recipe")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground).shadow(radius: 2))
                }
                
                if let errorMessage = recipesVM.errorMessage {
                    VStack {
                        Spacer()
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(10)
                            .padding()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    recipesVM.errorMessage = nil
                                }
                            }
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingFilters) {
                FilterView(viewModel: recipesVM)
            }
            .sheet(isPresented: $showingSearch) {
                SearchView(viewModel: recipesVM)
            }
            .sheet(isPresented: $showingFavorites) {
                FavoritesView(viewModel: recipesVM)
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView(viewModel: recipesVM)
            }
        }
    }
}

struct FilterTag: View {
    let text: String
    
    var body: some View {
        Text(text.capitalized)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.blue.opacity(0.2))
            .foregroundColor(.blue)
            .cornerRadius(15)
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    @State var viewModel: RecipesViewModel
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if let imageURL = recipe.image {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(10)
                    } else if phase.error != nil {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .cornerRadius(10)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    } else {
                        ProgressView()
                            .frame(height: 200)
                    }
                }
                .overlay(
                    Button(action: {
                        if viewModel.isFavorite(recipe: recipe) {
                            viewModel.removeFromFavorites(recipe: recipe)
                        } else {
                            viewModel.addToFavorites(recipe: recipe)
                        }
                    }) {
                        Image(systemName: viewModel.isFavorite(recipe: recipe) ? "heart.fill" : "heart")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                            .padding()
                    }
                    , alignment: .topTrailing
                )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .cornerRadius(10)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            
            Button(action: {
                showingDetail = true
            }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    HStack {
                        if let readyInMinutes = recipe.readyInMinutes {
                            Label("\(readyInMinutes) min", systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let servings = recipe.servings {
                            Label("\(servings) servings", systemImage: "person")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let cuisines = recipe.cuisines, !cuisines.isEmpty {
                        Text("Cuisine: \(cuisines.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding()
        .sheet(isPresented: $showingDetail) {
            RecipeDetailView(recipe: recipe, viewModel: viewModel)
        }
    }
}

#Preview {
    RecipeListView()
}
