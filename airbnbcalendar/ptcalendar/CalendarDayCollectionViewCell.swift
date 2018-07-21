//
//  CalendarDayCollectionViewCell.swift
//  ptcalendar
//
//  Created by PHOUMANO THONGSITHAVONG on 6/8/18.
//  Copyright © 2018 Phoumano Thongsithavong. All rights reserved.
//

import UIKit
import QuartzCore
class CalendarDayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var circle: UIView! {
        didSet {
            circle.backgroundColor = .green
        }
    }
    
    func configure(with calendarItem: CalendarItem, dateFormatter: DateFormatter, showEnds: Bool) {
        if calendarItem is EmptyCalendarItem {
            dayLabel.text = ""
        }
        else {
            dateFormatter.dateFormat = "d"
            dayLabel.text = dateFormatter.string(from: calendarItem.date)
        }
        
        if calendarItem.isStartDate || calendarItem.isEndDate {
            circle.isHidden = false
            dayLabel.textColor = .white
            backgroundColor = .white

            if showEnds {
                if calendarItem.isStartDate {
                    circle.roundCorners([.layerMinXMinYCorner, .layerMinXMaxYCorner])
                }
                else {
                    circle.roundCorners([.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
                }
            }
            else {
                circle.roundAllCorners()
            }
        }
        else {
            circle.isHidden = true
            
            if calendarItem.isSelected {
                dayLabel.textColor = .white
                backgroundColor = .green
            }
            else {
                dayLabel.textColor = .black
                backgroundColor = .white
            }
        }
        
    }
}
