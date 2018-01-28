open Node;

[@bs.val] [@bs.module "fs-extra"] external ensureDirSync : string => unit = "";

[@bs.val] [@bs.module "fs-extra"]
external copySync : (string, string) => unit = "";

[@bs.module] external getStdin : unit => Js_promise.t(string) = "get-stdin";

let arguments = Array.to_list(Process.argv);

let swiftOptions: Swift.Options.options = {
  framework:
    switch (arguments |> List.find(Js.String.includes("--framework="))) {
    | arg when arg |> Js.String.endsWith("appkit") => Swift.Options.AppKit
    | _ => Swift.Options.UIKit
    | exception Not_found => Swift.Options.UIKit
    }
};

let exit = message => {
  Js.log(message);
  [%bs.raw {|process.exit(1)|}];
};

if (List.length(arguments) < 3) {
  exit("No command given");
};

let command = Process.argv[2];

if (Array.length(Process.argv) < 4) {
  exit("No target given");
};

let target =
  switch Process.argv[3] {
  | "js" => Types.JavaScript
  | "swift" => Types.Swift
  | "xml" => Types.Xml
  | _ => exit("Unrecognized target")
  };

/* Rudimentary workspace detection */
let rec findWorkspaceDirectory = path => {
  let exists = Fs.existsSync(Path.join([|path, "colors.json"|]));
  exists ?
    Some(path) :
    (
      switch (Path.dirname(path)) {
      | "/" => None
      | parent => findWorkspaceDirectory(parent)
      }
    );
};

let concat = (base, addition) => Path.join([|base, addition|]);

let getTargetExtension =
  fun
  | Types.JavaScript => ".js"
  | Swift => ".swift"
  | Xml => ".xml";

let targetExtension = getTargetExtension(target);

let renderColors = (target, colors) =>
  switch target {
  | Types.Swift => Swift.Color.render(swiftOptions, colors)
  | Xml => Xml.Color.render(colors)
  | _ => ""
  };

let renderTextStyles = (target, colors, textStyles) =>
  switch target {
  | Types.Swift => Swift.TextStyle.render(swiftOptions, colors, textStyles)
  | _ => ""
  };

let convertColors = (target, content) =>
  Color.parseFile(content) |> renderColors(target);

let convertTextStyles = (target, filename) =>
  switch (findWorkspaceDirectory(filename)) {
  | None =>
    exit(
      "Couldn't find workspace directory. Try specifying it as a parameter (TODO)"
    )
  | Some(workspace) =>
    let colorsFile =
      Node.Fs.readFileSync(Path.join([|workspace, "colors.json"|]), `utf8);
    let colors = Color.parseFile(colorsFile);
    let textStylesFile = Node.Fs.readFileSync(filename, `utf8);
    TextStyle.parseFile(textStylesFile) |> renderTextStyles(target, colors);
  };

let convertComponent = filename => {
  let content = Fs.readFileSync(filename, `utf8);
  let parsed = content |> Js.Json.parseExn;
  let name = Path.basenameExt(~path=filename, ~ext=".component");
  switch target {
  | Types.JavaScript =>
    JavaScript.Component.generate(name, parsed) |> JavaScript.Render.toString
  | Swift =>
    switch (findWorkspaceDirectory(filename)) {
    | None =>
      exit(
        "Couldn't find workspace directory. Try specifying it as a parameter (TODO)"
      )
    | Some(workspace) =>
      let colorsFile =
        Node.Fs.readFileSync(Path.join([|workspace, "colors.json"|]), `utf8);
      let colors = Color.parseFile(colorsFile);
      let textStylesFile =
        Node.Fs.readFileSync(
          Path.join([|workspace, "textStyles.json"|]),
          `utf8
        );
      let textStyles = TextStyle.parseFile(textStylesFile);
      let result =
        Swift.Component.generate(
          swiftOptions,
          name,
          colors,
          textStyles,
          parsed
        );
      result |> Swift.Render.toString;
    }
  | _ => exit("Unrecognized target")
  };
};

let copyStaticFiles = outputDirectory =>
  switch target {
  | Types.Swift =>
    let framework =
      switch swiftOptions.framework {
      | AppKit => "appkit"
      | UIKit => "uikit"
      };
    copySync(
      concat(
        NodeGlobal.__dirname,
        "../static/swift/AttributedFont." ++ framework ++ ".swift"
      ),
      concat(outputDirectory, "AttributedFont.swift")
    );
  | _ => ()
  };

let convertWorkspace = (workspace, output) => {
  let fromDirectory = Path.resolve([|workspace|]);
  let toDirectory = Path.resolve([|output|]);
  ensureDirSync(toDirectory);
  let colorsInputPath = concat(fromDirectory, "colors.json");
  let colorsOutputPath = concat(toDirectory, "Colors" ++ targetExtension);
  let colors = Color.parseFile(Node.Fs.readFileSync(colorsInputPath, `utf8));
  Fs.writeFileSync(
    ~filename=colorsOutputPath,
    ~text=colors |> renderColors(target)
  );
  let textStylesInputPath = concat(fromDirectory, "textStyles.json");
  let textStylesOutputPath =
    concat(toDirectory, "TextStyles" ++ targetExtension);
  let textStylesFile = Node.Fs.readFileSync(textStylesInputPath, `utf8);
  let textStyles =
    TextStyle.parseFile(textStylesFile) |> renderTextStyles(target, colors);
  Fs.writeFileSync(~filename=textStylesOutputPath, ~text=textStyles);
  copyStaticFiles(toDirectory);
  Glob.glob(
    concat(fromDirectory, "**/*.component"),
    (_, files) => {
      let files = Array.to_list(files);
      let processFile = file => {
        let fromRelativePath =
          Path.relative(~from=fromDirectory, ~to_=file, ());
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
        switch (convertComponent(file)) {
        | exception (Json_decode.DecodeError(reason)) =>
          Js.log("Failed to decode " ++ file);
          Js.log(reason);
        | exception (Decode.UnknownParameter(name)) =>
          Js.log("Unknown parameter: " ++ name)
        | content =>
          ensureDirSync(Path.dirname(outputPath));
          Fs.writeFileSync(~filename=outputPath, ~text=content);
        };
      };
      files |> List.iter(processFile);
    }
  );
};

switch command {
| "workspace" =>
  if (Array.length(Process.argv) < 5) {
    exit("No workspace path given");
  };
  if (Array.length(Process.argv) < 6) {
    exit("No output path given");
  };
  convertWorkspace(Process.argv[4], Process.argv[5]);
| "component" =>
  if (Array.length(Process.argv) < 5) {
    exit("No filename given");
  };
  convertComponent(Process.argv[4]) |> Js.log;
| "colors" =>
  if (Array.length(Process.argv) < 5) {
    let render = content =>
      Js.Promise.resolve(convertColors(target, content) |> Js.log);
    getStdin() |> Js.Promise.then_(render) |> ignore;
  } else {
    let content = Node.Fs.readFileSync(Process.argv[4], `utf8);
    convertColors(target, content) |> Js.log;
  }
| _ => Js.log2("Invalid command", command)
};