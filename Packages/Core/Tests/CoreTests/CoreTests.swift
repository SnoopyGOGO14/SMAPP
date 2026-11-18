// CoreTests — Session 1 minimum test list from 02-SESSION-TASKS.md.
// All dates fixed via UTC/Europe-London calendars so results are deterministic.

import XCTest
@testable import Core

private func utcDate(_ string: String) -> Date {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.date(from: string)!
}

private func utcCalendar() -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
}

private func londonCalendar() -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Europe/London")!
    return calendar
}

// MARK: - Zone

final class ZoneTests: XCTestCase {

    func testBoundaries() {
        // Allowance 180 minutes, amber at 75%.
        XCTAssertEqual(Core.zone(usedMinutes: 0, allowanceMinutes: 180, amberFraction: 0.75), .green)      // 0%
        XCTAssertEqual(Core.zone(usedMinutes: 134.82, allowanceMinutes: 180, amberFraction: 0.75), .green) // 74.9%
        XCTAssertEqual(Core.zone(usedMinutes: 135, allowanceMinutes: 180, amberFraction: 0.75), .amber)    // exactly 75%
        XCTAssertEqual(Core.zone(usedMinutes: 180, allowanceMinutes: 180, amberFraction: 0.75), .amber)    // exactly 100%
        XCTAssertEqual(Core.zone(usedMinutes: 180.18, allowanceMinutes: 180, amberFraction: 0.75), .red)   // 100.1%
    }

    func testZeroAllowanceIsGreen() {
        XCTAssertEqual(Core.zone(usedMinutes: 500, allowanceMinutes: 0, amberFraction: 0.75), .green)
    }
}

// MARK: - TargetMath

final class TargetMathTests: XCTestCase {

    func testConversionRoundTrips() {
        // Targets are entered in 15-minute steps; round-trips must be exact.
        for daily in [15, 30, 45, 60, 90, 120, 180, 240] {
            let weekly = TargetMath.toWeekly(fromDailyMinutes: daily)
            XCTAssertEqual(weekly, daily * 7)
            XCTAssertEqual(TargetMath.toDaily(fromWeeklyMinutes: weekly), daily)
        }
        XCTAssertEqual(TargetMath.toWeekly(fromDailyMinutes: 180), 1260)
        XCTAssertEqual(TargetMath.toDaily(fromWeeklyMinutes: 1260), 180)
    }

    func testAllowanceTableDailyMode() {
        // Daily mode, target 180 minutes/day.
        XCTAssertEqual(TargetMath.allowanceMinutes(view: .todayRing, mode: .daily, targetMinutes: 180), 180)
        XCTAssertEqual(TargetMath.allowanceMinutes(view: .hourlyBars, mode: .daily, targetMinutes: 180), 180)
        XCTAssertEqual(TargetMath.allowanceMinutes(view: .dailyBars, mode: .daily, targetMinutes: 180), 180)
        XCTAssertEqual(TargetMath.allowanceMinutes(view: .weeklyBars, mode: .daily, targetMinutes: 180), 1260)
        XCTAssertEqual(TargetMath.allowanceMinutes(view: .monthly, mode: .daily, targetMinutes: 180), 180)
        XCTAssertEqual(TargetMath.allowanceMinutes(view: .weeklyAverageLine, mode: .daily, targetMinutes: 180), 180)
    }

    func testAllowanceTableWeeklyMode() {
        // Weekly mode, target 1260 minutes/week.
        XCTAssertEqual(TargetMath.allowanceMinutes(view: .todayRing, mode: .weekly, targetMinutes: 1260), 1260)
        XCTAssertEqual(TargetMath.allowanceMinutes(view: .hourlyBars, mode: .weekly, targetMinutes: 1260), 180)
        XCTAssertEqual(TargetMath.allowanceMinutes(view: .dailyBars, mode: .weekly, targetMinutes: 1260), 180)
        XCTAssertEqual(TargetMath.allowanceMinutes(view: .weeklyBars, mode: .weekly, targetMinutes: 1260), 1260)
        XCTAssertEqual(TargetMath.allowanceMinutes(view: .monthly, mode: .weekly, targetMinutes: 1260), 1260)
        XCTAssertEqual(TargetMath.allowanceMinutes(view: .weeklyAverageLine, mode: .weekly, targetMinutes: 1260), 180)
    }

    func testWeekToDateAverage() {
        XCTAssertEqual(TargetMath.weekToDateAverage(totalMinutes: 600, daysElapsed: 4), 150)
        XCTAssertEqual(TargetMath.weekToDateAverage(totalMinutes: 0, daysElapsed: 5), 0)
        XCTAssertEqual(TargetMath.weekToDateAverage(totalMinutes: 600, daysElapsed: 0), 0)
    }
}

