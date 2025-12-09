import SwiftUI

struct UpcomingEpisodesView: View {
    @EnvironmentObject var myshowsmodel: MyShowsModel
    let selectedDate: Date
    
    var body: some View {
        let items = myshowsmodel.upcomingEpisodes[selectedDate] ?? []
        List {
            if items.isEmpty {
                Section {
                    Text("No upcoming episodes for this date.")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section(header: Text(selectedDate, style: .date)) {
                    ForEach(items, id: \.1.id) { show, episode in
                        HStack {
                            Text(show.name)
                                .fontWeight(.semibold)
                            Spacer()
                            Text(episode.title)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Upcoming Episodes")
    }
}

// Preview with sample data
#Preview {
    let model = MyShowsModel()
    return UpcomingEpisodesView(selectedDate: Date())
        .environmentObject(model)
}
