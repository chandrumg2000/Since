//
//  NotificationService.swift
//  Since
//
//  Manages strictly local notifications with zero server dependency.
//

import Foundation
import UserNotifications

public final class NotificationService {
    public static let shared = NotificationService()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    // MARK: - Authorization
    
    /// Requests user authorization for alert and sound notifications.
    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Failed to request notification authorization: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Checks current authorization status.
    public func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Schedule Notification
    
    /// Schedules a local notification for an item based on its next due date and notification offset.
    public func scheduleNotification(for item: TrackedItem) {
        // First cancel any existing notification for this item
        cancelNotification(for: item)
        
        guard item.notificationEnabled, !item.isArchived, item.hasSchedule else {
            return
        }
        
        guard let intervalValue = item.intervalValue,
              let intervalUnit = item.intervalUnit else {
            return
        }
        
        let baseDate = item.lastCompletedAt ?? item.createdAt
        guard let dueDate = DateCalculationService.nextDueDate(
            from: baseDate,
            intervalValue: intervalValue,
            intervalUnit: intervalUnit
        ) else {
            return
        }
        
        let offsetDays = item.notificationOffset ?? 0
        let calendar = Calendar.current
        
        guard let scheduledDate = calendar.date(byAdding: .day, value: -offsetDays, to: dueDate) else {
            return
        }
        
        let settings = UserSettings.shared
        var triggerComponents = calendar.dateComponents([.year, .month, .day], from: scheduledDate)
        triggerComponents.hour = settings.notificationTimeHour
        triggerComponents.minute = settings.notificationTimeMinute
        triggerComponents.second = 0
        
        guard let finalTriggerDate = calendar.date(from: triggerComponents),
              finalTriggerDate > Date() else {
            // If the calculated trigger date has already passed, do not schedule
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = item.name
        
        if offsetDays == 0 {
            content.body = "\(item.name) is due today."
        } else if offsetDays == 1 {
            content.body = "\(item.name) is due tomorrow."
        } else {
            content.body = "\(item.name) is due in \(offsetDays) days."
        }
        
        content.sound = .default
        content.userInfo = ["itemId": item.id.uuidString]
        
        let finalComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: finalTriggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: finalComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: notificationIdentifier(for: item),
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification for \(item.name): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Cancel Notification
    
    /// Cancels scheduled notification for an item.
    public func cancelNotification(for item: TrackedItem) {
        let identifier = notificationIdentifier(for: item)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    /// Reschedules notifications for all active items.
    public func rescheduleAll(items: [TrackedItem]) {
        for item in items {
            scheduleNotification(for: item)
        }
    }
    
    private func notificationIdentifier(for item: TrackedItem) -> String {
        "since.item.\(item.id.uuidString)"
    }
}
