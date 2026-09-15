//
//  StatusCalculationTests.swift
//  SinceTests
//
//  Unit tests covering item status calculation thresholds.
//

import XCTest
@testable import Since

final class StatusCalculationTests: XCTestCase {
    private var gregorianCalendar: Calendar!
    
    override func setUp() {
        super.setUp()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        self.gregorianCalendar = calendar
    }
    
    func testHealthyStatus() {
        // Completed 10 days ago with 1 month interval -> next due in ~20 days -> Healthy
        let referenceDate = makeDate(year: 2026, month: 9, day: 15)
        let lastDone = makeDate(year: 2026, month: 9, day: 5)
        
        let status = DateCalculationService.status(
            lastCompletedAt: lastDone,
            createdAt: lastDone,
            intervalValue: 1,
            intervalUnit: .months,
            referenceDate: referenceDate,
            calendar: gregorianCalendar
        )
        
        if case .healthy(let days) = status {
            XCTAssertGreaterThan(days, 3)
        } else {
            XCTFail("Expected .healthy status, got \(status)")
        }
    }
    
    func testDueSoonStatus() {
        // Reference is Sep 15. Due on Sep 17 -> 2 days remaining -> Due Soon
        let referenceDate = makeDate(year: 2026, month: 9, day: 15)
        let lastDone = makeDate(year: 2026, month: 8, day: 17)
        
        let status = DateCalculationService.status(
            lastCompletedAt: lastDone,
            createdAt: lastDone,
            intervalValue: 1,
            intervalUnit: .months,
            referenceDate: referenceDate,
            calendar: gregorianCalendar
        )
        
        if case .dueSoon(let days) = status {
            XCTAssertEqual(days, 2)
        } else {
            XCTFail("Expected .dueSoon status, got \(status)")
        }
    }
    
    func testDueTodayStatus() {
        // Reference is Sep 15. Due on Sep 15 -> Due Today
        let referenceDate = makeDate(year: 2026, month: 9, day: 15)
        let lastDone = makeDate(year: 2026, month: 8, day: 15)
        
        let status = DateCalculationService.status(
            lastCompletedAt: lastDone,
            createdAt: lastDone,
            intervalValue: 1,
            intervalUnit: .months,
            referenceDate: referenceDate,
            calendar: gregorianCalendar
        )
        
        XCTAssertEqual(status, .dueToday)
    }
    
    func testOverdueStatus() {
        // Reference is Sep 15. Completed July 1 with 1 month interval -> due Aug 1 -> 45 days overdue
        let referenceDate = makeDate(year: 2026, month: 9, day: 15)
        let lastDone = makeDate(year: 2026, month: 7, day: 1)
        
        let status = DateCalculationService.status(
            lastCompletedAt: lastDone,
            createdAt: lastDone,
            intervalValue: 1,
            intervalUnit: .months,
            referenceDate: referenceDate,
            calendar: gregorianCalendar
        )
        
        if case .overdue(let days) = status {
            XCTAssertEqual(days, 45)
        } else {
            XCTFail("Expected .overdue status, got \(status)")
        }
    }
    
    func testNoScheduleStatus() {
        // No recurrence interval defined -> No Schedule
        let referenceDate = makeDate(year: 2026, month: 9, day: 15)
        let lastDone = makeDate(year: 2026, month: 8, day: 25)
        
        let status = DateCalculationService.status(
            lastCompletedAt: lastDone,
            createdAt: lastDone,
            intervalValue: nil,
            intervalUnit: nil,
            referenceDate: referenceDate,
            calendar: gregorianCalendar
        )
        
        if case .noSchedule(let days) = status {
            XCTAssertEqual(days, 21)
        } else {
            XCTFail("Expected .noSchedule status, got \(status)")
        }
    }
    
    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 0
        components.minute = 0
        components.second = 0
        return gregorianCalendar.date(from: components)!
    }
}
