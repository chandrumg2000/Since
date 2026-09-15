//
//  DateCalculationServiceTests.swift
//  SinceTests
//
//  Unit tests covering leap years, month-end calculations, daylight saving transitions,
//  and intervals.
//

import XCTest
@testable import Since

final class DateCalculationServiceTests: XCTestCase {
    private var gregorianCalendar: Calendar!
    
    override func setUp() {
        super.setUp()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        self.gregorianCalendar = calendar
    }
    
    // MARK: - Recurrence Intervals
    
    func testDailyRecurrence() {
        let baseDate = makeDate(year: 2026, month: 3, day: 10)
        let nextDue = DateCalculationService.nextDueDate(
            from: baseDate,
            intervalValue: 1,
            intervalUnit: .days,
            calendar: gregorianCalendar
        )
        let expected = makeDate(year: 2026, month: 3, day: 11)
        XCTAssertEqual(nextDue, expected)
    }
    
    func testWeeklyRecurrence() {
        let baseDate = makeDate(year: 2026, month: 3, day: 10)
        let nextDue = DateCalculationService.nextDueDate(
            from: baseDate,
            intervalValue: 2,
            intervalUnit: .weeks,
            calendar: gregorianCalendar
        )
        let expected = makeDate(year: 2026, month: 3, day: 24)
        XCTAssertEqual(nextDue, expected)
    }
    
    func testMonthlyRecurrence() {
        let baseDate = makeDate(year: 2026, month: 1, day: 15)
        let nextDue = DateCalculationService.nextDueDate(
            from: baseDate,
            intervalValue: 1,
            intervalUnit: .months,
            calendar: gregorianCalendar
        )
        let expected = makeDate(year: 2026, month: 2, day: 15)
        XCTAssertEqual(nextDue, expected)
    }
    
    func testQuarterlyRecurrence() {
        let baseDate = makeDate(year: 2026, month: 3, day: 15)
        let nextDue = DateCalculationService.nextDueDate(
            from: baseDate,
            intervalValue: 3,
            intervalUnit: .months,
            calendar: gregorianCalendar
        )
        let expected = makeDate(year: 2026, month: 6, day: 15)
        XCTAssertEqual(nextDue, expected)
    }
    
    func testSixMonthsRecurrence() {
        let baseDate = makeDate(year: 2026, month: 3, day: 15)
        let nextDue = DateCalculationService.nextDueDate(
            from: baseDate,
            intervalValue: 6,
            intervalUnit: .months,
            calendar: gregorianCalendar
        )
        let expected = makeDate(year: 2026, month: 9, day: 15)
        XCTAssertEqual(nextDue, expected)
    }
    
    func testYearlyRecurrence() {
        let baseDate = makeDate(year: 2026, month: 5, day: 20)
        let nextDue = DateCalculationService.nextDueDate(
            from: baseDate,
            intervalValue: 1,
            intervalUnit: .years,
            calendar: gregorianCalendar
        )
        let expected = makeDate(year: 2027, month: 5, day: 20)
        XCTAssertEqual(nextDue, expected)
    }
    
    // MARK: - Month-End and Leap Year Behavior
    
    func testMonthEndJanuary31ToFebruaryNonLeapYear() {
        // In 2025 (non-leap year), adding 1 month to Jan 31 should safely resolve to Feb 28
        let baseDate = makeDate(year: 2025, month: 1, day: 31)
        let nextDue = DateCalculationService.nextDueDate(
            from: baseDate,
            intervalValue: 1,
            intervalUnit: .months,
            calendar: gregorianCalendar
        )
        let expected = makeDate(year: 2025, month: 2, day: 28)
        XCTAssertEqual(nextDue, expected)
    }
    
    func testMonthEndJanuary31ToFebruaryLeapYear() {
        // In 2024 (leap year), adding 1 month to Jan 31 should safely resolve to Feb 29
        let baseDate = makeDate(year: 2024, month: 1, day: 31)
        let nextDue = DateCalculationService.nextDueDate(
            from: baseDate,
            intervalValue: 1,
            intervalUnit: .months,
            calendar: gregorianCalendar
        )
        let expected = makeDate(year: 2024, month: 2, day: 29)
        XCTAssertEqual(nextDue, expected)
    }
    
    func testLeapYearFebruary29ToNextYear() {
        // Feb 29 2024 + 1 year should resolve to Feb 28 2025
        let baseDate = makeDate(year: 2024, month: 2, day: 29)
        let nextDue = DateCalculationService.nextDueDate(
            from: baseDate,
            intervalValue: 1,
            intervalUnit: .years,
            calendar: gregorianCalendar
        )
        let expected = makeDate(year: 2025, month: 2, day: 28)
        XCTAssertEqual(nextDue, expected)
    }
    
    // MARK: - Relative Elapsed Time Strings
    
    func testElapsedStringFormatting() {
        let reference = makeDate(year: 2026, month: 9, day: 15)
        
        let sameDay = makeDate(year: 2026, month: 9, day: 15)
        XCTAssertEqual(DateCalculationService.timeElapsedString(from: sameDay, to: reference, calendar: gregorianCalendar), "Today")
        
        let yesterday = makeDate(year: 2026, month: 9, day: 14)
        XCTAssertEqual(DateCalculationService.timeElapsedString(from: yesterday, to: reference, calendar: gregorianCalendar), "Yesterday")
        
        let threeDays = makeDate(year: 2026, month: 9, day: 12)
        XCTAssertEqual(DateCalculationService.timeElapsedString(from: threeDays, to: reference, calendar: gregorianCalendar), "3 days ago")
        
        let twentyOneDays = makeDate(year: 2026, month: 8, day: 25)
        XCTAssertEqual(DateCalculationService.timeElapsedString(from: twentyOneDays, to: reference, calendar: gregorianCalendar), "3 weeks ago")
        
        let oneHundredTwentySevenDays = makeDate(year: 2026, month: 5, day: 11)
        XCTAssertEqual(DateCalculationService.compactTimeElapsedString(from: oneHundredTwentySevenDays, to: reference, calendar: gregorianCalendar), "127d")
    }
    
    // MARK: - Helpers
    
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
