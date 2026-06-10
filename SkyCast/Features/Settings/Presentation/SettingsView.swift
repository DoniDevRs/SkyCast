import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "0f0f1a").ignoresSafeArea()

            VStack(spacing: 0) {
                settingsHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        temperatureSection
                        windSection
                        locationSection
                        aboutSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var settingsHeader: some View {
        HStack {
            Text("Settings")
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .semibold))
            Spacer()
            Button("Done") {
                dismiss()
            }
            .foregroundStyle(Color(hex: "7DB8F7"))
            .font(.system(size: 14))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .overlay(
            Divider()
                .background(.white.opacity(0.08)),
            alignment: .bottom
        )
    }

    // MARK: - Temperature Section

    private var temperatureSection: some View {
        settingsGroup(title: "Temperature") {
            ForEach(TemperatureUnit.allCases, id: \.rawValue) { unit in
                settingsRow(
                    label: unit.label,
                    isSelected: viewModel.temperatureUnit == unit
                ) {
                    viewModel.temperatureUnit = unit
                }
            }
        }
    }

    // MARK: - Wind Section

    private var windSection: some View {
        settingsGroup(title: "Wind Speed") {
            ForEach(WindUnit.allCases, id: \.rawValue) { unit in
                settingsRow(
                    label: unit.label,
                    isSelected: viewModel.windUnit == unit
                ) {
                    viewModel.windUnit = unit
                }
            }
        }
    }

    // MARK: - Location Section

    private var locationSection: some View {
        settingsGroup(title: "Location") {
            HStack {
                Text("Use GPS automatically")
                    .foregroundStyle(.white)
                    .font(.system(size: 14))
                Spacer()
                Toggle("", isOn: $viewModel.useAutoLocation)
                    .tint(Color(hex: "7DB8F7"))
                    .labelsHidden()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        settingsGroup(title: "About") {
            infoRow(label: "Data source", value: "Open-Meteo")
            infoRow(label: "Air quality", value: "OpenAQ")
            infoRow(label: "Version", value: "1.0.0")
        }
    }

    // MARK: - Reusable Components

    private func settingsGroup<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .foregroundStyle(.white.opacity(0.3))
                .font(.system(size: 9, weight: .semibold))
                .tracking(1)
                .padding(.horizontal, 4)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                content()
            }
            .background(.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
        }
    }

    private func settingsRow(
        label: String,
        isSelected: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack {
                Text(label)
                    .foregroundStyle(.white)
                    .font(.system(size: 14))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color(hex: "7DB8F7"))
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .overlay(
            Divider()
                .background(.white.opacity(0.06)),
            alignment: .bottom
        )
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.white.opacity(0.6))
                .font(.system(size: 14))
            Spacer()
            Text(value)
                .foregroundStyle(.white.opacity(0.4))
                .font(.system(size: 14))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .overlay(
            Divider()
                .background(.white.opacity(0.06)),
            alignment: .bottom
        )
    }
}

#Preview {
    SettingsView()
}
