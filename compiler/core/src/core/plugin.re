type context = {
  .
  "target": string,
  "framework": string,
};

type t = {transformType: (context, string, string) => string};

let applyTransformTypePlugins = (plugins: list(t), context, filename, value) => {
  let f: (context, string, string, t) => string = [%raw
    (context, filename, a, plugin) => "{return plugin.transformType(context, filename, a)}"
  ];
  List.fold_left(
    (a, plugin) => f(context, filename, a, plugin),
    value,
    plugins,
  );
};
