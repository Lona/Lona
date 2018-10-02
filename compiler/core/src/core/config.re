type file('a) = {
  path: string,
  contents: 'a,
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

  let compilerFile = (workspacePath: string): list(Plugin.t) => {
    let path = Path.join([|workspacePath, "compiler.js"|]);
    let rawConfig = Compiler.parseConfig(path);
    Array.to_list(rawConfig->Compiler.pluginsGet);
  };
};

type t = {
  plugins: list(Plugin.t),
  colorsFile: file(list(Color.t)),
  textStylesFile: file(TextStyle.file),
  shadowsFile: file(Shadow.file),
  workspacePath: string,
};

let exit = message => {
  Js.log(message);
  %bs.raw
  {|process.exit(1)|};
};

let load = path =>
  switch (Workspace.find(path)) {
  | None =>
    exit(
      "Couldn't find workspace directory. Try specifying it as a parameter (TODO)",
    )
  | Some(workspacePath) => {
      plugins: Workspace.compilerFile(workspacePath),
      colorsFile: Workspace.colorsFile(workspacePath),
      textStylesFile: Workspace.textStylesFile(workspacePath),
      shadowsFile: Workspace.shadowsFile(workspacePath),
      workspacePath,
    }
  };