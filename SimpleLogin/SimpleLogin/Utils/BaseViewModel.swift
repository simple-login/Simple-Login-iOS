//
//  BaseViewModel.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import SimpleLoginPackage
import UIKit

class BaseViewModel {
    deinit {
        print("\(Self.self) is deallocated")
    }
}

class BaseClientViewModel: BaseViewModel {
    let client: SLClient

    init(client: SLClient) {
        self.client = client
    }
}

class BaseSessionViewModel: BaseViewModel {
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addAction(UIAction { [unowned self] _ in
            self.refresh()
        }, for: .valueChanged)
        return refreshControl
    }()

    let session: Session

    init(session: Session) {
        self.session = session
    }

    func refresh() {}
}
