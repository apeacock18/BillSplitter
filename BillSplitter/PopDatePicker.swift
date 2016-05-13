//
//  PopDatePicker.swift
//  BillSplitter
//
//  Created by gomeow on 5/12/16.
//  Copyright © 2016 Davis Mariotti. All rights reserved.
//

import UIKit

class PopDatePicker : NSObject, UIPopoverPresentationControllerDelegate, DatePickerViewControllerDelegate {

    typealias PopDatePickerCallback = (newDate : NSDate, forTextField : UITextField)->()

    var datePickerVC : PopDateViewController
    var popover : UIPopoverPresentationController?
    var textField : UITextField!
    var dataChanged : PopDatePickerCallback?
    var presented = false
    var offset : CGFloat = 8.0


}