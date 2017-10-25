const _ = require('lodash');

function importSource(j, root, module) {
  return root.find(j.ImportDeclaration, {
    source: { value: module },
  });
}

function hasImportSource(j, root, module) {
  return importSource(j, root, module).size() > 0;
}

function hasImport(j, root, module, name) {
  if (!hasImportSource(j, root, module)) return false;

  const source = importSource(j, root, module);

  const namedImport = source.find(j.ImportSpecifier, {
    imported: {
      name,
    },
  });

  return namedImport.size() > 0;
}

function addImport(j, root, module, name) {
  if (hasImport(j, root, module, name)) return;

  const importSpecifier = j.importSpecifier(j.identifier(name));

  if (hasImportSource(j, root, module)) {
    const source = importSource(j, root, module);

    source.find(j.ImportSpecifier).at(-1).insertAfter(importSpecifier);
  } else {
    const source = j(j.importDeclaration([importSpecifier], j.literal(module)));
    const imports = root.find(j.ImportDeclaration);

    if (imports.size() > 0) {
      imports.at(-1).insertAfter(source.toSource());
    } else {
      root.find(j.Program).get('body').unshift(source.toSource());
    }
  }
}

function isLiteralProperty(j, node) {
  switch (node.type) {
    case 'ObjectProperty': {
      const type = j(node).get('value').get('type').value;
      return type.endsWith('Literal');
    }
    case 'SpreadProperty': {
      const type = j(node).get('argument').get('type').value;

      if (type === 'MemberExpression') {
        const name = j(node).get('argument').get('object').get('name').value;

        // Assume if a member expression ends with an identifier,
        const propertyType = j(node).get('argument').get('property').get('type')
          .value;

        // TODO: Determine where this variable comes from (e.g. imports)
        // and make a best guess if it's dynamic?
        return name === 'fonts' && propertyType !== 'Identifier';
      }
      return false;
    }
    default:
      return false;
  }
}

module.exports = function transformer(file, api, options) {
  const j = api.jscodeshift;

  const definitions = [];

  const createStyleDefinition = (name, objectLiteral) => {
    const properties = Object.entries(objectLiteral).map(([key, value]) =>
      j.property('init', j.identifier(key), j.literal(value)),
    );

    return j.property(
      'init',
      j.identifier(name),
      j.objectExpression(properties),
    );
  };

  const root = j(file.source);

  addImport(j, root, options.primitives ? 'react-primitives' : 'react-native', 'StyleSheet');

  // For each JSX element
  root.find(j.JSXElement).forEach((path) => {
    const attributes = path.get('openingElement').get('attributes').value;

    // Find the style attribute
    const styleAttribute = j(attributes).filter(
      attributePath => attributePath.get('name').get('name').value === 'style',
    );

    // Find the name attribute
    const nameAttribute = j(attributes).filter(
      attributePath => attributePath.get('name').get('name').value === '__name',
    );

    // Ensure both style and name exist
    if (styleAttribute.size() <= 0 || nameAttribute.size() <= 0) return;

    // Extract the component name
    const componentName = _.camelCase(
      nameAttribute.find(j.Literal).get('value').value,
    );

    // Get the inline style literal
    const inlineStyleLiteral = styleAttribute.find(j.ObjectExpression);

    if (inlineStyleLiteral.size() <= 0) return;

    const properties = inlineStyleLiteral.nodes()[0].properties;

    const literalProperties = properties.filter(node =>
      isLiteralProperty(j, node),
    );
    const dynamicProperties = properties.filter(
      node => !isLiteralProperty(j, node),
    );

    const hasLiteralProperties = literalProperties.length > 0;
    const hasDynamicProperties = dynamicProperties.length > 0;
    const hasMixedProperties = hasLiteralProperties && hasDynamicProperties;

    const literalPropertiesObject = j.objectExpression(literalProperties);
    const dynamicPropertiesObject = j.objectExpression(dynamicProperties);

    // Create a reference to the StyleSheet style we're about to add
    const reference = j.memberExpression(
      j.identifier('styles'),
      j.identifier(componentName),
      false,
    );

    if (hasMixedProperties) {
      const styleArrayLiteral = j.arrayExpression([
        reference,
        dynamicPropertiesObject,
      ]);

      inlineStyleLiteral.replaceWith(styleArrayLiteral);
    } else if (hasLiteralProperties) {
      inlineStyleLiteral.replaceWith(reference);
    }

    if (hasLiteralProperties) {
      // Add it to the StyleSheet definitions
      const namedStyleLiteral = j.property(
        'init',
        j.identifier(componentName),
        literalPropertiesObject,
      );

      // Add to the StyleSheet definitions
      definitions.push(namedStyleLiteral);
    }
  });

  // Create StyleSheet definitions
  const styles = j.variableDeclaration('const', [
    j.variableDeclarator(
      j.identifier('styles'),
      j.callExpression(
        j.memberExpression(
          j.identifier('StyleSheet'),
          j.identifier('create'),
          false,
        ),
        [j.objectExpression(definitions)],
      ),
    ),
  ]);

  // Add StyleSheet definitions to the end of the file
  root.find(j.ExportDefaultDeclaration).insertAfter(j(styles).toSource());

  return root.toSource();
};
