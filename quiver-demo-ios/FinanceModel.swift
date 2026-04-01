// Copyright 2026 Wayne W Bishop. All rights reserved.
// Licensed under the Apache License, Version 2.0.

import Foundation
import Quiver

// Quiver Demo — Personal Finance Dashboard
//
// Most finance apps show totals and categories but can't explain what
// changed or why. Quiver turns raw transaction data into statistical
// insights — percentage normalization that shows where money goes,
// downsampling that reveals weekly patterns, and z-score outlier
// detection that flags the days that broke the budget. Every
// computation runs directly on [Double] arrays — the same arrays
// that SwiftUI and Swift Charts render.

@Observable
class FinanceModel {

    // MARK: - Simulated transaction data

    // The single source of truth — 24 transactions paired with
    // category labels. Every chart in this demo is derived from
    // these two parallel arrays using Quiver. In a real app,
    // transactions would come from Core Data or a banking API.
    let amounts: [Double] = [
        32.0, 15.0, 8.0, 45.0, 120.0, 22.0,
        18.0, 55.0, 12.0, 85.0, 67.0, 9.0,
        42.0, 150.0, 28.0, 35.0, 14.0, 95.0,
        200.0, 75.0, 11.0, 38.0, 25.0, 60.0
    ]

    let categories: [String] = [
        "Food", "Transport", "Food", "Shopping", "Bills", "Food",
        "Transport", "Entertainment", "Food", "Bills", "Shopping", "Transport",
        "Food", "Shopping", "Health", "Food", "Transport", "Entertainment",
        "Bills", "Shopping", "Food", "Health", "Transport", "Food"
    ]

    // Daily spending over 30 days for the weekly and outlier charts.
    // Three splurge days ($310, $285, $360) create the outliers that
    // Quiver's outlierMask() will detect.
    let dailySpending: [Double] = [
        42.0, 55.0, 38.0, 67.0, 51.0, 73.0, 48.0,
        61.0, 44.0, 310.0, 52.0, 39.0, 58.0, 46.0,
        71.0, 63.0, 45.0, 285.0, 54.0, 49.0, 66.0,
        57.0, 41.0, 72.0, 53.0, 360.0, 47.0, 59.0,
        68.0, 50.0
    ]

    // Last month's total for month-over-month comparison
    let priorMonthTotal: Double = 1650.0
    let weekLabels = ["Week 1", "Week 2", "Week 3", "Week 4", "Week 5"]

    // MARK: - Quiver-powered analysis

    // sum() and mean() — the monthly headline numbers
    var totalSpending: Double { dailySpending.sum() }
    var dailyAverage: Double { dailySpending.mean() ?? 0.0 }

    // percentChange(lag:) computes the relative change between two
    // values in one call — no manual (new - old) / old arithmetic
    var monthOverMonthChange: Double {
        let twoMonths = [priorMonthTotal, dailySpending.sum()]
        return twoMonths.percentChange(lag: 1).first ?? 0.0
    }

    // groupedData(by:using: .percentage) aggregates transactions by
    // category and normalizes to 100% in a single call. This replaces
    // a 5-line chain of groupBy → sort → map → asPercentages → zip.
    var categoryBreakdown: [(category: String, value: Double)] {
        amounts.groupedData(by: categories, using: .percentage)
    }

    // downsample(factor:using:) chunks 30 days into groups of 6 and
    // sums each chunk — one call converts daily data into weekly totals
    var weeklyTotals: [Double] {
        dailySpending.downsample(factor: 6, using: .sum)
    }

    // outlierMask(threshold:) uses z-score analysis to flag days that
    // deviate significantly from the mean. Standard Swift has no
    // built-in outlier detection — this is one call.
    var outlierFlags: [Bool] {
        dailySpending.outlierMask(threshold: 1.5)
    }

    // maskedWithIndices(by:) extracts flagged values with their
    // original positions — useful for chart annotations
    var outlierDays: [(index: Int, value: Double)] {
        dailySpending.maskedWithIndices(by: outlierFlags)
    }
}
