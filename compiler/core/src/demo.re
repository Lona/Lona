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

switch command {
| "component" =>
  if (Array.length(Process.argv) < 5) {
    exit("No filename given")
  };
  let filename = Process.argv[4];
  let content = Fs.readFileSync(filename, `utf8);
  let parsed = content |> Js.Json.parseExn;
  let result = Component.JavaScript.generate("DocumentMarquee", parsed);
  Render.JavaScript.toString(result) |> Js.log
| "colors" =>
  if (Array.length(Process.argv) < 5) {
    exit("No filename given")
  };
  let filename = Process.argv[4];
  Color.parseFile(filename) |> Color.render(target) |> Js.log
| _ => Js.log2("Invalid command", command)
};