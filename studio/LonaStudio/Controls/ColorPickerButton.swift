import Foundation
import Cocoa

func createCircularImage(size: Double, color: NSColor) -> NSImage {
    NSGraphicsContext.saveGraphicsState()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)

    let image = NSImage(size: rect.size)
    image.lockFocus()

    let path = NSBezierPath(roundedRect: rect, xRadius: CGFloat(size / 2), yRadius: CGFloat(size / 2))
    path.addClip()
    color.drawSwatch(in: rect)

    NSColor(white: 0, alpha: 0.8).set()
    path.stroke()

    image.unlockFocus()

    NSGraphicsContext.restoreGraphicsState()

    return image
}

class ColorPickerButton: NSButton, CSControl {

    var data: CSData {
        get { return CSData.String(textValue) }
        set { textValue = newValue.stringValue }
    }

    var onChangeData: (CSData) -> Void = { _ in }

    var textValue: String = "#FFFFFF" {
        didSet {
            setImage()
            title = CSColors.parse(css: textValue).name
        }
    }

    var onChangeTextValue: (String) -> Void = {_ in}

    func setImage() {
        image = createCircularImage(size: 10, color: CSColors.parse(css: textValue).color)
    }

    func setup() {
        action = #selector(handleClick)
        target = self
        setButtonType(.momentaryPushIn)
        imagePosition = .imageLeft
        alignment = .left
        bezelStyle = .rounded

        setImage()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    func showPopover() {
        let picker = ColorPickerView(selected: data.stringValue) {[weak self] (color) in
            guard let strongSelf = self else { return }
            strongSelf.title = color.name
            strongSelf.textValue = color.resolvedValue
            strongSelf.onChangeTextValue(strongSelf.textValue)
            strongSelf.onChangeData(strongSelf.data)
        }
        picker.popover.show(relativeTo: NSRect.zero, of: self, preferredEdge: .maxY)
    }

    @objc func handleClick() {
        showPopover()
    }
}
