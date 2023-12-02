//
//  CICalendar.swift
//  Calendar App
//
//  Created by Chiragdip Israni on 20/11/23.
//

import SwiftUI

public struct CICalendar: View {
    
    @ObservedObject private var model: CICalendarViewModel
    
    private var onCurrentPageChange: ((Date) -> ())?
    private var didSelectedDate: ((Date) -> ())?
    private var didSelectedDates: (([Date]) -> ())?
    private var didDeSelectedDate: ((Date) -> ())?
    private var onSelectedDateChange: (([Date]) -> ())?
    
    private let gridItems: [GridItem]
    
    public init(currentPage: Date = Date(),
                configuration: CalendarConfiguration = .defaultConfiguration,
                selectedDates: [Date] = []) {
        _model = ObservedObject(initialValue: CICalendarViewModel(currentPage: currentPage,
                                                                  selectedDates: selectedDates,
                                                                  configuration: configuration))
        
        gridItems = Array(repeating: GridItem(.flexible()), count: 7)
    }
    
    public var body: some View {
        VStack {
            calendarTitleView
            daysView
            calendarView
        }
        .padding()
        .background(Color.gray)
        .onChange(of: model.currentPage) { newValue in
            DispatchQueue.main.async {
                self.onCurrentPageChange?(model.currentPage)
            }
        }
    }
}

extension CICalendar {
    @ViewBuilder
    private var calendarTitleView: some View {
        HStack(spacing: .zero) {
            Button {
                // Write code for backword pagination
                withAnimation(.linear(duration: 0.2)) {
                    self.model.previousPage()
                }
                
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "chevron.left")
                    
                    Text("Back")
                }
                .foregroundColor(Color.primary)
            }
            
            Spacer()
            
            Text(fetchHeaderTitleDate(), style: .date)
                .font(.headline)
            
            Spacer()
            
            Button {
                // Write code for forward pagination
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.model.nextPage()
                }
            } label: {
                HStack(spacing: 3) {
                    Text("Next")
                    
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(Color.primary)
            }
        }
        .padding(.vertical)
    }
    
    @ViewBuilder
    private var daysView: some View {
        HStack {
            ForEach(model.configuration.days, id: \.self) { day in
                Text(day)
                    .font(.callout)
                    .bold()
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    private var calendarView: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                TabView(selection: $model.currentPage) {
                    ForEach(model.calendarPages) { page in
                        getCalendarGridFor(page: page)
                            .tag(page.pageDate)
                    }
                }
                .frame(width: proxy.size.width, height: model.configuration.type.calendarHeight)
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }

    @ViewBuilder
    private func getCalendarGridFor(page: CalendarPageData) -> some View {
        VStack {
            LazyVGrid(columns: gridItems) {
                ForEach(page.dates) { date in
                    let isCurrentPageDate = model.checkIfCurrentPage(date: date.date)
                    DateView(date: date,
                             isSelected: model.checkIfDateIsSelected(date: date.date),
                             isCurrentPageDate: isCurrentPageDate,
                             configuration: model.configuration)
                    .onTapGesture {
                        let shouldEnableTap = model.configuration.otherPageDateViewType == .regular ? true : isCurrentPageDate
                        if shouldEnableTap {
                            defer {
                                self.onSelectedDateChange?(model.selectedDates)
                            }
                            withAnimation(.linear(duration: 0.15)) {
                                self.model.didTapOn(date)
                            }
                            
                            if model.checkIfDateIsSelected(date: date.date) {
                                if model.configuration.isMultiSelectionAllowed {
                                    self.didSelectedDates?(model.selectedDates)
                                } else {
                                    self.didSelectedDate?(model.selectedDates.first ?? Date())
                                }
                            } else {
                                self.didDeSelectedDate?(date.date)
                            }
                        }
                    }
                }
            }
            
            if model.configuration.type == .Month {
                Spacer()
            }
        }
    }
}

extension CICalendar {
    private func fetchHeaderTitleDate() -> Date {
        return model.currentPage
    }
    
    public func didSelectedDate(_ completion: @escaping (Date) -> Void) -> Self {
        var new = self
        new.didSelectedDate = completion
        return new
    }
    
    public func didSelectedDates(_ completion: @escaping ([Date]) -> Void) -> Self {
        var new = self
        new.didSelectedDates = completion
        return new
    }
    
    public func didDeSelectedDate(_ completion: @escaping (Date) -> Void) -> Self {
        var new = self
        new.didDeSelectedDate = completion
        return new
    }
    
    public func onSelectedDateChange(_ completion: @escaping ([Date]) -> Void) -> Self {
        var new = self
        new.onSelectedDateChange = completion
        return new
    }
    
    public func onCurrentPageChange(_ completion: @escaping (Date) -> Void) -> Self {
        var new = self
        new.onCurrentPageChange = completion
        return new
    }
}

struct CICalendar_Previews: PreviewProvider {
    static var previews: some View {
        CICalendar()
    }
}
