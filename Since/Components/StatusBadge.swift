//
//  StatusBadge.swift
//  Since
//
//  Restrained, elegant status capsule indicating schedule health.
//

import SwiftUI

public struct StatusBadge: View {
    public let status: ItemStatus
    public var compact: Bool = false
    
    public init(status: ItemStatus, compact: Bool = false) {
        self.status = status
        self.compact = compact
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.systemImageName)
                .font(.system(size: compact ? 9 : 11, weight: .bold))
            
            Text(compact ? status.compactText : status.displayText)
                .font(.system(size: compact ? 11 : 12, weight: .medium))
        }
        .foregroundColor(status.tintColor)
        .padding(.horizontal, compact ? 6 : 8)
        .padding(.vertical, compact ? 3 : 4)
        .background(status.backgroundTint)
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("Status: \(status.displayText)"))
    }
}
