import SwiftUI

struct CalendarHeatMapView: View {
    let data: [Date: Int]
    let accentColor: Color

    private let calendar = DateHelpers.calendar

    private var sortedDates: [Date] {
        let today = DateHelpers.startOfDay(Date())
        guard let start = calendar.date(byAdding: .day, value: -89, to: today) else {
            return []
        }

        // Align the first displayed date to the beginning of its week
        let weekday = calendar.component(.weekday, from: start)
        let alignedStart = calendar.date(byAdding: .day, value: -(weekday - 1), to: start) ?? start

        return DateHelpers.datesInRange(from: alignedStart, to: today)
    }

    private var maxCount: Int {
        max(1, data.values.filter { $0 > 0 }.max() ?? 1)
    }

    private let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("90-Day Heat Map")
                .font(.headline)
                .foregroundStyle(.white)

            HStack(alignment: .top, spacing: 6) {
                VStack(spacing: 3) {
                    ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, day in
                        Text(day)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 14, height: 14)
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(
                        rows: Array(repeating: GridItem(.fixed(14), spacing: 3), count: 7),
                        spacing: 3
                    ) {
                        ForEach(sortedDates, id: \.self) { date in
                            let count = data[date] ?? 0

                            RoundedRectangle(cornerRadius: 3)
                                .fill(cellColor(for: count))
                                .frame(width: 14, height: 14)
                                .accessibilityElement()
                                .accessibilityLabel(accessibilityText(for: date, count: count))
                        }
                    }
                    .padding(.vertical, 1)
                }
            }

            legendView
        }
    }

    private var legendView: some View {
        HStack(spacing: 10) {
            Text("Less")
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white.opacity(0.06))
                    .frame(width: 12, height: 12)

                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor.opacity(0.3))
                    .frame(width: 12, height: 12)

                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor.opacity(0.6))
                    .frame(width: 12, height: 12)

                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor.opacity(1.0))
                    .frame(width: 12, height: 12)
            }

            Text("More")
                .font(.caption2)
                .foregroundStyle(.secondary)

            if data.values.contains(where: { $0 < 0 }) {
                Spacer()

                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.red.opacity(0.6))
                        .frame(width: 12, height: 12)

                    Text("Slip")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func cellColor(for count: Int) -> Color {
        if count < 0 {
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

    private func accessibilityText(for date: Date, count: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        if count < 0 {
            return "\(formatter.string(from: date)), slip day"
        } else if count == 0 {
            return "\(formatter.string(from: date)), no activity"
        } else if count == 1 {
            return "\(formatter.string(from: date)), 1 completion"
        } else {
            return "\(formatter.string(from: date)), \(count) completions"
        }
    }
}
