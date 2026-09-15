//
//  ArchivedItemsView.swift
//  Since
//
//  Allows browsing, restoring, or permanently deleting archived activities.
//

import SwiftUI
import SwiftData

public struct ArchivedItemsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<TrackedItem> { $0.isArchived }, sort: \TrackedItem.createdAt, order: .reverse)
    private var archivedItems: [TrackedItem]
    
    @State private var itemPendingPermanentDelete: TrackedItem?
    @State private var isShowingDeleteDialog: Bool = false
    
    public var body: some View {
        Group {
            if archivedItems.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "archivebox")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(.secondary)
                    
                    Text("No Archived Activities")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Activities you archive will be saved here safely without cluttering your dashboard.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                List {
                    ForEach(archivedItems) { item in
                        HStack(spacing: 12) {
                            CategoryIconView(icon: item.icon, category: item.category, size: 38)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text("Archived • \(DateCalculationService.timeElapsedString(from: item.lastCompletedAt))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Restore") {
                                ItemService.shared.restoreItem(item, context: modelContext)
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .buttonStyle(.bordered)
                        }
                        .padding(.vertical, 4)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                itemPendingPermanentDelete = item
                                isShowingDeleteDialog = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Archived Activities")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Permanently Delete \(itemPendingPermanentDelete?.name ?? "Activity")?",
            isPresented: $isShowingDeleteDialog,
            titleVisibility: .visible,
            presenting: itemPendingPermanentDelete
        ) { item in
            Button("Permanently Delete", role: .destructive) {
                ItemService.shared.deleteItem(item, context: modelContext)
            }
            Button("Cancel", role: .cancel) {}
        } message: { _ in
            Text("This cannot be undone. All completion history will be removed.")
        }
    }
}
