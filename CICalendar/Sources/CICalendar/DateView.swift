//
//  DateView.swift
//  Calendar App
//
//  Created by Chiragdip Israni on 18/11/23.
//

import SwiftUI

struct DateView: View {

    let date: CalendarDate
    let isSelected: Bool
    let isCurrentPageDate: Bool
    let configuration: CalendarConfiguration

    private var shouldSelect: Bool {
        configuration.otherPageDateViewType == .regular ? true : isCurrentPageDate
    }
    private let randomInt = Int.random(in: 0..<5)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                backGroundView
                eventView
                Text("\(date.day)")
            }
            .padding(5)
        }
        .opacity(shouldSelect ? 1.0 : 0.4)
        .disabled(!shouldSelect)
    }
    
    @ViewBuilder
    private var backGroundView: some View {
        Circle()
            .foregroundColor(getBGColor())
    }
    
    private func getBGColor() -> Color {
        if isSelected {
            return .red
        } else {
            if date.date.isToday {
                return .blue
            } else {
                if date.date.isWeekend() {
                    switch configuration.weekendType {
                    case .normal:
                        return .clear
                    case .highlighted(let color):
                        return Color(color)
                    }
                } else {
                    return .clear
                }
            }
        }
    }
    
    @ViewBuilder
    private var eventView: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 3) {
                ForEach(makeList(randomInt), id: \.self) { num in
                    Circle()
                        .frame(width: 3)
                        .foregroundStyle(.black)
                }
            }
            .padding(.bottom, 5)
        }
    }
    
    func makeList(_ n: Int) -> [Int] {
        return (0..<n).map{ _ in n }
    }
}

struct DateView_Previews: PreviewProvider {
    static var previews: some View {
        DateView(
            date: .init(date: Date()), isSelected: true, isCurrentPageDate: true, configuration: .defaultConfiguration)
    }
}
