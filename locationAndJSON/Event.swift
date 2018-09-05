//
//  meetupViewController.swift
//  locationAndJSON
//
//  Created by isha on 9/3/18.
//  Copyright © 2018 isha. All rights reserved.

import UIKit

enum EventFields: String {
    case group  = "group"
    case name   = "name"
    case time   = "time"
    case venue  = "venue"
}


class Event {
    let eventDate   : String
    let eventGroupName  : String
    let eventName   : String
    let eventTime   : String
    let eventVenue  : String
    let eventCity: String
    let eventAddress: String
    
    init(eventDate: String, eventGroupName: String, eventName: String, eventTime: String, eventVenue: String, eventCity: String, eventAddress: String)
    {
        self.eventDate    = eventDate
        self.eventGroupName   = eventGroupName
        self.eventName    = eventName
        self.eventTime    = eventTime
        self.eventVenue   = eventVenue
        self.eventCity = eventCity
        self.eventAddress = eventAddress
    }
    
    
    private static let dateFormatter = DateFormatter()
    
    
    static func eventFromJsonDict(json: [String: AnyObject]) -> Event? {
        guard let time      = json[EventFields.time.rawValue]    as? Int,
            let name      = json[EventFields.name.rawValue]    as? String,
            let groupName = json[EventFields.group.rawValue]?[EventFields.name.rawValue] as? String,
            let venue     = json[EventFields.venue.rawValue]?[EventFields.name.rawValue] as? String,
            let city = json[EventFields.venue.rawValue]?["city"] as? String,
            let address = json[EventFields.venue.rawValue]?["address_1"] as? String
        else { return nil }

        let (eventDate, eventTime) = dateFormatter.dateAndTimeFrom(time: time)
        
        return Event(eventDate: eventDate, eventGroupName: groupName, eventName: name, eventTime: eventTime, eventVenue: venue, eventCity: city, eventAddress: address)
    }
    
}

extension DateFormatter {
    
    func dateAndTimeFrom(time: Int) -> (eventDate: String, eventTime: String) {
        let dateFormatter = DateFormatter()
        let seconds = TimeInterval(Double(time))/1000
        let date = Date(timeIntervalSince1970: seconds)
        dateFormatter.dateFormat = "MMM d, yyyy"
        let eventDate = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "h:mm a"
        let eventTime = dateFormatter.string(from: date)
        
        return (eventDate, eventTime)
    }
    
}



