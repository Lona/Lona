module.exports = function transformer(file, api) {
  const j = api.jscodeshift;

  const root = j(file.source);

  root
    .find(j.ConditionalExpression, { test: { value: true } })
    .forEach((path) => {
      const consequent = j(j(path).get('consequent'));

      j(path).replaceWith(consequent.toSource());
    });

  root
    .find(j.ConditionalExpression, { test: { value: false } })
    .forEach((path) => {
      const alternate = j(j(path).get('alternate'));

      j(path).replaceWith(alternate.toSource());
    });

  return root.toSource();
};
