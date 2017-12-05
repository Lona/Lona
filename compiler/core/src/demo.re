/* include Types; */
/* include Map; */
open Node;

if (Array.length(Process.argv) < 3) {
  Js.log("No filename given");
  [%bs.raw {|process.exit()|}]
};

let filename = Process.argv[2];

let content = Fs.readFileSync(filename, `utf8);

let parsed = content |> Js.Json.parseExn;

let result = Component.JavaScript.generate("DocumentMarquee", parsed);

result |> Render.JavaScript.render |> Render.join("\n") |> Js.log;