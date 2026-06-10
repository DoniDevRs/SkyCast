import SwiftUI

struct SearchView: View {
    @State private var viewModel = SearchViewModel()
    @Binding var selectedCity: SavedCity?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "0f0f1a").ignoresSafeArea()

            VStack(spacing: 0) {
                searchHeader
                searchField
                Divider()
                    .background(.white.opacity(0.08))
                resultsList
            }
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.query) {
            viewModel.onQueryChanged()
        }
    }

    // MARK: - Header

    private var searchHeader: some View {
        HStack {
            Text("Search City")
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .semibold))
            Spacer()
            Button("Cancel") {
                dismiss()
            }
            .foregroundStyle(Color(hex: "7DB8F7"))
            .font(.system(size: 14))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Search Field

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.3))
                .font(.system(size: 14))

            TextField("", text: $viewModel.query)
                .foregroundStyle(.white)
                .font(.system(size: 14))
                .placeholder(when: viewModel.query.isEmpty) {
                    Text("New York, Tokyo, London...")
                        .foregroundStyle(.white.opacity(0.3))
                        .font(.system(size: 14))
                }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.3))
                        .font(.system(size: 14))
                }
            }

            if viewModel.isSearching {
                ProgressView()
                    .tint(.white.opacity(0.5))
                    .scaleEffect(0.7)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Results List

    private var resultsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                if viewModel.query.isEmpty {
                    recentSection
                } else if viewModel.results.isEmpty && !viewModel.isSearching {
                    emptyResults
                } else {
                    searchResults
                }
            }
        }
    }

    // MARK: - Recent Section

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            if !viewModel.recentSearches.isEmpty {
                sectionLabel("Recent")
                ForEach(viewModel.recentSearches) { city in
                    cityRow(city: city, showDelete: true)
                }
            }
        }
    }

    // MARK: - Search Results

    private var searchResults: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("Results")
            ForEach(viewModel.results) { city in
                cityRow(city: city, showDelete: false)
            }
        }
    }

    // MARK: - Empty Results

    private var emptyResults: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.2))
                .padding(.top, 48)
            Text("No cities found")
                .foregroundStyle(.white.opacity(0.4))
                .font(.system(size: 14))
            Text("Try a different search term")
                .foregroundStyle(.white.opacity(0.25))
                .font(.system(size: 12))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - City Row

    private func cityRow(city: SavedCity, showDelete: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Circle()
                    .fill(isSelected(city) ? Color(hex: "7DB8F7") : .white.opacity(0.15))
                    .frame(width: 7, height: 7)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(city.name)
                        .foregroundStyle(.white)
                        .font(.system(size: 14, weight: .medium))
                    Text("\(city.country)\(isSelected(city) ? " · Current" : "")")
                        .foregroundStyle(.white.opacity(0.4))
                        .font(.system(size: 11))
                }
                
                Spacer()
                
                if showDelete {
                    Button {
                        viewModel.removeRecent(city)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected(city) ? .white.opacity(0.05) : .clear)
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.selectCity(city)
                selectedCity = city
                dismiss()
            }
            
            Divider()
                .background(.white.opacity(0.05))
                .padding(.leading, 16)
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .foregroundStyle(.white.opacity(0.3))
            .font(.system(size: 9, weight: .semibold))
            .tracking(1)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 6)
    }

    private func isSelected(_ city: SavedCity) -> Bool {
        selectedCity?.name == city.name && selectedCity?.country == city.country
    }
}

// MARK: - Placeholder Extension

extension View {
    func placeholder<Content: View>(
        when condition: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack(alignment: .leading) {
            if condition { content() }
            self
        }
    }
}

#Preview {
    SearchView(selectedCity: .constant(nil))
}
