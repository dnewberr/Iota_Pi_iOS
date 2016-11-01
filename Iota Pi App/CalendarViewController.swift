//
//  SecondViewController.swift
//  Iota Pi App
//
//  Created by Deborah Newberry on 10/27/16.
//  Copyright © 2016 Deborah Newberry. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCellView: JTAppleDayCellView {
    @IBOutlet weak var dayLabel: UILabel!

    var normalDayColor = UIColor.black
    var weekendDayColor = UIColor.gray
    
    
    func setupCellBeforeDisplay(cellState: CellState, date: NSDate) {
        // Setup Cell text
        dayLabel.text =  cellState.text
        
        // Setup text color
        configureTextColor(cellState: cellState)
    }
    
    func configureTextColor(cellState: CellState) {
        if cellState.dateBelongsTo == DateOwner.thisMonth {
            dayLabel.textColor = normalDayColor
        } else {
            dayLabel.textColor = weekendDayColor
        }
    }
}

class CalendarViewController: UIViewController, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        // You can set your date using NSDate() or NSDateFormatter. Your choice.
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let firstDate = formatter.date(from: "2016 01 05")
        let secondDate = NSDate()
        let numberOfRows = 6
        let aCalendar = NSCalendar.current // Properly configure your calendar to your time zone here
        
        return ConfigurationParameters(
            startDate: (firstDate! as Date) as Date,
            endDate: secondDate as Date,
            numberOfRows: numberOfRows,
            calendar: (aCalendar as NSCalendar) as Calendar,
            generateInDates: InDateCellGeneration.forFirstMonthOnly,
            generateOutDates: OutDateCellGeneration.tillEndOfGrid,
            firstDayOfWeek: DaysOfWeek.sunday)
    }
    
    func calendar(calendar: JTAppleCalendarView, isAboutToDisplayCell cell: JTAppleDayCellView, date: NSDate, cellState: CellState) {
        (cell as! CalendarCellView).setupCellBeforeDisplay(cellState: cellState, date: date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calendarView.dataSource = self
        self.calendarView.delegate = self
        self.calendarView.registerCellViewXib(file: "CalendarCellView")
    }
}

