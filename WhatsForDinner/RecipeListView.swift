//
//  RecipeListView.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import SwiftUI
import SwiftData

struct RecipeListView: View {
    @Query(sort: \Recipe.dateAdded, order: .reverse) var recipes: [Recipe]
    @Query(filter: #Predicate<Recipe> { $0.isFavorite }, sort: \Recipe.dateAdded) var favoriteRecipes: [Recipe]
    @Query(sort: \CustomRecipe.dateAdded, order: .reverse) var customRecipes: [CustomRecipe]
    
    @State private var randomRecipe: Recipe?
    @State private var showingFilters = false
    @State private var showingSearch = false
    @State private var showingFavorites = false
    @State private var showingAddRecipe = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Filter properties
    @State private var selectedMainIngredient: String = ""
    @State private var selectedCuisine: String = ""
    @State private var selectedMaxPrepTime: Int?
    @State private var selectedDietaryRestrictions: [String] = []
    
    // Available filter options
    let availableMainIngredients = ["chicken", "beef", "pork", "fish", "vegetable"]
    let availableCuisines = ["italian", "mexican", "asian", "american", "mediterranean", "indian"]
    let availableDietaryRestrictions = ["vegetarian", "vegan", "gluten free", "dairy free"]
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    // Header
                    Text("What's for Dinner?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // Random Recipe Card
                    if isLoading {
                        ProgressView("Finding your dinner...")
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let recipe = randomRecipe {
                        RecipeCard(recipe: recipe)
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 70))
                                .foregroundColor(.secondary)
                            Text("Tap the button below to find a random dinner recipe")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                Task {
                                    await fetchRandomRecipe()
                                }
                            }) {
                                Text("Find Random Dinner")
                                    .fontWeight(.semibold)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Filter indicators
                    if !selectedMainIngredient.isEmpty || !selectedCuisine.isEmpty ||
                       !selectedDietaryRestrictions.isEmpty || selectedMaxPrepTime != nil {
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                if !selectedMainIngredient.isEmpty {
                                    FilterTag(text: selectedMainIngredient)
                                }
                                
                                if !selectedCuisine.isEmpty {
                                    FilterTag(text: selectedCuisine)
                                }
                                
                                if let time = selectedMaxPrepTime {
                                    FilterTag(text: "Under \(time) min")
                                }
                                
                                ForEach(selectedDietaryRestrictions, id: \.self) { restriction in
                                    FilterTag(text: restriction)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Bottom menu
                    HStack {
                        Button(action: {
                            showingSearch = true
                        }) {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 24))
                                Text("Search")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {
                            Task {
                                await fetchRandomRecipe()
                            }
                        }) {
                            VStack {
                                Image(systemName: "dice")
                                    .font(.system(size: 24))
                                Text("Random")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {
                            showingFilters = true
                        }) {
                            VStack {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 24))
                                Text("Filters")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {
                            showingFavorites = true
                        }) {
                            VStack {
                                Image(systemName: "heart")
                                    .font(.system(size: 24))
                                Text("Favorites")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {
                            showingAddRecipe = true
                        }) {
                            VStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 24))
                                Text("Add Recipe")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground).shadow(radius: 2))
                }
                
                if let errorMessage = errorMessage {
                    VStack {
                        Spacer()
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(10)
                            .padding()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    self.errorMessage = nil
                                }
                            }
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingFilters) {
                FilterView(
                    selectedMainIngredient: $selectedMainIngredient,
                    selectedCuisine: $selectedCuisine,
                    selectedMaxPrepTime: $selectedMaxPrepTime,
                    selectedDietaryRestrictions: $selectedDietaryRestrictions,
                    availableMainIngredients: availableMainIngredients,
                    availableCuisines: availableCuisines,
                    availableDietaryRestrictions: availableDietaryRestrictions,
                    onApply: {
                        Task {
                            await fetchRandomRecipe()
                        }
                    }
                )
            }
            .sheet(isPresented: $showingSearch) {
                SearchView()
            }
            .sheet(isPresented: $showingFavorites) {
                FavoritesView()
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView()
            }
        }
    }
    
    // API methods
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
        
        var components = URLComponents(string: "https://api.spoonacular.com/recipes/random")!
        
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
            
            if let apiRecipe = returned.recipes.first {
                // Check if recipe already exists in database
                let fetchDescriptor = FetchDescriptor<Recipe>(
                    predicate: #Predicate<Recipe> { $0.id == apiRecipe.id }
                )
                
                // Check if we already have this recipe
                if let existingRecipe = try? modelContext.fetch(fetchDescriptor).first {
                    // Use existing recipe
                    randomRecipe = existingRecipe
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
                    randomRecipe = newRecipe
                }
            } else {
                errorMessage = "No recipes found with the selected filters"
            }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            print("😡 ERROR: Could not get data \(error.localizedDescription)")
        }
    }
    
    // API Response Structure
    struct RandomRecipeResponse: Codable {
        var recipes: [RecipeResponse]
    }
    
    struct RecipeResponse: Codable {
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
}

struct FilterTag: View {
    let text: String
    
    var body: some View {
        Text(text.capitalized)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.blue.opacity(0.2))
            .foregroundColor(.blue)
            .cornerRadius(15)
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    @Environment(\.modelContext) private var modelContext
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading) {
            if let imageURL = recipe.image {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(10)
                    } else if phase.error != nil {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .cornerRadius(10)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    } else {
                        ProgressView()
                            .frame(height: 200)
                    }
                }
                .overlay(
                    Button(action: {
                        recipe.isFavorite.toggle()
                    }) {
                        Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .shadow(radius: 2)
                            .padding()
                    }
                    , alignment: .topTrailing
                )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .cornerRadius(10)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            
            Button(action: {
                showingDetail = true
            }) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    HStack {
                        if let readyInMinutes = recipe.readyInMinutes {
                            Label("\(readyInMinutes) min", systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if let servings = recipe.servings {
                            Label("\(servings) servings", systemImage: "person")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let cuisines = recipe.cuisines, !cuisines.isEmpty {
                        Text("Cuisine: \(cuisines.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
        .padding()
        .sheet(isPresented: $showingDetail) {
            RecipeDetailView(recipe: recipe)
        }
    }
}

#Preview {
    RecipeListView()
        .modelContainer(Recipe.preview)
}
