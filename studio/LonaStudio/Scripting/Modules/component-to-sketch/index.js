const program = require("commander");
const { createNewSketchFile, writeSketchFile, generateId } = require('sketch-file');

const { convertArtboard } = require("./convertToSketchFormat");

let outFile;

program
  .version("0.1.0")
  .arguments("[out]")
  // .option("-l, --layers [optional]", "Layers to append", x => JSON.parse(x))
  .action(out => {
    outFile = out;
  })
  .parse(process.argv);

if (!outFile) {
  console.log("Missing output file!");
  program.help();
}

console.log("writing to", outFile);

async function modifySketchTemplate({ layers, references }) {
  const sketchDoc = createNewSketchFile(generateId(outFile));

  if (layers) {
    sketchDoc.pages[0].layers = sketchDoc.pages[0].layers.concat(layers);
  }
  if (references) {
    references.forEach(image => {
      const { id, data } = image;
      console.log("adding image", id + ".png");
      sketchDoc.images[id] = new Buffer(data, "base64")
    });
  }

  if (outFile) {
    await writeSketchFile(sketchDoc, outFile);
    console.log(outFile + " written");
  }
}

function readFromStream(stream) {
  return new Promise(resolve => {
    let data = "";
    stream.on("data", chunk => data += chunk);
    stream.on("end", () => {
      resolve(data);
    });
  });
}

(async () => {
  const json = await readFromStream(process.stdin);
  const input = JSON.parse(json);
  modifySketchTemplate(input);
})();
