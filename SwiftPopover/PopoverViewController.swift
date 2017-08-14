//
//  PopoverViewController.swift
//  SwiftPopover
//
//  Created by Pixelmator on 8/5/17.
//  Copyright © 2017 Pixelmator. All rights reserved.
//

import Cocoa

class PopoverViewController: NSViewController {
    
    @IBAction func checkBoxAction(_ sender: Any) {
        NSLog("The checkbox has been checked")
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        NSLog("The button has been pressed")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
