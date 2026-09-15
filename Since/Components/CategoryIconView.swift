//
//  CategoryIconView.swift
//  Since
//
//  Subtle, premium circular category icon badge.
//

import SwiftUI

public struct CategoryIconView: View {
    public let icon: String
    public let category: String
    public var size: CGFloat = 40
    
    public init(icon: String, category: String, size: CGFloat = 40) {
        self.icon = icon
        self.category = category
        self.size = size
    }
    
    private var accentColor: Color {
        if let cat = ItemCategory(rawValue: category) {
            return cat.accentColor
        }
        return Color.secondary
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(accentColor.opacity(0.12))
                .frame(width: size, height: size)
            
            Image(systemName: icon)
                .font(.system(size: size * 0.44, weight: .semibold))
                .foregroundColor(accentColor)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(category) category"))
    }
}
