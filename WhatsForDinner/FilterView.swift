//
//  FilterView.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import SwiftUI

struct FilterView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var viewModel: RecipesViewModel
    
    // Temporary state to hold filters until applied
    @State private var tempMainIngredient: String
    @State private var tempCuisine: String
    @State private var tempMaxPrepTime: Int?
    @State private var tempDietaryRestrictions: [String]
    
    init(viewModel: RecipesViewModel) {
        self.viewModel = viewModel
        // Initialize temporary state with current values
        _tempMainIngredient = State(initialValue: viewModel.selectedMainIngredient)
        _tempCuisine = State(initialValue: viewModel.selectedCuisine)
        _tempMaxPrepTime = State(initialValue: viewModel.selectedMaxPrepTime)
        _tempDietaryRestrictions = State(initialValue: viewModel.selectedDietaryRestrictions)
    }
    
    let prepTimeOptions = [15, 30, 45, 60, 90, 120]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Main Ingredient")) {
                    Picker("Select main ingredient", selection: $tempMainIngredient) {
                        Text("Any").tag("")
                        ForEach(viewModel.availableMainIngredients, id: \.self) { ingredient in
                            Text(ingredient.capitalized).tag(ingredient)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Cuisine")) {
                    Picker("Select cuisine", selection: $tempCuisine) {
                        Text("Any").tag("")
                        ForEach(viewModel.availableCuisines, id: \.self) { cuisine in
                            Text(cuisine.capitalized).tag(cuisine)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Maximum Preparation Time")) {
                    Picker("Max preparation time", selection: $tempMaxPrepTime) {
                        Text("Any").tag(nil as Int?)
                        ForEach(prepTimeOptions, id: \.self) { time in
                            Text("\(time) minutes").tag(time as Int?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Dietary Restrictions")) {
                    ForEach(viewModel.availableDietaryRestrictions, id: \.self) { restriction in
                        Button(action: {
                            if tempDietaryRestrictions.contains(restriction) {
                                tempDietaryRestrictions.removeAll { $0 == restriction }
                            } else {
                                tempDietaryRestrictions.append(restriction)
                            }
                        }) {
                            HStack {
                                Text(restriction.capitalized)
                                Spacer()
                                if tempDietaryRestrictions.contains(restriction) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section {
                    Button("Reset All Filters") {
                        tempMainIngredient = ""
                        tempCuisine = ""
                        tempMaxPrepTime = nil
                        tempDietaryRestrictions = []
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Apply") {
                    // Apply filters
                    viewModel.selectedMainIngredient = tempMainIngredient
                    viewModel.selectedCuisine = tempCuisine
                    viewModel.selectedMaxPrepTime = tempMaxPrepTime
                    viewModel.selectedDietaryRestrictions = tempDietaryRestrictions
                    
                    // Fetch new results with filters
                    Task {
                        await viewModel.fetchRandomRecipe()
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

#Preview {
    FilterView(viewModel: RecipesViewModel())
}
