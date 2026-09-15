//
//  AddRecordView.swift
//  Since
//
//  Sheet to manually log a past completion date with optional note.
//

import SwiftUI
import SwiftData

public struct AddRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    public let item: TrackedItem
    
    @State private var completedDate: Date = Date()
    @State private var noteText: String = ""
    
    public init(item: TrackedItem) {
        self.item = item
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("WHEN WAS THIS COMPLETED?") {
                    DatePicker(
                        "Completion Date",
                        selection: $completedDate,
                        in: ...Date(),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                Section("NOTES (OPTIONAL)") {
                    TextField("Details, cost, location, brand, etc.", text: $noteText, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Record Past Completion")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Record") {
                        ItemService.shared.markDone(
                            item: item,
                            completedAt: completedDate,
                            note: noteText.isEmpty ? nil : noteText,
                            context: modelContext
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
