type file('a) = {
  path: string,
  contents: 'a,
};

type t = {
  componentNames: list(string),
  plugins: list(Plugin.t),
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

  /* Rudimentary workspace detection */
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

  let findPath = (workspacePath: string, fileSuffix: string) => {
    let searchPath = Path.join([|workspacePath, "**/*?(.)" ++ fileSuffix|]);
    let searchResults =
      FileSearch.sync(
        searchPath,
        ~options={ignore: ["**/node_modules"]},
        (),
      );
    /* Find exactly one path */
    let path =
      switch (List.length(searchResults)) {
      | 0 =>
        Js.log("Failed to find colors file in " ++ searchPath);
        raise(Not_found);
      | 1 => List.hd(searchResults)
      | _ =>
        Js.log(
          "ERROR: Found multiple '*"
          ++ fileSuffix
          ++ "' files in "
          ++ searchPath,
        );
        raise(Not_found);
      };
    path;
  };

  let colorsFile = (workspacePath: string): file(list(Color.t)) => {
    let path = findPath(workspacePath, "colors.json");
    let data = Node.Fs.readFileSync(path, `utf8);
    let contents = Color.parseFile(data);
    {path, contents};
  };

  let textStylesFile = (workspacePath: string): file(TextStyle.file) => {
    let path = findPath(workspacePath, "textStyles.json");
    let data = Node.Fs.readFileSync(path, `utf8);
    let contents = TextStyle.parseFile(data);
    {path, contents};
  };

  let shadowsFile = (workspacePath: string): file(Shadow.file) => {
    let path = findPath(workspacePath, "shadows.json");
    let data = Node.Fs.readFileSync(path, `utf8);
    let contents = Shadow.parseFile(data);
    {path, contents};
  };

  let userTypesFile = (workspacePath: string): file(UserTypes.file) => {
    let path = findPath(workspacePath, "types.json");
    let contents =
      switch (Node.Fs.readFileSync(path, `utf8)) {
      | data => UserTypes.parseFile(data)
      | exception _ => {types: []}
      };
    {path, contents};
  };

  let svgFiles =
      (workspacePath: string): Js.Promise.t(list(file(Svg.node))) =>
    Js.Promise.(
      Glob.sync(Path.join([|workspacePath, "**/*.svg"|]))
      |> Array.map(file => {
           let data = Node.Fs.readFileSync(file, `utf8);
           Svg.decode(data)
           |> then_(node => resolve({path: file, contents: node}));
         })
      |> all
      |> then_(array => resolve(Array.to_list(array)))
    );

  let componentNames = (workspacePath: string): list(string) => {
    let searchPath = "**/*.component";
    Glob.sync(Path.join([|workspacePath, searchPath|]))
    |> Array.to_list
    |> List.map(file => Node.Path.basename_ext(file, ".component"));
  };

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
};

exception ComponentNotFound(string);

module Find = {
  let component = (config: t, componentName: string): Js.Json.t => {
    let searchPath =
      Node.Path.join([|
        config.workspacePath,
        "**/" ++ componentName ++ ".component",
      |]);

    let files = searchPath |> Glob.sync |> Array.to_list;

    let filename =
      switch (List.length(files)) {
      | 0 => raise(ComponentNotFound(componentName))
      | _ => List.hd(files)
      };

    Node.Fs.readFileSync(filename, `utf8) |> Js.Json.parseExn;
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
  Js.log(message);
  %bs.raw
  {|process.exit(1)|};
};

let load =
    (platformId: Types.platformId, options: Options.options, path, outputPath)
    : Js.Promise.t(t) =>
  switch (Workspace.find(path)) {
  | None =>
    exit(
      "Couldn't find workspace directory starting from '"
      ++ path
      ++ "'. A workspace must contain a `lona.json` file.",
    )
  | Some(workspacePath) =>
    Js.Promise.(
      Workspace.svgFiles(workspacePath)
      |> then_(svgFiles =>
           resolve({
             options,
             platformId,
             componentNames: Workspace.componentNames(workspacePath),
             plugins: Workspace.compilerFile(workspacePath),
             colorsFile: Workspace.colorsFile(workspacePath),
             textStylesFile: Workspace.textStylesFile(workspacePath),
             shadowsFile: Workspace.shadowsFile(workspacePath),
             userTypesFile: Workspace.userTypesFile(workspacePath),
             svgFiles,
             workspacePath,
             outputPath,
           })
         )
    )
  };