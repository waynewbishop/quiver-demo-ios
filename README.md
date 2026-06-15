# Quiver Demo for iOS

Personal finance apps show totals and categories, but they rarely reveal
what changed and why. Which days broke the pattern? How are spending
habits shifting week to week? Answering these questions requires outlier
detection, percentage normalization, and downsampling.

This demo uses [Quiver](https://github.com/waynewbishop/quiver) to build
a spending dashboard entirely on-device. `groupedData(by:using: .percentage)`
shows where money goes. `downsample(factor:using:)` converts 30 days
into weekly summaries. `outlierMask()` flags the days that broke the
pattern. All computation runs on Swift arrays — no server, no bridge,
no third-party analytics SDK.

## Run it

1. Clone this repo
2. Open in Xcode 26
3. Run on the iOS simulator

## Screens

**This Month** — Total spend, daily average, daily spread, and
month-over-month percentage change computed with `sum()`, `mean()`,
`standardDeviation()`, and `percentChange(lag:)`. Every headline
number shows up with the spread next to it — the daily mean alone
hides whether spending is steady or volatile.

**Where It Goes** — Donut chart of spending by category, powered by
`groupedData(by:using: .percentage)` — one call aggregates and normalizes.

**Weekly Breakdown** — Bar chart of weekly spending totals computed by
`downsample(factor:using:)` — one call chunks 30 days into 5 weeks.

**Unusual Days** — Scatter chart highlighting outlier spending days
detected by `outlierMask()` with dollar annotations on each flagged
day. The subtitle shows the live derivation — mean, standard
deviation, and the actual dollar cutoff — so the 1.5-threshold
becomes a visible computation rather than a black box.

## Quiver APIs used

- `sum()` / `mean()` — monthly total and daily average
- `standardDeviation()` / `standardError()` — daily spread and confidence in the mean
- `percentChange(lag:)` — month-over-month spending change
- `groupedData(by:using: .percentage)` — category shares normalized to 100%
- `downsample(factor:using:)` — chunk daily data into weekly summaries
- `outlierMask()` — z-score flagging of unusual spending days
- `maskedWithIndices(by:)` — extract flagged days with their positions

## Learn more

- [Quiver](https://github.com/waynewbishop/quiver) — the framework
- [Quiver Cookbook](https://github.com/waynewbishop/quiver-cookbook) — 41 interactive recipes
- [Quiver Documentation](https://waynewbishop.github.io/quiver/documentation/quiver/) — API reference and conceptual guides
- [Swift Algorithms & Data Structures](https://waynewbishop.github.io/swift-algorithms/) — the companion book
