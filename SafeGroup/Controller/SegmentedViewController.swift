//
//  SegmentedViewController.swift
//  SafeGroup
//
//  Created by jmateos on 28/12/20.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit

class SegmentedViewController: UIViewController {

    //----------------------------------------------------------------
    // MARK:-
    // MARK:- Outlets
    //----------------------------------------------------------------

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    

    //----------------------------------------------------------------
    // MARK:-
    // MARK:- Variables
    //----------------------------------------------------------------

    var event: Event!
    
    private lazy var firstViewController: ActiveEventViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ActiveEventViewController") as! ActiveEventViewController
        viewController.event = event

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()

    private lazy var secondViewController: WallViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "WallViewController") as! WallViewController
        viewController.event = self.event

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()
    
    private lazy var thirdViewController: EventAlertsViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)

        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "EventAlertsViewController") as! EventAlertsViewController
        viewController.event = self.event

        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)

        return viewController
    }()


    //----------------------------------------------------------------
    // MARK:-
    // MARK:- Abstract Method
    //----------------------------------------------------------------

    static func viewController() -> SegmentedViewController {
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SegmentedViewController") as! SegmentedViewController
    }

    //----------------------------------------------------------------
    // MARK:-
    // MARK:- Memory Management Methods
    //----------------------------------------------------------------

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    //----------------------------------------------------------------
    // MARK:-
    // MARK:- Action Methods
    //----------------------------------------------------------------

    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        updateView()
    }

    @IBAction func doneButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //----------------------------------------------------------------
    // MARK:-
    // MARK:- Custom Methods
    //----------------------------------------------------------------

    private func add(asChildViewController viewController: UIViewController) {

        // Add Child View Controller
        addChild(viewController)

        // Add Child View as Subview
        containerView.addSubview(viewController.view)

        // Configure Child View
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // Notify Child View Controller
        viewController.didMove(toParent: self)
    }

    //----------------------------------------------------------------

    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParent: nil)

        // Remove Child View From Superview
        viewController.view.removeFromSuperview()

        // Notify Child View Controller
        viewController.removeFromParent()
    }

    //----------------------------------------------------------------

    private func updateView() {
        switch segmentControl.selectedSegmentIndex {
        case 0:
            remove(asChildViewController: secondViewController)
            remove(asChildViewController: thirdViewController)
            add(asChildViewController: firstViewController)
        case 1:
            remove(asChildViewController: firstViewController)
            remove(asChildViewController: thirdViewController)
            add(asChildViewController: secondViewController)
        case 2:
            remove(asChildViewController: firstViewController)
            remove(asChildViewController: secondViewController)
            add(asChildViewController: thirdViewController)
        default:
            break
        }
    }

    //----------------------------------------------------------------

    func setupView() {
        updateView()
    }



    //----------------------------------------------------------------
    // MARK:-
    // MARK:- View Life Cycle Methods
    //----------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    //----------------------------------------------------------------

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    //----------------------------------------------------------------

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}
