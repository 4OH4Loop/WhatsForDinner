//
//  AddIngredientView.swift
//  WhatsForDinner
//
//  Created by Carolyn Ballinger on 4/25/25.
//

import SwiftUI
import SwiftData

struct AddIngredientView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var amount: Double = 1.0
    @State private var unit: String = "cup"
    
    let onSave: (CustomIngredient) -> Void
    
    let units = ["cup", "tablespoon", "teaspoon", "ounce", "pound", "gram", "kilogram", "milliliter", "liter", "pinch", "piece", "slice", "clove"]
    
    var body: some View {
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
                    let newIngredient = CustomIngredient(name: name, amount: amount, unit: unit)
                    onSave(newIngredient)
                    dismiss()
                }
                .disabled(name.isEmpty)
            }
        }
        .navigationTitle("Add Ingredient")
        .navigationBarItems(leading: Button("Cancel") {
            dismiss()
        })
    }
}

#Preview {
    NavigationView {
        AddIngredientView( onSave: {_ in })
    }
}
