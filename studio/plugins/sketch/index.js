const fs = require("fs");
const path = require("path");
const { Buffer } = require("buffer");
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

function findImages(layers) {
  let images = {};
  layers.forEach(layer => {
    if (layer && layer.style && layer.style.fills) {
      layer.style.fills.forEach(fill => {
        if (!fill.image) {
          return;
        }
        if (fill.image.data && fill.image.sha1) {
          images[fill.image.sha1._data] = Buffer.from(
            fill.image.data._data,
            "base64"
          );
          fill.image._ref = "images/" + fill.image.sha1._data;
          delete fill.image.data;
          delete fill.image.sha1;
          fill.image._class = "MSJSONFileReference";
        }
      });
    }
    if (layer.layers) {
      Object.assign(images, findImages(layer.layers));
    }
  });
  return images;
}

function modifySketchTemplate(layers, textStyles, output) {
  const sketchDoc = createNewSketchFile(generateId(output));

  const images = findImages(layers);

  sketchDoc.document.layerTextStyles.objects = textStyles;
  sketchDoc.pages[0].layers = sketchDoc.pages[0].layers.concat(layers);
  sketchDoc.images = images;

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
