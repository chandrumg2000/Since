//
//  SettingsView.swift
//  Since
//
//  Application settings, appearance themes, notifications, and local data management.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [TrackedItem]
    
    @State private var userSettings = UserSettings.shared
    
    // Export state
    @State private var exportFileURL: URL?
    @State private var isShowingShareSheet: Bool = false
    
    // Import state
    @State private var isShowingFileImporter: Bool = false
    @State private var importSuccessMessage: String?
    @State private var importErrorMessage: String?
    @State private var isShowingImportAlert: Bool = false
    
    // Notification time binding
    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = userSettings.notificationTimeHour
                components.minute = userSettings.notificationTimeMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                userSettings.notificationTimeHour = components.hour ?? 9
                userSettings.notificationTimeMinute = components.minute ?? 0
            }
        )
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // MARK: - General
                Section("GENERAL") {
                    Picker("Default Category", selection: $userSettings.defaultCategory) {
                        ForEach(ItemCategory.allCases) { cat in
                            Label(cat.displayName, systemImage: cat.systemIcon)
                                .tag(cat.rawValue)
                        }
                    }
                    
                    Picker("Default Sort", selection: $userSettings.sortOption) {
                        ForEach(SortOption.allCases) { opt in
                            Label(opt.displayName, systemImage: opt.systemImageName)
                                .tag(opt)
                        }
                    }
                    
                    Toggle("Haptic Feedback", isOn: $userSettings.hapticsEnabled)
                }
                
                // MARK: - Appearance
                Section("APPEARANCE") {
                    Picker("Theme", selection: $userSettings.appearance) {
                        ForEach(AppAppearance.allCases) { app in
                            Text(app.displayName).tag(app)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // MARK: - Notifications
                Section("NOTIFICATIONS") {
                    DatePicker(
                        "Daily Reminder Time",
                        selection: reminderTimeBinding,
                        displayedComponents: [.hourAndMinute]
                    )
                    
                    Picker("Default Timing", selection: $userSettings.defaultNotificationOffset) {
                        Text("On due date").tag(0)
                        Text("1 day before").tag(1)
                        Text("3 days before").tag(3)
                        Text("7 days before").tag(7)
                    }
                }
                
                // MARK: - Data Management
                Section("DATA & BACKUP") {
                    NavigationLink {
                        ArchivedItemsView()
                    } label: {
                        HStack {
                            Text("Archived Activities")
                            Spacer()
                            let archivedCount = allItems.filter(\.isArchived).count
                            Text("\(archivedCount)")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button {
                        handleExportData()
                    } label: {
                        Label("Export Data (JSON)", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        isShowingFileImporter = true
                    } label: {
                        Label("Import Data (JSON)", systemImage: "square.and.arrow.down")
                    }
                }
                
                // MARK: - Privacy & Philosophy
                Section("PRIVACY") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Local-First Design")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("Since stores all your activities, dates, and notes exclusively on your device. There are no accounts, no cloud servers, no analytics trackers, and no advertisements.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                // MARK: - About
                Section("ABOUT") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Build 1)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Tagline")
                        Spacer()
                        Text("Remember when.")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $isShowingShareSheet) {
                if let fileURL = exportFileURL {
                    ShareSheet(activityItems: [fileURL])
                }
            }
            .fileImporter(
                isPresented: $isShowingFileImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result: result)
            }
            .alert(
                importErrorMessage != nil ? "Import Error" : "Import Successful",
                isPresented: $isShowingImportAlert
            ) {
                Button("OK") {}
            } message: {
                Text(importErrorMessage ?? importSuccessMessage ?? "")
            }
        }
    }
    
    // MARK: - Export Logic
    
    private func handleExportData() {
        do {
            let data = try ExportImportService.shared.exportData(items: allItems)
            let fileURL = try ExportImportService.shared.createExportFileURL(from: data)
            self.exportFileURL = fileURL
            self.isShowingShareSheet = true
        } catch {
            print("Export error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Import Logic
    
    private func handleFileImport(result: Result<[URL], Error>) {
        do {
            guard let selectedURL = try result.get().first else { return }
            
            if selectedURL.startAccessingSecurityScopedResource() {
                defer { selectedURL.stopAccessingSecurityScopedResource() }
                let data = try Data(contentsOf: selectedURL)
                let count = try ExportImportService.shared.importData(from: data, context: modelContext)
                
                self.importSuccessMessage = "Successfully imported \(count) activities."
                self.importErrorMessage = nil
                self.isShowingImportAlert = true
            }
        } catch {
            self.importErrorMessage = "Failed to import backup: \(error.localizedDescription)"
            self.importSuccessMessage = nil
            self.isShowingImportAlert = true
        }
    }
}

// Native iOS Activity ViewController wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
