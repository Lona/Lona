console.log("Hello");

const fs = require('fs')
const path = require('path')

fs.writeFileSync(path.resolve(require("os").homedir(), "Desktop/testnode.txt"), "working\n", "utf8");
