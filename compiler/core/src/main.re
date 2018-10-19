open Node;

[@bs.val] [@bs.module "fs-extra"] external ensureDirSync: string => unit = "";

[@bs.val] [@bs.module "fs-extra"]
external copySync: (string, string) => unit = "";

[@bs.module] external getStdin: unit => Js_promise.t(string) = "get-stdin";

let arguments = Array.to_list(Process.argv);

let positionalArguments =
  arguments |> List.filter(arg => !Js.String.startsWith("--", arg));

let getArgument = name => {
  let prefix = "--" ++ name ++ "=";
  switch (arguments |> List.find(Js.String.startsWith(prefix))) {
  | value =>
    Some(value |> Js.String.sliceToEnd(~from=Js.String.length(prefix)))
  | exception Not_found => None
  };
};

let options: LonaCompilerCore.Options.options = {
  preset:
    switch (getArgument("preset")) {
    | Some("airbnb") => Airbnb
    | _ => Standard
    },
  filterComponents: getArgument("filterComponents"),
};

let swiftOptions: Swift.Options.options = {
  framework:
    switch (getArgument("framework")) {
    | Some("appkit") => Swift.Options.AppKit
    | _ => Swift.Options.UIKit
    },
  debugConstraints:
    switch (getArgument("debugConstraints")) {
    | Some(_) => true
    | _ => false
    },
  typePrefix:
    switch (getArgument("typePrefix")) {
    | Some(value) => value
    | _ => ""
    },
};

let javaScriptOptions: JavaScriptOptions.options = {
  framework:
    switch (getArgument("framework")) {
    | Some("reactsketchapp") => JavaScriptOptions.ReactSketchapp
    | Some("reactdom") => JavaScriptOptions.ReactDOM
    | _ => JavaScriptOptions.ReactNative
    },
};

let exit = message => {
  Js.log(message);
  %bs.raw
  {|process.exit(1)|};
};

if (List.length(positionalArguments) < 3) {
  exit("No command given");
};

let command = List.nth(positionalArguments, 2);

if (command != "convertSvg" && List.length(positionalArguments) < 4) {
  exit("No target given");
};

let target =
  if (command != "convertSvg") {
    switch (List.nth(positionalArguments, 3)) {
    | "js" => Types.JavaScript
    | "swift" => Types.Swift
    | "xml" => Types.Xml
    | _ => exit("Unrecognized target")
    };
  } else {
    Types.JavaScript;
  };

let concat = (base, addition) => Path.join([|base, addition|]);

let getTargetExtension =
  fun
  | Types.JavaScript => ".js"
  | Swift => ".swift"
  | Xml => ".xml";

let formatFilename = (target, filename) =>
  switch (target) {
  | Types.Xml
  | Types.JavaScript => Format.camelCase(filename)
  | Types.Swift => Format.upperFirst(Format.camelCase(filename))
  };

let targetExtension = getTargetExtension(target);

let renderColors = (target, colors) =>
  switch (target) {
  | Types.Swift => Swift.Color.render(options, swiftOptions, colors)
  | JavaScript => JavaScript.Color.render(colors)
  | Xml => Xml.Color.render(colors)
  };

let renderTextStyles = (target, colors, textStyles) =>
  switch (target) {
  | Types.Swift => Swift.TextStyle.render(swiftOptions, colors, textStyles)
  | JavaScript =>
    JavaScriptTextStyle.render(javaScriptOptions, colors, textStyles)
  | _ => ""
  };

let renderShadows = (target, colors, shadows) =>
  switch (target) {
  | Types.Swift => SwiftShadow.render(swiftOptions, colors, shadows)
  | JavaScript => JavaScriptShadow.render(javaScriptOptions, colors, shadows)
  | _ => ""
  };

let convertTypes = (target, contents) => {
  let json = contents |> Js.Json.parseExn;
  switch (target) {
  | Types.Swift =>
    json
    |> TypeSystem.Decode.typesFile
    |> SwiftTypeSystem.render(swiftOptions)
  | _ => exit("Can't generate types for target")
  };
};

let convertColors = (target, contents) =>
  Color.parseFile(contents) |> renderColors(target);

