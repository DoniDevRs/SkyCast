import SwiftUI

struct ContentView: View {
    @State private var selectedCity: SavedCity?
    @State private var showSearch: Bool = false
    @State private var showSettings: Bool = false
    @State private var showAirQuality: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                HomeView(
                    selectedCity: $selectedCity
                )

                bottomBar
            }
            .navigationDestination(isPresented: $showSearch) {
                SearchView(selectedCity: $selectedCity)
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .navigationDestination(isPresented: $showAirQuality) {
                if let city = selectedCity {
                    AQView(
                        latitude: city.latitude,
                        longitude: city.longitude
                    )
                } else {
                    AQView(latitude: -23.5, longitude: -46.6)
                }
            }
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 0) {
            bottomBarButton(
                icon: "magnifyingglass",
                label: "Search"
            ) {
                showSearch = true
            }

            Spacer()

            bottomBarButton(
                icon: "wind",
                label: "Air Quality"
            ) {
                showAirQuality = true
            }

            Spacer()

            bottomBarButton(
                icon: "gearshape.fill",
                label: "Settings"
            ) {
                showSettings = true
            }
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 32)
        .padding(.bottom, 24)
    }

    private func bottomBarButton(
        icon: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.7))
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }
}

#Preview {
    ContentView()
}
