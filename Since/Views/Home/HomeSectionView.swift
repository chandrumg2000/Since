//
//  HomeSectionView.swift
//  Since
//
//  Renders a cleanly grouped section of tracked items on the home screen.
//

import SwiftUI
import SwiftData

public struct HomeSectionView: View {
    public let title: String
    public let subtitle: String?
    public let items: [TrackedItem]
    public let onDoneNow: (TrackedItem) -> Void
    public let onArchive: (TrackedItem) -> Void
    public let onDelete: (TrackedItem) -> Void
    
    public init(
        title: String,
        subtitle: String? = nil,
        items: [TrackedItem],
        onDoneNow: @escaping (TrackedItem) -> Void,
        onArchive: @escaping (TrackedItem) -> Void,
        onDelete: @escaping (TrackedItem) -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.items = items
        self.onDoneNow = onDoneNow
        self.onArchive = onArchive
        self.onDelete = onDelete
    }
    
    public var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items) { item in
                    NavigationLink(destination: ItemDetailView(item: item)) {
                        ItemRow(item: item) {
                            onDoneNow(item)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            onDoneNow(item)
                        } label: {
                            Label("Done Now", systemImage: "checkmark")
                        }
                        .tint(.green)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            onArchive(item)
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }
                        .tint(.orange)
                        
                        Button(role: .destructive) {
                            onDelete(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            } header: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                    
                    if let sub = subtitle {
                        Text(sub)
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                }
            }
        }
    }
}
