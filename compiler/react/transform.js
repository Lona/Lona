const jscodeshift = require('jscodeshift');

function run(file, source, transforms, options = {}) {
  const withParser = jscodeshift.withParser('babylon');

  return transforms.reduce((input, transform) => {
    const output = transform(
      {
        path: file,
        source: input,
      },
      {
        j: withParser,
        jscodeshift: withParser,
        stats: {},
      },
      options,
    );

    if (!output || output === input) {
      return input;
    }

    return output;
  }, source);
}

module.exports = run;
