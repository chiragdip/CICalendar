//
//  Helper.swift
//  Calendar App
//
//  Created by Chiragdip Israni on 18/11/23.
//

import SwiftUI

enum DateType {
    case current
    case past
    case next
    
    var circleColor: Color {
        switch self {
        case .current: return .yellow
        case .next, .past: return .blue
        }
    }
}

public enum WeekendPreview {
    case highlighted(color: UIColor)
    case normal
}

public enum CalendarType: String {
    case Month = "Month"
    case Week = "Week"
    case Day = "Day"
    
    static let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    func calculateHeight() -> CGFloat {
        let itemWidth = getItemWidth()
        let expectedHeight = (itemWidth*numberOfItemsInColumn) + Self.itemSpacing*(numberOfItemsInColumn-1)
        return expectedHeight
    }
    
    func getItemWidth() -> CGFloat {
        return 35
//        let totalWidth = UIScreen.main.bounds.size.width
//        let remainingWidth = totalWidth - ((Self.numberOfItemsInRow-1)*Self.itemSpacing)
//        return remainingWidth / Self.numberOfItemsInRow
    }
    
    public static let itemSpacing = 5.0
    static let numberOfItemsInRow = 7.0
    var numberOfItemsInColumn: CGFloat { self == .Month ? 6.0 : 1.0 }
    
    static private let monthViewHeight = 350.0
    static private let weekViewHeight = 60.0
    
    public var calendarHeight: CGFloat {
        return calculateHeight()
    }
}

public enum ScrollSensitivity: CGFloat {
    case ultraLow = 80
    case low = 60
    case medium = 40
    case high = 30
    case ultraHigh = 15
}

public enum OtherPageDateViewType: CGFloat {
    case regular
    case disabled
}

public class CalendarConfiguration {
    public var type: CalendarType
    public var eventsAllowed: Bool
    public var isMultiSelectionAllowed: Bool
    public var days = CalendarType.days
    public var otherPageDateViewType: OtherPageDateViewType
    public var scrollSensitivity: ScrollSensitivity
    public var weekendType: WeekendPreview
    
    public init(type: CalendarType = .Month,
                eventsAllowed: Bool = true,
                isMultiSelectionAllowed: Bool = true,
                otherPageDateViewType: OtherPageDateViewType = .regular,
                scrollSensitivity: ScrollSensitivity = .medium,
                weekendType: WeekendPreview = .normal) {
        self.type = type
        self.eventsAllowed = eventsAllowed
        self.isMultiSelectionAllowed = isMultiSelectionAllowed
        self.otherPageDateViewType = otherPageDateViewType
        self.scrollSensitivity = scrollSensitivity
        self.weekendType = weekendType
    }
    
    public static let defaultConfiguration = CalendarConfiguration()
}

