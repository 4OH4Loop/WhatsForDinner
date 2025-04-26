//
//  FavoritesView.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var viewModel: RecipesViewModel
    @State private var showingCustomRecipes = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Segmented Control
                Picker("Recipe Type", selection: $showingCustomRecipes) {
                    Text("Favorites").tag(false)
                    Text("My Recipes").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if !showingCustomRecipes {
                    // Favorites List
                    if viewModel.favoriteRecipes.isEmpty {
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 70))
                                .foregroundColor(.secondary)
                            
                            Text("No favorite recipes yet")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Text("Tap the heart icon on any recipe to add it to your favorites")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.favoriteRecipes, id: \.id) { recipe in
                                    SearchResultRow(recipe: recipe, viewModel: viewModel)
                                }
                            }
                            .padding()
                        }
                    }
                } else {
                    // Custom Recipes List
                    if viewModel.customRecipes.isEmpty {
                        Spacer()
                        VStack(spacing: 20) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 70))
                                .foregroundColor(.secondary)
                            
                            Text("No custom recipes yet")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Text("Create your own recipes by tapping the + button on the main screen")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.customRecipes) { recipe in
                                    CustomRecipeRow(recipe: recipe, viewModel: viewModel)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle(showingCustomRecipes ? "My Recipes" : "Favorites")
            .navigationBarItems(leading: Button("Back") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct CustomRecipeRow: View {
    let recipe: CustomRecipe
    @State var viewModel: RecipesViewModel
    @State private var showingDetail = false
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack(spacing: 16) {
                // Recipe Image
                if let imageData = recipe.image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
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
                
                // Recipe Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        Label("\(recipe.readyInMinutes) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("\(recipe.servings) servings", systemImage: "person")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Actions Menu
                Menu {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                    
                    Button(action: {
                        var updatedRecipe = recipe
                        updatedRecipe.isFavorite.toggle()
                        viewModel.updateCustomRecipe(updatedRecipe)
                    }) {
                        Label(recipe.isFavorite ? "Remove from Favorites" : "Add to Favorites", systemImage: recipe.isFavorite ? "heart.slash" : "heart")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            CustomRecipeDetailView(recipe: recipe, viewModel: viewModel)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditRecipeView(recipe: recipe, viewModel: viewModel)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Recipe"),
                message: Text("Are you sure you want to delete '\(recipe.title)'? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    viewModel.deleteCustomRecipe(recipe)
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct CustomRecipeDetailView: View {
    let recipe: CustomRecipe
    @State var viewModel: RecipesViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe Image
                if let imageData = recipe.image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 250)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                
                // Recipe Title and Info
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text(recipe.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                        
                        Button(action: {
                            showingEditSheet = true
                        }) {
                            Image(systemName: "pencil")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Recipe Information
                    HStack(spacing: 20) {
                        VStack {
                            Image(systemName: "clock")
                                .font(.system(size: 24))
                            Text("\(recipe.readyInMinutes) min")
                                .font(.caption)
                        }
                        
                        VStack {
                            Image(systemName: "person.2")
                                .font(.system(size: 24))
                            Text("\(recipe.servings) servings")
                                .font(.caption)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                    
                    // Dietary Tags
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            DietaryTag(text: recipe.cuisineType, color: .purple)
                            DietaryTag(text: recipe.dietType, color: .green)
                        }
                    }
                    
                    Divider()
                    
                    // Ingredients Section
                    Text("Ingredients")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ForEach(recipe.ingredients) { ingredient in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 8))
                                .padding(.trailing, 5)
                            
                            Text("\(ingredient.amount, specifier: "%.1f") \(ingredient.unit) \(ingredient.name)")
                        }
                        .padding(.vertical, 2)
                    }
                    
                    Divider()
                    
                    // Instructions Section
                    Text("Instructions")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(recipe.instructions)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .font(.title2)
            }
        )
        .sheet(isPresented: $showingEditSheet) {
            EditRecipeView(recipe: recipe, viewModel: viewModel)
        }
    }
}

#Preview {
    FavoritesView(viewModel: RecipesViewModel())
}
