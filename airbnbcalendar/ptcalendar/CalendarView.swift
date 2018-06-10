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

public struct CalendarItem {
    public let date: Date
    public var indexPath: IndexPath?
    public var isSelected: Bool
    public var isStartDate: Bool
    public var isEndDate: Bool
    
    init(date: Date, indexPath: IndexPath? = nil, isSelected: Bool = false, isStartDate: Bool = false, isEndDate: Bool = false) {
        self.date = date
        self.indexPath = indexPath
        self.isSelected = isSelected
        self.isStartDate = isStartDate
        self.isEndDate = isEndDate
    }
}

public class CalendarView: UIView {

    public enum ViewID: String {
        case clearButton
        case collectionView
    }
    
    private enum Constant {
        static let HeaderViewHeight: CGFloat = 60
        static let CalendarDayCollectionViewCell = "CalendarDayCollectionViewCell"
        static let MonthHeaderCollectionReusableView = "MonthHeaderCollectionReusableView"
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
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
            
            let nib = UINib(nibName: Constant.CalendarDayCollectionViewCell, bundle: Bundle.init(for: CalendarDayCollectionViewCell.self))
            let headerNib = UINib(nibName: Constant.MonthHeaderCollectionReusableView, bundle: Bundle.init(for: MonthHeaderCollectionReusableView.self))
            
