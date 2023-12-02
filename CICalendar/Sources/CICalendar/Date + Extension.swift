//
//  Dates.swift
//  Calendar App
//
//  Created by Chiragdip Israni on 18/11/23.
//

import Foundation

extension Date {
    func getAllDatesInWeek(value: Int) -> [Date] {
        if value == 0 {
            return Self.dates(from: startOfWeek, to: endOfWeek)
        } else {
            let startOfWeek = getStartOfWeek(value: value)
            let endOfWeek = getEndOfWeek(value: value)
            return Self.dates(from: startOfWeek, to: endOfWeek)
        }
    }
    
    func getNextMonthDate(months: Int = 1) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.month = months
        return calendar.date(byAdding: components, to: self)
     }
    
    func getPreviousMonthDate(months: Int = -1) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.month = months
        return calendar.date(byAdding: components, to: self)
     }
    
    func getStartOfWeek(value: Int) -> Date {
        if value == 0 {
            return startOfWeek
        } else {
            let calendar = Calendar(identifier: .gregorian)
            return calendar.date(byAdding: .day, value: value*7, to: startOfWeek) ?? Date()
        }
    }
    
    func getEndOfWeek(value: Int) -> Date {
        if value == 0 {
            return endOfWeek
        } else {
            let calendar = Calendar(identifier: .gregorian)
            return calendar.date(byAdding: .day, value: value*7, to: endOfWeek) ?? Date()
        }
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    public var startOfWeek:  Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    public var endOfWeek: Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? Date()
    }
    
    func getAllDatesInMonth() -> [Date] {
        Self.dates(from: startOfMonth, to: endOfMonth)
    }
    
    public func getDatesInCurrentMonth() -> [Date] {
        Date.dates(from: startOfMonth, to: endOfMonth)
    }
    
    public static func dates(from fromDate: Date, to toDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = fromDate
        
        while date <= toDate {
            dates.append(date)
            guard let newDate = Calendar.current.date(byAdding: .day, value: 1, to: date) else { break }
            date = newDate
        }
        return dates
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var startOfMonth: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        return  calendar.date(from: components)!
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }

    func isMonday() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 2
    }
}


extension Date {
    func getNextWeekDate(weekOffset: Int = 1) -> Date? {
        return datesOfWeek(weekOffset: weekOffset).first
    }
    
    func getPreviousWeekDate(weekOffset: Int = -1) -> Date? {
        return datesOfWeek(weekOffset: weekOffset).first
    }

    // Get Date Array in a certain week, offset by some day
    private func datesOfWeek(weekOffset: Int = 0) -> [Date] {
        var dates = [Date]()
        for index in 1...7 {
            if let weekday = Weekday(rawValue: index) {
                let date = dateOfWeek(weekday: weekday, weekOffset: weekOffset)
                dates.append(date)
            }
        }

        return dates
    }

    // Get Date in a certain week, in a certain week day
    private func dateOfWeek(weekday targetDayOfWeek: Weekday, weekOffset: Int = 0) -> Date {
        var selfDate = self
        let weekInterval = intervalByDays(days: weekOffset * 7)
        selfDate.addTimeInterval(weekInterval)

        let formattor = DateFormatter()
        formattor.timeZone = TimeZone.current
        formattor.dateFormat = "e"

        if let selfDayOfWeek = Int(formattor.string(from: selfDate)) {
            let interval_days = targetDayOfWeek.rawValue - selfDayOfWeek
            let interval = intervalByDays(days: interval_days)
            selfDate.addTimeInterval(interval)
            return selfDate
        }

        return selfDate
    }
    
    func isWeekend() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return Weekday.weekend.contains(where: { $0.rawValue == components.weekday })
    }
    
    func isWeekday() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return Weekday.weekday.contains(where: { $0.rawValue == components.weekday })
    }

    // for good reading
    enum Weekday: Int, CaseIterable {
        case Sunday = 1
        case Monday = 2
        case Tuesday = 3
        case Wednesday = 4
        case Thursday = 5
        case Friday = 6
        case Saturday = 7
        
        static let weekend: [Weekday] = [.Sunday, .Saturday]
        static let weekday: [Weekday] = Weekday.allCases.filter { !weekend.contains($0) }
    }

    // how many seconds in a day
    private func intervalByDays(days: Int) -> TimeInterval {

        let secondsPerMinute = 60
        let minutesPerHour = 60
        let hoursPerDay = 24

        return TimeInterval(
            days * hoursPerDay * minutesPerHour * secondsPerMinute)
    }
}
