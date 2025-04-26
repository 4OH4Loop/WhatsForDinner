//
//  RecipeDetail.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import Foundation

struct RecipeDetail: Codable, Identifiable {
    let id: Int
    var title: String
    var image: String?
    var servings: Int
    var readyInMinutes: Int
    var sourceName: String?
    var sourceUrl: String?
    var spoonacularSourceUrl: String?
    var aggregateLikes: Int?
    var healthScore: Double?
    var spoonacularScore: Double?
    var pricePerServing: Double?
    var cheap: Bool
    var creditsText: String?
    var cuisines: [String]
    var dairyFree: Bool
    var glutenFree: Bool
    var instructions: String?
    var analyzedInstructions: [AnalyzedInstruction]?
    var summary: String
    var vegetarian: Bool
    var vegan: Bool
    var dishTypes: [String]
    var extendedIngredients: [Ingredient]
}

struct Ingredient: Identifiable, Codable {
    let id: Int
    var aisle: String?
    var image: String?
    var consistency: String?
    var name: String
    var original: String
    var originalString: String?
    var originalName: String?
    var amount: Double
    var unit: String
    var meta: [String]?
    var metaInformation: [String]?
}

struct AnalyzedInstruction: Codable {
    var name: String
    var steps: [Step]
}

struct Step: Identifiable, Codable {
    var number: Int
    var step: String
    var ingredients: [StepItem]?
    var equipment: [StepItem]?
    var length: Length?
    
    var id: Int { number }
}

struct StepItem: Identifiable, Codable {
    let id: Int
    var name: String
    var localizedName: String?
    var image: String?
}

struct Length: Codable {
    var number: Int
    var unit: String
}
