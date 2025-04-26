//
//  Recipe.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import Foundation
import SwiftData

@Model
class Recipe {
    @Attribute(.unique) var id: Int
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
    var isFavorite: Bool
    var dateAdded: Date
    
    init(id: Int = 0, title: String = "", image: String? = "",
         servings: Int? = 0, readyInMinutes: Int? = 0, sourceName: String? = "",
         sourceUrl: String? = "", spoonacularSourceUrl: String? = "", healthScore: Double? = 0.0,
         spoonacularScore: Double? = 0.0, pricePerServing: Double? = 0.0, cheap: Bool? = false,
         creditsText: String? = "", cuisines: [String]? = [], dairyFree: Bool? = false,
         glutenFree: Bool? = false, instructions: String? = "", summary: String? = "",
         vegetarian: Bool? = false, vegan: Bool? = false, dishTypes: [String]? = [],
         isFavorite: Bool = false, dateAdded: Date = Date()) {
        self.id = id
        self.title = title
        self.image = image
        self.servings = servings
        self.readyInMinutes = readyInMinutes
        self.sourceName = sourceName
        self.sourceUrl = sourceUrl
        self.spoonacularSourceUrl = spoonacularSourceUrl
        self.healthScore = healthScore
        self.spoonacularScore = spoonacularScore
        self.pricePerServing = pricePerServing
        self.cheap = cheap
        self.creditsText = creditsText
        self.cuisines = cuisines
        self.dairyFree = dairyFree
        self.glutenFree = glutenFree
        self.instructions = instructions
        self.summary = summary
        self.vegetarian = vegetarian
        self.vegan = vegan
        self.dishTypes = dishTypes
        self.isFavorite = isFavorite
        self.dateAdded = dateAdded
    }
}

@Model
class CustomRecipe {
    @Attribute(.unique) var id: UUID
    var title: String = ""
    var image: String = ""
    var servings: Int = 0
    var readyInMinutes: Int = 0
    var instructions: String = ""
    var cuisineType: String = ""
    var dietType: String = ""
    var isFavorite: Bool
    var dateAdded: Date = Date()
    @Relationship(deleteRule: .cascade) var ingredients: [CustomIngredient] = []
    
    init(id: UUID = UUID(), title: String, imageData: Data? = nil, servings: Int,
         readyInMinutes: Int, instructions: String, cuisineType: String,
         dietType: String, isFavorite: Bool = false, dateAdded: Date = Date()) {
        self.id = id
        self.title = title
        self.servings = servings
        self.readyInMinutes = readyInMinutes
        self.instructions = instructions
        self.cuisineType = cuisineType
        self.dietType = dietType
        self.isFavorite = isFavorite
        self.dateAdded = dateAdded
    }
}

@Model
class CustomIngredient {
    @Attribute(.unique) var id: UUID
    var name: String
    var amount: Double
    var unit: String
    
    init(id: UUID = UUID(), name: String, amount: Double, unit: String) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
    }
}

// Extension for preview data
extension Recipe {
    static var preview: ModelContainer {
        let container = try! ModelContainer(for: Recipe.self, CustomRecipe.self, CustomIngredient.self,
                                          configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        Task { @MainActor in
            // Add Mock Recipe Data
            let pastaRecipe = Recipe(
                id: 716429,
                title: "Pasta with Garlic, Scallions, Cauliflower & Breadcrumbs",
                image: "https://spoonacular.com/recipeImages/716429-556x370.jpg",
                servings: 4,
                readyInMinutes: 45,
                sourceName: "Full Belly Sisters",
                sourceUrl: "http://fullbellysisters.blogspot.com/2012/06/pasta-with-garlic-scallions-cauliflower.html",
                spoonacularSourceUrl: "https://spoonacular.com/pasta-with-garlic-scallions-cauliflower-breadcrumbs-716429",
                healthScore: 19.0,
                spoonacularScore: 83.0,
                pricePerServing: 163.15,
                cheap: false,
                creditsText: "Full Belly Sisters",
                cuisines: ["italian", "mediterranean"],
                dairyFree: false,
                glutenFree: false,
                instructions: "Cook the pasta in a large pot of boiling salted water until al dente. Drain and toss with a splash of oil. Meanwhile, heat 3 tablespoons oil in a large skillet over medium heat. Add the cauliflower and salt and pepper. Cook until golden, about 5 minutes. Add the garlic and cook for 30 seconds. Add the scallions, Italian seasoning, and red pepper. Cook for one minute longer. Add the wine and cook until reduced by about half. Add the spaghetti and toss to combine. Sprinkle with breadcrumbs and cheese before serving.",
                summary: "Pasta with Garlic, Scallions, Cauliflower & Breadcrumbs might be a good recipe to expand your side dish recipe box. One serving contains 528 calories, 19g of protein, and 13g of fat.",
                vegetarian: true,
                vegan: false,
                dishTypes: ["lunch", "main course", "main dish", "dinner"],
                isFavorite: true
            )
            
            let tacoRecipe = Recipe(
                id: 715538,
                title: "Cajun Spiced Chicken Tacos",
                image: "https://spoonacular.com/recipeImages/715538-556x370.jpg",
                servings: 4,
                readyInMinutes: 30,
                sourceName: "Simply Recipes",
                healthScore: 38.0,
                spoonacularScore: 97.0,
                pricePerServing: 282.35,
                cheap: false,
                dairyFree: false,
                glutenFree: true,
                instructions: "Season chicken with cajun seasoning. Cook in skillet until done. Warm tortillas. Assemble tacos with toppings of your choice.",
                summary: "Cajun Spiced Chicken Tacos features tender chicken coated in spicy cajun seasoning, wrapped in warm tortillas with fresh toppings.",
                vegetarian: false,
                vegan: false,
                dishTypes: ["lunch", "main course", "dinner"],
                isFavorite: false
            )
            
            // Add Custom Recipe with Ingredients
            let pizzaRecipe = CustomRecipe(
                title: "Homemade Pizza",
                servings: 4,
                readyInMinutes: 60,
                instructions: "1. Preheat oven to 450°F.\n2. Roll out pizza dough.\n3. Add sauce and toppings.\n4. Bake for 12-15 minutes.",
                cuisineType: "Italian",
                dietType: "Vegetarian",
                isFavorite: true
            )
            
            let doughIngredient = CustomIngredient(name: "Pizza Dough", amount: 1, unit: "ball")
            let sauceIngredient = CustomIngredient(name: "Tomato Sauce", amount: 0.5, unit: "cup")
            let cheeseIngredient = CustomIngredient(name: "Mozzarella Cheese", amount: 2, unit: "cup")
            let basilIngredient = CustomIngredient(name: "Basil", amount: 0.25, unit: "cup")
            
            container.mainContext.insert(pastaRecipe)
            container.mainContext.insert(tacoRecipe)
            container.mainContext.insert(pizzaRecipe)
            
            container.mainContext.insert(doughIngredient)
            container.mainContext.insert(sauceIngredient)
            container.mainContext.insert(cheeseIngredient)
            container.mainContext.insert(basilIngredient)
            
            // Add ingredients to pizza recipe
            pizzaRecipe.ingredients.append(doughIngredient)
            pizzaRecipe.ingredients.append(sauceIngredient)
            pizzaRecipe.ingredients.append(cheeseIngredient)
            pizzaRecipe.ingredients.append(basilIngredient)
        }
        
        return container
    }
}
