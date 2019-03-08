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
  const componentsFilterKey = "Which components?";
  const componentsFilterAll = "All";
  const componentsFilterInclude = "Include components matching";
  const componentsFilterExclude = "Exclude components matching";
  const oneDay = 1000 * 60 * 60 * 24;

  const response = await sendRequest(
    "customParameters",
    {
      id: "dialog-configure-sketch",
      title: "Configure Sketch file generation",
      params: [
        { name: outputUrlKey, type: "URL" },
        {
          name: componentsFilterKey,
          type: {
            cases: [
              componentsFilterAll,
              { case: componentsFilterInclude, type: "String" },
              { case: componentsFilterExclude, type: "String" }
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
    sketchFilePath: formatSketchFileUrl(response[outputUrlKey]),
    componentPathFilter: componentPath => {
      const filterValue = response[componentsFilterKey];

      if (!filterValue) {
        return true;
      }

      switch (filterValue.case) {
        case componentsFilterAll: {
          return true;
        }
        case componentsFilterInclude: {
          const regex = new RegExp(filterValue.data);
          return regex.test(componentPath);
        }
        case componentsFilterExclude: {
          const regex = new RegExp(filterValue.data);
          return !regex.test(componentPath);
        }
      }
    }
  };
};
