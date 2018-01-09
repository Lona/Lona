open Node;

let exit = (message) => {
  Js.log(message);
  [%bs.raw {|process.exit()|}]
};

if (Array.length(Process.argv) < 3) {
  exit("No target given")
};

let target =
  switch Process.argv[2] {
  | "js" => Types.JavaScript
  | "swift" => Types.Swift
  | _ => exit("Unrecognized target")
  };

if (Array.length(Process.argv) < 4) {
  exit("No command given")
};

let command = Process.argv[3];

/* Primitive workspace detection */
let rec findWorkspaceDirectory = (path) => {
  let exists = Node.Fs.existsSync(Node.Path.join([|path, "colors.json"|]));

  switch exists {
  | true => Some(path)
  | false =>
    switch (Node.Path.dirname(path)) {
    | "/" => None
    | parent => findWorkspaceDirectory(parent)
    };
  };
};

switch command {
| "component" =>
  if (Array.length(Process.argv) < 5) {
    exit("No filename given")
  };
  let filename = Process.argv[4];
  let content = Fs.readFileSync(filename, `utf8);
  let parsed = content |> Js.Json.parseExn;
  let name = Node.Path.basenameExt(filename, ".component");
  switch target {
  | Types.JavaScript =>
    Component.JavaScript.generate(name, parsed) |> Render.JavaScript.toString |> Js.log
  | Swift =>
    switch (findWorkspaceDirectory(filename)) {
    | None => exit("Couldn't find workspace directory. Try specifying it as a parameter (TODO)")
    | Some(workspace) =>
      let colors = Color.parseFile(Node.Path.join([|workspace, "colors.json"|]));
      let result = Component.Swift.generate(name, parsed, colors);
      result |> Render.Swift.toString |> Js.log;
    };
  }
| "colors" =>
  if (Array.length(Process.argv) < 5) {
    exit("No filename given")
  };
  let filename = Process.argv[4];
  Color.parseFile(filename) |> Color.render(target) |> Js.log
| _ => Js.log2("Invalid command", command)
};