let convertTextStyles = (target, workspacePath, content) => {
  let colorsFile =
    Node.Fs.readFileSync(Path.join([|workspacePath, "colors.json"|]), `utf8);
  let colors = Color.parseFile(colorsFile);
  TextStyle.parseFile(content) |> renderTextStyles(target, colors);
};

let convertShadows = (target, workspacePath, content) => {
  let colorsFile =
    Node.Fs.readFileSync(Path.join([|workspacePath, "colors.json"|]), `utf8);
  let colors = Color.parseFile(colorsFile);
  Shadow.parseFile(content) |> renderShadows(target, colors);
};

exception ComponentNotFound(string);

let findComponentFile = (fromDirectory, componentName) => {
  let searchPath = "**/" ++ componentName ++ ".component";
  let files = Glob.sync(concat(fromDirectory, searchPath)) |> Array.to_list;
  switch (List.length(files)) {
  | 0 => raise(ComponentNotFound(componentName))
  | _ => List.hd(files)
  };
};

let findComponent = (fromDirectory, componentName) => {
  let filename = findComponentFile(fromDirectory, componentName);
  let contents = Fs.readFileSync(filename, `utf8);
  contents |> Js.Json.parseExn;
};

let getComponentRelativePath =
    (fromDirectory, sourceComponent, importedComponent) => {
  let sourcePath =
    Node.Path.dirname(findComponentFile(fromDirectory, sourceComponent));
  let importedPath = findComponentFile(fromDirectory, importedComponent);
  let relativePath =
    Node.Path.relative(~from=sourcePath, ~to_=importedPath, ());
  Js.String.startsWith(".", relativePath) ?
    relativePath : "./" ++ relativePath;
};

let getAssetRelativePath = (fromDirectory, sourceComponent, importedPath) => {
  let sourcePath =
    Node.Path.dirname(findComponentFile(fromDirectory, sourceComponent));
  let importedPath = Node.Path.join([|fromDirectory, importedPath|]);
  let relativePath =
    Node.Path.relative(~from=sourcePath, ~to_=importedPath, ());
  Js.String.startsWith(".", relativePath) ?
    relativePath : "./" ++ relativePath;
};

let convertComponent = (config: Config.t, filename: string) => {
  let contents = Fs.readFileSync(filename, `utf8);
  let parsed = contents |> Js.Json.parseExn;
  let name = Node.Path.basename_ext(filename, ".component");

  switch (target) {
  | Types.JavaScript =>
    JavaScriptComponent.generate(
      javaScriptOptions,
      name,
      Node.Path.relative(
        ~from=Node.Path.dirname(filename),
        ~to_=config.colorsFile.path,
        (),
      ),
      Node.Path.relative(
        ~from=Node.Path.dirname(filename),
        ~to_=config.shadowsFile.path,
        (),
      ),
      Node.Path.relative(
        ~from=Node.Path.dirname(filename),
        ~to_=config.textStylesFile.path,
        (),
      ),
      config,
      findComponent(config.workspacePath),
      getComponentRelativePath(config.workspacePath, name),
      getAssetRelativePath(config.workspacePath, name),
      parsed,
    )
    |> JavaScript.Render.toString
  | Swift =>
    let result =
      Swift.Component.generate(
        config,
        options,
        swiftOptions,
        name,
        findComponent(config.workspacePath),
        parsed,
      );
    result |> Swift.Render.toString;
  | _ => exit("Unrecognized target")
  };
};

let copyStaticFiles = outputDirectory =>
  switch (target) {
  | Types.Swift =>
    let framework =
      switch (swiftOptions.framework) {
      | AppKit => "appkit"
      | UIKit => "uikit"
      };
    if (swiftOptions.framework == UIKit) {
      copySync(
        concat(
          [%bs.raw {| __dirname |}],
          "static/swift/Shadow." ++ framework ++ ".swift",
        ),
        concat(outputDirectory, "Shadow.swift"),
      );
    };
    copySync(
      concat(
        [%bs.raw {| __dirname |}],
        "static/swift/TextStyle." ++ framework ++ ".swift",
      ),
      concat(outputDirectory, "TextStyle.swift"),
    );
    copySync(
      concat(
        [%bs.raw {| __dirname |}],
        "static/swift/CGSize+Crop." ++ framework ++ ".swift",
      ),
      concat(outputDirectory, "CGSize+Crop.swift"),
    );
  | _ => ()
  };