// MARK: - PeriodMath

final class PeriodMathTests: XCTestCase {

    func testCurrentIntervals() {
        let utc = utcCalendar()
        let now = utcDate("2026-11-18 14:35") // Wednesday

        let hour = PeriodMath.dateInterval(for: .hour, calendar: utc, now: now)
        XCTAssertEqual(hour.start, utcDate("2026-11-18 14:00"))
        XCTAssertEqual(hour.duration, 3600)

        let day = PeriodMath.dateInterval(for: .day, calendar: utc, now: now)
        XCTAssertEqual(day.start, utcDate("2026-11-18 00:00"))
        XCTAssertEqual(day.duration, 86400)
    }

    func testDayAcrossClockChange() {
        let london = londonCalendar()
        // 29 March 2026: clocks forward in London, the day is 23 hours.
        let forward = PeriodMath.dateInterval(for: .day, calendar: london, now: utcDate("2026-03-29 12:00"))
        XCTAssertEqual(forward.duration, 23 * 3600, accuracy: 2)
        // 25 October 2026: clocks back, the day is 25 hours.
        let back = PeriodMath.dateInterval(for: .day, calendar: london, now: utcDate("2026-10-25 12:00"))
        XCTAssertEqual(back.duration, 25 * 3600, accuracy: 2)
    }

    func testWeekWithMondayAndSundayStarts() {
        let utc = utcCalendar()
        let wednesday = utcDate("2026-11-18 12:00")

        let monday = PeriodMath.dateInterval(for: .week, calendar: utc, weekStartsOn: 2, now: wednesday)
        XCTAssertEqual(monday.start, utcDate("2026-11-16 00:00"))
        XCTAssertEqual(monday.duration, 7 * 86400, accuracy: 2)

        let sunday = PeriodMath.dateInterval(for: .week, calendar: utc, weekStartsOn: 1, now: wednesday)
        XCTAssertEqual(sunday.start, utcDate("2026-11-15 00:00"))
    }

    func testMonthLengths() {
        let utc = utcCalendar()
        XCTAssertEqual(PeriodMath.dateInterval(for: .month, calendar: utc, now: utcDate("2026-02-10 12:00")).duration, 28 * 86400)
        XCTAssertEqual(PeriodMath.dateInterval(for: .month, calendar: utc, now: utcDate("2024-02-10 12:00")).duration, 29 * 86400) // leap
        XCTAssertEqual(PeriodMath.dateInterval(for: .month, calendar: utc, now: utcDate("2026-04-10 12:00")).duration, 30 * 86400)
        XCTAssertEqual(PeriodMath.dateInterval(for: .month, calendar: utc, now: utcDate("2026-07-10 12:00")).duration, 31 * 86400)
    }

    func testOffsets() {
        let utc = utcCalendar()

        // Day −1 from Wednesday 18 Nov 2026.
        let prevDay = PeriodMath.dateInterval(for: .day, offset: -1, calendar: utc, now: utcDate("2026-11-18 12:00"))
        XCTAssertEqual(prevDay.start, utcDate("2026-11-17 00:00"))

        // Hour −12.
        let prev12h = PeriodMath.dateInterval(for: .hour, offset: -12, calendar: utc, now: utcDate("2026-11-18 14:35"))
        XCTAssertEqual(prev12h.start, utcDate("2026-11-18 02:00"))

        // Week −12 with Monday start: week of 16 Nov back 12 weeks → 24 Aug 2026 (a Monday).
        let prev12w = PeriodMath.dateInterval(for: .week, offset: -12, calendar: utc, weekStartsOn: 2, now: utcDate("2026-11-18 12:00"))
        XCTAssertEqual(prev12w.start, utcDate("2026-08-24 00:00"))

        // Month −12.
        let prev12m = PeriodMath.dateInterval(for: .month, offset: -12, calendar: utc, now: utcDate("2026-11-18 12:00"))
        XCTAssertEqual(prev12m.start, utcDate("2025-11-01 00:00"))
    }
}

// MARK: - DurationFormat

final class DurationFormatTests: XCTestCase {

    func testShort() {
        XCTAssertEqual(DurationFormat.short(minutes: 0), "0m")
        XCTAssertEqual(DurationFormat.short(minutes: 59), "59m")
        XCTAssertEqual(DurationFormat.short(minutes: 60), "1h")
        XCTAssertEqual(DurationFormat.short(minutes: 134), "2h 14m")
        XCTAssertEqual(DurationFormat.short(minutes: 600), "10h")
    }

