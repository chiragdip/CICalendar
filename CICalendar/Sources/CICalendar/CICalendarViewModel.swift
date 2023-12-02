//
//  CICalendarViewModel.swift
//  Calendar App
//
//  Created by Chiragdip Israni on 20/11/23.
//

import Foundation
import Combine

class CICalendarViewModel: ObservableObject {
    
    @Published var currentPage: Date = Date()
    @Published private (set)var calendarPages = [CalendarPageData]()
    @Published private (set)var selectedDates = [Date]()
    var configuration: CalendarConfiguration = .defaultConfiguration
    private var cancellables = Set<AnyCancellable>()
    
    init(currentPage: Date, selectedDates: [Date] = [Date](), configuration: CalendarConfiguration) {
        self.currentPage = configuration.type == .Month ? currentPage.startOfMonth : currentPage.startOfWeek
        self.selectedDates = selectedDates
        self.configuration = configuration
        setUpCalendarInitials()
        setBindings()
    }
    
    private func setBindings() {
        $currentPage
            .debounce(for: 0.08, scheduler: DispatchQueue.global())
            .sink { value in
                self.checkForAvailableCalendarPages()
            }
            .store(in: &cancellables)
    }
    
    func nextPage() {
        currentPage = getNextPageFirstDate(date: currentPage)
    }
    
    func previousPage() {
        currentPage = getPreviousPageFirstDate(date: currentPage)
    }
    
    func goToCurrentPage() {
        currentPage = Date()
    }
    
    func getCalendarPageFor(date: Date) -> CalendarPageData? {
        guard let currentPageModel = calendarPages.first(where: { $0.pageDate == date }) else {
            return nil
        }
        return currentPageModel
    }
    
    func checkForAvailableCalendarPages() {
        guard let currentPageModel = getCalendarPageFor(date: currentPage) else { return }
        
        if !calendarPages.contains(where: { $0.pageNumber == (currentPageModel.pageNumber ?? 0) + 1}) {
            var nextPageDates = getNextCalendarPageDataFor(date: currentPage, offset: 1)
            nextPageDates.pageNumber = (currentPageModel.pageNumber ?? 0) + 1
            calendarPages.append(nextPageDates)
        }
        
        if !calendarPages.contains(where: { $0.pageNumber == (currentPageModel.pageNumber ?? 0) + 2}) {
            var nextPageDates = getNextCalendarPageDataFor(date: currentPage, offset: 2)
            nextPageDates.pageNumber = (currentPageModel.pageNumber ?? 0) + 2
            calendarPages.append(nextPageDates)
        }
        
        if !calendarPages.contains(where: { $0.pageNumber == (currentPageModel.pageNumber ?? 0) - 1}) {
            var previousPageDates = getPreviousCalendarPageDataFor(date: currentPage, offset: -1)
            previousPageDates.pageNumber = (currentPageModel.pageNumber ?? 0) - 1
            calendarPages.insert(previousPageDates, at: 0)
        }
        
        if !calendarPages.contains(where: { $0.pageNumber == (currentPageModel.pageNumber ?? 0) - 2}) {
            var previousPageDates = getPreviousCalendarPageDataFor(date: currentPage, offset: -2)
            previousPageDates.pageNumber = (currentPageModel.pageNumber ?? 0) - 2
            calendarPages.insert(previousPageDates, at: 0)
        }
    }
    
    // load 5 page dates at a time
    private func setUpCalendarInitials() {
        var firstPrevPage = getPreviousCalendarPageDataFor(date: currentPage, offset: -2)
        firstPrevPage.pageNumber = -2
        
        var secondPrevPage = getPreviousCalendarPageDataFor(date: currentPage, offset: -1)
        secondPrevPage.pageNumber = -1
        
        var currentPageDates = CalendarDate.fetchPageDates(page: currentPage, forCalendarType: configuration.type)
        currentPageDates.pageNumber = 0
        
        var firstNextPageDates = getNextCalendarPageDataFor(date: currentPage, offset: 1)
        firstNextPageDates.pageNumber = 1
        
        var secondNextPageDates = getNextCalendarPageDataFor(date: currentPage, offset: 2)
        secondNextPageDates.pageNumber = 2
        calendarPages = [firstPrevPage, secondPrevPage, currentPageDates, firstNextPageDates, secondNextPageDates]
    }
    
    func getPreviousCalendarPageDataFor(date: Date, offset: Int = -1) -> CalendarPageData {
        let previousPageDate = getPreviousPageFirstDate(date: date, offset: offset)
        return CalendarDate.fetchPageDates(page: previousPageDate, forCalendarType: configuration.type)
    }
    
    func getNextCalendarPageDataFor(date: Date, offset: Int = 1) -> CalendarPageData {
        let nextPageDate = getNextPageFirstDate(date: date, offset: offset)
        return CalendarDate.fetchPageDates(page: nextPageDate, forCalendarType: configuration.type)
    }
    
    private func getPreviousPageFirstDate(date: Date, offset: Int = -1) -> Date {
        switch configuration.type {
        case .Month:
            guard let prevMonthDate = date.getPreviousMonthDate(months: offset) else { return Date().startOfMonth }
            return prevMonthDate.startOfMonth
        case .Week, .Day:
            guard let prevWeekDate = date.getPreviousWeekDate(weekOffset: offset) else { return Date().startOfWeek }
            return prevWeekDate.startOfWeek
        }
    }
    
    private func getNextPageFirstDate(date: Date, offset: Int = 1) -> Date {
        switch configuration.type {
        case .Month:
            guard let nextMonthDate = date.getNextMonthDate(months: offset) else { return Date().startOfMonth }
            return nextMonthDate.startOfMonth
        case .Week, .Day:
            guard let nextWeekDate = date.getNextWeekDate(weekOffset: offset) else { return Date().startOfWeek }
            return nextWeekDate.startOfWeek
        }
    }
    
    func checkIfDateIsSelected(date: Date) -> Bool {
        selectedDates.contains(date)
    }
    
    func checkIfCurrentPage(date: Date) -> Bool {
        switch configuration.type {
        case .Month:
            return currentPage.startOfMonth == date.startOfMonth
        case .Week, .Day:
            return currentPage.startOfWeek == date.startOfWeek
        }
    }
    
    func didTapOn(_ date: CalendarDate) {
        guard !selectedDates.isEmpty else {
            selectedDates = [date.date]
            return
        }
        
        if checkIfDateIsSelected(date: date.date) {
            if configuration.isMultiSelectionAllowed {
                selectedDates.removeAll(where: { date.date == $0 })
            } else {
                selectedDates = []
            }
        } else {
            if configuration.isMultiSelectionAllowed {
                selectedDates.append(date.date)
            } else {
                selectedDates = [date.date]
            }
        }
    }
}
