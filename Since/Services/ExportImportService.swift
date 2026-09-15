//
//  ExportImportService.swift
//  Since
//
//  Handles local-first JSON backup export and restore.
//

import Foundation
import SwiftData

public struct SinceExportData: Codable {
    public let version: Int
    public let exportedAt: Date
    public let items: [ExportedItem]
    
    public init(version: Int = 1, exportedAt: Date = Date(), items: [ExportedItem]) {
        self.version = version
        self.exportedAt = exportedAt
        self.items = items
    }
}

public struct ExportedItem: Codable {
    public let id: UUID
    public let name: String
    public let category: String
    public let icon: String
    public let createdAt: Date
    public let lastCompletedAt: Date?
    public let intervalValue: Int?
    public let intervalUnit: String?
    public let notificationEnabled: Bool
    public let notificationOffset: Int?
    public let isArchived: Bool
    public let sortOrder: Int
    public let history: [ExportedRecord]
    
    public init(
        id: UUID,
        name: String,
        category: String,
        icon: String,
        createdAt: Date,
        lastCompletedAt: Date?,
        intervalValue: Int?,
        intervalUnit: String?,
        notificationEnabled: Bool,
        notificationOffset: Int?,
        isArchived: Bool,
        sortOrder: Int,
        history: [ExportedRecord]
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.icon = icon
        self.createdAt = createdAt
        self.lastCompletedAt = lastCompletedAt
        self.intervalValue = intervalValue
        self.intervalUnit = intervalUnit
        self.notificationEnabled = notificationEnabled
        self.notificationOffset = notificationOffset
        self.isArchived = isArchived
        self.sortOrder = sortOrder
        self.history = history
    }
}

public struct ExportedRecord: Codable {
    public let id: UUID
    public let completedAt: Date
    public let note: String?
    
    public init(id: UUID, completedAt: Date, note: String?) {
        self.id = id
        self.completedAt = completedAt
        self.note = note
    }
}

public final class ExportImportService {
    public static let shared = ExportImportService()
    
    private init() {}
    
    private var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    
    private var jsonDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
    
    // MARK: - Export
    
    public func exportData(items: [TrackedItem]) throws -> Data {
        let exportedItems = items.map { item in
            ExportedItem(
                id: item.id,
                name: item.name,
                category: item.category,
                icon: item.icon,
                createdAt: item.createdAt,
                lastCompletedAt: item.lastCompletedAt,
                intervalValue: item.intervalValue,
                intervalUnit: item.intervalUnit?.rawValue,
                notificationEnabled: item.notificationEnabled,
                notificationOffset: item.notificationOffset,
                isArchived: item.isArchived,
                sortOrder: item.sortOrder,
                history: item.history.map {
                    ExportedRecord(id: $0.id, completedAt: $0.completedAt, note: $0.note)
                }
            )
        }
        
        let exportPayload = SinceExportData(items: exportedItems)
        return try jsonEncoder.encode(exportPayload)
    }
    
    public func createExportFileURL(from data: Data) throws -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let timestamp = formatter.string(from: Date())
        let filename = "Since_Backup_\(timestamp).json"
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try data.write(to: tempURL)
        return tempURL
    }
    
    // MARK: - Import
    
    @MainActor
    public func importData(from data: Data, context: ModelContext) throws -> Int {
        let backup = try jsonDecoder.decode(SinceExportData.self, from: data)
        var importedCount = 0
        
        for itemDTO in backup.items {
            let item = TrackedItem(
                id: itemDTO.id,
                name: itemDTO.name,
                category: itemDTO.category,
                icon: itemDTO.icon,
                createdAt: itemDTO.createdAt,
                lastCompletedAt: itemDTO.lastCompletedAt,
                intervalValue: itemDTO.intervalValue,
                intervalUnit: itemDTO.intervalUnit != nil ? IntervalUnit(rawValue: itemDTO.intervalUnit!) : nil,
                notificationEnabled: itemDTO.notificationEnabled,
                notificationOffset: itemDTO.notificationOffset ?? 0,
                isArchived: itemDTO.isArchived,
                sortOrder: itemDTO.sortOrder
            )
            
            context.insert(item)
            
            for recDTO in itemDTO.history {
                let record = CompletionRecord(
                    id: recDTO.id,
                    completedAt: recDTO.completedAt,
                    note: recDTO.note,
                    item: item
                )
                context.insert(record)
                item.history.append(record)
            }
            
            importedCount += 1
        }
        
        try context.save()
        return importedCount
    }
}
