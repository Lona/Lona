const fs = require("fs");
const os = require("os");
const path = require("path");
const { Buffer } = require("buffer");
const { exec, execSync } = require("child_process");
const { sendRequest } = require("stdio-jsonrpc");
const {
  createNewSketchFile,
  writeSketchFile,
  generateId
} = require("sketch-file");
const renderDocument = require("./lib/render-document");
const requestUserParameters = require("./lib/request-user-parameters");

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

function modifySketchTemplate({ layers, textStyles, colors }, output) {
  const sketchDoc = createNewSketchFile(generateId(output));

  const images = findImages(layers);

  sketchDoc.document.layerTextStyles.objects = textStyles;
  sketchDoc.document.assets.colors = colors.map(c => ({
    _class: "color",
    alpha: c.alpha,
    blue: c.blue,
    green: c.green,
    red: c.red
  }));
  sketchDoc.document.assets.colorAssets = colors.map(c => ({
    _class: "MSImmutableColorAsset",
    name: c.name,
    color: {
      _class: "color",
      alpha: c.alpha,
      blue: c.blue,
      green: c.green,
      red: c.red
    }
  }));
  sketchDoc.pages[0].layers = sketchDoc.pages[0].layers.concat(layers);
  sketchDoc.images = images;

  return writeSketchFile(sketchDoc, output);
}

module.exports = function(output) {
  return Promise.all([
    sendRequest("workspacePath"),
    sendRequest("compilerPath")
  ])
    .then(async ([workspace, compiler]) => {
      const {
        sketchFilePath,
        componentPathFilter
      } = await requestUserParameters();

      console.error(`Generating sketch file at ${sketchFilePath}`);

      if (!workspace) {
        throw new Error("missing workspace path");
      }

      if (!compiler) {
        compiler = require.resolve("lonac");
      }

      console.error(`Generating react-sketchapp project at ${output}`);

      try {
        fs.mkdirSync(output, { recursive: true });
      } catch (err) {
        if (err.code !== "EEXIST") {
          throw err;
        }
      }

      const compilerConfig = JSON.parse(
        execSync(`node "${compiler}" config "${workspace}"`)
      );

      const config = {
        paths: {
          output,
          sketchFile: sketchFilePath,
          workspace: compilerConfig.paths.workspace,
          colors: compilerConfig.paths.colors,
          textStyles: compilerConfig.paths.textStyles,
          components: compilerConfig.paths.components
        },
        componentPathFilter
      };

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
      const values = renderDocument(config);
      return modifySketchTemplate(values, config.paths.sketchFile);
    })
    .catch(x => console.error(x))
    .then(() => process.exit(0));
};
