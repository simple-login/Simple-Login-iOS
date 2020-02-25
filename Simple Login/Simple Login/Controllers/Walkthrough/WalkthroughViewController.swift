//
//  WalkthroughViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 25/02/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit

final class WalkthroughViewController: UIPageViewController, Storyboarded {
    
    private var currentWalkthroughStepViewControllerIndex: Int = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        print("WalkthroughViewController is deallocated")
    }
    
    var getStarted: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SLColor.tintColor
        dataSource = self
        
        if let walkthroughStep1ViewController = walkthroughStepControllerAt(index: 0) {
            setViewControllers([walkthroughStep1ViewController], direction: .forward, animated: true, completion: nil)
        }
        
    }
    
    private func walkthroughStepControllerAt(index: Int) -> BaseWalkthroughStepViewController? {
        guard index >= 0 && index <= 3 else { return nil }
        
        switch index {
        case 0: return WalkthroughWelcomeViewController.instantiate(storyboardName: "Walkthrough")
            
        case 1: return WalkthroughNoExtraMailViewController.instantiate(storyboardName: "Walkthrough")
            
        case 2: return WalkthroughNoMoreSpamViewController.instantiate(storyboardName: "Walkthrough")
            
        case 3:
            let walkthroughLastStepViewController = WalkthroughLastStepViewController.instantiate(storyboardName: "Walkthrough")
            
            walkthroughLastStepViewController.didTapGetStartedButton = { [unowned self] in
                self.dismiss(animated: true) {
                    self.getStarted?()
                }
            }
            
            return walkthroughLastStepViewController
            
        default: return nil
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension WalkthroughViewController: UIPageViewControllerDataSource {
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 4
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentWalkthroughStepViewControllerIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let walkthroughStepController = viewController as? BaseWalkthroughStepViewController else { return nil }
        
        let index = walkthroughStepController.index
        currentWalkthroughStepViewControllerIndex = index
        
        if index == 0 { return nil}
        
        return walkthroughStepControllerAt(index: index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let walkthroughStepController = viewController as? BaseWalkthroughStepViewController else { return nil }
        
        let index = walkthroughStepController.index
        currentWalkthroughStepViewControllerIndex = index
        
        if index == 3 { return nil}
        
        return walkthroughStepControllerAt(index: index + 1)
    }
}
