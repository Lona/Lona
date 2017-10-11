const jscodeshift = require('jscodeshift');

function run(file, source, transforms) {
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
      {},
    );

    if (!output || output === input) {
      return input;
    }

    return output;
  }, source);
}

module.exports = run;
