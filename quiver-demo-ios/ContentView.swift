import SwiftUI
import Charts
import Quiver
import UIKit

struct ContentView: View {
    var model = FinanceModel()

    let skyBlue = Color(red: 0.29, green: 0.56, blue: 0.85)
    let coral = Color(red: 1.0, green: 0.42, blue: 0.42)
    let accentGreen = Color(red: 0.31, green: 0.80, blue: 0.77)

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    thisMonthHeader

                    if isIPad {
                        LazyVGrid(
                            columns: [GridItem(.flexible()), GridItem(.flexible())],
                            spacing: 16
                        ) {
                            whereItGoesChart
                            weeklyBreakdownChart
                        }
                        unusualDaysChart
                    } else {
                        whereItGoesChart
                        weeklyBreakdownChart
                        unusualDaysChart
                    }
                }
                .padding()
            }
            .navigationTitle("Quiver Finance")
        }
    }

    // MARK: - This Month

    private var thisMonthHeader: some View {
        HStack(spacing: 16) {
            statCard("Total", value: String(format: "$%.0f", model.totalSpending))
            statCard("Daily Avg", value: String(format: "$%.0f", model.dailyAverage))
            statCard("Daily Spread",
                     value: String(format: "±$%.0f", model.dailyStd))
            let change = model.monthOverMonthChange
            statCard("vs Last Month", value: String(format: "%+.1f%%", change * 100),
                     color: change >= 0 ? coral : accentGreen)
        }
    }

    private func statCard(_ title: String, value: String, color: Color = .primary) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3).bold().foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Where It Goes (donut)

    private var whereItGoesChart: some View {
        VStack(alignment: .leading) {
            sectionHeader("Where It Goes",
                subtitle: "One Quiver call aggregates transactions by category and normalizes to 100% — no manual grouping, sorting, or percentage math.")
            Chart {
                ForEach(model.categoryBreakdown, id: \.category) { item in
                    SectorMark(angle: .value("Share", item.value), innerRadius: .ratio(0.5))
                        .foregroundStyle(by: .value("Category", item.category))
                }
            }
            .frame(height: isIPad ? 440 : 220)
        }
    }

    // MARK: - Weekly Breakdown

    private var weeklyBreakdownChart: some View {
        VStack(alignment: .leading) {
            sectionHeader("Weekly Breakdown",
                subtitle: "Quiver's downsample chunks 30 days into weekly groups and sums each — one call converts daily noise into a clear weekly pattern.")
            Chart {
                ForEach(Array(zip(model.weekLabels, model.weeklyTotals)), id: \.0) { week, total in
                    BarMark(x: .value("Week", week), y: .value("Total", total))
                        .foregroundStyle(skyBlue)
                }
            }
            .frame(height: isIPad ? 440 : 200)
        }
    }

    // MARK: - Unusual Days

    private var unusualDaysChart: some View {
        VStack(alignment: .leading) {
            sectionHeader("Unusual Days",
                subtitle: String(format: "Quiver's outlierMask flags days where |value − mean| / std exceeds 1.5. With mean $%.0f and std $%.0f, the cutoff sits near $%.0f.",
                                 model.dailyAverage,
                                 model.dailyStd,
                                 model.dailyAverage + 1.5 * model.dailyStd))
            let flags = model.outlierFlags
            Chart {
                ForEach(Array(model.dailySpending.enumerated()), id: \.offset) { day, amount in
                    PointMark(x: .value("Day", day + 1), y: .value("Amount", amount))
                        .foregroundStyle(flags[day] ? coral : skyBlue)
                        .symbolSize(flags[day] ? 200 : 40)
                        .annotation(position: .top) {
                            if flags[day] {
                                Text("$\(Int(amount))")
                                    .font(.caption2).bold()
                                    .foregroundStyle(coral)
                            }
                        }
                }
            }
            .frame(height: isIPad ? 360 : 200)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline)
            Text(subtitle).font(.caption).foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
