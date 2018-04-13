//
//  ViewSelectionVc.swift
//  LonaViewer
//
//  Created by Jason Zurita on 3/2/18.
//  Copyright © 2018 Lona. All rights reserved.
//

import Cocoa

final class ViewSelectionVc: NSViewController {
    @IBOutlet weak var containerBox: NSBox!
    override func viewDidLoad() {
        super.viewDidLoad()
        containerBox.fillColor = Colors.blue50
    }
}

extension ViewSelectionVc: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard tableColumn == tableView.tableColumns[0] else { return nil }
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ExampleCellID"), owner: self) as? NSTableCellView else { return nil}

        cell.textField?.stringValue = Generated.allValues()[row].rawValue
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tv = notification.object as? NSTableView else { return }
        containerBox.contentView?.subviews.forEach { $0.removeFromSuperview() }
        let noRowSelected = -1
        guard tv.selectedRow != noRowSelected else { return }
        let generated = Generated.allValues()[tv.selectedRow]
        containerBox.addSubview(generated.view, constraints: generated.constraints)
    }
}

extension ViewSelectionVc: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Generated.allValues().count
    }
}
