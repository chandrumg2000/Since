//
//  ItemService.swift
//  Since
//
//  Coordinates domain business actions: marking complete, archiving, deleting,
//  re-evaluating dates, dispatching haptics, and reloading widget timelines.
//

import SwiftUI
import SwiftData
import WidgetKit

@MainActor
public final class ItemService {
    public static let shared = ItemService()
    
    private init() {}
    
    // MARK: - Mark Done ("Done Now")
    
    /// Records an activity completion at the given date (defaults to current timestamp).
    @discardableResult
    public func markDone(
        item: TrackedItem,
        completedAt: Date = Date(),
        note: String? = nil,
        context: ModelContext
    ) -> CompletionRecord {
        let record = CompletionRecord(completedAt: completedAt, note: note, item: item)
        context.insert(record)
        item.history.append(record)
        
        // Re-evaluate lastCompletedAt based on the latest record in history
        updateLastCompletedAt(for: item)
        
        try? context.save()
        
        // Haptic feedback
        if UserSettings.shared.hapticsEnabled {
            let feedback = UIImpactFeedbackGenerator(style: .medium)
            feedback.prepare()
            feedback.impactOccurred()
        }
        
        // Reschedule notification
        NotificationService.shared.scheduleNotification(for: item)
        
        // Update widgets
        reloadWidgets()
        
        return record
    }
    
    // MARK: - History Management
    
    /// Deletes a specific completion record and recalculates item's lastCompletedAt.
    public func deleteCompletionRecord(
        _ record: CompletionRecord,
        from item: TrackedItem,
        context: ModelContext
    ) {
        if let index = item.history.firstIndex(where: { $0.id == record.id }) {
            item.history.remove(at: index)
        }
        context.delete(record)
        
        updateLastCompletedAt(for: item)
        try? context.save()
        
        NotificationService.shared.scheduleNotification(for: item)
        reloadWidgets()
    }
    
    /// Updates note or completion timestamp of an existing record.
    public func updateCompletionRecord(
        _ record: CompletionRecord,
        for item: TrackedItem,
        completedAt: Date,
        note: String?,
        context: ModelContext
    ) {
        record.completedAt = completedAt
        record.note = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        updateLastCompletedAt(for: item)
        try? context.save()
        
        NotificationService.shared.scheduleNotification(for: item)
        reloadWidgets()
    }
    
    // MARK: - Item Lifecycle
    
    /// Creates a new tracked item.
    @discardableResult
    public func createItem(
        name: String,
        category: String,
        icon: String,
        intervalValue: Int?,
        intervalUnit: IntervalUnit?,
        initialCompletionDate: Date? = nil,
        notificationEnabled: Bool = false,
        notificationOffset: Int = 0,
        context: ModelContext
    ) -> TrackedItem {
        let item = TrackedItem(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            icon: icon,
            createdAt: Date(),
            lastCompletedAt: initialCompletionDate,
            intervalValue: intervalValue,
            intervalUnit: intervalUnit,
            notificationEnabled: notificationEnabled,
            notificationOffset: notificationOffset
        )
        
        context.insert(item)
        
        if let initialDate = initialCompletionDate {
            let initialRecord = CompletionRecord(completedAt: initialDate, note: "Initial record", item: item)
            context.insert(initialRecord)
            item.history.append(initialRecord)
        }
        
        try? context.save()
        
        if notificationEnabled {
            NotificationService.shared.scheduleNotification(for: item)
        }
        
        reloadWidgets()
        return item
    }
    
    /// Updates an existing item's metadata and recurrence.
    public func updateItem(
        item: TrackedItem,
        name: String,
        category: String,
        icon: String,
        intervalValue: Int?,
        intervalUnit: IntervalUnit?,
        notificationEnabled: Bool,
        notificationOffset: Int,
        context: ModelContext
    ) {
        item.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        item.category = category
        item.icon = icon
        item.intervalValue = intervalValue
        item.intervalUnit = intervalUnit
        item.notificationEnabled = notificationEnabled
        item.notificationOffset = notificationOffset
        
        try? context.save()
        
        if notificationEnabled {
            NotificationService.shared.scheduleNotification(for: item)
        } else {
            NotificationService.shared.cancelNotification(for: item)
        }
        
        reloadWidgets()
    }
    
    /// Archives an item. Cancels active notifications.
    public func archiveItem(_ item: TrackedItem, context: ModelContext) {
        item.isArchived = true
        NotificationService.shared.cancelNotification(for: item)
        try? context.save()
        reloadWidgets()
    }
    
    /// Restores an archived item.
    public func restoreItem(_ item: TrackedItem, context: ModelContext) {
        item.isArchived = false
        if item.notificationEnabled {
            NotificationService.shared.scheduleNotification(for: item)
        }
        try? context.save()
        reloadWidgets()
    }
    
    /// Permanently deletes an item and all its historical records.
    public func deleteItem(_ item: TrackedItem, context: ModelContext) {
        NotificationService.shared.cancelNotification(for: item)
        
        // Haptic feedback for deletion
        if UserSettings.shared.hapticsEnabled {
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.warning)
        }
        
        context.delete(item)
        try? context.save()
        reloadWidgets()
    }
    
    // MARK: - Private Helpers
    
    private func updateLastCompletedAt(for item: TrackedItem) {
        let latestDate = item.history.map(\.completedAt).max()
        item.lastCompletedAt = latestDate
    }
    
    private func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
