type logicValue =
  | Identifier(Types.lonaType, list(string))
  | Literal(Types.lonaValue)
  | None;

type logicNode =
  | If(logicValue, Types.cmp, logicValue, logicNode)
  | IfExists(logicValue, logicNode)
  | Assign(logicValue, logicValue)
  | Add(logicValue, logicValue, logicValue)
  | Let(logicValue)
  | Block(list(logicNode))
  | None;

module IdentifierSet = {
  include
    Set.Make(
      {
        type t = (Types.lonaType, list(string));
        let compare = (a: t, b: t) : int => {
          let (_, a) = a;
          let (_, b) = b;
          compare(Render.String.join("", a), Render.String.join("", b))
        };
      }
    );
};

module LogicTree =
  Tree.Make(
    {
      type t = logicNode;
      let children = (node) =>
        switch node {
        | If(_, _, _, value) => [value]
        | Add(_, _, _) => []
        | Assign(_, _) => []
        | IfExists(_, value) => [value]
        | Block(body) => body
        | Let(_) => []
        | None => []
        };
      let restore = (node, contents) => {
        let at = (index) => List.nth(contents, index);
        switch node {
        | If(a, b, c, _) => If(a, b, c, at(0))
        | Add(_, _, _) => node
        | Assign(_, _) => node
        | IfExists(a, _) => IfExists(a, at(0))
        | Block(_) => Block(contents)
        | Let(_) => node
        | None => node
        }
      };
    }
  );

/* TODO: This only looks at assignments */
let undeclaredIdentifiers = (node) => {
  let inner = (node, identifiers) =>
    switch node {
    | Assign(_, Identifier(type_, path)) => IdentifierSet.add((type_, path), identifiers)
    | _ => identifiers
    };
  LogicTree.reduce(inner, IdentifierSet.empty, node)
};

let assignedIdentifiers = (node) => {
  let inner = (node, identifiers) =>
    switch node {
    | Assign(_, Identifier(type_, path)) => IdentifierSet.add((type_, path), identifiers)
    | _ => identifiers
    };
  LogicTree.reduce(inner, IdentifierSet.empty, node)
};

let conditionallyAssignedIdentifiers = (rootNode) => {
  let identifiers = undeclaredIdentifiers(rootNode);
  let paths = identifiers |> IdentifierSet.elements;
  let rec isAlwaysAssigned = (target, node) =>
    switch node {
    | Assign(_, Identifier(_, path)) => path == target
    | If(_, _, Identifier(_, path), body) when path == target => isAlwaysAssigned(target, body)
    | Block(nodes) => nodes |> List.exists(isAlwaysAssigned(target))
    | _ => false
    };
  let accumulate = (set, (ltype, path)) =>
    isAlwaysAssigned(path, rootNode) ? set : IdentifierSet.add((ltype, path), set);
  paths |> List.fold_left(accumulate, IdentifierSet.empty)
};

/* let testNode = Assign(Identifier(Reference("OK"), ["a"]), Identifier(Reference("OK"), ["b"])); */
let addVariableDeclarations = (node) => {
  let identifiers = undeclaredIdentifiers(node);
  identifiers
  |> IdentifierSet.elements
  |> List.map(((type_, path)) => Let(Identifier(type_, path)))
  |> List.fold_left(
       (acc, declaration) =>
         LogicTree.insert_child((item) => item == acc ? Some(declaration) : None, acc),
       node
     )
};