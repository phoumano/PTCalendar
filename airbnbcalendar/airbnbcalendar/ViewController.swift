//
//  ViewController.swift
//  airbnbcalendar
//
//  Created by PHOUMANO THONGSITHAVONG on 6/7/18.
//  Copyright © 2018 Phoumano Thongsithavong. All rights reserved.
//

import UIKit
import ptcalendar

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCalendar()
    }
    
    // MARK: - Private Functions
    
    private func loadCalendar() {
        let nib = UINib(nibName: "CalendarView", bundle: Bundle.init(for: CalendarView.self))
        let objects = nib.instantiate(withOwner: nil, options: nil)
        let calendarView = objects.first as! CalendarView
        calendarView.frame = view.frame
        calendarView.delegate = self
        
        view.addSubview(calendarView)
    }
}

extension ViewController: PTCalendarViewDelegate {
    func calendarViewDidTapClearButton(_ calendar: CalendarView) {
        print("calendarViewDidTapClearButton")
    }
    
    func calendarView(_ calendar: CalendarView, didSelectStartDate date: Date) {
        print("didSelectStartDate: \(date)")
    }

    func calendarView(_ calendar: CalendarView, didSelectEndDate date: Date) {
        print("didSelectEndDate: \(date)")
    }
}
