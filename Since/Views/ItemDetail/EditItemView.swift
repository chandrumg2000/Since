//
//  EditItemView.swift
//  Since
//
//  Allows editing activity name, schedule, category, and notification preferences.
//

import SwiftUI
import SwiftData

public struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    public let item: TrackedItem
    
    @State private var name: String
    @State private var selectedCategory: ItemCategory
    @State private var iconName: String
    
    // Recurrence
    @State private var recurrencePreset: AddItemView.RecurrencePreset
    @State private var customIntervalValue: Int
    @State private var customIntervalUnit: IntervalUnit
    
    // Notifications
    @State private var notificationEnabled: Bool
    @State private var notificationOffset: Int
    
    public init(item: TrackedItem) {
        self.item = item
        _name = State(initialValue: item.name)
        _selectedCategory = State(initialValue: ItemCategory(rawValue: item.category) ?? .home)
        _iconName = State(initialValue: item.icon)
        
        let val = item.intervalValue
        let unit = item.intervalUnit
        
        if val == nil || unit == nil {
            _recurrencePreset = State(initialValue: .none)
            _customIntervalValue = State(initialValue: 1)
            _customIntervalUnit = State(initialValue: .months)
        } else if val == 1 && unit == .days {
            _recurrencePreset = State(initialValue: .daily)
            _customIntervalValue = State(initialValue: 1)
            _customIntervalUnit = State(initialValue: .days)
        } else if val == 1 && unit == .weeks {
            _recurrencePreset = State(initialValue: .weekly)
            _customIntervalValue = State(initialValue: 1)
            _customIntervalUnit = State(initialValue: .weeks)
        } else if val == 1 && unit == .months {
            _recurrencePreset = State(initialValue: .monthly)
            _customIntervalValue = State(initialValue: 1)
            _customIntervalUnit = State(initialValue: .months)
        } else if val == 3 && unit == .months {
            _recurrencePreset = State(initialValue: .threeMonths)
            _customIntervalValue = State(initialValue: 3)
            _customIntervalUnit = State(initialValue: .months)
        } else if val == 6 && unit == .months {
            _recurrencePreset = State(initialValue: .sixMonths)
            _customIntervalValue = State(initialValue: 6)
            _customIntervalUnit = State(initialValue: .months)
        } else if val == 1 && unit == .years {
            _recurrencePreset = State(initialValue: .yearly)
            _customIntervalValue = State(initialValue: 1)
            _customIntervalUnit = State(initialValue: .years)
        } else {
            _recurrencePreset = State(initialValue: .custom)
            _customIntervalValue = State(initialValue: val ?? 1)
            _customIntervalUnit = State(initialValue: unit ?? .months)
        }
        
        _notificationEnabled = State(initialValue: item.notificationEnabled)
        _notificationOffset = State(initialValue: item.notificationOffset ?? 0)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("NAME") {
                    TextField("Activity Name", text: $name)
                }
                
                Section("CATEGORY") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ItemCategory.allCases) { cat in
                            Label(cat.displayName, systemImage: cat.systemIcon)
                                .tag(cat)
                        }
                    }
                    .onChange(of: selectedCategory) { _, newCat in
                        self.iconName = newCat.systemIcon
                    }
                }
                
                Section("HOW OFTEN?") {
                    Picker("Schedule", selection: $recurrencePreset) {
                        ForEach(AddItemView.RecurrencePreset.allCases) { preset in
                            Text(preset.rawValue).tag(preset)
                        }
                    }
                    
                    if recurrencePreset == .custom {
                        HStack {
                            Text("Every")
                            Spacer()
                            Picker("Value", selection: $customIntervalValue) {
                                ForEach(1...100, id: \.self) { val in
                                    Text("\(val)").tag(val)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80, height: 100)
                            .clipped()
                            
                            Picker("Unit", selection: $customIntervalUnit) {
                                ForEach(IntervalUnit.allCases) { unit in
                                    Text(unit.pluralDisplayName).tag(unit)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 110, height: 100)
                            .clipped()
                        }
                    }
                }
                
                if recurrencePreset != .none {
                    Section("NOTIFICATIONS") {
                        Toggle("Remind Me", isOn: $notificationEnabled)
                            .onChange(of: notificationEnabled) { _, newValue in
                                if newValue {
                                    Task {
                                        _ = await NotificationService.shared.requestAuthorization()
                                    }
                                }
                            }
                        
                        if notificationEnabled {
                            Picker("Timing", selection: $notificationOffset) {
                                Text("On due date").tag(0)
                                Text("1 day before").tag(1)
                                Text("3 days before").tag(3)
                                Text("7 days before").tag(7)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        var intervalVal: Int? = nil
        var intervalUnit: IntervalUnit? = nil
        
        if recurrencePreset == .custom {
            intervalVal = customIntervalValue
            intervalUnit = customIntervalUnit
        } else if let preset = recurrencePreset.interval {
            intervalVal = preset.value
            intervalUnit = preset.unit
        }
        
        ItemService.shared.updateItem(
            item: item,
            name: name,
            category: selectedCategory.rawValue,
            icon: iconName,
            intervalValue: intervalVal,
            intervalUnit: intervalUnit,
            notificationEnabled: notificationEnabled,
            notificationOffset: notificationOffset,
            context: modelContext
        )
        
        dismiss()
    }
}