            collectionView.register(nib, forCellWithReuseIdentifier: Constant.CalendarDayCollectionViewCell)
            collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Constant.MonthHeaderCollectionReusableView)
        }
    }
    
    // MARK: - Public Properties
    
    public weak var delegate: PTCalendarViewDelegate?
    
    // MARK: - Private Properties
    
    private var calendar = Calendar.current
    private let dateFormatter = DateFormatter()

    private var calendarItems: [[CalendarItem]]!
    
    private var startCalendarItem: CalendarItem? {
        didSet {
            guard let date = startCalendarItem?.date else {
                return
            }
            
            delegate?.calendarView(self, didSelectStartDate: date)
        }
    }
    
    private var endCalendarItem: CalendarItem? {
        didSet {
            guard let date = endCalendarItem?.date else {
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
        
        calendarItems = createDates(from: startDate, to: endDate)
        collectionView.reloadData()
    }
    
    private func reset() {
        startCalendarItem = nil
        endCalendarItem = nil
        unselectAll()
        
        titleLabel.text = "Select dates"
        collectionView.reloadData()
    }
    
    private func unselectAll() {
        let selectedItems = calendarItems.flatMap { $0 }.filter { $0.isSelected }
        
        selectedItems.forEach { item in
            var tempItem = item
            tempItem.isSelected = false
            tempItem.isStartDate = false
            tempItem.isEndDate = false
            
            reassign(tempItem, indexPath: tempItem.indexPath!)
        }
    }
    
    private func startNewDateRange(_ calendarItem: CalendarItem, andUnselectAll unselect: Bool = true) {
        if unselect {
            unselectAll()
        }
        
        var m_calendarItem = calendarItem
        m_calendarItem.isSelected = true
        m_calendarItem.isStartDate = true
        startCalendarItem = m_calendarItem
        reassign(m_calendarItem, indexPath: m_calendarItem.indexPath!)
        
        endCalendarItem = nil
        
        dateFormatter.dateFormat = "MMM dd"
        titleLabel.text = "\(dateFormatter.string(from: m_calendarItem.date)) - End Date"
        print("Start date: \(m_calendarItem.date)\nEnd Date: nil")
    }
    
    private func reassign(_ calendarItem: CalendarItem, indexPath: IndexPath) {
        calendarItems[indexPath.section][indexPath.row] = calendarItem
    }
    
    private func completeDateSelection(_ selected: Bool, startCalendarItem: CalendarItem, endCalendarItem: CalendarItem) {
        
        // Select/Deselect all dates between startDate and endDate
        guard let startIndexPath = startCalendarItem.indexPath,
            let endIndexPath = endCalendarItem.indexPath else {
                return
        }
        
        var currentIndexPath = IndexPath(row: startIndexPath.row + 1, section: startIndexPath.section)
        
        repeat {
            let tempItems: [CalendarItem] = calendarItems[currentIndexPath.section]
            
            if currentIndexPath.row < tempItems.count {
                // we still have days left in the month to highlight
                var calendarItem = tempItems[currentIndexPath.row]
                calendarItem.isSelected = true
                reassign(calendarItem, indexPath: currentIndexPath)
                
                currentIndexPath = IndexPath(row: currentIndexPath.row + 1, section: currentIndexPath.section)
            }
            else {
                // go to next month and start on day 1
                currentIndexPath = IndexPath(row: 0, section: currentIndexPath.section + 1)
            }
            
        } while currentIndexPath.compare(endIndexPath) == .orderedAscending
    }
}

// MARK: - UICollectionView

extension CalendarView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return calendarItems.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarItems[section].count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize{
        return CGSize(width: collectionView.frame.size.width, height: Constant.HeaderViewHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.bounds.size.width / 7
        return CGSize(width: width, height: width)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: Constant.MonthHeaderCollectionReusableView,
                                                                         for: indexPath) as! MonthHeaderCollectionReusableView

        let calendarItem = calendarItems[indexPath.section][0]
        let month = calendar.component(.month, from: calendarItem.date)
        
        view.primaryLabel.text = calendar.monthString(month)
        
        return view
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.CalendarDayCollectionViewCell, for: indexPath) as? CalendarDayCollectionViewCell else {
            fatalError()
        }
        
        var calendarItem = calendarItems[indexPath.section][indexPath.row]
        calendarItem.indexPath = indexPath
        reassign(calendarItem, indexPath: indexPath)
        
        let showEnds = startCalendarItem != nil && endCalendarItem != nil
        cell.configure(with: calendarItem, dateFormatter: dateFormatter, showEnds: showEnds)
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var calendarItem = calendarItems[indexPath.section][indexPath.row]

        // We already have both selected start and end date
        if startCalendarItem != nil && endCalendarItem != nil {
            reset()
            
            // Start a new date range
            startNewDateRange(calendarItem, andUnselectAll: false)
        }
        // We haven't selected anything yet
        else if startCalendarItem == nil && endCalendarItem == nil {
            // Start a new date range
            startNewDateRange(calendarItem)
        }
        // Attempting to select an end date
        else if let startCalendarItem = startCalendarItem, endCalendarItem == nil {
            if startCalendarItem.date.isBefore(calendarItem.date) {
                // User selected an end date that's after the start date
                calendarItem.isSelected = true
                calendarItem.isEndDate = true
                endCalendarItem = calendarItem
                reassign(calendarItem, indexPath: calendarItem.indexPath!)
                
                print("\n\nStart date: \(startCalendarItem.date)\nEnd Date: \(calendarItem.date)\n\n")
            }
            else {
                // User selected an end date BEFORE the start date
                // Start a new date range
                startNewDateRange(calendarItem)
            }
        }
        
        if let startItem = startCalendarItem, let endItem = endCalendarItem {
            completeDateSelection(true, startCalendarItem: startItem, endCalendarItem: endItem)
            dateFormatter.dateFormat = "MMM dd"
            titleLabel.text = "\(dateFormatter.string(from: startItem.date)) - \(dateFormatter.string(from: endItem.date))"
        }
        
        collectionView.reloadData()
    }
}

extension CalendarView {
    func createDates(from startDate: Date, to endDate:Date) -> [[CalendarItem]] {
        var datesArray: [CalendarItem] =  []
        var startDate = startDate
        
        var startNewMonth = false
        var calendarDates: [[CalendarItem]] = []
        
        while startDate <= endDate {
            
            if startNewMonth {
                calendarDates.append(datesArray)
                datesArray.removeAll()
                startNewMonth = false
            }
            
            let calendarItem = CalendarItem(date: startDate)
            datesArray.append(calendarItem)
            
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
