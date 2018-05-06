const fs = require("fs");

const analyze = require("./index");

const source = fs.readFileSync("./examples/View1.js", "utf8");

const output = analyze(source);

console.log(output);

fs.writeFileSync(
  "./workspace/View1.component",
  JSON.stringify(output, null, 2)
);
