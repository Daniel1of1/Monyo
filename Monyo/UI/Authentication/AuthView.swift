//
//  AuthView.swift
//  Monyo
//
//  Created by Daniel Haight on 29/05/2019.
//  Copyright © 2019 Daniel Haight. All rights reserved.
//

import UIKit

protocol AuthViewDelegate: class {
    func didTapStart()
}

class AuthView: UIView {
    weak var delegate: AuthViewDelegate?
    func update(authentication: Authentication) {
        if authentication.loading {
            // loading state
        } else {
            // description state
        }
    }
}
