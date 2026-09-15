//
//  Category.swift
//  Since
//
//  Predefined activity categories and templates.
//

import SwiftUI

public struct ActivityTemplate: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let category: String
    public let icon: String
    public let defaultIntervalValue: Int?
    public let defaultIntervalUnit: IntervalUnit?
    
    public init(name: String, category: String, icon: String, defaultIntervalValue: Int? = nil, defaultIntervalUnit: IntervalUnit? = nil) {
        self.id = "\(category)_\(name)"
        self.name = name
        self.category = category
        self.icon = icon
        self.defaultIntervalValue = defaultIntervalValue
        self.defaultIntervalUnit = defaultIntervalUnit
    }
}

public enum ItemCategory: String, CaseIterable, Identifiable, Codable {
    case home = "Home"
    case car = "Car"
    case personal = "Personal"
    case technology = "Technology"
    case documents = "Documents"
    case custom = "Custom"
    
    public var id: String { rawValue }
    public var displayName: String { rawValue }
    
    public var systemIcon: String {
        switch self {
        case .home: return "house.fill"
        case .car: return "car.fill"
        case .personal: return "person.fill"
        case .technology: return "laptopcomputer"
        case .documents: return "doc.text.fill"
        case .custom: return "sparkles"
        }
    }
    
    public var accentColor: Color {
        switch self {
        case .home: return Color.blue
        case .car: return Color.indigo
        case .personal: return Color.teal
        case .technology: return Color.purple
        case .documents: return Color.orange
        case .custom: return Color.secondary
        }
    }
    
    public static var popularTemplates: [ActivityTemplate] {
        [
            ActivityTemplate(name: "Car Service", category: ItemCategory.car.rawValue, icon: "car.fill", defaultIntervalValue: 6, defaultIntervalUnit: .months),
            ActivityTemplate(name: "AC Filter", category: ItemCategory.home.rawValue, icon: "air.conditioner.horizontal.fill", defaultIntervalValue: 3, defaultIntervalUnit: .months),
            ActivityTemplate(name: "Toothbrush", category: ItemCategory.personal.rawValue, icon: "mouth.fill", defaultIntervalValue: 3, defaultIntervalUnit: .months),
            ActivityTemplate(name: "Haircut", category: ItemCategory.personal.rawValue, icon: "scissors", defaultIntervalValue: 4, defaultIntervalUnit: .weeks),
            ActivityTemplate(name: "Bedsheets", category: ItemCategory.home.rawValue, icon: "bed.double.fill", defaultIntervalValue: 2, defaultIntervalUnit: .weeks),
            ActivityTemplate(name: "Water Filter", category: ItemCategory.home.rawValue, icon: "drop.fill", defaultIntervalValue: 6, defaultIntervalUnit: .months),
            ActivityTemplate(name: "Laptop Backup", category: ItemCategory.technology.rawValue, icon: "externaldrive.fill", defaultIntervalValue: 1, defaultIntervalUnit: .months),
            ActivityTemplate(name: "Tyre Pressure", category: ItemCategory.car.rawValue, icon: "gauge.with.dots.needle.bottom.50percent", defaultIntervalValue: 1, defaultIntervalUnit: .months)
        ]
    }
    
    public var templates: [ActivityTemplate] {
        switch self {
        case .home:
            return [
                ActivityTemplate(name: "AC Filter", category: rawValue, icon: "air.conditioner.horizontal.fill", defaultIntervalValue: 3, defaultIntervalUnit: .months),
                ActivityTemplate(name: "Water Filter", category: rawValue, icon: "drop.fill", defaultIntervalValue: 6, defaultIntervalUnit: .months),
                ActivityTemplate(name: "Bedsheets", category: rawValue, icon: "bed.double.fill", defaultIntervalValue: 2, defaultIntervalUnit: .weeks),
                ActivityTemplate(name: "Deep Cleaning", category: rawValue, icon: "sparkles", defaultIntervalValue: 1, defaultIntervalUnit: .months),
                ActivityTemplate(name: "Refrigerator Cleaning", category: rawValue, icon: "refrigerator.fill", defaultIntervalValue: 3, defaultIntervalUnit: .months),
                ActivityTemplate(name: "Washing Machine Cleaning", category: rawValue, icon: "washer.fill", defaultIntervalValue: 3, defaultIntervalUnit: .months)
            ]
        case .car:
            return [
                ActivityTemplate(name: "Car Service", category: rawValue, icon: "car.fill", defaultIntervalValue: 6, defaultIntervalUnit: .months),
                ActivityTemplate(name: "Car Wash", category: rawValue, icon: "car.side.front.open.fill", defaultIntervalValue: 2, defaultIntervalUnit: .weeks),
                ActivityTemplate(name: "Oil Change", category: rawValue, icon: "fuelpump.fill", defaultIntervalValue: 6, defaultIntervalUnit: .months),
                ActivityTemplate(name: "Tyre Pressure", category: rawValue, icon: "gauge.with.dots.needle.bottom.50percent", defaultIntervalValue: 1, defaultIntervalUnit: .months),
                ActivityTemplate(name: "Vehicle Inspection", category: rawValue, icon: "checklist", defaultIntervalValue: 1, defaultIntervalUnit: .years)
            ]
        case .personal:
            return [
                ActivityTemplate(name: "Haircut", category: rawValue, icon: "scissors", defaultIntervalValue: 4, defaultIntervalUnit: .weeks),
                ActivityTemplate(name: "Toothbrush", category: rawValue, icon: "mouth.fill", defaultIntervalValue: 3, defaultIntervalUnit: .months),
                ActivityTemplate(name: "Skincare", category: rawValue, icon: "face.smiling.inverse", defaultIntervalValue: 1, defaultIntervalUnit: .weeks),
                ActivityTemplate(name: "Grooming", category: rawValue, icon: "comb.fill", defaultIntervalValue: 2, defaultIntervalUnit: .weeks),
                ActivityTemplate(name: "Contact Lenses", category: rawValue, icon: "eye.fill", defaultIntervalValue: 1, defaultIntervalUnit: .months)
            ]
        case .technology:
            return [
                ActivityTemplate(name: "Phone Backup", category: rawValue, icon: "iphone", defaultIntervalValue: 1, defaultIntervalUnit: .months),
                ActivityTemplate(name: "Laptop Backup", category: rawValue, icon: "laptopcomputer", defaultIntervalValue: 1, defaultIntervalUnit: .months),
                ActivityTemplate(name: "Device Cleaning", category: rawValue, icon: "sparkles", defaultIntervalValue: 2, defaultIntervalUnit: .weeks)
            ]
        case .documents:
            return [
                ActivityTemplate(name: "Passport Renewal", category: rawValue, icon: "person.crop.square.fill", defaultIntervalValue: 10, defaultIntervalUnit: .years),
                ActivityTemplate(name: "Driving Licence", category: rawValue, icon: "car.circle.fill", defaultIntervalValue: 5, defaultIntervalUnit: .years),
                ActivityTemplate(name: "Insurance", category: rawValue, icon: "shield.lefthalf.filled", defaultIntervalValue: 1, defaultIntervalUnit: .years),
                ActivityTemplate(name: "Vehicle Documents", category: rawValue, icon: "doc.plaintext.fill", defaultIntervalValue: 1, defaultIntervalUnit: .years)
            ]
        case .custom:
            return []
        }
    }
}
