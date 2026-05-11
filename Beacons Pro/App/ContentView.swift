import SwiftUI

enum AppTab: String, CaseIterable, Hashable {
    case scanner
    case beacons
    case broadcast
    case settings
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .scanner
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        } else {
            mainTabView
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ScannerTab()
            }
            .tabItem {
                Label("Scanner", systemImage: "sensor.tag.radiowaves.forward.fill")
            }
            .tag(AppTab.scanner)

            NavigationStack {
                BeaconsTab()
            }
            .tabItem {
                Label("Beacons", systemImage: "antenna.radiowaves.left.and.right")
            }
            .tag(AppTab.beacons)

            NavigationStack {
                BroadcastTab()
            }
            .tabItem {
                Label("Broadcast", systemImage: "dot.radiowaves.left.and.right")
            }
            .tag(AppTab.broadcast)

            NavigationStack {
                SettingsTab()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(AppTab.settings)
        }
        .tint(Theme.accentColor)
    }
}
