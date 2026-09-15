//
//  UserSettings.swift
//  Since
//
//  Manages user preferences and application-level configuration.
//

import SwiftUI

public enum SortOption: String, CaseIterable, Identifiable, Codable {
    case smart = "Smart"
    case longestAgo = "Longest Ago"
    case recentlyDone = "Recently Done"
    case alphabetical = "Alphabetical"
    case category = "Category"
    
    public var id: String { rawValue }
    public var displayName: String { rawValue }
    
    public var systemImageName: String {
        switch self {
        case .smart: return "sparkles"
        case .longestAgo: return "clock.arrow.circlepath"
        case .recentlyDone: return "checkmark.circle"
        case .alphabetical: return "textformat.abc"
        case .category: return "folder"
        }
    }
}

public enum AppAppearance: String, CaseIterable, Identifiable, Codable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    public var id: String { rawValue }
    public var displayName: String { rawValue }
    
    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@Observable
public final class UserSettings {
    public static let shared = UserSettings()
    
    private let defaults: UserDefaults
    
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.sortOption = SortOption(rawValue: defaults.string(forKey: "since_sort_option") ?? "") ?? .smart
        self.appearance = AppAppearance(rawValue: defaults.string(forKey: "since_appearance") ?? "") ?? .system
        self.hapticsEnabled = defaults.object(forKey: "since_haptics_enabled") as? Bool ?? true
        self.defaultCategory = defaults.string(forKey: "since_default_category") ?? ItemCategory.home.rawValue
        self.defaultNotificationOffset = defaults.object(forKey: "since_notification_offset") as? Int ?? 0
        self.notificationTimeHour = defaults.object(forKey: "since_notification_hour") as? Int ?? 9
        self.notificationTimeMinute = defaults.object(forKey: "since_notification_minute") as? Int ?? 0
        self.hasCompletedOnboarding = defaults.bool(forKey: "since_has_completed_onboarding")
    }
    
    public var sortOption: SortOption {
        didSet {
            defaults.set(sortOption.rawValue, forKey: "since_sort_option")
        }
    }
    
    public var appearance: AppAppearance {
        didSet {
            defaults.set(appearance.rawValue, forKey: "since_appearance")
        }
    }
    
    public var hapticsEnabled: Bool {
        didSet {
            defaults.set(hapticsEnabled, forKey: "since_haptics_enabled")
        }
    }
    
    public var defaultCategory: String {
        didSet {
            defaults.set(defaultCategory, forKey: "since_default_category")
        }
    }
    
    public var defaultNotificationOffset: Int {
        didSet {
            defaults.set(defaultNotificationOffset, forKey: "since_notification_offset")
        }
    }
    
    public var notificationTimeHour: Int {
        didSet {
            defaults.set(notificationTimeHour, forKey: "since_notification_hour")
        }
    }
    
    public var notificationTimeMinute: Int {
        didSet {
            defaults.set(notificationTimeMinute, forKey: "since_notification_minute")
        }
    }
    
    public var hasCompletedOnboarding: Bool {
        didSet {
            defaults.set(hasCompletedOnboarding, forKey: "since_has_completed_onboarding")
        }
    }
}
