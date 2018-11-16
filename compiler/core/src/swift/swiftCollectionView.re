let template =
    (
      cellRegistration: string,
      cellConfiguration: string,
      cellSelection: string,
    ) => {j|
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

public class LonaCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {

  public init(
    items: [LonaViewModel] = [],
    collectionViewLayout layout: UICollectionViewLayout = LonaCollectionViewListLayout()) {

    super.init(frame: .zero, collectionViewLayout: layout)

    self.items = items

    contentInsetAdjustmentBehavior = .always
    alwaysBounceVertical = true
    backgroundColor = .clear

    delegate = self
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


  // MARK: - Delegate

  public var onSelectItem: ((LonaViewModel) -> Void)?

  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = items[indexPath.row]
    let cell = cellForItem(at: indexPath)

    switch (item.type) {$cellSelection
    default:
      break
    }

    onSelectItem?(item)
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

  let cellIsHighlighted = (): node =>
    VariableDeclaration({
      "modifiers": [AccessLevelModifier(PublicModifier), OverrideModifier],
      "pattern":
        IdentifierPattern({
          "identifier": SwiftIdentifier("isHighlighted"),
          "annotation": Some(TypeName("Bool")),
        }),
      "init": None,
      "block":
        Some(
          WillSetDidSetBlock({
            "willSet": None,
            "didSet":
              Some([
                BinaryExpression({
                  "left":
                    SwiftAst.Builders.memberExpression([
                      "view",
                      "isControlPressed",
                    ]),
                  "operator": "=",
                  "right": SwiftIdentifier("isHighlighted"),
                }),
              ]),
          }),
        ),
    });

  let cellClass = (isInteractive: bool, componentName: string) =>
    ClassDeclaration({
      "name": componentName ++ "Cell",
      "inherits": [
        TypeName("LonaCollectionViewCell<" ++ componentName ++ ">"),
      ],
      "modifier": Some(PublicModifier),
      "isFinal": false,
      "body":
        [
          [cellParametersVariable(componentName)],
          isInteractive ? [cellIsHighlighted()] : [],
          [cellIdentifierStaticVariable(componentName)],
        ]
        |> List.concat,
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

  let configureCell =
      (
        isInteractive: bool,
        containsNestedInteractives: bool,
        componentName: string,
      )
      : node => {
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
          "block":
            [
              BinaryExpression({
                "left": Builders.memberExpression(["cell", "parameters"]),
                "operator": "=",
                "right": Builders.memberExpression(["item", "parameters"]),
              }),
            ]
            @ (
              isInteractive ?
                [
                  BinaryExpression({
                    "left":
                      Builders.memberExpression([
                        "cell",
                        "view",
                        containsNestedInteractives ?
                          "isRootControlTrackingEnabled" : "isEnabled",
                      ]),
                    "operator": "=",
                    "right": LiteralExpression(Boolean(false)),
                  }),
                ] :
                []
            ),
        }),
      ],
    });
  };

  let cellSelection = (componentName: string): node => {
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
            ]),
          "block": [
            Builders.functionCall(
              ["cell", "view", "sendActions"],
              [(Some("for"), [".touchUpInside"])],
            ),
          ],
        }),
      ],
    });
  };

  let print = (nodes: list(node)): string =>
    TopLevelDeclaration({"statements": nodes}) |> SwiftRender.toString;
};

let isInteractive =
    (getComponent: string => Js.Json.t, componentName: string): bool => {
  let component = getComponent(componentName);
  let rootLayer = Decode.Component.rootLayer(getComponent, component);
  let logic = Decode.Component.logic(component);
  Layer.isInteractive(logic, rootLayer);
};

let interactiveLayers =
    (getComponent: string => Js.Json.t, componentName: string)
    : list(Types.layer) => {
  let component = getComponent(componentName);
  let rootLayer = Decode.Component.rootLayer(getComponent, component);
  let logic = Decode.Component.logic(component);
  rootLayer |> Layer.flatten |> List.filter(Layer.isInteractive(logic));
};

let generate =
    (
      config: Config.t,
      options: Options.options,
      swiftOptions: SwiftOptions.options,
      getComponent: string => Js.Json.t,
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
      let code =
        componentNames
        |> List.map(name =>
             Ast.configureCell(
               isInteractive(getComponent, name),
               List.length(interactiveLayers(getComponent, name)) > 1,
               name,
             )
           )
        |> Ast.print;
      "\n" ++ (code |> Js.String.trim |> Format.indent(4));
    } else {
      "";
    };

  let cellSelection =
    if (List.length(componentNames) > 0) {
      let code =
        componentNames
        |> List.filter(isInteractive(getComponent))
        |> List.map(Ast.cellSelection)
        |> Ast.print;
      "\n" ++ (code |> Js.String.trim |> Format.indent(4));
    } else {
      "";
    };

  let cellClasses =
    componentNames
    |> List.map(name =>
         Ast.cellClass(isInteractive(getComponent, name), name)
       )
    |> SwiftDocument.join(SwiftAst.Empty)
    |> Ast.print
    |> Js.String.trim;

  Format.joinWith(
    "\n\n",
    [
      template(cellRegistration, cellConfiguration, cellSelection),
      cellClasses,
    ],
  );
};