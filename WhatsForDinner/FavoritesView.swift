//
//  FavoritesView.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query(filter: #Predicate<Recipe> { $0.isFavorite == true },
           sort: \Recipe.dateAdded,
           order: .reverse) var favoriteRecipes: [Recipe]
    
    @Query(filter: #Predicate<CustomRecipe> { $0.isFavorite == true },
           sort: \CustomRecipe.dateAdded,
           order: .reverse) var favoriteCustomRecipes: [CustomRecipe]
    
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
                    if favoriteRecipes.isEmpty {
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
                                ForEach(favoriteRecipes) { recipe in
                                    SearchResultRow(recipe: recipe)
                                }
                            }
                            .padding()
                        }
                    }
                } else {
                    // Custom Recipes List
                    if favoriteCustomRecipes.isEmpty {
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
                                ForEach(favoriteCustomRecipes) { recipe in
                                    CustomRecipeRow(recipe: customRecipe)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle(showingCustomRecipes ? "My Recipes" : "Favorites")
            .navigationBarItems(leading: Button("Back") {
                dismiss()
            })
        }
    }
}

struct CustomRecipeRow: View {
    @Environment(\.modelContext) private var modelContext
    // Create a new recipe object
    @State var customRecipe = ""
    @State private var showingDetail = false
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack(spacing: 16) {
                // Recipe Image
                if let imageURL = customRecipe.image {
                    AsyncImage(url: URL(string: imageURL)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                        } else if phase.error != nil {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 250)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                )
                        } else {
                            ProgressView()
                                .frame(height: 250)
                        }
                    }
                }
            
                // Recipe Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(customRecipe.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        Label("\(customRecipe.readyInMinutes) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Label("\(customRecipe.servings) servings", systemImage: "person")
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
                        customRecipe.isFavorite.toggle()
                    }) {
                        Label(customRecipe.isFavorite ? "Remove from Favorites" : "Add to Favorites", systemImage: customRecipe.isFavorite ? "heart.slash" : "heart")
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
            CustomRecipeDetailView(recipe: customRecipe)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditRecipeView(recipe: customRecipe)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Recipe"),
                message: Text("Are you sure you want to delete '\($customRecipe.title)'? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    modelContext.delete($customRecipe)
                },
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    FavoritesView()
        .modelContainer(Recipe.preview)
}
