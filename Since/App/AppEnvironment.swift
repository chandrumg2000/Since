//
//  AppEnvironment.swift
//  Since
//
//  Shared environment coordinator managing navigation state, deep linking,
//  and active sheets across the application.
//

import SwiftUI

@Observable
public final class AppEnvironment {
    public static let shared = AppEnvironment()
    
    public var selectedItemIdForNavigation: UUID?
    public var isShowingAddItem: Bool = false
    public var isShowingSettings: Bool = false
    public var isShowingOnboarding: Bool = false
    public var searchText: String = ""
    public var activeAlertMessage: String?
    
    public init() {}
    
    /// Handles deep linking from widgets or notifications: "since://item/<uuid>"
    public func handleDeepLink(url: URL) {
        guard url.scheme == "since" else { return }
        
        if url.host == "item", let uuidString = url.pathComponents.dropFirst().first, let uuid = UUID(uuidString: uuidString) {
            self.selectedItemIdForNavigation = uuid
        } else if url.host == "add" {
            self.isShowingAddItem = true
        }
    }
}
