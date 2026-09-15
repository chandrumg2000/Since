//
//  WidgetViews.swift
//  SinceWidget
//
//  Visual layouts for all supported Home Screen and Lock Screen widget sizes.
//

import SwiftUI
import WidgetKit

public struct WidgetSmallView: View {
    public let entry: SinceWidgetEntry
    
    public var body: some View {
        if let topItem = entry.items.first {
            Link(destination: topItem.deepLinkURL) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("SINCE")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: topItem.icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.accentColor)
                    }
                    
                    Spacer()
                    
                    Text(topItem.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(topItem.elapsedText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                    
                    if let status = topItem.statusText {
                        Text(status)
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(topItem.isOverdue ? .red : .orange)
                            .padding(.top, 4)
                    }
                }
                .padding(14)
            }
        } else {
            VStack(spacing: 8) {
                Text("SINCE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                Text("No activities")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

public struct WidgetMediumView: View {
    public let entry: SinceWidgetEntry
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("SINCE")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            VStack(spacing: 6) {
                ForEach(entry.items.prefix(3)) { item in
                    Link(destination: item.deepLinkURL) {
                        HStack(spacing: 8) {
                            Image(systemName: item.icon)
                                .font(.system(size: 13))
                                .foregroundColor(.accentColor)
                                .frame(width: 16)
                            
                            Text(item.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if let status = item.statusText, item.isOverdue {
                                Text(status)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            }
                            
                            Text(item.compactElapsedText)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(14)
    }
}

public struct WidgetLargeView: View {
    public let entry: SinceWidgetEntry
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("SINCE")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            VStack(spacing: 8) {
                ForEach(entry.items.prefix(6)) { item in
                    Link(destination: item.deepLinkURL) {
                        HStack(spacing: 10) {
                            Image(systemName: item.icon)
                                .font(.system(size: 14))
                                .foregroundColor(.accentColor)
                                .frame(width: 18)
                            
                            Text(item.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if let status = item.statusText {
                                Text(status)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(item.isOverdue ? .red : .orange)
                            }
                            
                            Text(item.elapsedText)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    if item.id != entry.items.prefix(6).last?.id {
                        Divider()
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
    }
}

// MARK: - Lock Screen Accessories

public struct WidgetAccessoryCircularView: View {
    public let entry: SinceWidgetEntry
    
    public var body: some View {
        if let item = entry.items.first {
            Link(destination: item.deepLinkURL) {
                VStack(spacing: 1) {
                    Image(systemName: item.icon)
                        .font(.system(size: 12))
                    Text(item.compactElapsedText)
                        .font(.system(size: 12, weight: .bold))
                }
            }
        } else {
            Image(systemName: "clock")
        }
    }
}

public struct WidgetAccessoryRectangularView: View {
    public let entry: SinceWidgetEntry
    
    public var body: some View {
        if let item = entry.items.first {
            Link(destination: item.deepLinkURL) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: item.icon)
                            .font(.system(size: 10))
                        Text(item.name)
                            .font(.system(size: 12, weight: .bold))
                            .lineLimit(1)
                    }
                    
                    Text("\(item.compactElapsedText) ago")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    
                    if let status = item.statusText {
                        Text(status)
                            .font(.system(size: 10, weight: .semibold))
                    }
                }
            }
        } else {
            Text("Since: No activities")
                .font(.caption)
        }
    }
}

public struct WidgetAccessoryInlineView: View {
    public let entry: SinceWidgetEntry
    
    public var body: some View {
        if let item = entry.items.first {
            ViewThatFits {
                Text("\(item.name): \(item.compactElapsedText)")
                Text(item.name)
            }
        } else {
            Text("Since")
        }
    }
}
