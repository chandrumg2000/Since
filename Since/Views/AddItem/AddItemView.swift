//
//  AddItemView.swift
//  Since
//
//  Add item flow optimized for speed: Name -> Add. Everything else is optional.
//

import SwiftUI
import SwiftData

public struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    public var initialTemplate: ActivityTemplate?
    
    @State private var name: String = ""
    @State private var selectedCategory: ItemCategory = .home
    @State private var iconName: String = "clock.fill"
    
    // Recurrence
    @State private var recurrencePreset: RecurrencePreset = .none
    @State private var customIntervalValue: Int = 1
    @State private var customIntervalUnit: IntervalUnit = .months
    
    // Past completion
    @State private var initialCompletionOption: InitialCompletionOption = .never
    @State private var customCompletionDate: Date = Date()
    
    // Notification
    @State private var notificationEnabled: Bool = false
    @State private var notificationOffset: Int = 0
    
    @FocusState private var isNameFocused: Bool
    
    public init(initialTemplate: ActivityTemplate? = nil) {
        self.initialTemplate = initialTemplate
    }
    
    public enum RecurrencePreset: String, CaseIterable, Identifiable {
        case none = "No schedule"
        case daily = "Every day"
        case weekly = "Every week"
        case monthly = "Every month"
        case threeMonths = "Every 3 months"
        case sixMonths = "Every 6 months"
        case yearly = "Every year"
        case custom = "Custom"
        
        public var id: String { rawValue }
        
        public var interval: (value: Int, unit: IntervalUnit)? {
            switch self {
            case .none: return nil
            case .daily: return (1, .days)
            case .weekly: return (1, .weeks)
            case .monthly: return (1, .months)
            case .threeMonths: return (3, .months)
            case .sixMonths: return (6, .months)
            case .yearly: return (1, .years)
            case .custom: return nil
            }
        }
    }
    
    public enum InitialCompletionOption: String, CaseIterable, Identifiable {
        case never = "Never done"
        case today = "Done today"
        case customDate = "Past date"
        
        public var id: String { rawValue }
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // Section 1: Name and quick templates
                Section {
                    TextField("What do you want to remember?", text: $name)
                        .font(.body)
                        .focused($isNameFocused)
                        .submitLabel(.done)
                } header: {
                    Text("ACTIVITY")
                } footer: {
                    if name.isEmpty {
                        Text("Pick a popular suggestion or type your own.")
                    }
                }
                
                // Popular templates chips
                if name.isEmpty {
                    Section {
                        TemplatePickerView { template in
                            applyTemplate(template)
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        .listRowBackground(Color.clear)
                    } header: {
                        Text("POPULAR")
                    }
                }
                
                // Section 2: Category & Icon
                Section("CATEGORY") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(ItemCategory.allCases) { cat in
                            Label(cat.displayName, systemImage: cat.systemIcon)
                                .tag(cat)
                        }
                    }
                }
                
                // Section 3: Recurrence
                Section("HOW OFTEN?") {
                    Picker("Schedule", selection: $recurrencePreset) {
                        ForEach(RecurrencePreset.allCases) { preset in
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
                
                // Section 4: Initial completion
                Section("LAST COMPLETED") {
                    Picker("Completed", selection: $initialCompletionOption) {
                        ForEach(InitialCompletionOption.allCases) { opt in
                            Text(opt.rawValue).tag(opt)
                        }
                    }
                    
                    if initialCompletionOption == .customDate {
                        DatePicker(
                            "Completion Date",
                            selection: $customCompletionDate,
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                    }
                }
                
                // Section 5: Reminders
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
            .navigationTitle("Add Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        saveItem()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let template = initialTemplate {
                    applyTemplate(template)
                } else {
                    let defaultCat = UserSettings.shared.defaultCategory
                    if let cat = ItemCategory(rawValue: defaultCat) {
                        self.selectedCategory = cat
                        self.iconName = cat.systemIcon
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isNameFocused = true
                    }
                }
            }
        }
    }
    
    private func applyTemplate(_ template: ActivityTemplate) {
        self.name = template.name
        if let cat = ItemCategory(rawValue: template.category) {
            self.selectedCategory = cat
        }
        self.iconName = template.icon
        
        if let val = template.defaultIntervalValue, let unit = template.defaultIntervalUnit {
            if val == 1 && unit == .days { recurrencePreset = .daily }
            else if val == 1 && unit == .weeks { recurrencePreset = .weekly }
            else if val == 1 && unit == .months { recurrencePreset = .monthly }
            else if val == 3 && unit == .months { recurrencePreset = .threeMonths }
            else if val == 6 && unit == .months { recurrencePreset = .sixMonths }
            else if val == 1 && unit == .years { recurrencePreset = .yearly }
            else {
                recurrencePreset = .custom
                customIntervalValue = val
                customIntervalUnit = unit
            }
        } else {
            recurrencePreset = .none
        }
    }
    
    private func saveItem() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        var intervalVal: Int? = nil
        var intervalUnit: IntervalUnit? = nil
        
        if recurrencePreset == .custom {
            intervalVal = customIntervalValue
            intervalUnit = customIntervalUnit
        } else if let preset = recurrencePreset.interval {
            intervalVal = preset.value
            intervalUnit = preset.unit
        }
        
        var initialDate: Date? = nil
        if initialCompletionOption == .today {
            initialDate = Date()
        } else if initialCompletionOption == .customDate {
            initialDate = customCompletionDate
        }
        
        ItemService.shared.createItem(
            name: trimmedName,
            category: selectedCategory.rawValue,
            icon: iconName,
            intervalValue: intervalVal,
            intervalUnit: intervalUnit,
            initialCompletionDate: initialDate,
            notificationEnabled: notificationEnabled,
            notificationOffset: notificationOffset,
            context: modelContext
        )
        
        dismiss()
    }
}