let findContentsAbove = contents => {
  let lines = contents |> Js.String.split("\n");
  let index =
    lines
    |> Js.Array.findIndex(line =>
         line |> Js.String.includes("LONA: KEEP ABOVE")
       );
  switch (index) {
  | (-1) => None
  | _ =>
    Some(
      (
        lines
        |> Js.Array.slice(~start=0, ~end_=index + 1)
        |> Js.Array.joinWith("\n")
      )
      ++ "\n\n",
    )
  };
};

let findContentsBelow = contents => {
  let lines = contents |> Js.String.split("\n");
  let index =
    lines
    |> Js.Array.findIndex(line =>
         line |> Js.String.includes("LONA: KEEP BELOW")
       );
  switch (index) {
  | (-1) => None
  | _ =>
    Some(
      "\n" ++ (lines |> Js.Array.sliceFrom(index) |> Js.Array.joinWith("\n")),
    )
  };
};

let convertWorkspace = (workspace, output) =>
  Config.load(workspace)
  |> Js.Promise.then_((config: Config.t) => {
       let colors = config.colorsFile.contents;
       let textStyles = config.textStylesFile.contents;
       let shadows = config.shadowsFile.contents;

       let fromDirectory = Path.resolve(workspace, "");
       let toDirectory = Path.resolve(output, "");
       ensureDirSync(toDirectory);

       let colorsOutputPath =
         concat(
           toDirectory,
           formatFilename(target, "Colors") ++ targetExtension,
         );
       Fs.writeFileSync(
         colorsOutputPath,
         colors |> renderColors(target),
         `utf8,
       );

       let textStylesOutputPath =
         concat(
           toDirectory,
           formatFilename(target, "TextStyles") ++ targetExtension,
         );
       Fs.writeFileSync(
         textStylesOutputPath,
         textStyles |> renderTextStyles(target, colors),
         `utf8,
       );

       if (target == Types.Swift || target == Types.JavaScript) {
         let shadowsOutputPath =
           concat(
             toDirectory,
             formatFilename(target, "Shadows") ++ targetExtension,
           );
         Fs.writeFileSync(
           shadowsOutputPath,
           shadows |> renderShadows(target, colors),
           `utf8,
         );
       };

       copyStaticFiles(toDirectory);
       Glob.glob(
         concat(fromDirectory, "**/*.component"),
         (_, files) => {
           let files =
             Array.to_list(files)
             |> List.filter(file =>
                  switch (options.filterComponents) {
                  | Some(value) => Js.Re.test(file, Js.Re.fromString(value))
                  | None => true
                  }
                );
           let processFile = file => {
             let fromRelativePath =
               Path.relative(~from=fromDirectory, ~to_=file, ());
             let toRelativePath =
               concat(
                 Path.dirname(fromRelativePath),
                 Path.basename_ext(fromRelativePath, ".component"),
               )
               ++ targetExtension;
             let outputPath = Path.join([|toDirectory, toRelativePath|]);
             Js.log(
               Path.join([|workspace, fromRelativePath|])
               ++ "=>"
               ++ Path.join([|output, toRelativePath|]),
             );
             switch (convertComponent(config, file)) {
             | exception (Json_decode.DecodeError(reason)) =>
               Js.log("Failed to decode " ++ file);
               Js.log(reason);
             | exception (Decode.UnknownParameter(name)) =>
               Js.log("Unknown parameter: " ++ name)
             | exception (Decode.UnknownExprType(name)) =>
               Js.log("Unknown expr name: " ++ name)
             | exception e =>
               Js.log("Unknown error");
               Js.log(e);
             | contents =>
               ensureDirSync(Path.dirname(outputPath));
               let (contentsAbove, contentsBelow) =
                 switch (Fs.readFileAsUtf8Sync(outputPath)) {
                 | existing => (
                     findContentsAbove(existing),
                     findContentsBelow(existing),
                   )
                 | exception _ => (None, None)
                 };
               let contents =
                 switch (contentsAbove) {
                 | Some(contentsAbove) => contentsAbove ++ contents
                 | None => contents
                 };
               let contents =
                 switch (contentsBelow) {
                 | Some(contentsBelow) => contents ++ contentsBelow
                 | None => contents
                 };
               Fs.writeFileSync(outputPath, contents, `utf8);
             };
           };
           files |> List.iter(processFile);
         },
       );
       Glob.glob(
         concat(fromDirectory, "**/*.png"),
         (_, files) => {
           let files = Array.to_list(files);
           let processFile = file => {
             let fromRelativePath =
               Path.relative(~from=fromDirectory, ~to_=file, ());
             let outputPath = Path.join([|toDirectory, fromRelativePath|]);
             Js.log(
               Path.join([|workspace, fromRelativePath|])
               ++ "=>"
               ++ Path.join([|output, fromRelativePath|]),
             );
             copySync(file, outputPath);
           };
           files |> List.iter(processFile);
         },
       );
       Js.Promise.resolve();
     });

