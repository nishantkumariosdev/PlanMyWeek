import SwiftUI

struct ForecastView: View {
    @State private var viewModel: ForecastViewModel

    init(location: Location, service: any WeatherService) {
        _viewModel = State(initialValue: ForecastViewModel(location: location, service: service))
    }

    var body: some View {
        content
            .navigationTitle(viewModel.location.name)
            .task {
                await viewModel.loadIfNeeded()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Loading forecast…")
        case .failed(let message):
            ContentUnavailableView {
                Label("Forecast Unavailable", systemImage: "cloud.slash")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") {
                    Task { await viewModel.load() }
                }
            }
        case .loaded(let forecast):
            rankingList(timeZone: forecast.timeZone)
        }
    }

    private func rankingList(timeZone: TimeZone) -> some View {
        List {
            Section {
                Picker("Activity", selection: $viewModel.selectedActivity) {
                    ForEach(Activity.allCases) { activity in
                        Text(activity.shortTitle).tag(activity)
                    }
                }
                .pickerStyle(.segmented)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            } header: {
                if !viewModel.location.subtitle.isEmpty {
                    Text(viewModel.location.subtitle)
                }
            }

            Section {
                ForEach(Array(viewModel.rankedDays.enumerated()), id: \.element.id) { index, dayScore in
                    DayScoreRow(rank: index + 1, dayScore: dayScore, timeZone: timeZone)
                }
            } header: {
                Label(viewModel.selectedActivity.title, systemImage: viewModel.selectedActivity.symbolName)
            } footer: {
                if let note = viewModel.selectedActivity.note {
                    Text(note)
                }
            }
        }
        .refreshable {
            await viewModel.load()
        }
    }
}

#Preview {
    NavigationStack {
        ForecastView(
            location: Location(
                id: 2657928,
                name: "Zermatt",
                latitude: 46.02126,
                longitude: 7.74912,
                elevation: 1608,
                timezone: "Europe/Zurich",
                countryCode: "CH",
                country: "Switzerland",
                admin1: "Valais"
            ),
            service: OpenMeteoClient()
        )
    }
}
