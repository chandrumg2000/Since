//
//  DateCalculationService.swift
//  Since
//
//  Calendar and time mathematics engine.
//  Accurately handles leap years, month-end recurrence, daylight saving time (DST),
//  and time zone shifts using Apple Foundation Calendar APIs.
//

import Foundation

public struct DateCalculationService {
    
    // MARK: - Due Date Calculation
    
    /// Calculates the next due date based on the last completion date and interval.
    /// Handles month-end boundaries properly (e.g. Jan 31 + 1 month = Feb 28/29).
    public static func nextDueDate(
        from baseDate: Date,
        intervalValue: Int,
        intervalUnit: IntervalUnit,
        calendar: Calendar = .current
    ) -> Date? {
        guard intervalValue > 0 else { return nil }
        
        let startOfBaseDate = calendar.startOfDay(for: baseDate)
        
        var dateComponents = DateComponents()
        switch intervalUnit {
        case .days:
            dateComponents.day = intervalValue
        case .weeks:
            dateComponents.day = intervalValue * 7
        case .months:
            dateComponents.month = intervalValue
        case .years:
            dateComponents.year = intervalValue
        }
        
        return calendar.date(byAdding: dateComponents, to: startOfBaseDate)
    }
    
    // MARK: - Elapsed Time Calculation
    
    /// Computes the number of full calendar days elapsed between two dates.
    public static func daysElapsed(
        from pastDate: Date,
        to referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let startOfPast = calendar.startOfDay(for: pastDate)
        let startOfRef = calendar.startOfDay(for: referenceDate)
        
        let components = calendar.dateComponents([.day], from: startOfPast, to: startOfRef)
        return max(0, components.day ?? 0)
    }
    
    /// Computes the number of full calendar days remaining until target date (can be negative if overdue).
    public static func daysRemaining(
        until targetDate: Date,
        from referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let startOfRef = calendar.startOfDay(for: referenceDate)
        let startOfTarget = calendar.startOfDay(for: targetDate)
        
        let components = calendar.dateComponents([.day], from: startOfRef, to: startOfTarget)
        return components.day ?? 0
    }
    
    // MARK: - Human Readable Strings
    
    /// Returns natural language string: "Just now", "Yesterday", "3 days ago", "4 weeks ago", "2 months ago", "1 year ago".
    public static func timeElapsedString(
        from pastDate: Date?,
        to referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> String {
        guard let pastDate = pastDate else {
            return "Never recorded"
        }
        
        let days = daysElapsed(from: pastDate, to: referenceDate, calendar: calendar)
        
        if days == 0 {
            // Check if it's within a few minutes or today
            let seconds = referenceDate.timeIntervalSince(pastDate)
            if seconds < 60 {
                return "Just now"
            } else if seconds < 3600 {
                let minutes = max(1, Int(seconds / 60))
                return "\(minutes)m ago"
            } else {
                return "Today"
            }
        } else if days == 1 {
            return "Yesterday"
        } else if days < 14 {
            return "\(days) days ago"
        } else if days < 60 {
            let weeks = days / 7
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        } else if days < 365 {
            let months = days / 30
            return months <= 1 ? "1 month ago" : "\(months) months ago"
        } else {
            let years = max(1, days / 365)
            return years == 1 ? "1 year ago" : "\(years) years ago"
        }
    }
    
    /// Compact representation for widgets and badges: "today", "yesterday", "43d", "5w", "2m", "1y".
    public static func compactTimeElapsedString(
        from pastDate: Date?,
        to referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> String {
        guard let pastDate = pastDate else {
            return "—"
        }
        
        let days = daysElapsed(from: pastDate, to: referenceDate, calendar: calendar)
        
        if days == 0 {
            return "today"
        } else if days == 1 {
            return "1d"
        } else if days < 14 {
            return "\(days)d"
        } else if days < 60 {
            return "\(days / 7)w"
        } else if days < 365 {
            return "\(days / 30)m"
        } else {
            return "\(max(1, days / 365))y"
        }
    }
    
    // MARK: - Status Calculation
    
    /// Evaluates the ItemStatus given the item's schedule and last completion.
    public static func status(
        lastCompletedAt: Date?,
        createdAt: Date,
        intervalValue: Int?,
        intervalUnit: IntervalUnit?,
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> ItemStatus {
        let baseDate = lastCompletedAt ?? createdAt
        
        guard let intervalValue = intervalValue,
              let intervalUnit = intervalUnit,
              let nextDueDate = nextDueDate(from: baseDate, intervalValue: intervalValue, intervalUnit: intervalUnit, calendar: calendar) else {
            let days = daysElapsed(from: baseDate, to: referenceDate, calendar: calendar)
            return .noSchedule(daysSince: days)
        }
        
        let remainingDays = daysRemaining(until: nextDueDate, from: referenceDate, calendar: calendar)
        
        if remainingDays < 0 {
            return .overdue(daysOverdue: abs(remainingDays))
        } else if remainingDays == 0 {
            return .dueToday
        } else if remainingDays <= 3 {
            return .dueSoon(daysRemaining: remainingDays)
        } else {
            return .healthy(daysRemaining: remainingDays)
        }
    }
    
    /// Formatted date string (e.g. "15 Sep 2026")
    public static func formattedDate(_ date: Date, format: String = "d MMM yyyy") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    /// Year string (e.g. "2026")
    public static func yearString(from date: Date, calendar: Calendar = .current) -> String {
        let year = calendar.component(.year, from: date)
        return String(year)
    }
}
