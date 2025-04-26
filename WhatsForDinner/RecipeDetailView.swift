//
//  RecipeDetailView.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import SwiftUI

struct RecipeDetailView: View {
    @State var recipe: Recipe
    @State var viewModel: RecipesViewModel
    @State private var recipeDetailVM = RecipeDetailViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe Image
                if let imageURL = recipe.image {
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
                    .overlay(
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                                    .padding()
                            }
                            Spacer()
                            Button(action: {
                                if viewModel.isFavorite(recipe: recipe) {
                                    viewModel.removeFromFavorites(recipe: recipe)
                                } else {
                                    viewModel.addToFavorites(recipe: recipe)
                                }
                            }) {
                                Image(systemName: viewModel.isFavorite(recipe: recipe) ? "heart.fill" : "heart")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .shadow(radius: 2)
                                    .padding()
                            }
                        }, alignment: .top
                    )
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
                    Text(recipe.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Recipe Information
                    HStack(spacing: 20) {
                        if let readyInMinutes = recipe.readyInMinutes {
                            VStack {
                                Image(systemName: "clock")
                                    .font(.system(size: 24))
                                Text("\(readyInMinutes) min")
                                    .font(.caption)
                            }
                        }
                        
                        if let servings = recipe.servings {
                            VStack {
                                Image(systemName: "person.2")
                                    .font(.system(size: 24))
                                Text("\(servings) servings")
                                    .font(.caption)
                            }
                        }
                        
                        if let healthScore = recipe.healthScore {
                            VStack {
                                Image(systemName: "heart")
                                    .font(.system(size: 24))
                                Text("\(Int(healthScore))/100")
                                    .font(.caption)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                    
                    if recipeDetailVM.isLoading {
                        ProgressView("Loading recipe details...")
                            .padding()
                    } else if let recipeDetail = recipeDetailVM.recipeDetail {
                        // Dietary Tags
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                if recipeDetail.vegetarian {
                                    DietaryTag(text: "Vegetarian", color: .green)
                                }
                                
                                if recipeDetail.vegan {
                                    DietaryTag(text: "Vegan", color: .green)
                                }
                                
                                if recipeDetail.glutenFree {
                                    DietaryTag(text: "Gluten Free", color: .orange)
                                }
                                
                                if recipeDetail.dairyFree {
                                    DietaryTag(text: "Dairy Free", color: .blue)
                                }
                                
                                ForEach(recipeDetail.cuisines, id: \.self) { cuisine in
                                    DietaryTag(text: cuisine, color: .purple)
                                }
                                
                                ForEach(recipeDetail.dishTypes, id: \.self) { dishType in
                                    DietaryTag(text: dishType, color: .gray)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Ingredients Section
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ForEach(recipeDetail.extendedIngredients, id: \.id) { ingredient in
                            HStack(alignment: .top) {
                                if let image = ingredient.image, !image.isEmpty {
                                    AsyncImage(url: URL(string: "https://spoonacular.com/cdn/ingredients_100x100/\(image)")) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .frame(width: 40, height: 40)
                                                .cornerRadius(20)
                                        } else {
                                            Image(systemName: "circle.fill")
                                                .foregroundColor(.gray)
                                                .frame(width: 40, height: 40)
                                        }
                                    }
                                } else {
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(.gray)
                                        .frame(width: 40, height: 40)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(ingredient.original)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        
                        Divider()
                        
                        // Instructions Section
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if let instructions = recipeDetail.instructions, !instructions.isEmpty {
                            Text(instructions.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil))
                                .fixedSize(horizontal: false, vertical: true)
                        } else if let analyzedInstructions = recipeDetail.analyzedInstructions, !analyzedInstructions.isEmpty {
                            ForEach(analyzedInstructions.first?.steps ?? [], id: \.number) { step in
                                HStack(alignment: .top) {
                                    Text("\(step.number)")
                                        .font(.headline)
                                        .frame(width: 25, alignment: .center)
                                    
                                    Text(step.step)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        
                        // Source Link
                        if let sourceUrl = recipeDetail.sourceUrl, !sourceUrl.isEmpty {
                            Divider()
                            
                            Link(destination: URL(string: sourceUrl)!) {
                                HStack {
                                    Text("View Original Recipe")
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .task {
            await recipeDetailVM.fetchRecipeDetails(id: recipe.id)
        }
    }
}

struct DietaryTag: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text.capitalized)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(15)
    }
}

#Preview {
    RecipeDetailView(recipe: Recipe(id: 716426, title: "Cauliflower, Brown Rice, and Vegetable Fried Rice"), viewModel: RecipesViewModel())
}
