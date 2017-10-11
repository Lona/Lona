const fs = require('fs');

// Take all local assets (starting with 'file://') used and inline them
//
// const assets = {
//   'file://test.png': 'base64...',
// }
module.exports = function transformer(file, api) {
  const j = api.jscodeshift;
  const root = j(file.source);

  const assets = [];

  root.find(j.Literal).forEach((path) => {
    const value = path.get('value').value;

    if (!value || typeof value !== 'string' || !value.startsWith('file://')) {
      return;
    }
    if (assets.includes(value)) return;

    assets.push(value);

    const lookup = j.memberExpression(j.identifier('assets'), j.literal(value));
    j(path).replaceWith(lookup);
  });

  if (assets.length === 0) {
    return root.toSource();
  }

  const objectProperties = assets.map((asset) => {
    const uri = asset.replace('file://', '');
    const metadata = 'data:image/png;base64,';
    const encoded = fs.readFileSync(uri).toString('base64');
    return j.property('init', j.literal(asset), j.literal(metadata + encoded));
  });

  const assetMap = j.variableDeclaration('const', [
    j.variableDeclarator(
      j.identifier('assets'),
      j.objectExpression(objectProperties),
    ),
  ]);

  return `${j(assetMap).toSource()}\n\n${root.toSource()}`;
};
