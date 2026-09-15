//
//  IntervalUnit.swift
//  Since
//
//  Defines the supported recurrence units and date calculation helpers.
//

import Foundation

public enum IntervalUnit: String, Codable, CaseIterable, Identifiable {
    case days
    case weeks
    case months
    case years
    
    public var id: String { rawValue }
    
    public var singularDisplayName: String {
        switch self {
        case .days: return "Day"
        case .weeks: return "Week"
        case .months: return "Month"
        case .years: return "Year"
        }
    }
    
    public var pluralDisplayName: String {
        switch self {
        case .days: return "Days"
        case .weeks: return "Weeks"
        case .months: return "Months"
        case .years: return "Years"
        }
    }
    
    public func formatted(for value: Int) -> String {
        if value == 1 {
            return "Every \(singularDisplayName.lowercased())"
        } else {
            return "Every \(value) \(pluralDisplayName.lowercased())"
        }
    }
    
    public var calendarComponent: Calendar.Component {
        switch self {
        case .days: return .day
        case .weeks: return .weekOfYear
        case .months: return .month
        case .years: return .year
        }
    }
}
