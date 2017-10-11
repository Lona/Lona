module.exports = function transformer(file, api) {
  const j = api.jscodeshift;

  const root = j(file.source);

  // For each JSX element
  root.find(j.JSXElement).forEach((path) => {
    // Find the name attribute
    const nameAttribute = j(path).find(j.JSXAttribute, {
      name: {
        name: '__name',
      },
    });

    if (nameAttribute.size() <= 0) return;

    // Remove the name attribute
    nameAttribute.remove();
  });

  return root.toSource();
};
