//
//  Utilities+Dates.swift
//  ARVision
//
//  Created by Zheng on 11/27/21.
//  Copyright © 2021 Andrew. All rights reserved.
//

import Foundation

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }

    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }

    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }

    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }

    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }

    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }

    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }

    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date) > 0 { return "\(years(from: date))y" }
        if months(from: date) > 0 { return "\(months(from: date))M" }
        if weeks(from: date) > 0 { return "\(weeks(from: date))w" }
        if days(from: date) > 0 { return "\(days(from: date))d" }
        if hours(from: date) > 0 { return "\(hours(from: date))h" }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension Date {
    func convertDateToReadableString() -> String {
        /// Initializing a Date object will always return the current date (including time)
        let today = Date()
        
        guard let yesterday = today.subtract(days: 1) else { return "2022" }
        guard let oneWeekAgo = today.subtract(days: 7) else { return "2022" }
        guard let dayBeforeYesterday = today.subtract(days: 1) else { return "2022" }
        
        /// This will be any date from one week ago to the day before yesterday
        let recently = oneWeekAgo ... dayBeforeYesterday
        
        /// convert the date into a string, if the date is before yesterday
        let dateFormatter = DateFormatter()
        
        /// If self (the date that you're comparing) is today
        if Calendar.current.isDate(self, inSameDayAs: today) {
            return "Today"
            
            /// if self is yesterday
        } else if Calendar.current.isDate(self, inSameDayAs: yesterday) {
            return "Yesterday"
            
            /// if self is in between one week ago and the day before yesterday
        } else if recently.contains(self) {
            /// "EEEE" will display something like "Wednesday" (the weekday)
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: self)
            
            /// self is before one week ago
        } else {
            /// displays the date as "January 1, 2020"
            /// the ' ' marks indicate a character that you add (in our case, a comma)
            dateFormatter.dateFormat = "MMMM d',' yyyy"
            return dateFormatter.string(from: self)
        }
    }
    
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        let components = DateComponents(year: years, month: months, day: days, hour: hours, minute: minutes, second: seconds)
        return Calendar.current.date(byAdding: components, to: self)
    }
    
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date? {
        return add(years: -years, months: -months, days: -days, hours: -hours, minutes: -minutes, seconds: -seconds)
    }
}
