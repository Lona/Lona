//
//  ImageField.swift
//  ComponentStudio
//
//  Created by devin_abbott on 6/15/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class ImageField: NSImageView, CSControl {

    var data: CSData {
        get { return CSData.String(value) }
        set { value = newValue.stringValue }
    }

    var onChangeData: (CSData) -> Void = { _ in }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        registerForDragged()
    }

    let sizeLabel = TextField(labelWithString: "")

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        sizeLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(sizeLabel)

        sizeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        sizeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true

        wantsLayer = true
        layer?.borderWidth = 1.0
        layer?.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1).cgColor

        registerForDragged()
    }

    let fileTypes = ["jpg", "jpeg", "bmp", "png", "gif", "pdf", "eps", "svg"]
    var fileTypeIsOk = false
    var droppedFilePath: String?

    var value: String {
        get { return droppedFilePath ?? "" }
        set {
            if let url = URL(string: newValue)?.absoluteURLForWorkspaceURL() {
                if url.pathExtension == "svg" {
                    // Delay so that bounds are calculated
                    DispatchQueue.main.async {
                        SVG.render(contentsOf: url, size: self.bounds.size, resizingMode: .scaleAspectFit, successHandler: { image in
                            self.image = image
                        })
                    }
                } else {
                    image = NSImage(contentsOf: url)

                    if let image = image {
                        sizeLabel.value = "\(image.size.width) × \(image.size.height)"
                    }
                }

                droppedFilePath = url.absoluteString
            } else {
                image = nil
                sizeLabel.value = ""

                droppedFilePath = newValue
            }
        }
    }

    var onChange: (String) -> Void = {_ in }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(drag: sender) {
            fileTypeIsOk = true
            return .copy
        } else {
            fileTypeIsOk = false
            return []
        }
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if fileTypeIsOk {
            return .copy
        } else {
            return []
        }
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let board = sender.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let imagePath = board[0] as? String {

            droppedFilePath = "file://" + imagePath
            onChange(value)
            onChangeData(data)

            return true
        }

        return false
    }

    func checkExtension(drag: NSDraggingInfo) -> Bool {
        if let board = drag.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = board[0] as? String {
            let url = NSURL(fileURLWithPath: path)
            if let fileExtension = url.pathExtension?.lowercased() {
                return fileTypes.contains(fileExtension)
            }
        }
        return false
    }

    private func registerForDragged() {
        registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeFileURL as String),
                                 NSPasteboard.PasteboardType(kUTTypeURL as String),
                                 NSPasteboard.PasteboardType.tiff])
    }
}
