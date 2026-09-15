//
//  SinceWidgetProvider.swift
//  SinceWidget
//
//  Timeline provider loading tracked activities for Home Screen and Lock Screen widgets.
//

import WidgetKit
import SwiftUI
import SwiftData

public struct WidgetItemSnapshot: Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let category: String
    public let icon: String
    public let elapsedText: String
    public let compactElapsedText: String
    public let statusText: String?
    public let isOverdue: Bool
    public let deepLinkURL: URL
    
    public init(
        id: UUID,
        name: String,
        category: String,
        icon: String,
        elapsedText: String,
        compactElapsedText: String,
        statusText: String?,
        isOverdue: Bool
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.icon = icon
        self.elapsedText = elapsedText
        self.compactElapsedText = compactElapsedText
        self.statusText = statusText
        self.isOverdue = isOverdue
        self.deepLinkURL = URL(string: "since://item/\(id.uuidString)")!
    }
}

public struct SinceWidgetEntry: TimelineEntry {
    public let date: Date
    public let items: [WidgetItemSnapshot]
    
    public init(date: Date, items: [WidgetItemSnapshot]) {
        self.date = date
        self.items = items
    }
    
    public static var placeholder: SinceWidgetEntry {
        SinceWidgetEntry(
            date: Date(),
            items: [
                WidgetItemSnapshot(
                    id: UUID(),
                    name: "AC Filter",
                    category: "Home",
                    icon: "air.conditioner.horizontal.fill",
                    elapsedText: "127 days ago",
                    compactElapsedText: "127d",
                    statusText: "37d over",
                    isOverdue: true
                ),
                WidgetItemSnapshot(
                    id: UUID(),
                    name: "Car Service",
                    category: "Car",
                    icon: "car.fill",
                    elapsedText: "43 days ago",
                    compactElapsedText: "43d",
                    statusText: "in 137d",
                    isOverdue: false
                ),
                WidgetItemSnapshot(
                    id: UUID(),
                    name: "Haircut",
                    category: "Personal",
                    icon: "scissors",
                    elapsedText: "21 days ago",
                    compactElapsedText: "21d",
                    statusText: nil,
                    isOverdue: false
                ),
                WidgetItemSnapshot(
                    id: UUID(),
                    name: "Bedsheets",
                    category: "Home",
                    icon: "bed.double.fill",
                    elapsedText: "5 days ago",
                    compactElapsedText: "5d",
                    statusText: "in 9d",
                    isOverdue: false
                )
            ]
        )
    }
}

public struct SinceTimelineProvider: TimelineProvider {
    public typealias Entry = SinceWidgetEntry
    
    public func placeholder(in context: Context) -> SinceWidgetEntry {
        SinceWidgetEntry.placeholder
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (SinceWidgetEntry) -> Void) {
        Task { @MainActor in
            let items = fetchWidgetItems()
            let entry = SinceWidgetEntry(date: Date(), items: items.isEmpty ? SinceWidgetEntry.placeholder.items : items)
            completion(entry)
        }
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<SinceWidgetEntry>) -> Void) {
        Task { @MainActor in
            let items = fetchWidgetItems()
            let currentDate = Date()
            let entry = SinceWidgetEntry(date: currentDate, items: items.isEmpty ? SinceWidgetEntry.placeholder.items : items)
            
            // Refresh every 1 hour or when midnight passes
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate.addingTimeInterval(3600)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }
    
    @MainActor
    private func fetchWidgetItems() -> [WidgetItemSnapshot] {
        let persistence = PersistenceService.shared
        let context = persistence.container.mainContext
        
        var descriptor = FetchDescriptor<TrackedItem>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.lastCompletedAt, order: .forward)]
        )
        descriptor.fetchLimit = 10
        
        guard let items = try? context.fetch(descriptor) else {
            return []
        }
        
        return items.map { item in
            let status = DateCalculationService.status(
                lastCompletedAt: item.lastCompletedAt,
                createdAt: item.createdAt,
                intervalValue: item.intervalValue,
                intervalUnit: item.intervalUnit
            )
            
            var isOverdue = false
            var statusText: String? = nil
            
            switch status {
            case .overdue(let days):
                isOverdue = true
                statusText = "\(days)d over"
            case .dueToday:
                statusText = "today"
            case .dueSoon(let days):
                statusText = "in \(days)d"
            case .healthy(let days):
                statusText = "in \(days)d"
            case .noSchedule:
                statusText = nil
            }
            
            return WidgetItemSnapshot(
                id: item.id,
                name: item.name,
                category: item.category,
                icon: item.icon,
                elapsedText: DateCalculationService.timeElapsedString(from: item.lastCompletedAt ?? item.createdAt),
                compactElapsedText: DateCalculationService.compactTimeElapsedString(from: item.lastCompletedAt ?? item.createdAt),
                statusText: statusText,
                isOverdue: isOverdue
            )
        }
    }
}
