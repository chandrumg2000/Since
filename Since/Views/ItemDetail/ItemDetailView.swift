//
//  ItemDetailView.swift
//  Since
//
//  Comprehensive detail view: glanceable elapsed time, next due calculations,
//  one-tap "Done Now" recording, and historical completion timeline.
//

import SwiftUI
import SwiftData

public struct ItemDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    public let item: TrackedItem
    
    @State private var isShowingEditSheet: Bool = false
    @State private var isShowingAddRecordSheet: Bool = false
    @State private var recordToEdit: CompletionRecord?
    @State private var isShowingDeleteAlert: Bool = false
    @State private var isDoneNowJustTapped: Bool = false
    
    private var itemStatus: ItemStatus {
        DateCalculationService.status(
            lastCompletedAt: item.lastCompletedAt,
            createdAt: item.createdAt,
            intervalValue: item.intervalValue,
            intervalUnit: item.intervalUnit
        )
    }
    
    private var nextDueDate: Date? {
        guard let val = item.intervalValue, let unit = item.intervalUnit else { return nil }
        let baseDate = item.lastCompletedAt ?? item.createdAt
        return DateCalculationService.nextDueDate(from: baseDate, intervalValue: val, intervalUnit: unit)
    }
    
    private var relativeElapsedString: String {
        DateCalculationService.timeElapsedString(from: item.lastCompletedAt)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Hero Header
                VStack(spacing: 12) {
                    CategoryIconView(icon: item.icon, category: item.category, size: 68)
                        .padding(.top, 8)
                    
                    Text(item.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    // Glanceable Elapsed Time
                    VStack(spacing: 4) {
                        Text(relativeElapsedString)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        if let lastDate = item.lastCompletedAt {
                            Text("Last done: \(DateCalculationService.formattedDate(lastDate))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Created on \(DateCalculationService.formattedDate(item.createdAt))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Status Badge if scheduled
                    if item.hasSchedule {
                        StatusBadge(status: itemStatus)
                            .padding(.top, 2)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                
                // MARK: - Next Due Information Card
                if let nextDueDate = nextDueDate {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("NEXT DUE")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Text(DateCalculationService.formattedDate(nextDueDate))
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(item.recurrenceDisplayText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        StatusBadge(status: itemStatus, compact: false)
                    }
                    .padding(16)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                
                // MARK: - Primary Action: "Done Now"
                PrimaryButton(
                    title: isDoneNowJustTapped ? "✓ Done" : "✓ Done Now",
                    icon: nil
                ) {
                    performDoneNow()
                }
                .padding(.horizontal, 4)
                
                // MARK: - Completion History Timeline
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("HISTORY")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button {
                            isShowingAddRecordSheet = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.caption2)
                                Text("Add past date")
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                    
                    if item.history.isEmpty {
                        VStack(spacing: 8) {
                            Text("No history recorded yet.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Tap 'Done Now' above or add a past date to begin your timeline.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    } else {
                        VStack(spacing: 0) {
                            let sortedRecords = item.sortedHistory
                            ForEach(Array(sortedRecords.enumerated()), id: \.element.id) { index, record in
                                Button {
                                    recordToEdit = record
                                } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        Circle()
                                            .fill(index == 0 ? Color.accentColor : Color.secondary.opacity(0.3))
                                            .frame(width: 8, height: 8)
                                            .padding(.top, 6)
                                        
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(DateCalculationService.formattedDate(record.completedAt))
                                                .font(.body)
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                            
                                            Text(DateCalculationService.timeElapsedString(from: record.completedAt))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            if let note = record.note, !note.isEmpty {
                                                Text(note)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                                    .padding(.top, 2)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(Color(.tertiaryLabel))
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 16)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if index < sortedRecords.count - 1 {
                                    Divider()
                                        .padding(.leading, 36)
                                }
                            }
                        }
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        isShowingEditSheet = true
                    } label: {
                        Label("Edit Activity", systemImage: "pencil")
                    }
                    
                    Button {
                        if item.isArchived {
                            ItemService.shared.restoreItem(item, context: modelContext)
                        } else {
                            ItemService.shared.archiveItem(item, context: modelContext)
                            dismiss()
                        }
                    } label: {
                        Label(item.isArchived ? "Restore Activity" : "Archive Activity", systemImage: "archivebox")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        isShowingDeleteAlert = true
                    } label: {
                        Label("Delete Activity", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isShowingEditSheet) {
            EditItemView(item: item)
        }
        .sheet(isPresented: $isShowingAddRecordSheet) {
            AddRecordView(item: item)
        }
        .sheet(item: $recordToEdit) { record in
            EditRecordView(record: record, item: item)
        }
        .confirmationDialog(
            "Delete \(item.name)?",
            isPresented: $isShowingDeleteAlert,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                ItemService.shared.deleteItem(item, context: modelContext)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete its history.")
        }
    }
    
    private func performDoneNow() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            isDoneNowJustTapped = true
        }
        ItemService.shared.markDone(item: item, context: modelContext)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation {
                isDoneNowJustTapped = false
            }
        }
    }
}
