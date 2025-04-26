//
//  EditRecipeView.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import SwiftUI
import PhotosUI

struct EditRecipeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var viewModel: RecipesViewModel
    
    let recipe: CustomRecipe
    
    @State private var title: String
    @State private var selectedImage: UIImage?
    @State private var servings: Int
    @State private var readyInMinutes: Int
    @State private var instructions: String
    @State private var ingredients: [CustomIngredient]
    @State private var cuisineType: String
    @State private var dietType: String
    @State private var isFavorite: Bool
    
    @State private var showingImagePicker = false
    @State private var showingAddIngredient = false
    @State private var currentIngredient = CustomIngredient(name: "", amount: 1, unit: "cup")
    
    let cuisineTypes = ["Italian", "Mexican", "Asian", "American", "Mediterranean", "Indian", "French", "Greek", "Spanish", "Middle Eastern", "Thai", "Japanese", "Chinese", "Korean", "Vietnamese", "Other"]
    
    let dietTypes = ["None", "Vegetarian", "Vegan", "Gluten Free", "Dairy Free", "Keto", "Paleo", "Low Carb", "Low Fat", "Other"]
    
    init(recipe: CustomRecipe, viewModel: RecipesViewModel) {
        self.recipe = recipe
        self.viewModel = viewModel
        
        _title = State(initialValue: recipe.title)
        _servings = State(initialValue: recipe.servings)
        _readyInMinutes = State(initialValue: recipe.readyInMinutes)
        _instructions = State(initialValue: recipe.instructions)
        _ingredients = State(initialValue: recipe.ingredients)
        _cuisineType = State(initialValue: recipe.cuisineType)
        _dietType = State(initialValue: recipe.dietType)
        _isFavorite = State(initialValue: recipe.isFavorite)
        
        if let imageData = recipe.image {
            _selectedImage = State(initialValue: UIImage(data: imageData))
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Information")) {
                    TextField("Recipe Title", text: $title)
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        HStack {
                            Text("Recipe Photo")
                            Spacer()
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "photo")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Stepper("Servings: \(servings)", value: $servings, in: 1...20)
                    
                    Stepper("Prep Time: \(readyInMinutes) min", value: $readyInMinutes, in: 5...240, step: 5)
                    
                    Picker("Cuisine Type", selection: $cuisineType) {
                        ForEach(cuisineTypes, id: \.self) { cuisine in
                            Text(cuisine).tag(cuisine)
                        }
                    }
                    
                    Picker("Dietary Type", selection: $dietType) {
                        ForEach(dietTypes, id: \.self) { diet in
                            Text(diet).tag(diet)
                        }
                    }
                    
                    Toggle("Favorite", isOn: $isFavorite)
                }
                
                Section(header: Text("Ingredients")) {
                    ForEach(ingredients) { ingredient in
                        HStack {
                            Text("\(ingredient.amount, specifier: "%.1f") \(ingredient.unit) \(ingredient.name)")
                            Spacer()
                        }
                    }
                    .onDelete { indexSet in
                        ingredients.remove(atOffsets: indexSet)
                    }
                    
                    Button(action: {
                        showingAddIngredient = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add Ingredient")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("Instructions")) {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 150)
                }
                
                Section {
                    Button(action: saveRecipe) {
                        Text("Save Changes")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .background(isFormValid ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Edit Recipe")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingImagePicker) {
                PHPickerView(image: $selectedImage)
            }
            .sheet(isPresented: $showingAddIngredient) {
                AddIngredientView(ingredient: $currentIngredient, onSave: {
                    ingredients.append(currentIngredient)
                    currentIngredient = CustomIngredient(name: "", amount: 1, unit: "cup")
                })
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && !instructions.isEmpty && !ingredients.isEmpty && !cuisineType.isEmpty && !dietType.isEmpty
    }
    
    private func saveRecipe() {
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        let updatedRecipe = CustomRecipe(
            id: recipe.id,
            title: title,
            image: imageData,
            servings: servings,
            readyInMinutes: readyInMinutes,
            instructions: instructions,
            ingredients: ingredients,
            cuisineType: cuisineType,
            dietType: dietType,
            isFavorite: isFavorite
        )
        
        viewModel.updateCustomRecipe(updatedRecipe)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    NavigationStack {
        EditRecipeView(
            recipe: CustomRecipe(
                id: UUID(),
                title: "Homemade Pizza",
                servings: 4,
                readyInMinutes: 60,
                instructions: "1. Preheat oven to 450°F.\n2. Roll out pizza dough.\n3. Add sauce and toppings.\n4. Bake for 12-15 minutes.",
                ingredients: [
                    CustomIngredient(name: "Pizza Dough", amount: 1, unit: "ball"),
                    CustomIngredient(name: "Tomato Sauce", amount: 0.5, unit: "cup"),
                    CustomIngredient(name: "Mozzarella Cheese", amount: 2, unit: "cup"),
                    CustomIngredient(name: "Basil", amount: 0.25, unit: "cup")
                ],
                cuisineType: "Italian",
                dietType: "Vegetarian",
                isFavorite: true
            ), viewModel: RecipesViewModel())

    }
}
