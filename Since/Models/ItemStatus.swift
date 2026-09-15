//
//  ItemStatus.swift
//  Since
//
//  Represents the scheduling state of a tracked item.
//

import SwiftUI

public enum ItemStatus: Equatable {
    case healthy(daysRemaining: Int)
    case dueSoon(daysRemaining: Int)
    case dueToday
    case overdue(daysOverdue: Int)
    case noSchedule(daysSince: Int)
    
    public var displayText: String {
        switch self {
        case .healthy(let days):
            return days == 1 ? "Due tomorrow" : "Due in \(days) days"
        case .dueSoon(let days):
            if days == 1 {
                return "Due tomorrow"
            } else if days == 0 {
                return "Due today"
            } else {
                return "Due in \(days) days"
            }
        case .dueToday:
            return "Due today"
        case .overdue(let days):
            return days == 1 ? "1 day overdue" : "\(days) days overdue"
        case .noSchedule(let days):
            if days == 0 {
                return "Done today"
            } else if days == 1 {
                return "1 day ago"
            } else {
                return "\(days) days ago"
            }
        }
    }
    
    public var compactText: String {
        switch self {
        case .healthy(let days):
            return "in \(days)d"
        case .dueSoon(let days):
            return "in \(days)d"
        case .dueToday:
            return "today"
        case .overdue(let days):
            return "\(days)d over"
        case .noSchedule(let days):
            return "\(days)d ago"
        }
    }
    
    public var isAttentionNeeded: Bool {
        switch self {
        case .overdue, .dueToday, .dueSoon:
            return true
        default:
            return false
        }
    }
    
    public var sortPriority: Int {
        switch self {
        case .overdue: return 0
        case .dueToday: return 1
        case .dueSoon: return 2
        case .healthy: return 3
        case .noSchedule: return 4
        }
    }
    
    public var systemImageName: String {
        switch self {
        case .overdue:
            return "exclamationmark.circle.fill"
        case .dueToday:
            return "clock.fill"
        case .dueSoon:
            return "calendar.badge.clock"
        case .healthy:
            return "checkmark.circle.fill"
        case .noSchedule:
            return "arrow.counterclockwise"
        }
    }
    
    public var tintColor: Color {
        switch self {
        case .overdue:
            return Color.red
        case .dueToday:
            return Color.orange
        case .dueSoon:
            return Color.orange.opacity(0.85)
        case .healthy:
            return Color.secondary
        case .noSchedule:
            return Color.secondary
        }
    }
    
    public var backgroundTint: Color {
        switch self {
        case .overdue:
            return Color.red.opacity(0.12)
        case .dueToday:
            return Color.orange.opacity(0.12)
        case .dueSoon:
            return Color.orange.opacity(0.08)
        case .healthy:
            return Color(.tertiarySystemFill)
        case .noSchedule:
            return Color(.tertiarySystemFill)
        }
    }
}
