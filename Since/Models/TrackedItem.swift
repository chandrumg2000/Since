//
//  TrackedItem.swift
//  Since
//
//  SwiftData model representing an activity to remember.
//

import Foundation
import SwiftData

@Model
public final class TrackedItem: Identifiable {
    public var id: UUID = UUID()
    public var name: String = ""
    public var category: String = "Home"
    public var icon: String = "clock.fill"
    public var createdAt: Date = Date()
    public var lastCompletedAt: Date?
    public var intervalValue: Int?
    public var intervalUnitRaw: String?
    public var notificationEnabled: Bool = false
    public var notificationOffset: Int? = 0 // 0 = on due date, 1 = 1 day before, etc.
    public var isArchived: Bool = false
    public var sortOrder: Int = 0
    
    @Relationship(deleteRule: .cascade)
    public var history: [CompletionRecord] = []
    
    public init(
        id: UUID = UUID(),
        name: String,
        category: String = "Home",
        icon: String = "clock.fill",
        createdAt: Date = Date(),
        lastCompletedAt: Date? = nil,
        intervalValue: Int? = nil,
        intervalUnit: IntervalUnit? = nil,
        notificationEnabled: Bool = false,
        notificationOffset: Int? = 0,
        isArchived: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.icon = icon
        self.createdAt = createdAt
        self.lastCompletedAt = lastCompletedAt
        self.intervalValue = intervalValue
        self.intervalUnitRaw = intervalUnit?.rawValue
        self.notificationEnabled = notificationEnabled
        self.notificationOffset = notificationOffset
        self.isArchived = isArchived
        self.sortOrder = sortOrder
        self.history = []
    }
    
    public var intervalUnit: IntervalUnit? {
        get {
            guard let raw = intervalUnitRaw else { return nil }
            return IntervalUnit(rawValue: raw)
        }
        set {
            intervalUnitRaw = newValue?.rawValue
        }
    }
    
    public var hasSchedule: Bool {
        intervalValue != nil && intervalUnit != nil
    }
    
    public var recurrenceDisplayText: String {
        guard let val = intervalValue, let unit = intervalUnit else {
            return "No schedule"
        }
        return unit.formatted(for: val)
    }
    
    public var sortedHistory: [CompletionRecord] {
        history.sorted { $0.completedAt > $1.completedAt }
    }
}

extension TrackedItem: Hashable {
    public static func == (lhs: TrackedItem, rhs: TrackedItem) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
