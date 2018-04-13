//
//  ViewSelectionVC.swift
//  LonaViewer
//
//  Created by Jason Zurita on 3/2/18.
//  Copyright © 2018 Lona. All rights reserved.
//

import UIKit

final class ViewSelectionVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Colors.blue50

        let tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        view.addSubview(tableView, constraints: [
            equal(\.topAnchor),
            equal(\.bottomAnchor),
            equal(\.leftAnchor),
            equal(\.rightAnchor),
            ])
    }
}

extension ViewSelectionVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailVC(generated: Generated.allValues()[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension ViewSelectionVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Generated.allValues().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.clear
        let label = UILabel()
        label.text = "\(Generated.allValues()[indexPath.row].rawValue)"
        cell.contentView.addSubview(label, constraints: [
            equal(\.topAnchor),
            equal(\.bottomAnchor),
            equal(\.leftAnchor, constant: 15),
            equal(\.rightAnchor),
            ])
        return cell
    }
}
