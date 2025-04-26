//
//  RecipesViewModel.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import Foundation
import SwiftUI

@Observable
class RecipesViewModel {
    struct RandomRecipeResponse: Codable {
        var recipes: [Recipe]
    }
    
    struct RecipeSearchResponse: Codable {
        var results: [Recipe]
        var offset: Int
        var number: Int
        var totalResults: Int
    }
    
    var randomRecipe: Recipe?
    var searchResults: [Recipe] = []
    var favoriteRecipes: [Recipe] = []
    var customRecipes: [CustomRecipe] = []
    var isLoading = false
    var errorMessage: String?
    
    // Filter properties
    var selectedMainIngredient: String = ""
    var selectedCuisine: String = ""
    var selectedMaxPrepTime: Int?
    var selectedDietaryRestrictions: [String] = []
    
    // Available filter options
    let availableMainIngredients = ["chicken", "beef", "pork", "fish", "vegetable"]
    let availableCuisines = ["italian", "mexican", "asian", "american", "mediterranean", "indian"]
    let availableDietaryRestrictions = ["vegetarian", "vegan", "gluten free", "dairy free"]
    
    var baseURL = "https://api.spoonacular.com/"
    
    func fetchRandomRecipe() async {
        isLoading = true
        errorMessage = nil
        
        var tags: [String] = []
        
        if !selectedMainIngredient.isEmpty {
            tags.append(selectedMainIngredient)
        }
        
        if !selectedCuisine.isEmpty {
            tags.append(selectedCuisine)
        }
        
        for restriction in selectedDietaryRestrictions {
            tags.append(restriction.lowercased().replacingOccurrences(of: " ", with: "-"))
        }
        
        var components = URLComponents(string: "\(baseURL)/recipes/random")!
        
        var queryItems = [URLQueryItem(name: "apiKey", value: APIKeys.spoonacularKey),
                          URLQueryItem(name: "number", value: "1")]
        
        if !tags.isEmpty {
            queryItems.append(URLQueryItem(name: "tags", value: tags.joined(separator: ",")))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            print("😡 URL ERROR: Could not create URL")
            isLoading = false
            errorMessage = "Could not create URL"
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let returned = try? JSONDecoder().decode(RandomRecipeResponse.self, from: data) else {
                print("😡 JSON ERROR: Could not decode returned data")
                isLoading = false
                errorMessage = "Could not decode returned data"
                return
            }
            
            Task { @MainActor in
                if let recipe = returned.recipes.first {
                    self.randomRecipe = recipe
                } else {
                    self.errorMessage = "No recipes found with the selected filters"
                }
                isLoading = false
            }
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("😡 ERROR: Could not get data \(error.localizedDescription)")
        }
    }
    
    func searchRecipes(query: String) async {
        isLoading = true
        errorMessage = nil
        
        var components = URLComponents(string: "\(baseURL)/recipes/complexSearch")!
        
        var queryItems = [URLQueryItem(name: "apiKey", value: APIKeys.spoonacularKey),
                          URLQueryItem(name: "query", value: query),
                          URLQueryItem(name: "addRecipeInformation", value: "true")]
        
        if !selectedCuisine.isEmpty {
            queryItems.append(URLQueryItem(name: "cuisine", value: selectedCuisine))
        }
        
        if !selectedDietaryRestrictions.isEmpty {
            let diet = selectedDietaryRestrictions.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "diet", value: diet))
        }
        
        if let maxReadyTime = selectedMaxPrepTime {
            queryItems.append(URLQueryItem(name: "maxReadyTime", value: String(maxReadyTime)))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            print("😡 URL ERROR: Could not create URL")
            isLoading = false
            errorMessage = "Could not create URL"
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let returned = try? JSONDecoder().decode(RecipeSearchResponse.self, from: data) else {
                print("😡 JSON ERROR: Could not decode returned data")
                isLoading = false
                errorMessage = "Could not decode returned data"
                return
            }
            
            Task { @MainActor in
                self.searchResults = returned.results
                if returned.results.isEmpty {
                    self.errorMessage = "No recipes found matching your search criteria"
                }
                isLoading = false
            }
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("😡 ERROR: Could not get data \(error.localizedDescription)")
        }
    }
    
    func addToFavorites(recipe: Recipe) {
        if !favoriteRecipes.contains(where: { $0.id == recipe.id }) {
            favoriteRecipes.append(recipe)
            saveToUserDefaults()
        }
    }
    
    func removeFromFavorites(recipe: Recipe) {
        favoriteRecipes.removeAll { $0.id == recipe.id }
        saveToUserDefaults()
    }
    
    func isFavorite(recipe: Recipe) -> Bool {
        return favoriteRecipes.contains(where: { $0.id == recipe.id })
    }
    
    func addCustomRecipe(_ recipe: CustomRecipe) {
        customRecipes.append(recipe)
        saveCustomRecipesToUserDefaults()
    }
    
    func updateCustomRecipe(_ recipe: CustomRecipe) {
        if let index = customRecipes.firstIndex(where: { $0.id == recipe.id }) {
            customRecipes[index] = recipe
            saveCustomRecipesToUserDefaults()
        }
    }
    
    func deleteCustomRecipe(_ recipe: CustomRecipe) {
        customRecipes.removeAll { $0.id == recipe.id }
        saveCustomRecipesToUserDefaults()
    }
    
    // MARK: - User Defaults Storage
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(favoriteRecipes) {
            UserDefaults.standard.set(encoded, forKey: "FavoriteRecipes")
        }
    }
    
    private func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "FavoriteRecipes"),
           let decoded = try? JSONDecoder().decode([Recipe].self, from: data) {
            favoriteRecipes = decoded
        }
    }
    
    private func saveCustomRecipesToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(customRecipes) {
            UserDefaults.standard.set(encoded, forKey: "CustomRecipes")
        }
    }
    
    private func loadCustomRecipesFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "CustomRecipes"),
           let decoded = try? JSONDecoder().decode([CustomRecipe].self, from: data) {
            customRecipes = decoded
        }
    }
    
    init() {
        loadFromUserDefaults()
        loadCustomRecipesFromUserDefaults()
    }
}
