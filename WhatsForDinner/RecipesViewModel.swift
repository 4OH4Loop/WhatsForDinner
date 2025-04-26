//
//  RecipesViewModel.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class RecipesViewModel {
    // API Response structures for Spoonacular
    struct RandomRecipeResponse: Codable {
        var recipes: [RecipeAPIResponse]
    }
    
    struct RecipeSearchResponse: Codable {
        var results: [RecipeAPIResponse]
        var offset: Int
        var number: Int
        var totalResults: Int
    }
    
    struct RecipeAPIResponse: Codable, Identifiable {
        var id: Int
        var title: String
        var image: String?
        var servings: Int?
        var readyInMinutes: Int?
        var sourceName: String?
        var sourceUrl: String?
        var spoonacularSourceUrl: String?
        var healthScore: Double?
        var spoonacularScore: Double?
        var pricePerServing: Double?
        var cheap: Bool?
        var creditsText: String?
        var cuisines: [String]?
        var dairyFree: Bool?
        var glutenFree: Bool?
        var instructions: String?
        var summary: String?
        var vegetarian: Bool?
        var vegan: Bool?
        var dishTypes: [String]?
    }
    
    // State properties
    var isLoading = false
    var baseURL = "https://api.spoonacular.com"
    
    // Filter properties
    var selectedMainIngredient: String = ""
    var selectedCuisine: String = ""
    var selectedMaxPrepTime: Int?
    var selectedDietaryRestrictions: [String] = []
    
    // Available filter options
    let availableMainIngredients = ["chicken", "beef", "pork", "fish", "vegetable"]
    let availableCuisines = ["italian", "mexican", "asian", "american", "mediterranean", "indian"]
    let availableDietaryRestrictions = ["vegetarian", "vegan", "gluten free", "dairy free"]
    
    // ModelContext access
    var modelContext: ModelContext?
    
    // MARK: - API Methods
    
    func fetchRandomRecipe() async {
        guard let modelContext = self.modelContext else {
            return
        }
        
        isLoading = true
        
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
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let returned = try? JSONDecoder().decode(RandomRecipeResponse.self, from: data) else {
                print("😡 JSON ERROR: Could not decode returned data")
                isLoading = false
                return
            }
            
            if let apiRecipe = returned.recipes.first {
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
                
                // Check if we already have this recipe
                if (try? modelContext.fetch(fetchDescriptor).first) != nil {
                    // Recipe already exists
                    print("😎 Found existing recipe in database")
                } else {
                    // Create new recipe
                    let newRecipe = Recipe(
                        id: apiRecipe.id,
                        title: apiRecipe.title,
                        image: apiRecipe.image,
                        servings: apiRecipe.servings,
                        readyInMinutes: apiRecipe.readyInMinutes,
                        sourceName: apiRecipe.sourceName,
                        sourceUrl: apiRecipe.sourceUrl,
                        spoonacularSourceUrl: apiRecipe.spoonacularSourceUrl,
                        healthScore: apiRecipe.healthScore,
                        spoonacularScore: apiRecipe.spoonacularScore,
                        pricePerServing: apiRecipe.pricePerServing,
                        cheap: apiRecipe.cheap,
                        creditsText: apiRecipe.creditsText,
                        cuisines: apiRecipe.cuisines,
                        dairyFree: apiRecipe.dairyFree,
                        glutenFree: apiRecipe.glutenFree,
                        instructions: apiRecipe.instructions,
                        summary: apiRecipe.summary,
                        vegetarian: apiRecipe.vegetarian,
                        vegan: apiRecipe.vegan,
                        dishTypes: apiRecipe.dishTypes
                    )
                    
                    modelContext.insert(newRecipe)
                    print("😎 Added new recipe to database")
                }
            }
            isLoading = false
        } catch {
            isLoading = false
            print("😡 ERROR: Could not get data \(error.localizedDescription)")
        }
    }
    
    func searchRecipes(query: String) async {
        guard let modelContext = self.modelContext else {
            return
        }
        
        isLoading = true
        
        var components = URLComponents(string: "\(baseURL)/recipes/complexSearch")!
        
        var queryItems = [URLQueryItem(name: "apiKey", value: APIKeys.spoonacularKey),
                          URLQueryItem(name: "query", value: query),
                          URLQueryItem(name: "addRecipeInformation", value: "true"),
                          URLQueryItem(name: "number", value: "10")]
        
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
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let returned = try? JSONDecoder().decode(RecipeSearchResponse.self, from: data) else {
                print("😡 JSON ERROR: Could not decode returned data")
                isLoading = false
                return
            }
            
            if returned.results.isEmpty {
            } else {
                // Process and save recipes
                for apiRecipe in returned.results {
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
                    
                    // Skip if we already have this recipe
                    if (try? modelContext.fetch(fetchDescriptor).first) == nil {
                        // Create new recipe
                        let newRecipe = Recipe(
                            id: apiRecipe.id,
                            title: apiRecipe.title,
                            image: apiRecipe.image,
                            servings: apiRecipe.servings,
                            readyInMinutes: apiRecipe.readyInMinutes,
                            sourceName: apiRecipe.sourceName,
                            sourceUrl: apiRecipe.sourceUrl,
                            spoonacularSourceUrl: apiRecipe.spoonacularSourceUrl,
                            healthScore: apiRecipe.healthScore,
                            spoonacularScore: apiRecipe.spoonacularScore,
                            pricePerServing: apiRecipe.pricePerServing,
                            cheap: apiRecipe.cheap,
                            creditsText: apiRecipe.creditsText,
                            cuisines: apiRecipe.cuisines,
                            dairyFree: apiRecipe.dairyFree,
                            glutenFree: apiRecipe.glutenFree,
                            instructions: apiRecipe.instructions,
                            summary: apiRecipe.summary,
                            vegetarian: apiRecipe.vegetarian,
                            vegan: apiRecipe.vegan,
                            dishTypes: apiRecipe.dishTypes
                        )
                        
                        modelContext.insert(newRecipe)
                    }
                }
            }
            
            isLoading = false
        } catch {
            isLoading = false
            print("😡 ERROR: Could not get data \(error.localizedDescription)")
        }
    }
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }
}
