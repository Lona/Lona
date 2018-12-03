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

  let colorsFile = (workspacePath: string): file(list(Color.t)) => {
    let path = Path.join([|workspacePath, "colors.json"|]);
    let data = Node.Fs.readFileSync(path, `utf8);
    let contents = Color.parseFile(data);
    {path, contents};
  };

  let textStylesFile = (workspacePath: string): file(TextStyle.file) => {
    let path = Path.join([|workspacePath, "textStyles.json"|]);
    let data = Node.Fs.readFileSync(path, `utf8);
    let contents = TextStyle.parseFile(data);
    {path, contents};
  };

  let shadowsFile = (workspacePath: string): file(Shadow.file) => {
    let path = Path.join([|workspacePath, "shadows.json"|]);
    let data = Node.Fs.readFileSync(path, `utf8);
    let contents = Shadow.parseFile(data);
    {path, contents};
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

module Find = {
  let svg = (config: t, path: string): Svg.node => {
    let path = Workspace.relativePath(config, path);
    let file = config.svgFiles |> List.find(item => item.path == path);
    file.contents;
  };
};

let exit = message => {
  Js.log(message);
  %bs.raw
  {|process.exit(1)|};
};

let load = path: Js.Promise.t(t) =>
  switch (Workspace.find(path)) {
  | None =>
    exit(
      "Couldn't find workspace directory. A workspace must contain a `lona.json` file.",
    )
  | Some(workspacePath) =>
    Js.Promise.(
      Workspace.svgFiles(workspacePath)
      |> then_(svgFiles =>
           resolve({
             componentNames: Workspace.componentNames(workspacePath),
             plugins: Workspace.compilerFile(workspacePath),
             colorsFile: Workspace.colorsFile(workspacePath),
             textStylesFile: Workspace.textStylesFile(workspacePath),
             shadowsFile: Workspace.shadowsFile(workspacePath),
             userTypesFile: Workspace.userTypesFile(workspacePath),
             svgFiles,
             workspacePath,
           })
         )
    )
  };