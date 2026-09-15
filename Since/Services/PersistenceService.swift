//
//  PersistenceService.swift
//  Since
//
//  SwiftData container management supporting App Groups for WidgetKit sharing,
//  with seamless local fallback and in-memory test configurations.
//

import Foundation
import SwiftData

public final class PersistenceService {
    public static let shared = PersistenceService()
    public static let appGroupIdentifier = "group.com.since.app"
    
    public let container: ModelContainer
    
    public init(inMemory: Bool = false) {
        let schema = Schema([
            TrackedItem.self,
            CompletionRecord.self
        ])
        
        if inMemory {
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Failed to initialize in-memory ModelContainer: \(error.localizedDescription)")
            }
            return
        }
        
        // Attempt App Group directory first for widget sharing
        var storeURL: URL?
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Self.appGroupIdentifier) {
            storeURL = groupURL.appendingPathComponent("SinceShared.sqlite")
        }
        
        if let storeURL = storeURL {
            let modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
            do {
                self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                return
            } catch {
                print("App Group storage unavailable, falling back to local storage: \(error.localizedDescription)")
            }
        }
        
        // Default local storage fallback
        let defaultConfig = ModelConfiguration(schema: schema)
        do {
            self.container = try ModelContainer(for: schema, configurations: [defaultConfig])
        } catch {
            fatalError("Failed to initialize persistent ModelContainer: \(error.localizedDescription)")
        }
    }
    
    public static var previewContainer: ModelContainer = {
        let service = PersistenceService(inMemory: true)
        let context = service.container.mainContext
        
        // Populate sample data for SwiftUI Previews
        let calendar = Calendar.current
        let today = Date()
        
        let carService = TrackedItem(
            name: "Car Service",
            category: ItemCategory.car.rawValue,
            icon: "car.fill",
            createdAt: calendar.date(byAdding: .day, value: -200, to: today)!,
            lastCompletedAt: calendar.date(byAdding: .day, value: -43, to: today)!,
            intervalValue: 6,
            intervalUnit: .months,
            notificationEnabled: true
        )
        
        let acFilter = TrackedItem(
            name: "AC Filter",
            category: ItemCategory.home.rawValue,
            icon: "air.conditioner.horizontal.fill",
            createdAt: calendar.date(byAdding: .day, value: -300, to: today)!,
            lastCompletedAt: calendar.date(byAdding: .day, value: -127, to: today)!,
            intervalValue: 3,
            intervalUnit: .months,
            notificationEnabled: true
        )
        
        let toothbrush = TrackedItem(
            name: "Toothbrush",
            category: ItemCategory.personal.rawValue,
            icon: "mouth.fill",
            createdAt: calendar.date(byAdding: .day, value: -100, to: today)!,
            lastCompletedAt: calendar.date(byAdding: .day, value: -84, to: today)!,
            intervalValue: 3,
            intervalUnit: .months
        )
        
        let haircut = TrackedItem(
            name: "Haircut",
            category: ItemCategory.personal.rawValue,
            icon: "scissors",
            createdAt: calendar.date(byAdding: .day, value: -60, to: today)!,
            lastCompletedAt: calendar.date(byAdding: .day, value: -21, to: today)!
        )
        
        let bedsheets = TrackedItem(
            name: "Bedsheets",
            category: ItemCategory.home.rawValue,
            icon: "bed.double.fill",
            createdAt: calendar.date(byAdding: .day, value: -30, to: today)!,
            lastCompletedAt: calendar.date(byAdding: .day, value: -2, to: today)!,
            intervalValue: 2,
            intervalUnit: .weeks
        )
        
        context.insert(carService)
        context.insert(acFilter)
        context.insert(toothbrush)
        context.insert(haircut)
        context.insert(bedsheets)
        
        // Add sample history records
        let carHistory1 = CompletionRecord(
            completedAt: calendar.date(byAdding: .day, value: -43, to: today)!,
            note: "Hyundai Service Center - 40,000 km check",
            item: carService
        )
        let carHistory2 = CompletionRecord(
            completedAt: calendar.date(byAdding: .day, value: -220, to: today)!,
            note: "Oil change and tire rotation",
            item: carService
        )
        context.insert(carHistory1)
        context.insert(carHistory2)
        
        try? context.save()
        return service.container
    }()
}
