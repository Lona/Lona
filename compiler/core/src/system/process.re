let cwd = Node.Process.cwd;

let argv = Node.Process.argv;

[@bs.module] external getStdin: unit => Js_promise.t(string) = "get-stdin";

let exit = message => {
  Js.log2("Exiting with:", message);
  %bs.raw
  {|process.exit(1)|};
};