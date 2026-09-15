//
//  TemplatePickerView.swift
//  Since
//
//  Horizontal quick-selector for popular activity templates.
//

import SwiftUI

public struct TemplatePickerView: View {
    public let templates: [ActivityTemplate]
    public let onSelect: (ActivityTemplate) -> Void
    
    public init(templates: [ActivityTemplate] = ItemCategory.popularTemplates, onSelect: @escaping (ActivityTemplate) -> Void) {
        self.templates = templates
        self.onSelect = onSelect
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(templates) { template in
                    Button(action: {
                        onSelect(template)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: template.icon)
                                .font(.system(size: 13))
                            Text(template.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.secondarySystemFill))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
