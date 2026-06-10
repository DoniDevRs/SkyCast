import SwiftUI

struct AQView: View {
    let latitude: Double
    let longitude: Double

    @State private var viewModel = AQViewModel()

    var body: some View {
        ZStack {
            backgroundGradient

            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else if let aq = viewModel.airQuality {
                aqContent(aq: aq)
            }
        }
        .navigationTitle("Air Quality")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await viewModel.loadAirQuality(
                latitude: latitude,
                longitude: longitude
            )
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(hex: "0f2a1a"), Color(hex: "0a1a12")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - States

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.5)
            Text("Loading air quality...")
                .foregroundStyle(.white.opacity(0.7))
                .font(.system(size: 14, weight: .regular, design: .rounded))
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.7))
            Text("Could not load air quality")
                .foregroundStyle(.white)
                .font(.system(size: 18, weight: .semibold))
            Text(message)
                .foregroundStyle(.white.opacity(0.6))
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Try Again") {
                Task {
                    await viewModel.refresh(
                        latitude: latitude,
                        longitude: longitude
                    )
                }
            }
            .buttonStyle(.bordered)
            .tint(.white)
        }
    }

    // MARK: - AQ Content

    private func aqContent(aq: AQModel) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                aqHeader(aq: aq)
                aqGaugeBar(aq: aq)
                pollutantsGrid(aq: aq)
                recommendationCard(aq: aq)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .refreshable {
            await viewModel.refresh(
                latitude: latitude,
                longitude: longitude
            )
        }
    }

    // MARK: - Header

    private func aqHeader(aq: AQModel) -> some View {
        VStack(spacing: 4) {
            Text("\(aq.overallAQI)")
                .foregroundStyle(aq.category.color)
                .font(.system(size: 72, weight: .thin))
                .kerning(-3)

            Text(aq.category.label)
                .foregroundStyle(aq.category.color)
                .font(.system(size: 16, weight: .semibold))

            Text("\(aq.locationName) · Updated just now")
                .foregroundStyle(.white.opacity(0.4))
                .font(.system(size: 11))
                .padding(.top, 2)
        }
        .padding(.top, 24)
    }

    // MARK: - Gauge Bar

    private func aqGaugeBar(aq: AQModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Good")
                Spacer()
                Text("Moderate")
                Spacer()
                Text("Unhealthy")
                Spacer()
                Text("Hazardous")
            }
            .foregroundStyle(.white.opacity(0.4))
            .font(.system(size: 8, weight: .medium))

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "4ade80"),
                                Color(hex: "facc15"),
                                Color(hex: "fb923c"),
                                Color(hex: "ef4444"),
                                Color(hex: "a855f7"),
                                Color(hex: "7f1d1d")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 6)

                GeometryReader { geo in
                    Circle()
                        .fill(.white)
                        .frame(width: 12, height: 12)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                        .offset(
                            x: geo.size.width * aq.category.gaugePosition - 6,
                            y: -3
                        )
                }
                .frame(height: 6)
            }
        }
        .padding(14)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Pollutants Grid

    private func pollutantsGrid(aq: AQModel) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 10
        ) {
            ForEach(aq.measurements, id: \.parameter.rawValue) { measurement in
                pollutantCard(measurement: measurement)
            }
        }
    }

    private func pollutantCard(measurement: AQMeasurement) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(measurement.parameter.displayName)
                .foregroundStyle(.white.opacity(0.4))
                .font(.system(size: 10, weight: .medium))
                .tracking(0.5)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(String(format: "%.0f", measurement.value))
                    .foregroundStyle(.white)
                    .font(.system(size: 28, weight: .thin))

                Text(measurement.parameter.unit)
                    .foregroundStyle(.white.opacity(0.3))
                    .font(.system(size: 9))
            }

            pollutantStatus(measurement: measurement)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }

    private func pollutantStatus(measurement: AQMeasurement) -> some View {
        let category = categoryForMeasurement(measurement)
        return HStack(spacing: 4) {
            Circle()
                .fill(category.color)
                .frame(width: 6, height: 6)
            Text(category.label)
                .foregroundStyle(category.color)
                .font(.system(size: 10))
        }
    }

    private func categoryForMeasurement(_ measurement: AQMeasurement) -> AQCategory {
        switch measurement.parameter {
        case .pm25:
            return AQCategory.from(aqi: AQMapper.pm25ToAQI(measurement.value))
        case .pm10:
            return AQCategory.from(aqi: AQMapper.pm10ToAQI(measurement.value))
        case .no2:
            return measurement.value < 100 ? .good : measurement.value < 200 ? .moderate : .unhealthy
        case .o3:
            return measurement.value < 100 ? .good : measurement.value < 160 ? .moderate : .unhealthy
        }
    }

    // MARK: - Recommendation

    private func recommendationCard(aq: AQModel) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 14))
                .foregroundStyle(aq.category.color)
                .padding(.top, 2)

            Text(aq.category.recommendation)
                .foregroundStyle(.white.opacity(0.7))
                .font(.system(size: 13))
                .lineSpacing(4)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(aq.category.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(aq.category.color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        AQView(latitude: -23.5, longitude: -46.6)
    }
}