switch (command) {
| "workspace" =>
  if (List.length(positionalArguments) < 5) {
    exit("No workspace path given");
  };
  if (List.length(positionalArguments) < 6) {
    exit("No output path given");
  };
  convertWorkspace(
    List.nth(positionalArguments, 4),
    List.nth(positionalArguments, 5),
  )
  |> ignore;
| "component" =>
  if (List.length(positionalArguments) < 5) {
    exit("No filename given");
  };
  let filename = List.nth(positionalArguments, 4);
  Config.load(filename)
  |> Js.Promise.then_(config => {
       convertComponent(config, filename) |> Js.log;
       Js.Promise.resolve();
     })
  |> ignore;
| "colors" =>
  if (List.length(positionalArguments) < 5) {
    let render = contents =>
      Js.Promise.resolve(convertColors(target, contents) |> Js.log);
    getStdin() |> Js.Promise.then_(render) |> ignore;
  } else {
    let contents =
      Node.Fs.readFileSync(List.nth(positionalArguments, 4), `utf8);
    convertColors(target, contents) |> Js.log;
  }
| "shadows" =>
  if (List.length(positionalArguments) < 5) {
    let render = content =>
      Js.Promise.resolve(convertColors(target, content) |> Js.log);
    getStdin() |> Js.Promise.then_(render) |> ignore;
  } else {
    let filename = List.nth(positionalArguments, 4);
    switch (Config.Workspace.find(filename)) {
    | None =>
      exit(
        "Couldn't find workspace directory. Try specifying it as a parameter (TODO)",
      )
    | Some(workspacePath) =>
      let content = Node.Fs.readFileSync(filename, `utf8);
      convertShadows(target, workspacePath, content) |> Js.log;
    };
  }
| "types" =>
  if (List.length(positionalArguments) < 5) {
    exit("No filename given");
  } else {
    let contents =
      Node.Fs.readFileSync(List.nth(positionalArguments, 4), `utf8);
    convertTypes(target, contents) |> Js.log;
  }
| "textStyles" =>
  if (List.length(positionalArguments) < 5) {
    let render = content =>
      Js.Promise.resolve(convertColors(target, content) |> Js.log);
    getStdin() |> Js.Promise.then_(render) |> ignore;
  } else {
    let filename = List.nth(positionalArguments, 4);
    switch (Config.Workspace.find(filename)) {
    | None =>
      exit(
        "Couldn't find workspace directory. Try specifying it as a parameter (TODO)",
      )
    | Some(workspacePath) =>
      let content = Node.Fs.readFileSync(filename, `utf8);
      convertTextStyles(target, workspacePath, content) |> Js.log;
    };
  }
| "convertSvg" =>
  let contents =
    if (List.length(positionalArguments) < 3) {
      getStdin();
    } else {
      Js.Promise.resolve(
        Node.Fs.readFileSync(List.nth(positionalArguments, 3), `utf8),
      );
    };
  Js.Promise.(
    contents
    |> then_(Svg.parse)
    |> then_(parsed => parsed |> Js.Json.stringify |> Js.log |> resolve)
    |> ignore
  );
| _ => Js.log2("Invalid command", command)
};