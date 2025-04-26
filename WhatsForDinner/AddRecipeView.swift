//
//  AddRecipeView.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import SwiftUI
import PhotosUI

struct AddRecipeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var viewModel: RecipesViewModel
    
    @State private var title = ""
    @State private var selectedImage: UIImage?
    @State private var servings = 4
    @State private var readyInMinutes = 30
    @State private var instructions = ""
    @State private var ingredients: [CustomIngredient] = []
    @State private var cuisineType = ""
    @State private var dietType = ""
    
    @State private var showingImagePicker = false
    @State private var showingAddIngredient = false
    @State private var currentIngredient = CustomIngredient(name: "", amount: 1, unit: "cup")
    
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
                        ForEach(cuisineTypes, id: \.self) { cuisine in
                            Text(cuisine).tag(cuisine)
                        }
                    }
                    
                    Picker("Dietary Type", selection: $dietType) {
                        ForEach(dietTypes, id: \.self) { diet in
                            Text(diet).tag(diet)
                        }
                    }
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
                        Text("Save Recipe")
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
            .navigationTitle("Add Recipe")
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
        
        let newRecipe = CustomRecipe(
            title: title,
            image: imageData,
            servings: servings,
            readyInMinutes: readyInMinutes,
            instructions: instructions,
            ingredients: ingredients,
            cuisineType: cuisineType,
            dietType: dietType
        )
        
        viewModel.addCustomRecipe(newRecipe)
        presentationMode.wrappedValue.dismiss()
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
    AddRecipeView(viewModel: RecipesViewModel())
}
