import SwiftUI

struct CitySearchView: View {
    private let service: any WeatherService
    @State private var viewModel: CitySearchViewModel
    @State private var path: [Location] = []

    init(service: any WeatherService) {
        self.service = service
        _viewModel = State(initialValue: CitySearchViewModel(service: service))
    }

    var body: some View {
        NavigationStack(path: $path) {
            content
                .navigationTitle("Plan My Week")
                .searchable(
                    text: $viewModel.query,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "City or town"
                )
                .autocorrectionDisabled()
                .task(id: viewModel.query) {
                    await viewModel.search()
                }
                .navigationDestination(for: Location.self) { location in
                    ForecastView(location: location, service: service)
                }
        }
        .onChange(of: path) { _, newPath in
            if let location = newPath.last {
                viewModel.addRecent(location)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            if viewModel.recentCities.isEmpty {
                searchPrompt
            } else {
                recentList
            }
        case .loading:
            ProgressView("Searching…")
        case .noResults:
            ContentUnavailableView.search(text: viewModel.query)
        case .failed(let message):
            ContentUnavailableView {
                Label("Search Failed", systemImage: "wifi.exclamationmark")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") {
                    Task { await viewModel.search() }
                }
            }
        case .results(let locations):
            List(locations) { location in
                NavigationLink(value: location) {
                    LocationRow(location: location)
                }
            }
            .listStyle(.plain)
        }
    }

    private var searchPrompt: some View {
        ContentUnavailableView(
            "Search for a City",
            systemImage: "magnifyingglass",
            description: Text("Find a city or town to see how good the next 7 days are for skiing, surfing and sightseeing.")
        )
    }

    private var recentList: some View {
        List {
            Section {
                searchPrompt
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
            }

            Section {
                ForEach(viewModel.recentCities) { location in
                    NavigationLink(value: location) {
                        LocationRow(location: location)
                    }
                }
                .onDelete { offsets in
                    viewModel.removeRecents(at: offsets)
                }
            } header: {
                HStack {
                    Text("Recent")
                    Spacer()
                    Button("Clear") {
                        viewModel.clearRecents()
                    }
                }
                .textCase(nil)
            }
        }
    }
}

private struct LocationRow: View {
    let location: Location

    var body: some View {
        HStack(spacing: 12) {
            Text(location.flagEmoji ?? "📍")
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(location.name)
                    .font(.headline)
                if !location.subtitle.isEmpty {
                    Text(location.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    CitySearchView(service: OpenMeteoClient())
}
