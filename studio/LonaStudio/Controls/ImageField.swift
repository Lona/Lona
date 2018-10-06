//
//  ImageField.swift
//  ComponentStudio
//
//  Created by devin_abbott on 6/15/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation
import MacawOSX

// MARK: - ImageField

public class ImageField: NSBox, CSControl {

    // MARK: Lifecycle

    public init(imageSource: String, onChangeImageSource: StringHandler) {
        self.imageSource = imageSource
        self.onChangeImageSource = onChangeImageSource

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public convenience init() {
        self.init(imageSource: "", onChangeImageSource: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var imageSource: String { didSet { update() } }
    public var onChangeImageSource: StringHandler { didSet { update() } }

    // MARK: Private

    private var imageViewer = ImageViewer()
    private var macawView = MacawView(frame: .zero)

    // Record which svg we're displaying so that we only parse once
    private var parsedPath: String?

    private func setUpViews() {
        boxType = .custom
        borderType = .lineBorder
        borderWidth = 1
        borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        contentViewMargins = .zero

        addSubview(imageViewer)
        addSubview(macawView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        imageViewer.translatesAutoresizingMaskIntoConstraints = false
        macawView.translatesAutoresizingMaskIntoConstraints = false

        imageViewer.topAnchor.constraint(equalTo: topAnchor).isActive = true
        imageViewer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageViewer.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageViewer.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        macawView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        macawView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        macawView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        macawView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func update() {
        let isSvg = imageSource.hasSuffix(".svg")
        imageViewer.isHidden = isSvg
        macawView.isHidden = !isSvg

        if isSvg {
            if parsedPath != imageSource {
                parsedPath = imageSource
                if
                    let url = URL(string: imageSource)?.absoluteURLForWorkspaceURL(),
                    let svg = try? SVGParser.parse(fullPath: url.path) {
                    macawView.node = svg
                }
            }
        } else {
            imageViewer.value = imageSource
            imageViewer.onChange = { source in
                self.onChangeImageSource?(source)
                self.onChangeData(CSData.String(source))
            }
        }
    }

    // MARK: CSControl

    var data: CSData {
        get { return CSData.String(imageSource) }
        set { imageSource = newValue.stringValue }
    }

    var onChangeData: (CSData) -> Void = { _ in }
}

class ImageViewer: NSImageView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        registerForDragged()
    }

    let sizeLabel = TextField(labelWithStringCompat: "")

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        sizeLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(sizeLabel)

        sizeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        sizeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true

        registerForDragged()
    }

    let fileTypes = ["jpg", "jpeg", "bmp", "png", "gif", "pdf", "eps", "svg"]
    var fileTypeIsOk = false
    var droppedFilePath: String?

    var value: String {
        get { return droppedFilePath ?? "" }
        set {
            if let url = URL(string: newValue)?.absoluteURLForWorkspaceURL() {
                image = NSImage(contentsOf: url)

                if let image = image {
                    sizeLabel.value = "\(image.size.width) × \(image.size.height)"
                }

                droppedFilePath = url.absoluteString
            } else {
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
