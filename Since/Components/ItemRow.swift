//
//  ItemRow.swift
//  Since
//
//  Clean native row with relative time, health status, and quick one-tap completion.
//

import SwiftUI
import SwiftData

public struct ItemRow: View {
    public let item: TrackedItem
    public let onDoneNow: () -> Void
    
    @State private var isDoneAnimating: Bool = false
    
    public init(item: TrackedItem, onDoneNow: @escaping () -> Void) {
        self.item = item
        self.onDoneNow = onDoneNow
    }
    
    private var itemStatus: ItemStatus {
        DateCalculationService.status(
            lastCompletedAt: item.lastCompletedAt,
            createdAt: item.createdAt,
            intervalValue: item.intervalValue,
            intervalUnit: item.intervalUnit
        )
    }
    
    private var relativeTimeString: String {
        DateCalculationService.timeElapsedString(from: item.lastCompletedAt ?? item.createdAt)
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            CategoryIconView(icon: item.icon, category: item.category, size: 42)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(relativeTimeString)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if item.hasSchedule {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary.opacity(0.6))
                        
                        StatusBadge(status: itemStatus, compact: true)
                    }
                }
            }
            
            Spacer()
            
            // "Done Now" quick tap button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isDoneAnimating = true
                }
                onDoneNow()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation {
                        isDoneAnimating = false
                    }
                }
            }) {
                ZStack {
                    Circle()
                        .fill(isDoneAnimating ? Color.green : Color(.tertiarySystemFill))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: isDoneAnimating ? "checkmark" : "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(isDoneAnimating ? .white : .secondary)
                        .scaleEffect(isDoneAnimating ? 1.2 : 1.0)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel(Text("Mark \(item.name) as done now"))
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}
