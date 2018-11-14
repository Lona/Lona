import UIKit

// MARK: - LonaControl

protocol LonaControl {}

// MARK: - LonaControlView

public class LonaControlView: UIControl, LonaControl {

  var onHighlight: (() -> Void)?

  public override var isHighlighted: Bool {
    didSet {
      onHighlight?()
    }
  }
}
