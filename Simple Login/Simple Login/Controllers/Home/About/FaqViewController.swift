//
//  FaqViewController.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 16/01/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import UIKit
import FirebaseAnalytics

final class FaqViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    
    deinit {
        print("FaqViewController is deallocated")
    }
    
    private var faqs: [Faq] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        readFaqsFromPlist()
        Analytics.logEvent("open_faq_view_controller", parameters: nil)
    }
    
    private func setUpUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorColor = .clear
        FaqTableViewCell.register(with: tableView)
    }
    
    private func readFaqsFromPlist() {
        if let url = Bundle.main.url(forResource: "Faq", withExtension: "plist"), let faqArray = NSArray(contentsOf: url) as? [[String: String]] {
            faqArray.forEach { (faqDictionary) in
                if let question = faqDictionary["question"], let answer = faqDictionary["answer"] {
                    let faq = Faq(question: question, answer: answer)
                    faqs.append(faq)
                }
            }
        }
    }
}

// MARK: - FaqViewController
extension FaqViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return faqs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FaqTableViewCell.dequeueFrom(tableView, forIndexPath: indexPath)
        cell.bind(with: faqs[indexPath.row])
        return cell
    }
}
