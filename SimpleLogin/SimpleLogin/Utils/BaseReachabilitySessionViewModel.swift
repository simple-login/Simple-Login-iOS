//
//  BaseReachabilitySessionViewModel.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 13/03/2022.
//

import Combine
import Foundation

class BaseReachabilitySessionViewModel: BaseSessionViewModel {
    let reachabilityObserver: ReachabilityObserver
    private var cancellables = Set<AnyCancellable>()

    init(session: Session, reachabilityObserver: ReachabilityObserver) {
        self.reachabilityObserver = reachabilityObserver
        super.init(session: session)
        self.reachabilityObserver.$reachable
            .receive(on: DispatchQueue.main)
            .sink { [weak self] reachable in
                guard let self = self else { return }
                if reachable {
                    self.whenReachable()
                } else {
                    self.whenUnreachable()
                }
            }
            .store(in: &cancellables)
    }

    func whenReachable() {}
    func whenUnreachable() {}
}
