type file('a) = {
  path: string,
  contents: 'a,
};

type t = {
  componentNames: list(string),
  componentPaths: list(string),
  plugins: list(Plugin.t),
  lonaFile: file(LonaFile.t),
  logicFiles: list(file(LogicAst.syntaxNode)),
  logicLibraries: list(file(LogicAst.syntaxNode)),
  mdxFiles: list(file(MdxTypes.root)),
  colorsFile: file(list(Color.t)),
  textStylesFile: file(TextStyle.file),
  shadowsFile: file(Shadow.file),
  userTypesFile: file(UserTypes.file),
  svgFiles: list(file(Svg.node)),
  workspacePath: string,
  options: Options.options,
  platformId: Types.platformId,
  outputPath: string,
};

module Compiler = {
  [@bs.deriving abstract]
  type raw = {plugins: array(Plugin.t)};

  [@bs.module] external parseConfig: string => raw = "../config";
};

module Workspace = {
  open Node;

  /* Detect workspace by finding nearest lona.json in the file hierarchy */
  let rec find = path => {
    let exists = Fs.existsSync(Path.join([|path, "lona.json"|]));
    exists ?
      Some(path) :
      (
        switch (Path.dirname(path)) {
        | "/" => None
        | parent => find(parent)
        }
      );
  };

  let findPathWithSuffix =
      (workspacePath: string, fileSuffix: string, ~ignore: list(string)) => {
    let searchPath = Path.join([|workspacePath, "**/*?(.)" ++ fileSuffix|]);
    let searchResults =
      FileSearch.sync(searchPath, ~options={ignore: ignore}, ());

    /* Find exactly one path */
    let path =
      switch (List.length(searchResults)) {
      | 0 => None
      | 1 => Some(List.hd(searchResults))
      | _ => None
      };
    path;
  };

