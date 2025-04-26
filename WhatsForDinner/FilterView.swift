//
//  FilterView.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

//
//  FilterView.swift
//  WhatsForDinner
//

import SwiftUI
import SwiftData

struct FilterView: View {
    @Binding var selectedMainIngredient: String
    @Binding var selectedCuisine: String
    @Binding var selectedMaxPrepTime: Int?
    @Binding var selectedDietaryRestrictions: [String]
    
    let availableMainIngredients: [String]
    let availableCuisines: [String]
    let availableDietaryRestrictions: [String]
    
    let onApply: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    // Temporary state to hold filters until applied
    @State private var tempMainIngredient: String
    @State private var tempCuisine: String
    @State private var tempMaxPrepTime: Int?
    @State private var tempDietaryRestrictions: [String]
    
    init(selectedMainIngredient: Binding<String>,
         selectedCuisine: Binding<String>,
         selectedMaxPrepTime: Binding<Int?>,
         selectedDietaryRestrictions: Binding<[String]>,
         availableMainIngredients: [String],
         availableCuisines: [String],
         availableDietaryRestrictions: [String],
         onApply: @escaping () -> Void) {
        self._selectedMainIngredient = selectedMainIngredient
        self._selectedCuisine = selectedCuisine
        self._selectedMaxPrepTime = selectedMaxPrepTime
        self._selectedDietaryRestrictions = selectedDietaryRestrictions
        self.availableMainIngredients = availableMainIngredients
        self.availableCuisines = availableCuisines
        self.availableDietaryRestrictions = availableDietaryRestrictions
        self.onApply = onApply
        
        // Initialize temporary state with current values
        _tempMainIngredient = State(initialValue: selectedMainIngredient.wrappedValue)
        _tempCuisine = State(initialValue: selectedCuisine.wrappedValue)
        _tempMaxPrepTime = State(initialValue: selectedMaxPrepTime.wrappedValue)
        _tempDietaryRestrictions = State(initialValue: selectedDietaryRestrictions.wrappedValue)
    }
    
    let prepTimeOptions = [15, 30, 45, 60, 90, 120]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Main Ingredient")) {
                    Picker("Select main ingredient", selection: $tempMainIngredient) {
                        Text("Any").tag("")
                        ForEach(availableMainIngredients, id: \.self) { ingredient in
                            Text(ingredient.capitalized).tag(ingredient)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Cuisine")) {
                    Picker("Select cuisine", selection: $tempCuisine) {
                        Text("Any").tag("")
                        ForEach(availableCuisines, id: \.self) { cuisine in
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
                    ForEach(availableDietaryRestrictions, id: \.self) { restriction in
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
                    dismiss()
                },
                trailing: Button("Apply") {
                    // Apply filters
                    selectedMainIngredient = tempMainIngredient
                    selectedCuisine = tempCuisine
                    selectedMaxPrepTime = tempMaxPrepTime
                    selectedDietaryRestrictions = tempDietaryRestrictions
                    
                    // Call the onApply closure
                    onApply()
                    
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    // Since we need to bind to values, we need to use a state object wrapper
    struct PreviewWrapper: View {
        @State private var ingredient = ""
        @State private var cuisine = ""
        @State private var maxTime: Int? = nil
        @State private var restrictions: [String] = []
        
        var body: some View {
            FilterView(
                selectedMainIngredient: $ingredient,
                selectedCuisine: $cuisine,
                selectedMaxPrepTime: $maxTime,
                selectedDietaryRestrictions: $restrictions,
                availableMainIngredients: ["chicken", "beef", "pork", "fish", "vegetable"],
                availableCuisines: ["italian", "mexican", "asian", "american", "mediterranean"],
                availableDietaryRestrictions: ["vegetarian", "vegan", "gluten free", "dairy free"],
                onApply: {}
            )
        }
    }
    
    return PreviewWrapper()
}
