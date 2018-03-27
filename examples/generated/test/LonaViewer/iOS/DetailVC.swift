//
//  DetailVC.swift
//  iOS
//
//  Created by Jason Zurita on 3/3/18.
//  Copyright © 2018 Lona. All rights reserved.
//

import UIKit

final class DetailVC: UIViewController {
    private let _generated: Generated

    init(generated: Generated) {
        _generated = generated
        super.init(nibName: nil, bundle: nil)
        self.title = generated.rawValue
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) not implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.blue50
        view.addSubview(_generated.view, constraints: _generated.constraints)
    }
}
