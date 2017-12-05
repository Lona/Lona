module.exports = function transformer(file, api) {
  const j = api.jscodeshift;

  const root = j(file.source);

  // Remove empty if statements: "if (...) { /* empty */ }"
  root
    .find(j.IfStatement, {
      alternate: null,
      consequent: { body: { length: 0 } },
    })
    .forEach((path) => {
      j(path).remove();
    });

  return root.toSource();
};
