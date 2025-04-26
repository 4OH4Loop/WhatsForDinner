//
//  WhatsForDinnerApp.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import SwiftUI
import SwiftData

@main
struct WhatsForDinnerApp: App {
    var body: some Scene {
        WindowGroup {
            RecipeListView()
                .modelContainer(for: Recipe.self)
                .modelContainer(for: CustomRecipe.self)
                .modelContainer(for: CustomIngredient.self)
        }
    }
    
    // This helps find where simulator data is saved (for debugging)
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
