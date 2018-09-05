//
//  meetupViewController.swift
//  locationAndJSON
//
//  Created by isha on 9/3/18.
//  Copyright © 2018 isha. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class meetupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var meetupTabeView: UITableView!
    
    var userLatitude: CLLocationDegrees = 0.0
    var userLongitude: CLLocationDegrees = 0.0
    var events = [[String: AnyObject]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        meetupTabeView.delegate = self
        meetupTabeView.dataSource = self
        getUpcomingEvents()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetups.count
    }
    
    var meetups = [Event]()
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = meetupTabeView.dequeueReusableCell(withIdentifier: "meetupCell", for: indexPath) as! meetupTableViewCell
        let event = meetups[indexPath.row]
        cell.eventTitleLabel.text = event.eventName
        cell.meetupGroupName.text = "Organized by: \(event.eventGroupName)"
        if event.eventVenue == "" {
            print(event.eventVenue, event.eventName)
            cell.eventVenue.text = "Needs a Location"
        } else {
            cell.eventVenue.text = "\(event.eventVenue), \(event.eventAddress), \(event.eventCity)"
        }
        if event.eventDate == "" {
            cell.eventDate.text = "Date not available"
        } else {
            cell.eventDate.text = "\(event.eventDate) at \(event.eventTime)"
        }
        return cell
    }
    
    
    func getUpcomingEvents() {
        Alamofire.request("https://api.meetup.com/2/open_events?lat=\(userLatitude)&lon=\(userLongitude)&key=721e256c6c2f292c50394c77752a62").responseJSON(completionHandler: { response in
            guard let validResponse = response.result.value else { return }
            let swiftyJsonVar = JSON(validResponse)
            if let resData = swiftyJsonVar["results"].arrayObject  {
                let x = resData as! [[String: AnyObject]]
                self.events = x
                self.meetups = x.compactMap(Event.eventFromJsonDict)
                self.meetupTabeView.reloadData()
            }
        })
    }

}
