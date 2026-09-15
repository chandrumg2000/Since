//
//  ItemServiceTests.swift
//  SinceTests
//
//  Unit tests covering ItemService lifecycle, completion history, and cascade rules.
//

import XCTest
import SwiftData
@testable import Since

@MainActor
final class ItemServiceTests: XCTestCase {
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
    
    func testCreateItem() {
        let item = ItemService.shared.createItem(
            name: "Car Service",
            category: "Car",
            icon: "car.fill",
            intervalValue: 6,
            intervalUnit: .months,
            initialCompletionDate: nil,
            context: context
        )
        
        XCTAssertEqual(item.name, "Car Service")
        XCTAssertEqual(item.category, "Car")
        XCTAssertEqual(item.intervalValue, 6)
        XCTAssertEqual(item.intervalUnit, .months)
        XCTAssertNil(item.lastCompletedAt)
        XCTAssertTrue(item.history.isEmpty)
    }
    
    func testMarkDoneUpdatesTimestampAndHistory() {
        let item = ItemService.shared.createItem(
            name: "AC Filter",
            category: "Home",
            icon: "air.conditioner.horizontal.fill",
            intervalValue: 3,
            intervalUnit: .months,
            context: context
        )
        
        let completionDate = Date()
        let record = ItemService.shared.markDone(
            item: item,
            completedAt: completionDate,
            note: "Replaced HEPA filter",
            context: context
        )
        
        XCTAssertEqual(item.lastCompletedAt, completionDate)
        XCTAssertEqual(item.history.count, 1)
        XCTAssertEqual(item.history.first?.id, record.id)
        XCTAssertEqual(item.history.first?.note, "Replaced HEPA filter")
    }
    
    func testDeleteCompletionRecordRecalculatesLatest() {
        let item = ItemService.shared.createItem(
            name: "Toothbrush",
            category: "Personal",
            icon: "mouth.fill",
            intervalValue: 3,
            intervalUnit: .months,
            context: context
        )
        
        let earlierDate = Date().addingTimeInterval(-86400 * 90)
        let laterDate = Date()
        
        let earlierRecord = ItemService.shared.markDone(item: item, completedAt: earlierDate, context: context)
        let laterRecord = ItemService.shared.markDone(item: item, completedAt: laterDate, context: context)
        
        XCTAssertEqual(item.lastCompletedAt, laterDate)
        XCTAssertEqual(item.history.count, 2)
        
        // Deleting the later record should reset lastCompletedAt back to earlierDate
        ItemService.shared.deleteCompletionRecord(laterRecord, from: item, context: context)
        
        XCTAssertEqual(item.lastCompletedAt, earlierDate)
        XCTAssertEqual(item.history.count, 1)
        XCTAssertEqual(item.history.first?.id, earlierRecord.id)
    }
    
    func testArchiveAndRestoreItem() {
        let item = ItemService.shared.createItem(
            name: "Bedsheets",
            category: "Home",
            icon: "bed.double.fill",
            intervalValue: 2,
            intervalUnit: .weeks,
            context: context
        )
        
        XCTAssertFalse(item.isArchived)
        
        ItemService.shared.archiveItem(item, context: context)
        XCTAssertTrue(item.isArchived)
        
        ItemService.shared.restoreItem(item, context: context)
        XCTAssertFalse(item.isArchived)
    }
    
    func testDeleteItemCascade() {
        let item = ItemService.shared.createItem(
            name: "Haircut",
            category: "Personal",
            icon: "scissors",
            intervalValue: 4,
            intervalUnit: .weeks,
            context: context
        )
        
        _ = ItemService.shared.markDone(item: item, completedAt: Date(), context: context)
        XCTAssertEqual(item.history.count, 1)
        
        ItemService.shared.deleteItem(item, context: context)
        
        let descriptor = FetchDescriptor<TrackedItem>()
        let items = (try? context.fetch(descriptor)) ?? []
        XCTAssertTrue(items.isEmpty)
        
        let historyDescriptor = FetchDescriptor<CompletionRecord>()
        let records = (try? context.fetch(historyDescriptor)) ?? []
        XCTAssertTrue(records.isEmpty)
    }
}
