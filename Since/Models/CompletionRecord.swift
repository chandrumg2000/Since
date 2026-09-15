//
//  CompletionRecord.swift
//  Since
//
//  SwiftData model representing a historical completion of an activity.
//

import Foundation
import SwiftData

@Model
public final class CompletionRecord: Identifiable {
    public var id: UUID = UUID()
    public var completedAt: Date = Date()
    public var note: String?
    
    @Relationship(inverse: \TrackedItem.history)
    public var item: TrackedItem?
    
    public init(id: UUID = UUID(), completedAt: Date = Date(), note: String? = nil, item: TrackedItem? = nil) {
        self.id = id
        self.completedAt = completedAt
        self.note = note
        self.item = item
    }
}

extension CompletionRecord: Hashable {
    public static func == (lhs: CompletionRecord, rhs: CompletionRecord) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

