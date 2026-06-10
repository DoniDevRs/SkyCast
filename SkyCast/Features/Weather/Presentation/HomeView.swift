import SwiftUI

struct HomeView: View {
    @Binding var selectedCity: SavedCity?
    @State private var viewModel = HomeViewModel()

    var body: some View {
        ZStack {
            backgroundGradient

            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else if let weather = viewModel.weather {
                weatherContent(weather: weather)
            } else {
                emptyView
            }
        }
        .task {
            viewModel.updateCity(selectedCity)
            await viewModel.loadWeather()
        }
        .onChange(of: selectedCity) {
            viewModel.updateCity(selectedCity)
            Task { await viewModel.loadWeather() }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var gradientColors: [Color] {
        guard let weather = viewModel.weather else {
            return [Color(hex: "1a2a4a"), Color(hex: "0d1525")]
        }
        let code = weather.current.weatherCode
        switch code {
        case 0:
            return [Color(hex: "1a6bb5"), Color(hex: "0d3d6b")]
        case 1, 2, 3:
            return [Color(hex: "3a4a6a"), Color(hex: "1a2535")]
        case 45, 48:
            return [Color(hex: "4a4a5a"), Color(hex: "2a2a35")]
        case 61...65, 80...82:
            return [Color(hex: "1a3a5a"), Color(hex: "0d1f35")]
        case 71...75, 85, 86:
            return [Color(hex: "3a4a6a"), Color(hex: "2a3545")]
        case 95, 96, 99:
            return [Color(hex: "2a2a3a"), Color(hex: "0d0d1a")]
        default:
            return [Color(hex: "1a2a4a"), Color(hex: "0d1525")]
        }
    }

    // MARK: - States

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.5)
            Text("Loading weather...")
                .foregroundStyle(.white.opacity(0.7))
                .font(.system(size: 14, weight: .regular, design: .rounded))
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.7))
            Text("Something went wrong")
                .foregroundStyle(.white)
                .font(.system(size: 18, weight: .semibold))
            Text(message)
                .foregroundStyle(.white.opacity(0.6))
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Try Again") {
                Task { await viewModel.refresh() }
            }
            .buttonStyle(.bordered)
            .tint(.white)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.5))
            Text("No location selected")
                .foregroundStyle(.white.opacity(0.7))
                .font(.system(size: 16))
        }
    }

    // MARK: - Weather Content

    private func weatherContent(weather: WeatherModel) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                currentWeatherHeader(weather: weather)
                    .padding(.bottom, 24)

                statsRow(weather: weather)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                HourlyForecastView(hourly: weather.hourly)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)

                DailyForecastView(daily: weather.daily)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
    }

    // MARK: - Current Header

    private func currentWeatherHeader(weather: WeatherModel) -> some View {
        VStack(spacing: 4) {
            Text(selectedCity == nil ? "My Location" : "")
                .foregroundStyle(.white.opacity(0.6))
                .font(.system(size: 12, weight: .medium))
                .tracking(1)

            Text(weather.cityName)
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .semibold))

            Text("\(Int(weather.current.temperature))°")
                .foregroundStyle(.white)
                .font(.system(size: 80, weight: .thin))
                .kerning(-4)

            Text(weather.current.condition.description)
                .foregroundStyle(.white.opacity(0.7))
                .font(.system(size: 14, weight: .regular))

            Text("H:\(Int(weather.daily.first?.maxTemperature ?? 0))° L:\(Int(weather.daily.first?.minTemperature ?? 0))°")
                .foregroundStyle(.white.opacity(0.5))
                .font(.system(size: 13))
        }
        .padding(.top, 60)
    }

    // MARK: - Stats Row

    private func statsRow(weather: WeatherModel) -> some View {
        HStack(spacing: 0) {
            statItem(
                label: "Feels",
                value: "\(Int(weather.current.apparentTemperature))°"
            )
            Divider()
                .background(.white.opacity(0.2))
                .frame(height: 30)
            statItem(
                label: "Wind",
                value: "\(Int(weather.current.windSpeed)) km/h"
            )
            Divider()
                .background(.white.opacity(0.2))
                .frame(height: 30)
            statItem(
                label: "Humid",
                value: "\(weather.current.humidity)%"
            )
            Divider()
                .background(.white.opacity(0.2))
                .frame(height: 30)
            statItem(
                label: "Rain",
                value: "\(String(format: "%.1f", weather.current.precipitation))mm"
            )
        }
        .padding(.vertical, 12)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }

    private func statItem(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .foregroundStyle(.white.opacity(0.4))
                .font(.system(size: 10, weight: .medium))
                .tracking(0.5)
            Text(value)
                .foregroundStyle(.white)
                .font(.system(size: 13, weight: .semibold))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView(selectedCity: .constant(nil))
}
