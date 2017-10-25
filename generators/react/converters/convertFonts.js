/* eslint no-param-reassign: 0 */
const prettier = require('prettier');

const j = require('../utils/j');

module.exports = function convertFonts(data = {}, colors) {
  const { styles = [] } = data;

  // E.g. ['fontFamily', 'Arial'] => fontFamily: 'Arial'
  function convertProperty([key, value]) {
    if (key === 'uppercase') {
      return null;
    }

    if (key === 'color' && value in colors) {
      return j.property(
        'init',
        j.literal(key),
        j.memberExpression(j.identifier('colors'), j.identifier(value)),
      );
    }

    return j.property('init', j.identifier(key), j.literal(value));
  }

  // E.g. { id, fontFamily, ... } => id: { fontFamily: ... }
  function styleToObjectProperty(style) {
    // We list `name` here to exclude it from the output
    const { id, name, ...rest } = style;

    return j.property(
      'init',
      j.literal(id),
      j.objectExpression(Object.entries(rest).map(convertProperty).filter(x => !!x)),
    );
  }

  const program = j.program([
    j.importDeclaration(
      [j.importDefaultSpecifier(j.identifier('colors'))],
      j.literal('./colors.json'),
    ),
    j.variableDeclaration('const', [
      j.variableDeclarator(
        j.identifier('fonts'),
        j.objectExpression(styles.map(styleToObjectProperty)),
      ),
    ]),
    j.exportDefaultDeclaration(j.identifier('fonts')),
  ]);

  const code = j(program).toSource();
  return prettier.format(code);
};
