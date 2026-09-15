//
//  ExportImportTests.swift
//  SinceTests
//
//  Unit tests covering JSON serialization, export formatting, and backup restoration.
//

import XCTest
import SwiftData
@testable import Since

@MainActor
final class ExportImportTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    
    override func setUp() {
        super.setUp()
        let schema = Schema([TrackedItem.self, CompletionRecord.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        self.container = try! ModelContainer(for: schema, configurations: [config])
        self.context = container.mainContext
    }
    
    override func tearDown() {
        container = nil
        context = nil
        super.tearDown()
    }
    
    func testExportAndImportRoundTrip() throws {
        // 1. Create test items with completion records
        let item1 = ItemService.shared.createItem(
            name: "Car Service",
            category: "Car",
            icon: "car.fill",
            intervalValue: 6,
            intervalUnit: .months,
            initialCompletionDate: nil,
            notificationEnabled: true,
            notificationOffset: 3,
            context: context
        )
        
        let recordDate = Date().addingTimeInterval(-86400 * 43)
        _ = ItemService.shared.markDone(
            item: item1,
            completedAt: recordDate,
            note: "Hyundai regular checkup",
            context: context
        )
        
        let item2 = ItemService.shared.createItem(
            name: "Haircut",
            category: "Personal",
            icon: "scissors",
            intervalValue: nil,
            intervalUnit: nil,
            initialCompletionDate: nil,
            context: context
        )
        
        let items = [item1, item2]
        
        // 2. Export to JSON data
        let exportData = try ExportImportService.shared.exportData(items: items)
        XCTAssertFalse(exportData.isEmpty)
        
        // Validate JSON string
        let jsonString = String(data: exportData, encoding: .utf8)!
        XCTAssertTrue(jsonString.contains("Car Service"))
        XCTAssertTrue(jsonString.contains("Hyundai regular checkup"))
        XCTAssertTrue(jsonString.contains("Haircut"))
        
        // 3. Create a clean secondary container to test import
        let newSchema = Schema([TrackedItem.self, CompletionRecord.self])
        let newConfig = ModelConfiguration(isStoredInMemoryOnly: true)
        let newContainer = try ModelContainer(for: newSchema, configurations: [newConfig])
        let newContext = newContainer.mainContext
        
        // 4. Import the data
        let importedCount = try ExportImportService.shared.importData(from: exportData, context: newContext)
        XCTAssertEqual(importedCount, 2)
        
        // 5. Query and verify the restored entities
        let descriptor = FetchDescriptor<TrackedItem>(sortBy: [SortDescriptor(\.name)])
        let restoredItems = try newContext.fetch(descriptor)
        
        XCTAssertEqual(restoredItems.count, 2)
        
        let restoredCar = restoredItems.first(where: { $0.name == "Car Service" })!
        XCTAssertEqual(restoredCar.category, "Car")
        XCTAssertEqual(restoredCar.intervalValue, 6)
        XCTAssertEqual(restoredCar.intervalUnit, .months)
        XCTAssertEqual(restoredCar.notificationEnabled, true)
        XCTAssertEqual(restoredCar.notificationOffset, 3)
        XCTAssertEqual(restoredCar.history.count, 1)
        XCTAssertEqual(restoredCar.history.first?.note, "Hyundai regular checkup")
        
        let restoredHaircut = restoredItems.first(where: { $0.name == "Haircut" })!
        XCTAssertEqual(restoredHaircut.category, "Personal")
        XCTAssertNil(restoredHaircut.intervalValue)
        XCTAssertNil(restoredHaircut.intervalUnit)
    }
}
