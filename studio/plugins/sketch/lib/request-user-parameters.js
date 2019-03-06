const { sendRequest } = require("stdio-jsonrpc");

function formatSketchFileUrl(url) {
  url = url.replace("file://", "");

  if (!url.endsWith(".sketch")) {
    url = url + ".sketch";
  }

  return url;
}

module.exports = async function requestUserParameters() {
  const outputUrlKey = "Save sketch file as";
  const componentsToIncludeKey = "Which components?";
  const oneDay = 1000 * 60 * 60 * 24;

  const response = await sendRequest(
    "customParameters",
    {
      id: "dialog-configure-sketch",
      title: "Configure Sketch file generation",
      params: [
        { name: outputUrlKey, type: "URL" },
        {
          name: componentsToIncludeKey,
          type: {
            cases: [
              "All",
              { case: "Include components matching", type: "String" },
              { case: "Exclude components matching", type: "String" }
            ],
            name: "Enum"
          }
        }
      ],
      persistenceScope: "workspace"
    },
    oneDay
  );

  console.error(`User params ${response}, ${response[outputUrlKey]}.`);

  if (!response) {
    console.error(`Sketch file generation cancelled`);
    process.exit(0);
  }

  if (!response[outputUrlKey]) {
    console.error(
      `Sketch file generation failed -- an output file path is required`
    );
    process.exit(0);
  }

  return {
    sketchFilePath: formatSketchFileUrl(response[outputUrlKey])
  };
};
