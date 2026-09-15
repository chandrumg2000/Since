//
//  OnboardingView.swift
//  Since
//
//  Short, 3-step friction-free onboarding without account creation, email, or nagging.
//

import SwiftUI
import SwiftData

public struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var currentStep: Int = 1
    @State private var selectedTemplates: Set<String> = []
    
    private let starterTemplates: [ActivityTemplate] = [
        ActivityTemplate(name: "Car Service", category: ItemCategory.car.rawValue, icon: "car.fill", defaultIntervalValue: 6, defaultIntervalUnit: .months),
        ActivityTemplate(name: "AC Filter", category: ItemCategory.home.rawValue, icon: "air.conditioner.horizontal.fill", defaultIntervalValue: 3, defaultIntervalUnit: .months),
        ActivityTemplate(name: "Toothbrush", category: ItemCategory.personal.rawValue, icon: "mouth.fill", defaultIntervalValue: 3, defaultIntervalUnit: .months),
        ActivityTemplate(name: "Haircut", category: ItemCategory.personal.rawValue, icon: "scissors", defaultIntervalValue: 4, defaultIntervalUnit: .weeks),
        ActivityTemplate(name: "Bedsheets", category: ItemCategory.home.rawValue, icon: "bed.double.fill", defaultIntervalValue: 2, defaultIntervalUnit: .weeks),
        ActivityTemplate(name: "Water Filter", category: ItemCategory.home.rawValue, icon: "drop.fill", defaultIntervalValue: 6, defaultIntervalUnit: .months),
        ActivityTemplate(name: "Tyre Pressure", category: ItemCategory.car.rawValue, icon: "gauge.with.dots.needle.bottom.50percent", defaultIntervalValue: 1, defaultIntervalUnit: .months),
        ActivityTemplate(name: "Laptop Backup", category: ItemCategory.technology.rawValue, icon: "externaldrive.fill", defaultIntervalValue: 1, defaultIntervalUnit: .months)
    ]
    
    public var body: some View {
        VStack {
            Spacer()
            
            if currentStep == 1 {
                // Screen 1: Welcome
                VStack(spacing: 20) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(.accentColor)
                    
                    Text("Since")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Remember when.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("The effortless personal memory for\neverything you do every now and then.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 8)
                }
            } else if currentStep == 2 {
                // Screen 2: Multi-select starter templates
                VStack(spacing: 16) {
                    Text("What do you want to remember?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Select a few things to get started. You can add more or customize anything later.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                            ForEach(starterTemplates) { template in
                                let isSelected = selectedTemplates.contains(template.id)
                                Button {
                                    if isSelected {
                                        selectedTemplates.remove(template.id)
                                    } else {
                                        selectedTemplates.insert(template.id)
                                    }
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: template.icon)
                                            .font(.system(size: 16))
                                            .foregroundColor(isSelected ? .white : .accentColor)
                                        
                                        Text(template.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(isSelected ? .white : .primary)
                                            .lineLimit(1)
                                        
                                        Spacer(minLength: 0)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .background(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    .frame(maxHeight: 340)
                }
            } else {
                // Screen 3: Ready
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(.green)
                    
                    Text("You're ready.")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Since will remember it for you.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("Add activities, tap 'Done Now' when completed, and glance at your widgets anytime.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            
            Spacer()
            
            // Bottom Action Controls
            VStack(spacing: 12) {
                if currentStep == 1 {
                    PrimaryButton(title: "Get Started") {
                        withAnimation {
                            currentStep = 2
                        }
                    }
                } else if currentStep == 2 {
                    PrimaryButton(title: selectedTemplates.isEmpty ? "Skip" : "Continue (\(selectedTemplates.count))") {
                        saveSelectedTemplates()
                        withAnimation {
                            currentStep = 3
                        }
                    }
                } else {
                    PrimaryButton(title: "Start") {
                        UserSettings.shared.hasCompletedOnboarding = true
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
    
    private func saveSelectedTemplates() {
        for template in starterTemplates where selectedTemplates.contains(template.id) {
            ItemService.shared.createItem(
                name: template.name,
                category: template.category,
                icon: template.icon,
                intervalValue: template.defaultIntervalValue,
                intervalUnit: template.defaultIntervalUnit,
                initialCompletionDate: nil,
                notificationEnabled: false,
                notificationOffset: 0,
                context: modelContext
            )
        }
    }
}
