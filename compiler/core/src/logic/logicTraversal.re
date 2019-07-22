type traversalOrder =
  | PreOrder
  | PostOrder;

type traversalConfig = {
  order: traversalOrder,
  ignoreChildren: ref(bool),
  stopTraversal: ref(bool),
  needsRevisitAfterTraversingChildren: ref(bool),
  _isRevisit: ref(bool),
};

let emptyConfig = (): traversalConfig => {
  order: PreOrder,
  ignoreChildren: ref(false),
  stopTraversal: ref(false),
  needsRevisitAfterTraversingChildren: ref(false),
  _isRevisit: ref(false),
};

let rec reduce:
  't.
  (
    traversalConfig,
    't,
    ('t, LogicAst.syntaxNode, traversalConfig) => 't,
    LogicAst.syntaxNode
  ) =>
  't
 =
  (config, initialResult, f, node) =>
    if (config.stopTraversal^) {
      initialResult;
    } else {
      switch (config.order) {
      | PostOrder =>
        let result = reduceChildren(config, initialResult, f, node);

        if (config.stopTraversal^) {
          result;
        } else {
          f(result, node, config);
        };
      | PreOrder =>
        let result = f(initialResult, node, config);

        let shouldRevisit = config.needsRevisitAfterTraversingChildren^;

        let result =
          if (config.ignoreChildren^) {
            config.ignoreChildren := false;
            result;
          } else {
            reduceChildren(config, result, f, node);
          };

        if (! config.stopTraversal^ && shouldRevisit) {
          config._isRevisit := true;

          let result = f(result, node, config);

          config._isRevisit := false;

          config.ignoreChildren := false;

          result;
        } else {
          result;
        };
      };
    }
and reduceChildren:
  't.
  (
    traversalConfig,
    't,
    ('t, LogicAst.syntaxNode, traversalConfig) => 't,
    LogicAst.syntaxNode
  ) =>
  't
 =
  (config, initialResult, f, node) =>
    List.fold_left(
      (result, subnode) =>
        if (config.stopTraversal^) {
          result;
        } else {
          reduce(config, result, f, subnode);
        },
      initialResult,
      LogicProtocol.subnodes(node),
    );