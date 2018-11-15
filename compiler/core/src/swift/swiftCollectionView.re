let template = (cellRegistration: string, cellConfiguration: string) => {j|
import UIKit

// MARK: - LonaViewModel

public protocol LonaViewModel {
  var type: String { get }
}

// MARK: - LonaCollectionViewCell

public class LonaCollectionViewCell<T: UIView>: UICollectionViewCell {

  // MARK: Lifecycle

  override public init(frame: CGRect) {
    super.init(frame: frame)

    setUpViews()
    setUpConstraints()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var view: T = T()

  override public func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    layoutIfNeeded()
    let layoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
    layoutAttributes.bounds.size = systemLayoutSizeFitting(
      UILayoutFittingCompressedSize,
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .defaultLow)
    return layoutAttributes
  }

  // MARK: Private

  private func setUpViews() {
    contentView.addSubview(view)
  }

  private func setUpConstraints() {
    contentView.translatesAutoresizingMaskIntoConstraints = false

    let width = contentView.widthAnchor.constraint(equalTo: widthAnchor)
    width.priority = .required - 1
    width.isActive = true

    let height = contentView.heightAnchor.constraint(equalTo: heightAnchor)
    height.priority = .required - 1
    height.isActive = true

    view.translatesAutoresizingMaskIntoConstraints = false
    view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
    view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
    view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
    view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
  }

}

// MARK: - LonaCollectionViewListLayout

public class LonaCollectionViewListLayout: UICollectionViewFlowLayout {
  override public init() {
    super.init()

    self.minimumInteritemSpacing = 0
    self.minimumLineSpacing = 0
    self.sectionInset = .zero
    self.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath),
      let collectionView = collectionView else { return nil }
    layoutAttributes.bounds.size.width =
      collectionView.safeAreaLayoutGuide.layoutFrame.width - sectionInset.left - sectionInset.right

    return layoutAttributes
  }

  override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let superLayoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
    guard scrollDirection == .vertical else { return superLayoutAttributes }

    let computedAttributes = superLayoutAttributes.compactMap { layoutAttribute in
      return layoutAttribute.representedElementCategory == .cell
        ? layoutAttributesForItem(at: layoutAttribute.indexPath)
        : layoutAttribute
    }

    return computedAttributes
  }
}

// MARK: - LonaCollectionView

public class LonaCollectionView: UICollectionView, UICollectionViewDataSource {

  public init(
    items: [LonaViewModel] = [],
    collectionViewLayout layout: UICollectionViewLayout = LonaCollectionViewListLayout()) {

    super.init(frame: .zero, collectionViewLayout: layout)

    self.items = items

    contentInsetAdjustmentBehavior = .always
    alwaysBounceVertical = true
    backgroundColor = .clear

    dataSource = self$cellRegistration
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override public func touchesShouldCancel(in view: UIView) -> Bool {
    if view is LonaControl {
      return true
    }

    return super.touchesShouldCancel(in: view)
  }

  // MARK: Data Source

  var items: [LonaViewModel] = []

  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let item = items[indexPath.row]
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.type, for: indexPath)

    switch (item.type) {$cellConfiguration
    default:
      break
    }

    return cell
  }
}
|j};

module Ast = {
  open SwiftAst;

  let cellIdentifierStaticVariable = name =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier), StaticModifier],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier("identifier"),
          "annotation": Some(TypeName("String")),
        }),
      "init": None,
      "block":
        Some(
          GetterBlock([
            ReturnStatement(Some(LiteralExpression(String(name)))),
          ]),
        ),
    });

  let cellParametersVariable = (className: string): node =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier)],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier("parameters"),
          "annotation": Some(TypeName(className ++ ".Parameters")),
        }),
      "init": None,
      "block":
        Some(
          GetterSetterBlock({
            "get": [
              ReturnStatement(
                Some(
                  SwiftAst.Builders.memberExpression(["view", "parameters"]),
                ),
              ),
            ],
            "set": [
              BinaryExpression({
                "left":
                  SwiftAst.Builders.memberExpression(["view", "parameters"]),
                "operator": "=",
                "right": SwiftIdentifier("newValue"),
              }),
            ],
          }),
        ),
    });

  let cellClass = (componentName: string) =>
    ClassDeclaration({
      "name": componentName ++ "Cell",
      "inherits": [
        TypeName("LonaCollectionViewCell<" ++ componentName ++ ">"),
      ],
      "modifier": Some(PublicModifier),
      "isFinal": false,
      "body": [
        cellParametersVariable(componentName),
        cellIdentifierStaticVariable(componentName),
      ],
    });

  let registerCell = (componentName: string): node => {
    let cellName = componentName ++ "Cell";

    Builders.functionCall(
      ["register"],
      [
        (None, [cellName, "self"]),
        (Some("forCellWithReuseIdentifier"), [cellName, "identifier"]),
      ],
    );
  };

  let configureCell = (componentName: string): node => {
    let cellName = componentName ++ "Cell";

    CaseLabel({
      "patterns": [
        ExpressionPattern({
          "value": Builders.memberExpression([cellName, "identifier"]),
        }),
      ],
      "statements": [
        IfStatement({
          "condition":
            ConditionList([
              OptionalBindingCondition({
                "const": true,
                "pattern":
                  IdentifierPattern({
                    "identifier": SwiftIdentifier("cell"),
                    "annotation": None,
                  }),
                "init":
                  BinaryExpression({
                    "left": SwiftIdentifier("cell"),
                    "operator": "as?",
                    "right": SwiftIdentifier(cellName),
                  }),
              }),
              OptionalBindingCondition({
                "const": true,
                "pattern":
                  IdentifierPattern({
                    "identifier": SwiftIdentifier("item"),
                    "annotation": None,
                  }),
                "init":
                  BinaryExpression({
                    "left": SwiftIdentifier("item"),
                    "operator": "as?",
                    "right":
                      Builders.memberExpression([componentName, "Model"]),
                  }),
              }),
            ]),
          "block": [
            BinaryExpression({
              "left": Builders.memberExpression(["cell", "parameters"]),
              "operator": "=",
              "right": Builders.memberExpression(["item", "parameters"]),
            }),
          ],
        }),
      ],
    });
  };

  let print = (nodes: list(node)): string =>
    TopLevelDeclaration({"statements": nodes}) |> SwiftRender.toString;
};

let generate =
    (
      config: Config.t,
      options: Options.options,
      swiftOptions: SwiftOptions.options,
      getComponent,
      componentNames: list(string),
    ) => {
  let cellRegistration =
    if (List.length(componentNames) > 0) {
      let code = componentNames |> List.map(Ast.registerCell) |> Ast.print;
      "\n\n" ++ (code |> Js.String.trim |> Format.indent(4));
    } else {
      "";
    };

  let cellConfiguration =
    if (List.length(componentNames) > 0) {
      let code = componentNames |> List.map(Ast.configureCell) |> Ast.print;
      "\n" ++ (code |> Js.String.trim |> Format.indent(4));
    } else {
      "";
    };

  let cellClasses =
    componentNames
    |> List.map(Ast.cellClass)
    |> SwiftDocument.join(SwiftAst.Empty)
    |> Ast.print
    |> Js.String.trim;

  Format.joinWith(
    "\n\n",
    [template(cellRegistration, cellConfiguration), cellClasses],
  );
};