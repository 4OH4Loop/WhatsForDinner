//
//  AddRecipeView.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AddRecipeView: View {
    // Create a new recipe object
    @State var recipe = ""
    
    // Local state to bind to UI elements
    @State private var title = ""
    @State private var selectedImage: UIImage?
    @State private var servings = 4
    @State private var readyInMinutes = 30
    @State private var instructions = ""
    @State private var cuisineType = ""
    @State private var dietType = ""
    
    // Manage ingredients
    @State private var ingredients: [CustomIngredient] = []
    
    // Sheet presentation
    @State private var showingImagePicker = false
    @State private var showingAddIngredient = false
    
    // Environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Available options
    let cuisineTypes = ["Italian", "Mexican", "Asian", "American", "Mediterranean", "Indian", "French", "Greek", "Spanish", "Middle Eastern", "Thai", "Japanese", "Chinese", "Korean", "Vietnamese", "Other"]
    
    let dietTypes = ["None", "Vegetarian", "Vegan", "Gluten Free", "Dairy Free", "Keto", "Paleo", "Low Carb", "Low Fat", "Other"]
    
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
                        Text("Select a cuisine").tag("")
                        ForEach(cuisineTypes, id: \.self) { cuisine in
                            Text(cuisine).tag(cuisine)
                        }
                    }
                    
                    Picker("Dietary Type", selection: $dietType) {
                        Text("Select dietary type").tag("")
                        ForEach(dietTypes, id: \.self) { diet in
                            Text(diet).tag(diet)
                        }
                    }
                }
                
                Section(header: Text("Ingredients")) {
                    if ingredients.isEmpty {
                        Text("Add ingredients to your recipe")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(ingredients) { ingredient in
                            HStack {
                                Text("\(ingredient.amount, specifier: "%.1f") \(ingredient.unit) \(ingredient.name)")
                                Spacer()
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                modelContext.delete(ingredients[index])
                            }
                            ingredients.remove(atOffsets: indexSet)
                        }
                    }
                    
                    Button(action: {
                        showingAddIngredient = true
                    }) {
                        Label("Add Ingredient", systemImage: "plus.circle.fill")
                            .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("Instructions")) {
                    TextEditor(text: $instructions)
                        .frame(minHeight: 150)
                }
            }
            .navigationTitle("Add Recipe")
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        // Update recipe with form data
                        recipe.title = title
                        recipe.servings = servings
                        recipe.readyInMinutes = readyInMinutes
                        recipe.instructions = instructions
                        recipe.cuisineType = cuisineType
                        recipe.dietType = dietType
                        recipe.ingredients = ingredients
                        modelContext.insert(recipe)
                        guard let _ = try? modelContext.save() else {
                            print("😡 ERROR: Save on AddRecipeView did not work.")
                            return
                        }
                        
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
            .onAppear {
                // Initialize empty form
                title = recipe.title
                servings = recipe.servings
                readyInMinutes = recipe.readyInMinutes
                instructions = recipe.instructions
                cuisineType = recipe.cuisineType
                dietType = recipe.dietType
                
                if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                    selectedImage = uiImage
                }
                
                ingredients = recipe.ingredients
            }
            .sheet(isPresented: $showingImagePicker) {
                PHPickerView(image: $selectedImage)
            }
            .sheet(isPresented: $showingAddIngredient) {
                NavigationView {
                    AddIngredientView { newIngredient in
                        modelContext.insert(newIngredient)
                        ingredients.append(newIngredient)
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && !instructions.isEmpty && !ingredients.isEmpty && !cuisineType.isEmpty && !dietType.isEmpty
    }
}

struct PHPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PHPickerView
        
        init(_ parent: PHPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                    DispatchQueue.main.async {
                        self?.parent.image = image as? UIImage
                    }
                }
            }
        }
    }
}

#Preview {
    AddRecipeView()
        .modelContainer(Recipe.preview)
}
