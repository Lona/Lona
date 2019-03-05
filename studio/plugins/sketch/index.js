const fs = require("fs");
const path = require("path");
const { exec, execSync } = require("child_process");
const {
  setup,
  sendRequest,
  sendNotification,
  RPCError
} = require("stdio-jsonrpc");
const {
  createNewSketchFile,
  writeSketchFile,
  generateId
} = require("sketch-file");
const renderDocument = require("./lib/render-document");

function modifySketchTemplate(layers, textStyles, output) {
  const sketchDoc = createNewSketchFile(generateId(output));

  sketchDoc.document.layerTextStyles.objects = textStyles;
  sketchDoc.pages[0].layers = sketchDoc.pages[0].layers.concat(layers);

  return writeSketchFile(sketchDoc, output);
}

Promise.all([sendRequest("workspacePath"), sendRequest("compilerPath")])
  .then(([workspace, compiler]) => {
    if (!workspace) {
      throw new Error("missing workspace path");
    }

    if (!compiler) {
      compiler = require.resolve("lonac");
    }

    // TODO: change that
    const output = path.join(__dirname, "./generated");

    try {
      fs.mkdirSync(output, { recursive: true });
    } catch (err) {
      if (err.code !== "EEXIST") {
        throw err;
      }
    }

    const config = JSON.parse(
      execSync(`node "${compiler}" config "${workspace}"`)
    );
    config.paths.output = output;

    return new Promise((resolve, reject) => {
      exec(
        `node "${compiler}" workspace js "${workspace}" "${output}" --framework=reactsketchapp`,
        (err, stdout, stderr) => {
          if (err) {
            err.stdout = stdout;
            err.stderr = stderr;
            return reject(err);
          }
          console.error(stdout);
          console.error(stderr);
          return resolve(config);
        }
      );
    });
  })
  .then(config => {
    const { layers, textStyles } = renderDocument(config);
    const outputFile = path.join(config.paths.output, "./library.sketch");
    return modifySketchTemplate(layers, textStyles, outputFile);
  })
  .catch(x => console.error(x))
  .then(() => process.exit(0));
