import Foundation

protocol DatePickerVCDelegate: class {
    func datePicked(sender: DatePickerViewController, date: NSDate)
}