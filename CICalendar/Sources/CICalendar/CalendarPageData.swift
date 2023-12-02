//
//  CalendarPageData.swift
//  Calendar App
//
//  Created by Chiragdip Israni on 18/11/23.
//

import Foundation

struct CalendarPageData: Identifiable {
    let id = UUID().uuidString
    let pageDate: Date
    let dates: [CalendarDate]
    var pageNumber: Int?
    
    init(dates: [CalendarDate]) {
        self.dates = dates
        self.pageDate = dates.first(where: { $0.day == 1 })?.date ?? Date()
    }
}

struct CalendarDate: Identifiable {
    let id = UUID().uuidString
    let day: Int
    let date: Date
    
    init(date: Date) {
        self.day = Calendar.current.component(.day, from: date)
        self.date = date
    }
    
    var isWeekend: Bool {
        date.isWeekend()
    }
    
    var isWeekday: Bool {
        date.isWeekday()
    }
}

extension CalendarDate {
    
    static private let calendar = Calendar.current
    
    static func fetchSelectedMonth(value: Int) -> Date {
        return calendar.date(byAdding: .month, value: value, to: Date()) ?? Date()
    }
    
    static func fetchSelectedWeek(value: Int) -> Date {
        return calendar.date(byAdding: .day, value: value, to: Date()) ?? Date()
    }
    
    // New FUNCTIONS FOR TRYING
    
    static func fetchPageDates(page: Date, forCalendarType type: CalendarType) -> CalendarPageData {
        switch type {
        case .Month:
            return CalendarPageData(dates: getDatesArrayInMonthContaining(page))
        case .Week, .Day:
            return CalendarPageData(dates: Date.dates(from: page.startOfWeek, to: page.endOfWeek).map { CalendarDate(date: $0) })
        }
    }
    
    static private func getDatesArrayInMonthContaining(_ page: Date) -> [CalendarDate] {
        let dates = Date.dates(from: page.startOfMonth, to: page.endOfMonth)
        var calendarDates = dates.map { CalendarDate(date: $0) }
        
        // Adding previous month dates in dates Array...
        guard let firstDate = dates.first else { return [] }
        calendarDates.insert(contentsOf: Self.getPreviousCalendarMonthDates(firstDate: firstDate), at: 0)
        
        // Adding next month dates in dates Array...
        guard let lastDate = dates.last else { return [] }
        calendarDates.append(contentsOf: Self.getNextCalendarMonthDates(lastDate: lastDate))
        
        return calendarDates
    }
    
    static func getPreviousCalendarMonthDates(firstDate: Date) -> [CalendarDate] {
        // Adding previous month dates in dates Array...
        let firstDay = calendar.component(.weekday, from: firstDate)
        var pastDate = firstDate
        var calendarDates = [CalendarDate]()
        for _ in 0..<firstDay-1 {
            pastDate = calendar.date(byAdding: .day, value: -1, to: pastDate) ?? Date()
            let pastDateObject = CalendarDate(date: pastDate)
            calendarDates.insert(pastDateObject, at: 0)
        }
        return calendarDates
    }
    
    static func getNextCalendarMonthDates(lastDate: Date) -> [CalendarDate] {
        // Adding next month dates in dates Array...
        let lastDay = calendar.component(.weekday, from: lastDate)
        var nextDate = lastDate
        var calendarDates = [CalendarDate]()
        for _ in lastDay..<7 {
            nextDate = calendar.date(byAdding: .day, value: 1, to: nextDate) ?? Date()
            let nextDateObject = CalendarDate(date: nextDate)
            calendarDates.append(nextDateObject)
        }
        return calendarDates
    }
}