    func testLeft() {
        XCTAssertEqual(DurationFormat.left(minutes: 46), "46m left")
        XCTAssertEqual(DurationFormat.left(minutes: 134), "2h 14m left")
    }
}

// MARK: - Checkpoint

final class CheckpointTests: XCTestCase {

    func testThresholdMinutesForThreeHourTarget() {
        XCTAssertEqual(Checkpoint.thresholdMinutes(percent: 25, targetMinutes: 180), 45)
        XCTAssertEqual(Checkpoint.thresholdMinutes(percent: 50, targetMinutes: 180), 90)
        XCTAssertEqual(Checkpoint.thresholdMinutes(percent: 75, targetMinutes: 180), 135)
        XCTAssertEqual(Checkpoint.thresholdMinutes(percent: 100, targetMinutes: 180), 180)
        XCTAssertEqual(Checkpoint.thresholdMinutes(percent: 125, targetMinutes: 180), 225)
        XCTAssertEqual(Checkpoint.thresholdMinutes(percent: 150, targetMinutes: 180), 270)
    }

    func testSanityGuard() {
        // 3-hour target, the 100% event means 180 minutes of usage.
        // At 01:00 only 60 minutes have elapsed since midnight → implausible.
        XCTAssertFalse(Checkpoint.isPlausible(percent: 100, targetMinutes: 180, minutesSinceIntervalStart: 60))
        // At 15:00, 900 minutes have elapsed → plausible.
        XCTAssertTrue(Checkpoint.isPlausible(percent: 100, targetMinutes: 180, minutesSinceIntervalStart: 900))
    }

    func testCheckpointCodableRoundTrip() throws {
        let checkpoint = Checkpoint(date: utcDate("2026-11-17 09:30"), percent: 75)
        let data = try JSONEncoder().encode(checkpoint)
        XCTAssertEqual(try JSONDecoder().decode(Checkpoint.self, from: data), checkpoint)
    }

    func testCheckpointPercents() {
        XCTAssertEqual(Checkpoint.checkpointPercents, [25, 50, 75, 100, 125, 150])
    }
}

// MARK: - SettingsKeys

final class SettingsKeysTests: XCTestCase {

    func testKeysMatchTheSpecDataModel() {
        XCTAssertEqual(SettingsKeys.selection, "selection")
        XCTAssertEqual(SettingsKeys.enabledTokens, "enabledTokens")
        XCTAssertEqual(SettingsKeys.monitoringEnabled, "monitoringEnabled")
        XCTAssertEqual(SettingsKeys.targetMode, "targetMode")
        XCTAssertEqual(SettingsKeys.targetMinutes, "targetMinutes")
        XCTAssertEqual(SettingsKeys.amberFraction, "amberFraction")
        XCTAssertEqual(SettingsKeys.alertsEnabled, "alertsEnabled")
        XCTAssertEqual(SettingsKeys.weekStartsOn, "weekStartsOn")
        XCTAssertEqual(SettingsKeys.recapsEnabled, "recapsEnabled")
        XCTAssertEqual(SettingsKeys.lastCheckpoint, "lastCheckpoint")
        XCTAssertEqual(SettingsKeys.orderedTokens, "orderedTokens")
        XCTAssertEqual(SettingsKeys.appTargets, "appTargets")
        XCTAssertEqual(SettingsKeys.detailToken, "detailToken")
        XCTAssertEqual(SettingsKeys.statsPeriod, "statsPeriod")
        XCTAssertEqual(SettingsKeys.lastMonitoringError, "lastMonitoringError")
        XCTAssertEqual(SettingsKeys.lastAlert, "lastAlert")
    }

    func testAllKeysUnique() {
        let all = [
            SettingsKeys.selection, SettingsKeys.enabledTokens, SettingsKeys.monitoringEnabled,
            SettingsKeys.targetMode, SettingsKeys.targetMinutes, SettingsKeys.amberFraction,
            SettingsKeys.alertsEnabled, SettingsKeys.weekStartsOn, SettingsKeys.recapsEnabled,
            SettingsKeys.lastCheckpoint, SettingsKeys.orderedTokens, SettingsKeys.appTargets,
            SettingsKeys.detailToken, SettingsKeys.statsPeriod, SettingsKeys.lastMonitoringError,
            SettingsKeys.lastAlert
        ]
        XCTAssertEqual(Set(all).count, 16)
        XCTAssertEqual(all.count, 16)
    }
}
