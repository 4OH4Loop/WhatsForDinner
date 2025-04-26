//
//  CustomRecipeDetailView.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/26/25.
//

import SwiftUI
import SwiftData

struct CustomRecipeDetailView: View {
    // Create a new recipe object
    @State var recipe = ""
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe Image
                if let imageURL = $recipe.image {
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
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                }
            )
            .sheet(isPresented: $showingEditSheet) {
                EditRecipeView(recipe: recipe)
            }
        }
    }
    
    #Preview {
        // Create a static mock custom recipe
        let mockRecipe = CustomRecipe(
            title: "Homemade Pizza",
            servings: 4,
            readyInMinutes: 60,
            instructions: "1. Preheat oven to 450°F.\n2. Roll out pizza dough.\n3. Add sauce and toppings.\n4. Bake for 12-15 minutes.",
            cuisineType: "Italian",
            dietType: "Vegetarian",
            isFavorite: true
        )
        
        // Add sample ingredients
        let doughIngredient = CustomIngredient(name: "Pizza Dough", amount: 1, unit: "ball")
        let sauceIngredient = CustomIngredient(name: "Tomato Sauce", amount: 0.5, unit: "cup")
        let cheeseIngredient = CustomIngredient(name: "Mozzarella", amount: 2, unit: "cup")
        
        // Connect ingredients to recipe
        mockRecipe.ingredients = [doughIngredient, sauceIngredient, cheeseIngredient]
        
        NavigationStack {
            CustomRecipeDetailView(recipe: mockRecipe)
                .modelContainer(Recipe.preview)
        }
    }
