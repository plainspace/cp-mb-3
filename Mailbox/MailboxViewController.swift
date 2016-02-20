//
//  MailboxViewController.swift
//  Mailbox
//
//  Created by Jared on 2/14/16.
//  Copyright © 2016 plainspace. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        var int = UInt32()
        NSScanner(string: hex).scanHexInt(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

class MailboxViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    // This function is necessary to have mutliple gesture recognizers work simultaneously.
    func gestureRecognizer(_: UIGestureRecognizer,shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var mailboxView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var archiveScrollView: UIScrollView!
    @IBOutlet weak var laterScrollView: UIScrollView!
    
    @IBOutlet weak var feedImageView: UIImageView!
    
    @IBOutlet weak var messageImageView: UIView!
    @IBOutlet weak var messageViewContainer: UIView!
    @IBOutlet weak var archiveIconView: UIImageView!
    @IBOutlet weak var laterIconView: UIImageView!
    
    @IBOutlet weak var listImageView: UIImageView!
    @IBOutlet weak var rescheduleImageView: UIImageView!
    @IBOutlet weak var menuImageView: UIImageView!
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var navSegmentedControl: UISegmentedControl!
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    // Original Centers
    var messageImageViewOriginalCenter: CGPoint!
    var archiveIconViewOriginalCenter: CGPoint!
    var laterIconViewOriginalCenter: CGPoint!
    var mailboxViewOriginalCenter: CGPoint!
    var feedImageViewOriginalCenter: CGPoint!
    var feedViewToTop: CGPoint!
    
    var menuVisible: Bool!
    
    // Colors
//    let blueColor = UIColor(red: 68/255, green: 170/255, blue: 210/255, alpha: 1)
//    let yellowColor = UIColor(red: 254/255, green: 202/255, blue: 22/255, alpha: 1)
//    let brownColor = UIColor(red: 206/255, green: 150/255, blue: 98/255, alpha: 1)
//    let greenColor = UIColor(red: 85/255, green: 213/255, blue: 80/255, alpha: 1)
//    let redColor = UIColor(red: 231/255, green: 61/255, blue: 14/255, alpha: 1)
//    let grayColor = UIColor(red: 178/255, green: 178/255, blue: 178/255, alpha: 1)

    let blueColor = UIColor(hexString: "#44AAD2")
    let yellowColor = UIColor(hexString: "#FECA16")
    let brownColor = UIColor(hexString: "#CE9662")
    let greenColor = UIColor(hexString: "#55D550")
    let redColor = UIColor(hexString: "#E73D0C")
    let grayColor = UIColor(hexString: "#B2B2B2")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        // scrollView.contentSize = feedImageView.image!.size
        scrollView.contentSize = CGSize(width: 320, height: 1450)
        scrollView.frame.origin.y = 65
        scrollView.frame.origin.x = 0
        scrollView.alpha = 1
        
        archiveScrollView.delegate = self
        archiveScrollView.contentSize = CGSize(width: 320, height: 1244)
        archiveScrollView.frame.origin.y = 65
        archiveScrollView.frame.origin.x = 320
        archiveScrollView.alpha = 0
        
        laterScrollView.delegate = self
        laterScrollView.contentSize = CGSize(width: 320, height: 128)
        laterScrollView.frame.origin.y = 65
        laterScrollView.frame.origin.x = -320
        laterScrollView.alpha = 0
        
        listImageView.alpha = 0
        rescheduleImageView.alpha = 0
        rescheduleImageView.userInteractionEnabled = Bool(false)
        listImageView.userInteractionEnabled = Bool(false)
        
        messageImageViewOriginalCenter = messageImageView.center
        
        archiveIconViewOriginalCenter = archiveIconView.center
        archiveIconView.alpha = 0
        
        laterIconViewOriginalCenter = laterIconView.center
        laterIconView.alpha = 0
        
        mailboxViewOriginalCenter = mailboxView.center
        
        feedImageViewOriginalCenter = feedImageView.center
        feedViewToTop = CGPoint(x: feedImageView.center.x, y: feedImageView.center.y - messageImageView.center.y*2 )
        
        
        navSegmentedControl.tintColor = blueColor
        navSegmentedControl.selectedSegmentIndex = 1
        
        // The onMessagePan: method will be defined below.
        
        let messageGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onMessagePan:")
        
        messageGestureRecognizer.delegate = self;
        
        // Attach it to a view of your choice. If it's a UIImageView, remember to enable user interaction
        
        messageViewContainer.addGestureRecognizer(messageGestureRecognizer)
        
        messageImageView.addGestureRecognizer(messageGestureRecognizer)
        
        let edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: "onEdgePan:")
        edgeGesture.edges = UIRectEdge.Left
        mailboxView.addGestureRecognizer(edgeGesture)
        
        
        menuButton.enabled = false
        menuVisible = false
        
        // Do any additional setup after loading the view.
    }
    
    // Functions
    
    // Snaps the message back to its original place
    func messageViewGoBack() {
        self.messageImageView.center = self.messageImageViewOriginalCenter
        self.archiveIconView.center = self.archiveIconViewOriginalCenter
        self.laterIconView.center = self.laterIconViewOriginalCenter
    }
    
    // Slides the message back to its original place
    func messageViewGoBackWithAnimation() {
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut , animations: { () -> Void in
            self.messageImageView.center = self.messageImageViewOriginalCenter
            self.archiveIconView.center = self.archiveIconViewOriginalCenter
            self.laterIconView.center = self.laterIconViewOriginalCenter
            }, completion: nil)
        print("message go back")
        
    }
    
    // Slides the message right and moves the feed up
    func messageViewGoRight() {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.messageImageView.center.x = self.messageImageViewOriginalCenter.x + 600
            self.archiveIconView.center.x = self.archiveIconViewOriginalCenter.x + 600
            self.feedImageView.center.y = self.feedViewToTop.y
            print("message go right")
        })
    }
    
    // Slides the message left and moves the feed up
    func messageViewGoLeft() {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.messageImageView.center.x = self.messageImageViewOriginalCenter.x - 600
            self.laterIconView.center.x = self.laterIconViewOriginalCenter.x - 600
            self.feedImageView.center.y = self.feedViewToTop.y
            print("message go left")
            
        })
    }
    
    // Resets the message and moves the feed back down
    func messageAndFeedReset() {
        UIView.animateWithDuration(0.01, delay: 0.4, options: [], animations: { () -> Void in
            self.messageViewGoBack()
            }, completion: nil)
        
        UIView.animateWithDuration(0.4, delay: 0.4, options: [], animations: { () -> Void in
            self.feedImageView.center.y = self.feedImageViewOriginalCenter.y
            }, completion: nil)
    }
    
    
    // Turns on the left icons and turns off the right
    func archiveIconsOnly() {
        laterIconView.alpha = 0
        archiveIconView.alpha = 1
    }
    
    // Turns on the right icons and turns of the left
    func laterIconsOnly() {
        laterIconView.alpha = 1
        archiveIconView.alpha = 0
    }
    
    // Turns the reschedule view on and make it interactive
    func rescheduleViewOn() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.rescheduleImageView.alpha = 1
        })
        rescheduleImageView.userInteractionEnabled = Bool(true)
    }
    
    // Turns the reschedule view off and turns off its interactivity
    func rescheduleViewOff() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.rescheduleImageView.alpha = 0
        })
        rescheduleImageView.userInteractionEnabled = Bool(true)
    }
    
    
    // Turns the list view on and make it interactive
    func listViewOn() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.listImageView.alpha = 1
        })
        listImageView.userInteractionEnabled = Bool(true)
    }
    
    // Turns the list view off and turns off its interactivity
    func listViewOff() {
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.listImageView.alpha = 0
        })
        listImageView.userInteractionEnabled = Bool(true)
    }
    
    // Hide menu
    func hideMenu() {
        print("Menu Hidden")
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.mailboxView.center.x = self.mailboxViewOriginalCenter.x
            }, completion: nil)
        scrollView.userInteractionEnabled = Bool(true)
        menuVisible = false
        
    }
    
    // Show menu
    func showMenu() {
        print("Menu Shown")
        // self.menuImageView.transform = CGAffineTransformMakeScale(0.8, 1)
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.mailboxView.center.x = self.mailboxViewOriginalCenter.x + 270}, completion: nil)
        scrollView.userInteractionEnabled = Bool(false)
        menuVisible = true
    }
    
    // Create Pan Gesture
    func createPanGesture(){
        
        print("Pan Gesture Created")
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onMenuGesture:")
        mailboxView.addGestureRecognizer(panGestureRecognizer)
        scrollView.userInteractionEnabled = Bool(false)
        
    }
    
    // Kill Pan Gesture
    func killPanGesture() {
        
        scrollView.userInteractionEnabled = Bool(true)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onMenuGesture:")
        mailboxView.removeGestureRecognizer(panGestureRecognizer)
        print("Pan Gesture Killed")
        
    }
    
    @IBAction func onMenuButton(sender: AnyObject) {
        
        print("pressed menu button")
        
        if menuVisible == false {
            
            // When menu is shown
            showMenu()
            createPanGesture()
            
            scrollView.userInteractionEnabled = Bool(false)
            
        } else {
            
            // When menu is hidden
            hideMenu()
            killPanGesture()
            
            scrollView.userInteractionEnabled = Bool(true)
            
        }
    }
    
    @IBAction func onMessagePan(sender: AnyObject) {
        let point = sender.locationInView(view)
        let velocity = sender.velocityInView(view)
        let translation = sender.translationInView(view)
        let translationX = translation.x
        let location = sender.locationInView(view)
        
        if panGestureRecognizer.state == UIGestureRecognizerState.Began {
            // print("Gesture began at: \(point)")
            print("Translation Began \(translation.x) MessageView \(messageImageView.center.x) \(archiveIconView.center.x)")
            
        } else if panGestureRecognizer.state == UIGestureRecognizerState.Changed {
            
            print("Gesture changed at: \(point)")
            
            // Make the message follow the X position of the gesture
            messageImageView.center = CGPoint(x: messageImageViewOriginalCenter.x + translation.x, y: messageImageViewOriginalCenter.y)
            
            if translation.x < 60 && translation.x > -60 {
                
                messageViewContainer.backgroundColor = grayColor
                archiveIconView.image = UIImage(named: "archive_icon")
                laterIconView.image = UIImage(named: "later_icon")
                
                // Fade up the archive or later icons as we pan
                if velocity.x > 0 {
                    print("archive")
                    let archiveIconAlpha = convertValue(CGFloat(translation.x), r1Min: 0.0, r1Max: 60.0, r2Min: -1.0, r2Max: 1.0)
                    archiveIconView.alpha = CGFloat(archiveIconAlpha)
                    let laterIconAlpha = convertValue(CGFloat(translation.x), r1Min: 0.0, r1Max: -60.0, r2Min: -1.0, r2Max: 1.0)
                    laterIconView.alpha = CGFloat(laterIconAlpha)
                    
                } else {
                    print("later")
                    let archiveIconAlpha = convertValue(CGFloat(translation.x), r1Min: 0.0, r1Max: 60.0, r2Min: -1.0, r2Max: 1.0)
                    archiveIconView.alpha = CGFloat(archiveIconAlpha)
                    let laterIconAlpha = convertValue(CGFloat(translation.x), r1Min: 0.0, r1Max: -60.0, r2Min: -1.0, r2Max: 1.0)
                    laterIconView.alpha = CGFloat(laterIconAlpha)
                }
                
            } else if translation.x > 60 && translation.x < 200 {
                // ARCHIVE
                archiveIconsOnly()
                messageViewContainer.backgroundColor = greenColor
                archiveIconView.image = UIImage(named: "archive_icon")
                archiveIconView.center = CGPoint(x: archiveIconViewOriginalCenter.x + translation.x - 60 , y: archiveIconViewOriginalCenter.y)
                
            } else if translation.x > 200 {
                // DELETE
                archiveIconsOnly()
                messageViewContainer.backgroundColor = redColor
                archiveIconView.image = UIImage(named: "delete_icon")
                archiveIconView.center = CGPoint(x: archiveIconViewOriginalCenter.x + translation.x - 60 , y: archiveIconViewOriginalCenter.y)
                
            } else if translation.x < -60 && translation.x > -200 {
                // LATER
                laterIconsOnly()
                messageViewContainer.backgroundColor = yellowColor
                laterIconView.image = UIImage(named: "later_icon")
                laterIconView.center = CGPoint(x: laterIconViewOriginalCenter.x + translation.x + 60 , y: laterIconViewOriginalCenter.y)
                
            } else if translation.x < -200 {
                // LIST
                laterIconsOnly()
                messageViewContainer.backgroundColor = brownColor
                laterIconView.image = UIImage(named: "list_icon")
                laterIconView.center = CGPoint(x: laterIconViewOriginalCenter.x + translation.x + 60 , y: laterIconViewOriginalCenter.y)
                
            } else {
                // GREY
                messageViewContainer.backgroundColor = grayColor
                archiveIconView.image = UIImage(named: "archive_icon")
                laterIconView.image = UIImage(named: "later_icon")
            }
            
        } else if panGestureRecognizer.state == UIGestureRecognizerState.Ended {
            // After Gesture Ends
            // print("Gesture ended at \(point)")
            print("Gesture ended at \(translation) MessageView \(messageImageView.center)")
            if translation.x > 60 && translation.x < 200 {
                // Archive selected
                if velocity.x > 0 {
                    print("archive")
                    UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                        self.messageViewGoRight()
                        }, completion: { (TRUE) -> Void in
                            self.messageAndFeedReset()
                    })
                } else {
                    print("go back")
                    messageViewGoBackWithAnimation()
                }
                
            } else if  translation.x > 200 {
                // Delete Selected
                if velocity.x > 0 {
                    print("delete")
                    UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                        self.messageViewGoRight()
                        }, completion: { (TRUE) -> Void in
                            self.messageAndFeedReset()
                    })
                } else {
                    print("go back")
                    messageViewGoBackWithAnimation()
                }
                
            } else if translation.x < -60 && translation.x > -200 {
                // Later Selected
                if velocity.x < 0 {
                    print("later")
                    UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                        self.messageImageView.center.x = self.messageImageViewOriginalCenter.x - 600
                        self.laterIconView.center.x = self.laterIconViewOriginalCenter.x - 600
                        }, completion: { (TRUE) -> Void in
                            self.rescheduleViewOn()
                    })
                    
                } else {
                    print("go back")
                    messageViewGoBackWithAnimation()
                }
                
            } else if translation.x < -200 {
                // List Selected
                if velocity.x < 0 {
                    print("list")
                    UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                        self.messageImageView.center.x = self.messageImageViewOriginalCenter.x - 600
                        self.laterIconView.center.x = self.laterIconViewOriginalCenter.x - 600
                        }, completion: { (TRUE) -> Void in
                            self.listViewOn()
                    })
                    
                } else {
                    print("go back")
                    messageViewGoBackWithAnimation()
                }
                
            } else {
                print("go back")
                messageViewGoBackWithAnimation()
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    // On Reschedule tap
    @IBAction func onRescheduleTap(sender: UITapGestureRecognizer) {
        print("reschedule")
        delay(0.2) {
            self.messageViewGoLeft()
        }
        
        delay(0.5) {
            self.messageAndFeedReset()
        }
        rescheduleViewOff()
    }
    
    // On List tap
    @IBAction func onListTap(sender: UITapGestureRecognizer) {
        print("list")
        delay(0.2) {
            self.messageViewGoLeft()
        }
        
        delay(0.5) {
            self.messageAndFeedReset()
        }
        listViewOff()
    }
    
    // On Segmented control
    @IBAction func onSegmentedControlTap(sender: AnyObject) {
        print(navSegmentedControl.selectedSegmentIndex)
        
        if navSegmentedControl.selectedSegmentIndex == 0 {
            
            // Later selected
            
            navSegmentedControl.tintColor = yellowColor
            
            self.laterScrollView.alpha = 1
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: { () -> Void in
                self.scrollView.frame.origin.x = 320
                }, completion: { (Bool) -> Void in
                    self.scrollView.alpha = 0
                    
            })
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                self.archiveScrollView.frame.origin.x = 640
                }, completion: { (Bool) -> Void in
                    self.archiveScrollView.alpha = 0
                    
            })
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                self.laterScrollView.frame.origin.x = 0
                }, completion: { (Bool) -> Void in
                    self.laterScrollView.alpha = 1
                    
            })
            
            
        } else if navSegmentedControl.selectedSegmentIndex == 1 {
            
            // Mailbox Selected
            
            navSegmentedControl.tintColor = blueColor
            
            self.scrollView.alpha = 1
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                self.scrollView.frame.origin.x = 0
                }, completion: { (Bool) -> Void in
                    self.scrollView.alpha = 1
                    
            })
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                self.archiveScrollView.frame.origin.x = 320
                }, completion: { (Bool) -> Void in
                    self.archiveScrollView.alpha = 0
                    
            })
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                self.laterScrollView.frame.origin.x = -320
                }, completion: { (Bool) -> Void in
                    self.laterScrollView.alpha = 0
                    
            })
            
            
        } else {
            
            // Archive selected
            
            navSegmentedControl.tintColor = greenColor
            
            archiveScrollView.alpha = 1
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                self.scrollView.frame.origin.x = -320
                }, completion: { (Bool) -> Void in
                    self.scrollView.alpha = 0
                    
            })
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                self.archiveScrollView.frame.origin.x = 0
                }, completion: { (Bool) -> Void in
                    self.archiveScrollView.alpha = 1
                    
            })
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
                self.laterScrollView.frame.origin.x = -640
                }, completion: { (Bool) -> Void in
                    self.laterScrollView.alpha = 0
                    
            })
        }
    }
    
    // Screen edge pan gesture recognizer
    func onEdgePan(sender: UIScreenEdgePanGestureRecognizer){
        var point = sender.locationInView(view)
        var velocity = sender.velocityInView(view)
        var translation = sender.translationInView(view)
        var location = sender.locationInView(view)
        
        
        if sender.state == UIGestureRecognizerState.Began {
            print("Screen Edge Pan Began")
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            mailboxView.center = CGPoint(x: mailboxViewOriginalCenter.x + translation.x, y: mailboxViewOriginalCenter.y)
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            print("Screen Edge Pan Ended")
            
            if velocity.x > 0 {
                
                // Menu is shown
                showMenu()
                createPanGesture()
                
            } else {
                
                // Menu is hidden
                hideMenu()
                killPanGesture()
                
            }
        }
    }
    
    // Pan gesture recognizer for menu screen
    
    func onMenuGesture(sender: UIPanGestureRecognizer) {
        
        let point = sender.locationInView(view)
        let velocity = sender.velocityInView(view)
        let translation = sender.translationInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            
            print("Pan Gesture began at: \(point)")
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            mailboxView.center = CGPoint(x: mailboxViewOriginalCenter.x + 270 + translation.x, y: mailboxViewOriginalCenter.y)
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            
            print("Pan Gesture ended at: \(point)")
            
            if velocity.x > 0 {
                showMenu()
            } else if velocity.x < 0 {
                hideMenu()
                sender.enabled = false
                print("Pan Gesture Disabled")
            }
            
        } else {
            sender.enabled = false
        }
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
