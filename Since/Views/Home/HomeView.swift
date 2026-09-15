//
//  HomeView.swift
//  Since
//
//  Main application dashboard delivering calm, glanceable memory of activities.
//

import SwiftUI
import SwiftData

public struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<TrackedItem> { !$0.isArchived }, sort: \TrackedItem.createdAt, order: .reverse)
    private var allItems: [TrackedItem]
    
    @State private var environment = AppEnvironment.shared
    @State private var userSettings = UserSettings.shared
    
    @State private var selectedTemplateForAdd: ActivityTemplate?
    @State private var itemPendingDeletion: TrackedItem?
    @State private var isShowingDeleteAlert: Bool = false
    @State private var navigationPath = NavigationPath()
    
    // Dynamic localized date string (e.g. "Tuesday, 15 September")
    private var localizedCurrentDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "EEEE, d MMMM"
        return formatter.string(from: Date())
    }
    
    // Filtered items based on search query
    private var searchFilteredItems: [TrackedItem] {
        let query = environment.searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if query.isEmpty {
            return allItems
        }
        return allItems.filter { item in
            let matchesName = item.name.lowercased().contains(query)
            let matchesCategory = item.category.lowercased().contains(query)
            let matchesNotes = item.history.contains { ($0.note ?? "").lowercased().contains(query) }
            return matchesName || matchesCategory || matchesNotes
        }
    }
    
    // Smart sections
    private var dueSoonAndOverdueItems: [TrackedItem] {
        searchFilteredItems.filter { item in
            let status = DateCalculationService.status(
                lastCompletedAt: item.lastCompletedAt,
                createdAt: item.createdAt,
                intervalValue: item.intervalValue,
                intervalUnit: item.intervalUnit
            )
            return status.isAttentionNeeded
        }.sorted { item1, item2 in
            let s1 = DateCalculationService.status(
                lastCompletedAt: item1.lastCompletedAt,
                createdAt: item1.createdAt,
                intervalValue: item1.intervalValue,
                intervalUnit: item1.intervalUnit
            )
            let s2 = DateCalculationService.status(
                lastCompletedAt: item2.lastCompletedAt,
                createdAt: item2.createdAt,
                intervalValue: item2.intervalValue,
                intervalUnit: item2.intervalUnit
            )
            return s1.sortPriority < s2.sortPriority
        }
    }
    
    private var longestAgoItems: [TrackedItem] {
        let attentionIds = Set(dueSoonAndOverdueItems.map(\.id))
        return searchFilteredItems.filter { item in
            !attentionIds.contains(item.id) &&
            DateCalculationService.daysElapsed(from: item.lastCompletedAt ?? item.createdAt) >= 14
        }.sorted {
            let d1 = DateCalculationService.daysElapsed(from: $0.lastCompletedAt ?? $0.createdAt)
            let d2 = DateCalculationService.daysElapsed(from: $1.lastCompletedAt ?? $1.createdAt)
            return d1 > d2
        }
    }
    
    private var recentlyDoneItems: [TrackedItem] {
        let attentionIds = Set(dueSoonAndOverdueItems.map(\.id))
        let longestAgoIds = Set(longestAgoItems.map(\.id))
        return searchFilteredItems.filter { item in
            !attentionIds.contains(item.id) && !longestAgoIds.contains(item.id)
        }.sorted {
            let d1 = DateCalculationService.daysElapsed(from: $0.lastCompletedAt ?? $0.createdAt)
            let d2 = DateCalculationService.daysElapsed(from: $1.lastCompletedAt ?? $1.createdAt)
            return d1 < d2
        }
    }
    
    private var customSortedItems: [TrackedItem] {
        switch userSettings.sortOption {
        case .longestAgo:
            return searchFilteredItems.sorted {
                DateCalculationService.daysElapsed(from: $0.lastCompletedAt ?? $0.createdAt) >
                DateCalculationService.daysElapsed(from: $1.lastCompletedAt ?? $1.createdAt)
            }
        case .recentlyDone:
            return searchFilteredItems.sorted {
                DateCalculationService.daysElapsed(from: $0.lastCompletedAt ?? $0.createdAt) <
                DateCalculationService.daysElapsed(from: $1.lastCompletedAt ?? $1.createdAt)
            }
        case .alphabetical:
            return searchFilteredItems.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .category:
            return searchFilteredItems.sorted { $0.category.localizedCaseInsensitiveCompare($1.category) == .orderedAscending }
        case .smart:
            return searchFilteredItems
        }
    }
    
    public var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if allItems.isEmpty {
                    EmptyStateView(
                        onAddFirstItem: {
                            environment.isShowingAddItem = true
                        },
                        onSelectTemplate: { template in
                            selectedTemplateForAdd = template
                            environment.isShowingAddItem = true
                        }
                    )
                } else {
                    List {
                        if !environment.searchText.isEmpty {
                            Section("SEARCH RESULTS") {
                                ForEach(searchFilteredItems) { item in
                                    NavigationLink(value: item) {
                                        ItemRow(item: item) {
                                            handleDoneNow(item)
                                        }
                                    }
                                }
                            }
                        } else if userSettings.sortOption == .smart {
                            HomeSectionView(
                                title: "DUE SOON",
                                subtitle: nil,
                                items: dueSoonAndOverdueItems,
                                onDoneNow: handleDoneNow,
                                onArchive: handleArchive,
                                onDelete: confirmDelete
                            )
                            
                            HomeSectionView(
                                title: "YOU HAVEN'T DONE",
                                subtitle: nil,
                                items: longestAgoItems,
                                onDoneNow: handleDoneNow,
                                onArchive: handleArchive,
                                onDelete: confirmDelete
                            )
                            
                            HomeSectionView(
                                title: "RECENTLY DONE",
                                subtitle: nil,
                                items: recentlyDoneItems,
                                onDoneNow: handleDoneNow,
                                onArchive: handleArchive,
                                onDelete: confirmDelete
                            )
                        } else {
                            Section {
                                ForEach(customSortedItems) { item in
                                    NavigationLink(value: item) {
                                        ItemRow(item: item) {
                                            handleDoneNow(item)
                                        }
                                    }
                                }
                            } header: {
                                Text(userSettings.sortOption.displayName.uppercased())
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Since")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        environment.isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .accessibilityLabel("Settings")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Sort By", selection: $userSettings.sortOption) {
                            ForEach(SortOption.allCases) { opt in
                                Label(opt.displayName, systemImage: opt.systemImageName)
                                    .tag(opt)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .accessibilityLabel("Sort Options")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selectedTemplateForAdd = nil
                        environment.isShowingAddItem = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .accessibilityLabel("Add Item")
                }
            }
            .searchable(
                text: $environment.searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Search items, categories, notes"
            )
            .navigationDestination(for: TrackedItem.self) { item in
                ItemDetailView(item: item)
            }
            .sheet(isPresented: $environment.isShowingAddItem) {
                AddItemView(initialTemplate: selectedTemplateForAdd)
            }
            .sheet(isPresented: $environment.isShowingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $environment.isShowingOnboarding) {
                OnboardingView()
            }
            .confirmationDialog(
                "Delete \(itemPendingDeletion?.name ?? "Item")?",
                isPresented: $isShowingDeleteAlert,
                titleVisibility: .visible,
                presenting: itemPendingDeletion
            ) { item in
                Button("Delete", role: .destructive) {
                    ItemService.shared.deleteItem(item, context: modelContext)
                }
                Button("Cancel", role: .cancel) {}
            } message: { item in
                Text("This will permanently delete its history.")
            }
            .onAppear {
                if !userSettings.hasCompletedOnboarding && allItems.isEmpty {
                    environment.isShowingOnboarding = true
                }
            }
            .onChange(of: environment.selectedItemIdForNavigation) { _, newId in
                if let newId = newId, let targetItem = allItems.first(where: { $0.id == newId }) {
                    navigationPath.append(targetItem)
                    environment.selectedItemIdForNavigation = nil
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleDoneNow(_ item: TrackedItem) {
        ItemService.shared.markDone(item: item, context: modelContext)
    }
    
    private func handleArchive(_ item: TrackedItem) {
        ItemService.shared.archiveItem(item, context: modelContext)
    }
    
    private func confirmDelete(_ item: TrackedItem) {
        itemPendingDeletion = item
        isShowingDeleteAlert = true
    }
}
