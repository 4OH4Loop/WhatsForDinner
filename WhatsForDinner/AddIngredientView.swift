//
//  AddIngredientView.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import SwiftUI

struct AddIngredientView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var ingredient: CustomIngredient
    let onSave: () -> Void
    
    @State private var name: String
    @State private var amount: Double
    @State private var unit: String
    
    let units = ["cup", "tablespoon", "teaspoon", "ounce", "pound", "gram", "kilogram", "milliliter", "liter", "pinch", "piece", "slice", "clove"]
    
    init(ingredient: Binding<CustomIngredient>, onSave: @escaping () -> Void) {
        self._ingredient = ingredient
        self.onSave = onSave
        self._name = State(initialValue: ingredient.wrappedValue.name)
        self._amount = State(initialValue: ingredient.wrappedValue.amount)
        self._unit = State(initialValue: ingredient.wrappedValue.unit)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ingredient Details")) {
                    TextField("Ingredient Name", text: $name)
                    
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("Amount", value: $amount, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                    
                    Picker("Unit", selection: $unit) {
                        ForEach(units, id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section {
                    Button("Save Ingredient") {
                        ingredient.name = name
                        ingredient.amount = amount
                        ingredient.unit = unit
                        onSave()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    NavigationStack {
        AddIngredientView(
            ingredient: .constant(CustomIngredient(name: "Tomatoes", amount: 2, unit: "cup")),
            onSave: {}
        )
    }
}
