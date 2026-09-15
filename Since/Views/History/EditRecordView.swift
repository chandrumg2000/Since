//
//  EditRecordView.swift
//  Since
//
//  Sheet to modify a historical completion record's timestamp or notes.
//

import SwiftUI
import SwiftData

public struct EditRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    public let record: CompletionRecord
    public let item: TrackedItem
    
    @State private var completedDate: Date
    @State private var noteText: String
    
    public init(record: CompletionRecord, item: TrackedItem) {
        self.record = record
        self.item = item
        _completedDate = State(initialValue: record.completedAt)
        _noteText = State(initialValue: record.note ?? "")
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("COMPLETION DATE") {
                    DatePicker(
                        "Completed On",
                        selection: $completedDate,
                        in: ...Date(),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                Section("NOTES") {
                    TextField("Optional notes (e.g. location, details)", text: $noteText, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button(role: .destructive) {
                        ItemService.shared.deleteCompletionRecord(record, from: item, context: modelContext)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Completion Record")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        ItemService.shared.updateCompletionRecord(
                            record,
                            for: item,
                            completedAt: completedDate,
                            note: noteText,
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
