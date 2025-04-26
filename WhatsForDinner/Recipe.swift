//
//  Recipe.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import Foundation

struct Recipe: Codable, Identifiable {
    let id: Int
    var title: String
    var image: String?
    var imageType: String?
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

struct CustomRecipe: Codable, Identifiable {
    let id: UUID
    var title: String
    var image: Data?
    var servings: Int
    var readyInMinutes: Int
    var instructions: String
    var ingredients: [CustomIngredient]
    var cuisineType: String
    var dietType: String
    var isFavorite: Bool
    
    init(id: UUID = UUID(), title: String, image: Data? = nil, servings: Int, readyInMinutes: Int,
         instructions: String, ingredients: [CustomIngredient], cuisineType: String, dietType: String, isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.image = image
        self.servings = servings
        self.readyInMinutes = readyInMinutes
        self.instructions = instructions
        self.ingredients = ingredients
        self.cuisineType = cuisineType
        self.dietType = dietType
        self.isFavorite = isFavorite
    }
}

struct CustomIngredient: Codable, Identifiable {
    let id: UUID
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
