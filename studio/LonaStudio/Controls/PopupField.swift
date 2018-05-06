import Foundation
import Cocoa

class PopupField: NSPopUpButton, CSControl {

    var data: CSData {
        get { return CSData.String(value) }
        set { value = newValue.stringValue }
    }

    var onChangeData: (CSData) -> Void = { _ in }

    var value: String {
        get { return valueFor(title: titleOfSelectedItem ?? "") ?? "" }
        set {
            selectItem(withTitle: titleFor(value: newValue) ?? "")
        }
    }

    var onChange: (String) -> Void = {_ in }

    var values: [String]?
    var titles: [String]?

    func setup() {
        action = #selector(handleChange)
        target = self
    }

    override init(frame buttonFrame: NSRect, pullsDown flag: Bool) {
        super.init(frame: buttonFrame, pullsDown: flag)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    init(frame frameRect: NSRect, values: [String], valueToTitle: [String: String]) {
        super.init(frame: frameRect)
        setup()

        let titles = values.map({ valueToTitle[$0] }).compactMap({ $0 })
        addItems(withTitles: titles)

        self.values = values
        self.titles = titles
    }

    convenience init(frame frameRect: NSRect, values: [String], initialValue: String?) {
        var valueToTitle = [String: String]()
        var values = values

        if let initialValue = initialValue, !values.contains(initialValue) {
            values.append(initialValue)
        }

        for value in values {
            valueToTitle[value] = value
        }

        self.init(frame: frameRect, values: values, valueToTitle: valueToTitle)

        if let initialValue = initialValue {
            selectItem(withTitle: titleFor(value: initialValue) ?? "")
        }
    }

    func valueFor(title: String) -> String? {
        guard let index = titles?.index(of: title) else { return nil }
        return values?[index]
    }

    func titleFor(value: String) -> String? {
        guard let index = values?.index(of: value) else { return nil }
        return titles?[index]
    }

    @objc func handleChange() {
        onChange(value)
        onChangeData(data)
    }
}
