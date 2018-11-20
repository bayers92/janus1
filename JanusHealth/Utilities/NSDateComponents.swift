//
//  NSDateComponents.swift
//  JanusHealth
//
//  Created by bayers on 11/17/18.
//  Copyright © 2018 bayers. All rights reserved.
//


import Foundation

extension DateComponents {
    static var firstDateOfCurrentWeek: DateComponents {
        var beginningOfWeek: NSDate?
        
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        gregorian?.locale = Locale.current
        gregorian!.range(of: .weekOfYear, start: &beginningOfWeek, interval: nil, for: Date())
        let dateComponents = gregorian?.components([.era, .year, .month, .day],
                                                   from: beginningOfWeek! as Date)
        return dateComponents!
    }
}
