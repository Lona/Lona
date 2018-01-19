open Node;

[@bs.val] [@bs.module "fs-extra"] external ensureDirSync : string => unit = "";

let exit = (message) => {
  Js.log(message);
  [%bs.raw {|process.exit()|}]
};

if (Array.length(Process.argv) < 3) {
  exit("No command given")
};

let command = Process.argv[2];

if (Array.length(Process.argv) < 4) {
  exit("No target given")
};

let target =
  switch Process.argv[3] {
  | "js" => Types.JavaScript
  | "swift" => Types.Swift
  | _ => exit("Unrecognized target")
  };

/* Rudimentary workspace detection */
let rec findWorkspaceDirectory = (path) => {
  let exists = Fs.existsSync(Path.join([|path, "colors.json"|]));
  exists ?
    Some(path) :
    (
      switch (Path.dirname(path)) {
      | "/" => None
      | parent => findWorkspaceDirectory(parent)
      }
    )
};

let concat = (base, addition) => Path.join([|base, addition|]);

let getTargetExtension =
  fun
  | Types.JavaScript => ".js"
  | Swift => ".swift";

let targetExtension = getTargetExtension(target);

let convertColors = (filename) => Color.parseFile(filename) |> Swift.Color.render(target);

let convertComponent = (filename) => {
  let content = Fs.readFileSync(filename, `utf8);
  let parsed = content |> Js.Json.parseExn;
  let name = Path.basenameExt(~path=filename, ~ext=".component");
  switch target {
  | Types.JavaScript => JavaScript.Component.generate(name, parsed) |> JavaScript.Render.toString
  | Swift =>
    switch (findWorkspaceDirectory(filename)) {
    | None => exit("Couldn't find workspace directory. Try specifying it as a parameter (TODO)")
    | Some(workspace) =>
      let colors = Color.parseFile(Path.join([|workspace, "colors.json"|]));
      let result = Swift.Component.generate(name, parsed, colors);
      result |> Swift.Render.toString
    }
  }
};

let convertWorkspace = (workspace, output) => {
  let fromDirectory = Path.resolve([|workspace|]);
  let toDirectory = Path.resolve([|output|]);
  ensureDirSync(toDirectory);
  let colorsInputPath = concat(fromDirectory, "colors.json");
  let colorsOutputPath = concat(toDirectory, "colors" ++ targetExtension);
  let colors = Color.parseFile(colorsInputPath) |> Swift.Color.render(target);
  Fs.writeFileSync(~filename=colorsOutputPath, ~text=colors);
  Glob.glob(
    concat(fromDirectory, "**/*.component"),
    (_, files) => {
      let files = Array.to_list(files);
      let processFile = (file) => {
        let fromRelativePath = Path.relative(~from=fromDirectory, ~to_=file, ());
        let toRelativePath =
          concat(
            Path.dirname(fromRelativePath),
            Path.basenameExt(~path=fromRelativePath, ~ext=".component")
          )
          ++ targetExtension;
        let outputPath = Path.join([|toDirectory, toRelativePath|]);
        Js.log(
          Path.join([|workspace, fromRelativePath|])
          ++ "=>"
          ++ Path.join([|output, toRelativePath|])
        );
        let content = convertComponent(file);
        ensureDirSync(Path.dirname(outputPath));
        Fs.writeFileSync(~filename=outputPath, ~text=content)
      };
      files |> List.iter(processFile)
    }
  )
};

switch command {
| "workspace" =>
  if (Array.length(Process.argv) < 5) {
    exit("No workspace path given")
  };
  if (Array.length(Process.argv) < 6) {
    exit("No output path given")
  };
  convertWorkspace(Process.argv[4], Process.argv[5])
| "component" =>
  if (Array.length(Process.argv) < 5) {
    exit("No filename given")
  };
  convertComponent(Process.argv[4]) |> Js.log
| "colors" =>
  if (Array.length(Process.argv) < 5) {
    exit("No filename given")
  };
  convertColors(Process.argv[4]) |> Js.log
| _ => Js.log2("Invalid command", command)
};