const fs = require("fs");
const path = require("path");

const generateId = require("sketch-file/generateId");
const { TextStyles } = require("react-sketchapp");
const createSymbol = require("./symbol");

function findComponentsInWorkspace(startingPath, dir, done) {
  let results = [];

  fs.readdir(dir, (err, list) => {
    if (err) {
      return done(err);
    }

    let pending = list.length;

    if (!pending) {
      return done(null, results);
    }

    list.forEach(file => {
      const fullPath = path.resolve(dir, file);

      fs.stat(fullPath, (err, stat) => {
        if (stat && stat.isDirectory()) {
          findComponentsInWorkspace(
            `${startingPath}/${file}`,
            fullPath,
            (err, res) => {
              if (err) {
                done(err);
                return;
              }

              results = results.concat(res);

              if (!--pending) {
                done(null, results);
              }
            }
          );
          return;
        }
        if (path.extname(fullPath) === ".component") {
          results.push(`${startingPath}/${file.replace(/\.component$/gi, "")}`);
        }

        if (!--pending) {
          done(null, results);
        }
      });
    });
  });
}

function loadComponent(config, componentPath) {
  const relativeComponentPath = path
    .relative(config.paths.workspace, componentPath)
    .replace(/\.component$/gi, "");
  try {
    return {
      name: relativeComponentPath,
      compiled: require(path.join(config.paths.output, relativeComponentPath))
        .default,
      meta: JSON.parse(fs.readFileSync(componentPath))
    };
  } catch (err) {
    console.error("skipping " + componentPath);
    console.error(err);
  }
}

function generateSymbols(components) {
  return components.reduce((prev, component) => {
    if (!component) {
      return prev;
    }
    prev = prev.concat(
      component.meta.examples
        .map(example => {
          try {
            return createSymbol(
              component.compiled,
              example.params,
              example.name
            );
          } catch (err) {
            console.error("skipping " + component.name);
            console.error(err);
            return undefined;
          }
        })
        .filter(x => x)
    );
    return prev;
  }, []);
}

function arrangeSymbols(symbols) {
  return symbols.reduce(
    (acc, symbol) => {
      const { result, offset } = acc;

      symbol.frame.y = offset;
      result.push(symbol);

      return {
        result,
        offset: offset + symbol.frame.height + 48
      };
    },
    {
      result: [],
      offset: 0
    }
  );
}

module.exports = config => {
  const _TextStyles = require(config.paths.textStyles
    .replace(config.paths.workspace, config.paths.output)
    .replace(/\.json$/gi, "")).default;

  const _Colors = require(config.paths.colors
    .replace(config.paths.workspace, config.paths.output)
    .replace(/\.json$/gi, "")).default;

  TextStyles.create(
    {
      idMap: Object.keys(_TextStyles).reduce((prev, k) => {
        prev[k] = generateId(k);
        return prev;
      }, {})
    },
    Object.keys(_TextStyles).reduce((prev, k) => {
      prev[k] = _TextStyles[k];
      return prev;
    }, {})
  );

  const components = config.paths.components.map(componentPath =>
    loadComponent(config, componentPath)
  );

  return {
    layers: arrangeSymbols(generateSymbols(components)).result,
    textStyles: TextStyles.toJSON()
  };
};
