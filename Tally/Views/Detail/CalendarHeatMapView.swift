import SwiftUI

struct CalendarHeatMapView: View {
    let data: [Date: Int]
    let accentColor: Color

    private let columns = Array(repeating: GridItem(.fixed(14), spacing: 3), count: 7)
    private let calendar = DateHelpers.calendar

    private var sortedDates: [Date] {
        let today = DateHelpers.startOfDay(Date())
        guard let start = Calendar.current.date(byAdding: .day, value: -89, to: today) else { return [] }

        // Align start to the beginning of its week (Sunday)
        let weekday = calendar.component(.weekday, from: start)
        let alignedStart = calendar.date(byAdding: .day, value: -(weekday - 1), to: start) ?? start

        return DateHelpers.datesInRange(from: alignedStart, to: today)
    }

    private var maxCount: Int {
        max(1, data.values.filter { $0 > 0 }.max() ?? 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("90-Day Heat Map")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            // Weekday labels + grid
            HStack(alignment: .top, spacing: 3) {
                // Weekday initials
                VStack(spacing: 3) {
                    ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                            .frame(width: 14, height: 14)
                    }
                }

                // Heat map grid — laid out as columns (weeks)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: Array(repeating: GridItem(.fixed(14), spacing: 3), count: 7), spacing: 3) {
                        ForEach(sortedDates, id: \.self) { date in
                            let count = data[date] ?? 0
                            RoundedRectangle(cornerRadius: 2)
                                .fill(cellColor(for: count))
                                .frame(width: 14, height: 14)
                        }
                    }
                }
            }
        }
    }

    private func cellColor(for count: Int) -> Color {
        if count < 0 {
            // Slip day for break habits
            return .red.opacity(0.6)
        } else if count == 0 {
            return .white.opacity(0.06)
        } else {
            let intensity = min(1.0, Double(count) / Double(maxCount))
            let minOpacity = 0.25
            let opacity = minOpacity + intensity * (1.0 - minOpacity)
            return accentColor.opacity(opacity)
        }
    }
}
