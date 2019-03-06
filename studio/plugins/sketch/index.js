const os = require("os");
const path = require("path");

// Choose a directory for the compiler to write generated JS files
const compilerOutput = path.join(os.tmpdir(), "lona-sketch-plugin-generated");

// https://gist.github.com/branneman/8048520#gistcomment-1249909
// Add node_modules to the path, so they're resolved even when loading modules
// from our compilerOutput directory (which is outside the root of this project)
process.env["NODE_PATH"] = path.join(__dirname, "node_modules");
require("module").Module._initPaths();

// Load generated JS files using babel. Use a custom ignore pattern to use babel
// even when loading outside this directory.
require("@babel/register")({
  ignore: [/node_modules/]
});

require("./main")(compilerOutput);
