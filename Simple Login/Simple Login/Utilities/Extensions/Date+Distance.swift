//
//  Date+Distance.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 11/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//
import Foundation

extension Date {
    func distanceFromNow() -> (Int, String) {
        let dateNow = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute, .hour, .day, .year], from: self, to: dateNow)

        let year = components.year!
        let day = components.day!
        let hour = components.hour!
        let minute = components.minute!
        
        let week = (year * 365 + day)/7
        let month = (year * 365 + day)/30
        
        if month == 1 {
            return (month, "month")
        } else if month > 1 {
            return (month, "months")
        }
        
        if week == 1 {
            return (week, "week")
        } else if week > 1 {
            return (week, "weeks")
        }
        
        if day == 1 {
            return (day, "day")
        } else if day > 1 {
            return (day, "days")
        }
        
        if hour == 1 {
            return (hour, "hour")
        } else if hour > 1 {
            return (hour, "hours")
        }
    
        if minute <= 1 {
            return (minute, "minute")
        } else {
            return (minute, "minutes")
        }
    }
}
