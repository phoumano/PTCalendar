//
//  CalendarView.swift
//  ptcalendar
//
//  Created by PHOUMANO THONGSITHAVONG on 6/7/18.
//  Copyright © 2018 Phoumano Thongsithavong. All rights reserved.
//

import UIKit
import Foundation

public protocol PTCalendarViewDelegate: class {
    func calendarView(_ calendar: CalendarView, didSelectStartDate date: Date)
    func calendarView(_ calendar: CalendarView, didSelectEndDate date: Date)
    func calendarViewDidTapClearButton(_ calendar: CalendarView)
}

private struct SelectedDate {
    let date: Date
    let indexPath: IndexPath
}

public class CalendarView: UIView {

    enum ViewID: String {
        case clearButton
        case collectionView
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var clearButton: UIButton! {
        didSet {
            clearButton.accessibilityIdentifier = ViewID.clearButton.rawValue
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.accessibilityIdentifier = ViewID.collectionView.rawValue
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.allowsMultipleSelection = true
            
            let nib = UINib(nibName: "CalendarDayCollectionViewCell", bundle: Bundle.init(for: CalendarDayCollectionViewCell.self))
            let headerNib = UINib(nibName: "MonthHeaderCollectionReusableView", bundle: Bundle.init(for: MonthHeaderCollectionReusableView.self))
            
            collectionView.register(nib, forCellWithReuseIdentifier: "CalendarDayCollectionViewCell")
            collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "MonthHeaderCollectionReusableView")
        }
    }
    
    // MARK: - Public Properties
    
    public weak var delegate: PTCalendarViewDelegate?
    
    // MARK: - Private Properties
    
    private var calendar = Calendar.current
    private let dateFormatter = DateFormatter()

    private var dates: [[Date]]!
    private var selectedStartDate: SelectedDate? {
        didSet {
            guard let date = selectedStartDate?.date else {
                return
            }
            
            delegate?.calendarView(self, didSelectStartDate: date)
        }
    }
    
    private var selectedEndDate: SelectedDate? {
        didSet {
            guard let date = selectedEndDate?.date else {
                return
            }
            
            delegate?.calendarView(self, didSelectEndDate: date)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        reset()
        delegate?.calendarViewDidTapClearButton(self)
    }
    
    // MARK: - Public Functions
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        start()
    }
    
    // MARK: - Private Functions

    private func start() {
        let startDate = Date()
        guard let endDate = Calendar.current.date(byAdding: .year, value: 2, to: startDate) else {
            return
        }
        
        dateFormatter.dateFormat = "dd"
        dates = createDates(from: startDate, to: endDate)
        collectionView.reloadData()
    }
    
    private func reset() {
        setSelected(false, startDate: selectedStartDate, endDate: selectedEndDate)
        selectedStartDate = nil
        selectedEndDate = nil
    }
}

extension CalendarView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dates.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates[section].count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        return CGSize(width: collectionView.frame.size.width, height: 44)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "MonthHeaderCollectionReusableView",
                                                                         for: indexPath) as! MonthHeaderCollectionReusableView

        let date = dates[indexPath.section][0]
        let month = calendar.component(.month, from: date)
        
        view.primaryLabel.text = calendar.monthString(month)
        
        return view
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarDayCollectionViewCell", for: indexPath) as? CalendarDayCollectionViewCell else {
            fatalError()
        }
        
        let date = dates[indexPath.section][indexPath.row]
        cell.configure(with: date, dateFormatter: dateFormatter)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let date = dates[indexPath.section][indexPath.row]

        // We already have both selected start and end date
        if selectedStartDate != nil && selectedEndDate != nil {
            reset()
        }
        
        // We haven't selected anything yet
        if selectedStartDate == nil && selectedEndDate == nil {
            selectedStartDate = SelectedDate(date: date, indexPath: indexPath)
            print("Start date: \(date)\nEnd Date: nil")
            return
        }
        
        // Attempting to select an end date
        if let startDate = selectedStartDate, selectedEndDate == nil {
            
            // Make sure the end date is after the start date
            guard startDate.date.isBefore(date) else {
                
                // Start a new date range
                collectionView.deselectItem(at: startDate.indexPath, animated: false)
                selectedStartDate = SelectedDate(date: date, indexPath: indexPath)
                selectedEndDate = nil
                print("Start date: \(date)\nEnd Date: nil")
                return
            }
            
            selectedEndDate = SelectedDate(date: date, indexPath: indexPath)
            
            guard let endDate = selectedEndDate else {
                return
            }

            print("\n\nStart date: \(startDate.date)\nEnd Date: \(endDate.date)\n\n")
            
            setSelected(true, startDate: startDate, endDate: endDate)
        }
    }
    
    private func setSelected(_ selected: Bool, startDate: SelectedDate?, endDate: SelectedDate?) {
        
        // Start Date
        guard let startDate = startDate, let startDateCell = collectionView.cellForItem(at: startDate.indexPath) as? CalendarDayCollectionViewCell else {
            return
        }
        
        var startIndexPath = startDate.indexPath
        startDateCell.isSelected = selected
        
        if selected == false {
            collectionView.deselectItem(at: startDate.indexPath, animated: false)
        }

        // End Date
        guard let endDate = endDate, let endDateCell = collectionView.cellForItem(at: endDate.indexPath) as? CalendarDayCollectionViewCell else {
            return
        }
        
        let endIndexPath = endDate.indexPath
        endDateCell.isSelected = selected

        if selected == false {
            collectionView.deselectItem(at: endDate.indexPath, animated: false)
        }

        // Select/Deselect all dates between startDate and endDate
        repeat {
            let tempDates: [Date] = dates[startIndexPath.section]
            
            if startIndexPath.row < tempDates.count {
                // we still have days left in the month to highlight
                guard let cell = collectionView.cellForItem(at: startIndexPath) as? CalendarDayCollectionViewCell else {
                    return
                }
                
                cell.isSelected = selected
                
                startIndexPath = IndexPath(row: startIndexPath.row + 1, section: startIndexPath.section)
            }
            else {
                // go to next month and start on day 1
                startIndexPath = IndexPath(row: 0, section: startIndexPath.section + 1)
            }
            
        } while startIndexPath.compare(endIndexPath) == .orderedAscending
    }
}

extension CalendarView {
    func createDates(from startDate: Date, to endDate:Date) -> [[Date]] {
        var datesArray: [Date] =  [Date]()
        var startDate = startDate
        let calendar = Calendar.current
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        
        var startNewMonth = false
        var calendarDates: [[Date]] = []
        
        while startDate <= endDate {
            
            if startNewMonth {
                calendarDates.append(datesArray)
                datesArray.removeAll()
                startNewMonth = false
            }
            
            datesArray.append(startDate)
            
            let previousDateDay = calendar.component(.day, from: startDate)
            startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
            
            // Get month of dates to find out if it's a new day
            let startDateDay = calendar.component(.day, from: startDate)

            if startDateDay < previousDateDay {
                startNewMonth = true
            }
        }
        
        return calendarDates
    }
}
