let getContext = (config: Config.t): Plugin.context => {
  "target": "swift",
  "framework": SwiftOptions.frameworkToString(config.options.swift.framework),
};

let applyTransformType =
    (config: Config.t, componentName: option(string), typeName: string) =>
  Plugin.applyTransformTypePlugins(
    config.plugins,
    getContext(config),
    switch (componentName) {
    | Some(value) => value
    | None => ""
    },
    typeName,
  );