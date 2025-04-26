//
//  RecipeDetailViewModel.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import Foundation

@Observable
class RecipeDetailViewModel {
    var recipeDetail: RecipeDetail?
    var title: String = ""
    var readyInMinutes: Int = 0
    var image: String = ""
    var instructions: String = ""
    var baseURL = "https://api.spoonacular.com"
    var urlString = ""
    var isLoading = false
    
    func fetchRecipeDetails(id: Int) async {
        isLoading = true
        
        urlString = "\(baseURL)/recipes/\(id)/information?apiKey=\(APIKeys.spoonacularKey)"
        print("We are accessing the url \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("😡 URL ERROR: Could not create URL from \(urlString)")
            isLoading = false
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let recipeDetail = try? JSONDecoder().decode(RecipeDetail.self, from: data) else {
                print("😡 JSON ERROR: Could not decode returned data at \(urlString)")
                isLoading = false
                return
            }
            print("😎 JSON RETURNED: We have just returned \(recipeDetail.title) from RecipeDetail")
            
            Task { @MainActor in
                self.recipeDetail = recipeDetail
                isLoading = false
            }
        } catch {
            isLoading = false
            print("😡 ERROR: Could not get data from \(urlString) \(error.localizedDescription)")
        }
    }
}
