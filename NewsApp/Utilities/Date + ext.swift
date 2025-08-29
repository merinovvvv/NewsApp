//
//  Date + ext.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 27.08.25.
//

import Foundation

extension Date {
    
    func detailedDateDisplay() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
    
    func timeAgoDisplay() -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(self)
        
        let seconds = Int(timeInterval)
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 30 * day
        let year = 365 * day
        
        switch seconds {
        case 0..<30:
            return "just now"
            
        case 30..<minute:
            return "less than a minute ago"
            
        case minute..<(2 * minute):
            return "1 minute ago"
            
        case (2 * minute)..<hour:
            let minutes = seconds / minute
            return "\(minutes) minutes ago"
            
        case hour..<(2 * hour):
            return "1 hour ago"
            
        case (2 * hour)..<day:
            let hours = seconds / hour
            return "\(hours) hours ago"
            
        case day..<(2 * day):
            return "yesterday"
            
        case (2 * day)..<week:
            let days = seconds / day
            return "\(days) days ago"
            
        case week..<(2 * week):
            return "1 week ago"
            
        case (2 * week)..<month:
            let weeks = seconds / week
            return "\(weeks) weeks ago"
            
        case month..<(2 * month):
            return "1 month ago"
            
        case (2 * month)..<year:
            let months = seconds / month
            return "\(months) months ago"
            
        case year..<(2 * year):
            return "1 year ago"
            
        default:
            let years = seconds / year
            if years < 5 {
                return "\(years) years ago"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                formatter.locale = Locale.current
                return formatter.string(from: self)
            }
        }
    }
}
