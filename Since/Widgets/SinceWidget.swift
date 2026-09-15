//
//  SinceWidget.swift
//  SinceWidget
//
//  Widget configuration supporting systemSmall, systemMedium, systemLarge,
//  and lock screen accessory families.
//

import WidgetKit
import SwiftUI

public struct SinceWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    public var entry: SinceWidgetEntry
    
    public var body: some View {
        switch family {
        case .systemSmall:
            WidgetSmallView(entry: entry)
        case .systemMedium:
            WidgetMediumView(entry: entry)
        case .systemLarge:
            WidgetLargeView(entry: entry)
        case .accessoryCircular:
            WidgetAccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            WidgetAccessoryRectangularView(entry: entry)
        case .accessoryInline:
            WidgetAccessoryInlineView(entry: entry)
        default:
            WidgetSmallView(entry: entry)
        }
    }
}

public struct SinceWidget: Widget {
    public let kind: String = "SinceWidget"
    
    public init() {}
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SinceTimelineProvider()) { entry in
            SinceWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(.secondarySystemBackground)
                }
        }
        .configurationDisplayName("Since")
        .description("Glance at when you last performed important activities.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
