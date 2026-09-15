//
//  EmptyStateView.swift
//  Since
//
//  Welcoming, uncluttered empty state guiding the user to start tracking.
//

import SwiftUI

public struct EmptyStateView: View {
    public let onAddFirstItem: () -> Void
    public let onSelectTemplate: (ActivityTemplate) -> Void
    
    public init(
        onAddFirstItem: @escaping () -> Void,
        onSelectTemplate: @escaping (ActivityTemplate) -> Void
    ) {
        self.onAddFirstItem = onAddFirstItem
        self.onSelectTemplate = onSelectTemplate
    }
    
    private let suggestedTemplates: [ActivityTemplate] = [
        ActivityTemplate(name: "Car Service", category: ItemCategory.car.rawValue, icon: "car.fill", defaultIntervalValue: 6, defaultIntervalUnit: .months),
        ActivityTemplate(name: "AC Filter", category: ItemCategory.home.rawValue, icon: "air.conditioner.horizontal.fill", defaultIntervalValue: 3, defaultIntervalUnit: .months),
        ActivityTemplate(name: "Haircut", category: ItemCategory.personal.rawValue, icon: "scissors", defaultIntervalValue: 4, defaultIntervalUnit: .weeks),
        ActivityTemplate(name: "Water Filter", category: ItemCategory.home.rawValue, icon: "drop.fill", defaultIntervalValue: 6, defaultIntervalUnit: .months),
        ActivityTemplate(name: "Toothbrush", category: ItemCategory.personal.rawValue, icon: "mouth.fill", defaultIntervalValue: 3, defaultIntervalUnit: .months),
        ActivityTemplate(name: "Bedsheets", category: ItemCategory.home.rawValue, icon: "bed.double.fill", defaultIntervalValue: 2, defaultIntervalUnit: .weeks)
    ]
    
    public var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            VStack(spacing: 12) {
                Image(systemName: "clock.badge.checkmark")
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.secondary)
                
                Text("Nothing here yet.")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Keep track of the things\nyou don't want to forget.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onAddFirstItem) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Add your first item")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(Color.accentColor)
                .clipShape(Capsule())
            }
            .buttonStyle(ScaleButtonStyle())
            
            VStack(alignment: .leading, spacing: 12) {
                Text("POPULAR TO REMEMBER")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 10) {
                    ForEach(suggestedTemplates) { template in
                        Button(action: {
                            onSelectTemplate(template)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: template.icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(.accentColor)
                                
                                Text(template.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}
