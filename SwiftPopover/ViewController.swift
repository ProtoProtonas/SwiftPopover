//
//  ViewController.swift
//  SwiftPopover
//
//  Created by Pixelmator on 8/5/17.
//  Copyright © 2017 Pixelmator. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSPopoverDelegate {
    
    @IBOutlet weak var lightRadioButton: NSButton!
    @IBOutlet weak var darkRadioButton: NSButton!
    
    @IBOutlet weak var leftRadioButton: NSButton!
    @IBOutlet weak var rightRadioButton: NSButton!
    @IBOutlet weak var topRadioButton: NSButton!
    @IBOutlet weak var bottomRadioButton: NSButton!
    
    @IBOutlet weak var animatesCheckbox: NSButton?
    @IBOutlet weak var useCustomDetachedWindow: NSButton?
    @IBOutlet weak var showPopoverButton: NSButton?
    
    var myPopover: NSPopover?
    var popoverViewController: NSViewController?
    var prefEdge: NSRectEdge?
    
    var detachedWindow: NSWindow?
    var detachedHUDWindow: NSPanel?
    
    
    @IBAction func popoverPosition(_ sender: NSButton) {}
    @IBAction func getPopoverType(_ sender: NSButton) {}   //both are necessary in order to keep radio buttons in groups since using NSMatrix is not recommended anymore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popoverViewController = self.storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "PopoverViewController")) as? NSViewController
        
        // To make a popover detachable to a separate window you need:
        // 1) a separate NSWindow instance
        //      - it must not be visible:
        //          (if created by Interface Builder: not "Visible at Launch")
        //          (if created in code: must not be ordered front)
        //      - must not be released when closed
        //      - ideally the same size as the view controller's view frame size
        //
        // 2) NSViewController instance for each window
        //
        // To make the popover detached, simply drag the visible popover away from its attached view
        
        let frame: NSRect = self.popoverViewController!.view.bounds
        var styleMask: NSWindow.StyleMask =  [.closable, .titled]
        let rect: NSRect = NSWindow.contentRect(forFrameRect: frame, styleMask: styleMask)
        
        detachedWindow = NSWindow.init(contentRect: rect, styleMask: styleMask, backing: NSWindow.BackingStoreType.buffered, defer: true)
        self.detachedWindow?.contentViewController = self.popoverViewController
        
        self.detachedWindow?.isReleasedWhenClosed = false
        
        styleMask = [.titled, .closable, .hudWindow, .utilityWindow]
        detachedHUDWindow = NSPanel.init(contentRect: rect, styleMask: styleMask, backing: NSWindow.BackingStoreType.buffered, defer: true)
        self.detachedHUDWindow?.contentViewController = self.popoverViewController;
        self.detachedHUDWindow?.isReleasedWhenClosed = false
        
        lightRadioButton.state = NSControl.StateValue.on
        darkRadioButton.state = NSControl.StateValue.off
        
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    // -------------------------------------------------------------------------------
    //  createPopover
    // -------------------------------------------------------------------------------
    
    func createPopover() {
        if (self.myPopover == nil)
        {
            
            if leftRadioButton.state == NSControl.StateValue.on {
                self.prefEdge = NSRectEdge.minX
            } else if rightRadioButton.state == NSControl.StateValue.on {
                self.prefEdge = NSRectEdge.maxX
            } else if topRadioButton.state == NSControl.StateValue.on {
                self.prefEdge = NSRectEdge.minY
            } else if bottomRadioButton.state == NSControl.StateValue.on {
                self.prefEdge = NSRectEdge.maxY
            } else {
                assertionFailure("Invalid selection")
            }
            
            // create and setup our popover
            myPopover = NSPopover.init()
            
            // the popover retains us and we retain the popover,
            // we drop the popover whenever it is closed to avoid a cycle
            
            self.myPopover?.contentViewController = self.popoverViewController;
            
            switch self.animatesCheckbox!.state
            {
            case NSControl.StateValue.on:
                self.myPopover?.animates = true
            case NSControl.StateValue.off:
                self.myPopover?.animates = false
            default:
                assertionFailure("Invalid selection")
            }
            
            switch (self.lightRadioButton!.state)
            {
            case NSControl.StateValue.on:
                self.myPopover?.appearance = NSAppearance.init(named: NSAppearance.Name.vibrantLight)
            case NSControl.StateValue.off:
                self.myPopover?.appearance = NSAppearance.init(named: NSAppearance.Name.vibrantDark)
            default:
                assertionFailure("Invalid selection")
            }
            
            // AppKit will close the popover when the user interacts with a user interface element outside the popover.
            // note that interacting with menus or panels that become key only when needed will not cause a transient popover to close.
            self.myPopover?.behavior = NSPopover.Behavior.transient
            
            // so we can be notified when the popover appears or closes
            self.myPopover?.delegate = self
            NSLog("Popover has been created")
        }
    }
    
    // -------------------------------------------------------------------------------
    //  showPopoverAction:sender
    // -------------------------------------------------------------------------------
    
    @IBAction func showPopoverAction(_ sender: NSButton) {
        switch (self.useCustomDetachedWindow?.state)
        {
        case NSControl.StateValue.off?:
            if (self.detachedHUDWindow?.isVisible == true)
            {
                self.detachedHUDWindow?.close()
            }
            
            if (self.detachedWindow?.isVisible)!
            {
                // popover is already detached to a separate window, so select its window instead
                self.detachedWindow?.makeKeyAndOrderFront(self)
                return
            }
        case NSControl.StateValue.on?:
            if (self.detachedWindow?.isVisible == true)
            {
                self.detachedWindow?.close()
            }
            
            if (self.detachedHUDWindow?.isVisible)!
            {
                // dark style popover is already detached to a separate window, so select its window instead
                self.detachedHUDWindow?.makeKeyAndOrderFront(self)
                return
            }
        default:
            assertionFailure("Invalid selection")
        }
        
        self.createPopover()
        
        let targetButton: NSButton? = sender
        // configure the preferred position of the popover
        
        self.myPopover?.show(relativeTo: targetButton!.bounds, of: sender as NSView, preferredEdge: self.prefEdge!)
    }
    
    
    // -------------------------------------------------------------------------------
    // Invoked on the delegate when the NSPopoverWillShowNotification notification is sent.
    // This method will also be invoked on the popover.
    // -------------------------------------------------------------------------------
    func popoverWillShow(_ notification: Notification) {
        let popover: NSPopover? = notification.object as? NSPopover
        if popover != nil {
            //do stuff with the popover
        }
    }
    
    // -------------------------------------------------------------------------------
    // Invoked on the delegate when the NSPopoverDidShowNotification notification is sent.
    // This method will also be invoked on the popover.
    // -------------------------------------------------------------------------------
    
    func popoverDidShow(_ notification: Notification) {
        // add new code here after the popover has been shown
    }
    
    // -------------------------------------------------------------------------------
    // Invoked on the delegate when the NSPopoverDidCloseNotification notification is sent.
    // This method will also be invoked on the popover.
    // -------------------------------------------------------------------------------
    func popoverDidClose(_ notification: Notification) {
        myPopover = nil
    }
    
    // -------------------------------------------------------------------------------
    // Invoked on the delegate to give permission to detach popover as a separate window.
    // -------------------------------------------------------------------------------
    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        return true
    }
    
    // -------------------------------------------------------------------------------
    // Invoked on the delegate to when the popover was detached.
    // Note: Invoked only if AppKit provides the window for this popover.
    // -------------------------------------------------------------------------------
    func popoverDidDetach(_ popover: NSPopover) {
        NSLog("popoverDidDetach")
    }
    
    // -------------------------------------------------------------------------------
    // Invoked on the delegate asked for the detachable window for the popover.
    // -------------------------------------------------------------------------------
    //- (NSWindow *)detachableWindowForPopover:(NSPopover *)popover
    func detachableWindow(for popover: NSPopover) -> NSWindow? {
        
        var window: NSWindow?
        
        if (self.useCustomDetachedWindow?.state == NSControl.StateValue.on) {
            window = self.detachedWindow!
            if popover.appearance?.name == NSAppearance.Name.vibrantDark {
                // use the dark window (style HUD)
                window = self.detachedHUDWindow!
            }
        }
        
        return window
    }
}


