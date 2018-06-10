//
//  CalendarDayCollectionViewCell.swift
//  ptcalendar
//
//  Created by PHOUMANO THONGSITHAVONG on 6/8/18.
//  Copyright © 2018 Phoumano Thongsithavong. All rights reserved.
//

import UIKit

class CalendarDayCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                dayLabel.textColor = .white
                backgroundColor = .green
            }
            else {
                dayLabel.textColor = .black
                backgroundColor = .white
            }
        }
    }

    @IBOutlet weak var dayLabel: UILabel!
    
    func configure(with date: Date, dateFormatter: DateFormatter) {
        dayLabel.text = dateFormatter.string(from: date)
    }
}