  let lonaFile = (workspacePath: string): file(LonaFile.t) => {
    let path = Path.join2(workspacePath, "lona.json");
    let data = Node.Fs.readFileSync(path, `utf8);
    let contents = LonaFile.parseFile(data);
    {path, contents};
  };

  let logicFiles =
      (workspacePath: string, ~ignore: list(string))
      : list(file(LogicAst.syntaxNode)) => {
    let searchPath = Path.join([|workspacePath, "**/*.logic"|]);
    let paths = FileSearch.sync(searchPath, ~options={ignore: ignore}, ());
    paths
    |> List.map(path => {
         let data = Node.Fs.readFileSync(path, `utf8);
         let jsonContents = Serialization.convert(data, "logic", "json");
         let json = jsonContents |> Js.Json.parseExn;
         let contents = LogicAst.Decode.syntaxNode(json);
         {path, contents};
       });
  };

  let documentFiles =
      (workspacePath: string, ~ignore: list(string))
      : list(file(LogicAst.syntaxNode)) => {
    let searchPath = Path.join([|workspacePath, "**/*.md"|]);
    let paths = FileSearch.sync(searchPath, ~options={ignore: ignore}, ());
    paths
    |> List.map(path => {
         let data = Node.Fs.readFileSync(path, `utf8);
         let jsonContents = Serialization.program(data);
         let json = jsonContents |> Js.Json.parseExn;
         let contents = LogicAst.Decode.syntaxNode(json);
         {path, contents};
       });
  };

  let mdxFiles =
      (workspacePath: string, ~ignore: list(string))
      : list(file(MdxTypes.root)) => {
    let searchPath = Path.join([|workspacePath, "**/*.md"|]);
    let paths = FileSearch.sync(searchPath, ~options={ignore: ignore}, ());
    paths
    |> List.map(path => {
         let data = Node.Fs.readFileSync(path, `utf8);
         let jsonContents = Serialization.convertDocument(data, "json");
         let json = jsonContents |> Js.Json.parseExn;
         let contents = MdxTypes.Decode.decodeRoot(json);
         {path, contents};
       });
  };

  let colorsFile =
      (workspacePath: string, ~ignore: list(string)): file(list(Color.t)) => {
    let path = findPathWithSuffix(workspacePath, "colors.json", ~ignore);
    switch (path) {
    | Some(path) =>
      let data = Node.Fs.readFileSync(path, `utf8);
      let contents = Color.parseFile(data);
      {path, contents};
    | None => {path: Path.join2(workspacePath, "colors.json"), contents: []}
    };
  };

  let textStylesFile =
      (workspacePath: string, ~ignore: list(string)): file(TextStyle.file) => {
    let path = findPathWithSuffix(workspacePath, "textStyles.json", ~ignore);
    switch (path) {
    | Some(path) =>
      let data = Node.Fs.readFileSync(path, `utf8);
      let contents = TextStyle.parseFile(data);
      {path, contents};
    | None => {
        path: Path.join2(workspacePath, "textStyles.json"),
        contents: TextStyle.defaultFile,
      }
    };
  };

  let shadowsFile =
      (workspacePath: string, ~ignore: list(string)): file(Shadow.file) => {
    let path = findPathWithSuffix(workspacePath, "shadows.json", ~ignore);
    switch (path) {
    | Some(path) =>
      let data = Node.Fs.readFileSync(path, `utf8);
      let contents = Shadow.parseFile(data);
      {path, contents};
    | None => {
        path: Path.join2(workspacePath, "shadows.json"),
        contents: Shadow.defaultFile,
      }
    };
  };

  let userTypesFile = (workspacePath: string): file(UserTypes.file) => {
    let path = Path.join([|workspacePath, "types.json"|]);
    let contents =
      switch (Node.Fs.readFileSync(path, `utf8)) {
      | data => UserTypes.parseFile(data)
      | exception _ => {types: []}
      };
    {path, contents};
  };

  let svgFiles =
      (workspacePath: string, ~ignore: list(string))
      : Js.Promise.t(list(file(Svg.node))) => {
    let searchPath = Path.join2(workspacePath, "**/*.svg");

    Js.Promise.(
      FileSearch.sync(searchPath, ~options={ignore: ignore}, ())
      |> List.map(file => {
           let data = Node.Fs.readFileSync(file, `utf8);
           Svg.decode(data)
           |> then_(node => resolve({path: file, contents: node}));
         })
      |> Array.of_list
      |> all
      |> then_(array => resolve(Array.to_list(array)))
    );
  };

  let componentPaths =
      (workspacePath: string, ~ignore: list(string)): list(string) => {
    let searchPath = Path.join2(workspacePath, "**/*.component");
    FileSearch.sync(searchPath, ~options={ignore: ignore}, ());
  };

  let componentNames =
      (workspacePath: string, ~ignore: list(string)): list(string) =>
    componentPaths(workspacePath, ~ignore)
    |> List.map(file => Node.Path.basename_ext(file, ".component"));

  let compilerFile = (workspacePath: string): list(Plugin.t) => {
    let path = Path.join([|workspacePath, "compiler.js"|]);
    let path = Path.resolve(path, "");
    let rawConfig = Compiler.parseConfig(path);
    Array.to_list(rawConfig->Compiler.pluginsGet);
  };

  let relativePath = (config: t, path: string): string => {
    let path =
      Js.String.startsWith("file://", path) ?
        Js.String.replace("file://", "", path) : path;
    Node.Path.join2(config.workspacePath, path);
  };

  let outputPathForWorkspaceFile = (config: t, ~workspaceFile: string): string => {
    let relativePath =
      Path.relative(~from=config.workspacePath, ~to_=workspaceFile, ());
    let outputPath = Path.join2(config.outputPath, relativePath);
    outputPath;
  };
};

exception ComponentNotFound(string);

module Find = {
  let files = (config: t, pattern): list(string) => {
    let searchPath = Node.Path.join2(config.workspacePath, pattern);
    FileSearch.sync(
      searchPath,
      ~options={ignore: config.lonaFile.contents.ignore},
      (),
    );
  };

  let componentPath = (config: t, componentName: string): string => {
    let files =
      config.componentPaths
      |> List.filter(path =>
           Node.Path.basename_ext(path, ".component") == componentName
         );

    switch (List.length(files)) {
    | 0 => raise(ComponentNotFound(componentName))
    | _ => List.hd(files)
    };
  };

  let component = (config: t, componentName: string): Js.Json.t => {
    let path = componentPath(config, componentName);
    Node.Fs.readFileSync(path, `utf8) |> Js.Json.parseExn;
  };

  let svg = (config: t, path: string): Svg.node => {
    let path = Workspace.relativePath(config, path);
    let file = config.svgFiles |> List.find(item => item.path == path);
    file.contents;
  };

  let referenceType = (config: t, typeName: string) =>
    UserTypes.resolveType(config.userTypesFile.contents.types, typeName);

  let platformSpecificValue =
      (config: t, value: Types.platformSpecificValue('a)): 'a =>
    switch (config.platformId) {
    | Types.ReactDOM => value.reactDom
    | Types.ReactNative => value.reactNative
    | Types.ReactSketchapp => value.reactSketchapp
    | Types.IOS => value.iOS
    | Types.MacOS => value.macOS
    };
};

module Type = {
  let resolve = (config: t, ltype: Types.lonaType) =>
    switch (ltype) {
    | Types.Reference(typeName) =>
      switch (Find.referenceType(config, typeName)) {
      | Some(match) => match
      | None => ltype
      }
    | _ => ltype
    };
};

let exit = message => {
  Log.warn(message);
  %bs.raw
  {|process.exit(1)|};
};

let load =
    (
      platformId: Types.platformId,
      options: Options.options,
      path,
      outputPath,
      dirname: string,
    )
    : Js.Promise.t(t) =>
  switch (Workspace.find(path)) {
  | None =>
    exit(
      "Couldn't find workspace directory starting from '"
      ++ path
      ++ "'. A workspace must contain a `lona.json` file.",
    )
  | Some(workspacePath) =>
    Log.warn("Running compiler from: " ++ dirname);
    let logicLibrariesPath = Node.Path.join2(dirname, "static/logic");
    let lonaFile = Workspace.lonaFile(workspacePath);
    Js.Promise.(
      Workspace.svgFiles(workspacePath, ~ignore=lonaFile.contents.ignore)
      |> then_(svgFiles =>
           resolve({
             options,
             platformId,
             componentPaths:
               Workspace.componentPaths(
                 workspacePath,
                 ~ignore=lonaFile.contents.ignore,
               ),
             componentNames:
               Workspace.componentNames(
                 workspacePath,
                 ~ignore=lonaFile.contents.ignore,
               ),
             plugins: Workspace.compilerFile(workspacePath),
             lonaFile,
             logicFiles:
               Workspace.logicFiles(
                 workspacePath,
                 ~ignore=lonaFile.contents.ignore,
               )
               @ Workspace.documentFiles(
                   workspacePath,
                   ~ignore=lonaFile.contents.ignore,
                 ),
             logicLibraries:
               Workspace.logicFiles(logicLibrariesPath, ~ignore=[]),
             mdxFiles:
               Workspace.mdxFiles(
                 workspacePath,
                 ~ignore=lonaFile.contents.ignore,
               ),
             colorsFile:
               Workspace.colorsFile(
                 workspacePath,
                 ~ignore=lonaFile.contents.ignore,
               ),
             textStylesFile:
               Workspace.textStylesFile(
                 workspacePath,
                 ~ignore=lonaFile.contents.ignore,
               ),
             shadowsFile:
               Workspace.shadowsFile(
                 workspacePath,
                 ~ignore=lonaFile.contents.ignore,
               ),
             userTypesFile: Workspace.userTypesFile(workspacePath),
             svgFiles,
             workspacePath,
             outputPath,
           })
         )
    );
  };

let toJson = (compilerVersion: string, config: t): Js.Json.t =>
  Json.(
    Encode.object_([
      ("version", Encode.string(compilerVersion)),
      (
        "paths",
        Encode.object_([
          ("workspace", Encode.string(config.workspacePath)),
          ("colors", Encode.string(config.colorsFile.path)),
          ("textStyles", Encode.string(config.textStylesFile.path)),
          ("shadows", Encode.string(config.shadowsFile.path)),
          (
            "components",
            Encode.stringArray(config.componentPaths |> Array.of_list),
          ),
        ]),
      ),
    ])
  );