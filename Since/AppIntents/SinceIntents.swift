//
//  SinceIntents.swift
//  Since
//
//  App Intents providing native Shortcuts and Siri integration for Since.
//

import AppIntents
import SwiftData

// MARK: - TrackedItem Entity for Shortcuts

public struct TrackedItemEntity: AppEntity {
    public static var defaultQuery = TrackedItemQuery()
    
    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "Tracked Activity"
    
    public var id: UUID
    public var name: String
    public var category: String
    
    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(category)")
    }
    
    public init(id: UUID, name: String, category: String) {
        self.id = id
        self.name = name
        self.category = category
    }
}

public struct TrackedItemQuery: EntityQuery {
    public init() {}
    
    @MainActor
    public func entities(for identifiers: [UUID]) async throws -> [TrackedItemEntity] {
        let context = PersistenceService.shared.container.mainContext
        let descriptor = FetchDescriptor<TrackedItem>(
            predicate: #Predicate { identifiers.contains($0.id) }
        )
        let items = (try? context.fetch(descriptor)) ?? []
        return items.map { TrackedItemEntity(id: $0.id, name: $0.name, category: $0.category) }
    }
    
    @MainActor
    public func suggestedEntities() async throws -> [TrackedItemEntity] {
        let context = PersistenceService.shared.container.mainContext
        let descriptor = FetchDescriptor<TrackedItem>(
            predicate: #Predicate { !$0.isArchived }
        )
        let items = (try? context.fetch(descriptor)) ?? []
        return items.map { TrackedItemEntity(id: $0.id, name: $0.name, category: $0.category) }
    }
}

// MARK: - "Mark Activity Done" Intent

public struct MarkActivityDoneIntent: AppIntent {
    public static var title: LocalizedStringResource = "Mark Activity as Done"
    public static var description = IntentDescription("Records completion of an activity right now.")
    
    @Parameter(title: "Activity")
    public var activity: TrackedItemEntity
    
    public init() {}
    
    public init(activity: TrackedItemEntity) {
        self.activity = activity
    }
    
    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = PersistenceService.shared.container.mainContext
        let targetId = activity.id
        let descriptor = FetchDescriptor<TrackedItem>(
            predicate: #Predicate { $0.id == targetId }
        )
        
        guard let item = (try? context.fetch(descriptor))?.first else {
            return .result(dialog: "Could not find \(activity.name) in Since.")
        }
        
        ItemService.shared.markDone(item: item, context: context)
        return .result(dialog: "Marked \(item.name) as done.")
    }
}

// MARK: - "When Did I Last..." Intent

public struct WhenDidILastIntent: AppIntent {
    public static var title: LocalizedStringResource = "When Did I Last Do This"
    public static var description = IntentDescription("Checks when you last completed an activity.")
    
    @Parameter(title: "Activity")
    public var activity: TrackedItemEntity
    
    public init() {}
    
    public init(activity: TrackedItemEntity) {
        self.activity = activity
    }
    
    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let context = PersistenceService.shared.container.mainContext
        let targetId = activity.id
        let descriptor = FetchDescriptor<TrackedItem>(
            predicate: #Predicate { $0.id == targetId }
        )
        
        guard let item = (try? context.fetch(descriptor))?.first else {
            return .result(dialog: "Could not find \(activity.name) in Since.")
        }
        
        let elapsed = DateCalculationService.timeElapsedString(from: item.lastCompletedAt)
        return .result(dialog: "You last did \(item.name) \(elapsed).")
    }
}
