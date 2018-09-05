//
//  meetupTableViewCell.swift
//  locationAndJSON
//
//  Created by Amarjeet on 9/3/18.
//  Copyright © 2018 Amarjeet. All rights reserved.
//

import UIKit

class meetupTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

   
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventVenue: UILabel!
    @IBOutlet weak var meetupGroupName: UILabel!
    @IBOutlet weak var eventDate: UILabel!
}
