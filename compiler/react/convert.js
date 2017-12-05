/* eslint no-param-reassign: 0 global-require: 0 */
const _ = require('lodash');
const prettier = require('prettier');
const path = require('path');

const { readComponent, getComponentName } = require('./utils/component');
const transform = require('./transform');

const indentUnit = '  ';

function nameToVariable(name) {
  return _.camelCase(name);
}

function getVariableName(title, attribute) {
  return `${nameToVariable(title)}${_.upperFirst(attribute)}`;
}

function isInScope(scope, name, attribute) {
  return _.get(scope, [name, attribute], undefined) !== undefined;
}

function getScopeVariable(scope, name, attribute, defaultValue) {
  if (!isInScope(scope, name, attribute)) {
    return `${defaultValue}`;
  }

  const variableName = getVariableName(name, attribute);

  if (defaultValue) {
    return `${variableName} !== undefined ? ${variableName} : ${defaultValue}`;
  }
  return variableName;
}

function pad(pre = '', code, post = '') {
  if (!code) return '';

  return pre + code + post;
}

function indent(code = '', count = 0) {
  return code
    .split('\n')
    .map(line => indentUnit.repeat(count) + line)
    .join('\n');
}

function writeImports(imports = []) {
  return imports
    .map((imp) => {
      const { source, defaultMember, members = [] } = imp;

      const memberImports =
        members.length > 0 ? `{ ${members.join(', ')} }` : '';

      const allMembers = [defaultMember, memberImports]
        .filter(x => !!x)
        .join(', ');

      return `import ${allMembers} from '${source}';`;
    })
    .join('\n');
}

const TYPE_MAP = {
  Boolean: 'bool',
  String: 'string',
  Number: 'number',
};

function writePropTypes(parameters = []) {
  const types = parameters
    .map((parameter) => {
      const { name, type, optional } = parameter;
      const optionalCode = optional ? '' : '.isRequired';

      return `${name}: PropTypes.${TYPE_MAP[type]}${optionalCode},`;
    })
    .join('\n');

  return `static propTypes = {\n${indent(types, 1)}\n}`;
}

const DEFAULT_VALUE_MAP = {
  Boolean: false,
  String: '',
  Number: 0,
};

function writeDefaultProps(parameters = []) {
  const defaultProps = parameters
    .filter(parameter => parameter.optional)
    .map((parameter) => {
      const { name, type } = parameter;

      return `${name}: ${JSON.stringify(DEFAULT_VALUE_MAP[type])},`;
    })
    .join('\n');

  if (!defaultProps) return '';

  return `static defaultProps = {\n${indent(defaultProps, 1)}\n}`;
}

function writeDefaultExport(code) {
  return `export default ${code};`;
}

function writeClass(name, extendsName, body) {
  let code = '';
  code += `class ${name} extends ${extendsName} {\n`;
  code += indent(body, 1);
  code += '\n}';

  return code;
}

function writeObjectDestructureAssignment(
  declarationKeyword = 'const',
  source = 'this',
  members = [],
) {
  const memberCode = members.join(',\n');
  return `${declarationKeyword} {\n${indent(memberCode, 1)}\n} = ${source};`;
}

const STYLE_PROPS = [
  'width',
  'height',
  'flex',
  'flexDirection',
  'justifyContent',
  'alignItems',
  'alignSelf',
  'color',
  'backgroundColor',
  'font', // HACK: put font in styles temporarily
  'overflow',
  key => key.startsWith('padding'),
  key => key.startsWith('margin'),
  key => key.startsWith('border'),
];

function collectJSXProps(layer, scope, options) {
  const { name, type, parameters } = layer;

  if (type === 'Text' && !parameters.font) {
    // TODO Read default from json
    parameters.font = 'regular';
  }

  const props = {};
  const style = {};

  // Annotate components with their name. This will be transformed out at the end.
  props.__name = JSON.stringify(name);

  // Params that exist in scope but have no hardcoded defaults
  const scopeOnly =
    name in scope
      ? Object.keys(scope[name])
          .map((key) => {
            if (key in parameters) return null;

            return [key, getScopeVariable(scope, name, key)];
          })
          .filter(x => !!x)
      : [];

  // const fontProperties = parameters.font
  //   ? getFontProperties(parameters.font)
  //   : [];

  Object.entries(parameters)
    .map(([key, value]) => {
      if (key === 'backgroundColor' && (value in options.colors)) {
        value = options.colors[value];
      }

      const stringValue = JSON.stringify(value);

      return [key, getScopeVariable(scope, name, key, stringValue)];
    })
    .concat(scopeOnly)
    .forEach(([key, value]) => {
      if (type === 'Children') return;

      if (type === 'Component') {
        props[key] = value;
        return;
      }

      if (type === 'Text' && key === 'textStyle') {
        style.font = value;
        return;
      }
      if (type === 'Text' && key === 'text') return;
      if (type === 'Image' && key === 'image') {
        props.source = { uri: value };
        return;
      }

      if (key === 'visible') return;

      if (
        STYLE_PROPS.some(
          predicate =>
            typeof predicate === 'string'
              ? predicate === key
              : predicate(key, value),
        )
      ) {
        style[key] = value;
      } else {
        props[key] = value;
      }
    });

  if (type !== 'Component' && type !== 'Children') {
    style.overflow = JSON.stringify('hidden');
  }

  if (Object.keys(style).length > 0) {
    props.style = style;
  }

  return props;
}

function writePropValue(obj) {
  if (_.isObject(obj)) {
    const body = Object.entries(obj)
      .map(([key, value]) => `${key}: ${value}`)
      .join(',\n');

    return `{\n${indent(body, 1)}\n}`;
  }

  return obj;
}

function writeJSXElement(layer, scope, options) {
  const { name, type, parameters = [], children, url } = layer;

  if (type === 'Children') {
    return '{this.props.children}';
  }

  const text = `{${getScopeVariable(
    scope,
    name,
    'text',
    JSON.stringify(parameters.text),
  )}}`;
  const childrenCode =
    type === 'Text'
      ? text
      : children.map(child => writeJSXElement(child, scope, options)).join('\n');

  const props = collectJSXProps(layer, scope, options);
  const style = props.style;
  if (style) delete props.style;
  // const font = style && style.font;
  // if (font) delete style.font;

  let styleCode;
  if (style) {
    styleCode = writePropValue(style);
    styleCode = Object.entries(style)
      .map(([key, value]) => {
        if (key === 'font') {
          return `...fonts[${value}]`;
        }

        return `${key}: ${value}`;
      })
      .join(',\n');
    styleCode = `{\n${indent(styleCode, 1)}\n}`;
  }

  const parametersCode = Object.entries(props)
    .map(([key, value]) => `${key}={${writePropValue(value)}}`)
    .concat(style ? [`style={${styleCode}}`] : [])
    .join(' ');

  const elementType = type === 'Component' ? getComponentName(url) : type;

  let componentCode = [
    `<${elementType}${pad(' ', parametersCode)}>`,
    indent(childrenCode, 1),
    `</${elementType}>`,
  ].join('\n');

  const visible = getScopeVariable(scope, name, 'visible', parameters.visible);
  if (visible !== 'undefined' && visible !== 'true') {
    componentCode = `{(${visible}) && (\n${indent(componentCode, 1)}\n)}`;
  }

  return componentCode;
}

function addDeclarationsToScope(node, scope) {
  const { function: { name, arguments: args }, nodes } = node;

  if (name === 'Assign') {
    const { rhs: { value: { path } } } = args;

    // Special case layers for now
    // TODO: Make this generic for any kind of variable
    if (path.length === 3) {
      const [, layerName, layerAttribute] = path;
      scope[layerName] = scope[layerName] || {};
      scope[layerName][layerAttribute] = true;
    }
  }

  nodes.forEach(sub => addDeclarationsToScope(sub, scope));
}

function writeComparator(comparator) {
  switch (comparator) {
    case 'equal to':
      return '===';
    case 'greater than':
      return '>';
    case 'less than':
      return '<';
    default:
      throw new Error(`Bad Comparator: ${comparator}`);
  }
}

function writeNode(node, options) {
  const { function: { name, arguments: args }, nodes } = node;

  switch (name) {
    case 'If': {
      const {
        cmp: { value: { data: comparator } },
        lhs: { type: lhsType, value: { data: lhsData, path: lhsPath } },
        rhs: { type: rhsType, value: { data: rhsData, path: rhsPath } },
      } = args;

      const cmp = writeComparator(comparator);
      const block = nodes.map(child => writeNode(child, options)).join('\n');

      // TODO: Make generic
      if (
        lhsType === 'identifier' &&
        lhsPath.length === 2 &&
        lhsPath[0] === 'parameters'
      ) {
        const parameter = lhsPath[1];
        const value =
          rhsType === 'value' ? JSON.stringify(rhsData) : '?? TODO ??';
        return `if (${parameter} ${cmp} ${value}) {\n${indent(block, 1)}\n}`;
      }

      return '';
    }

    case 'Assign': {
      const {
        lhs: {
          type: sourceType,
          value: { data: sourceData, path: sourcePath },
        },
        rhs: {
          type: targetType,
          value: { data: targetData, path: targetPath, type: targetDataType },
        },
      } = args;

      // Special case layers for now
      // TODO: Make this generic for any kind of variable
      if (targetPath.length === 3) {
        const [targetVariableName, layerName, layerAttribute] = targetPath;
        const variableName = getVariableName(layerName, layerAttribute);

        switch (sourceType) {
          case 'identifier': {
            // Special case parameters
            // TODO: Make generic
            const [sourceVariableName, sourceAttribute] = sourcePath;
            return `${variableName} = ${sourceAttribute};`;
          }
          case 'value': {
            if (
              targetDataType.named === 'Color' &&
              sourceData in options.colors
            ) {
              return `${variableName} = colors.${sourceData}`;
            }
            return `${variableName} = ${JSON.stringify(sourceData)};`;
          }
          default:
            return '';
        }
      }

      return '';
    }

    default:
      return '';
  }
}

function buildScope(logic) {
  const scope = {};

  logic.forEach(node => addDeclarationsToScope(node, scope));

  return scope;
}

function writeLogic(logic, scope, options) {
  const declarations = Object.entries(scope)
    .map(([title, attributes]) =>
      Object.keys(attributes)
        .map(
          attribute => `let ${getVariableName(title, attribute)} = undefined;`,
        )
        .join('\n'),
    )
    .join('\n');

  const statements = logic.map(node => writeNode(node, options));

  return [declarations, ...statements].join('\n\n');
}

function writeRenderFunction(rootLayer, logic, parameters, options) {
  let body = '';

  if (parameters.length > 0) {
    body += writeObjectDestructureAssignment(
      'let',
      'this.props',
      parameters.map(parameter => parameter.name),
    );
    body += '\n\n';
  }

  const scope = buildScope(logic);

  body += writeLogic(logic, scope, options);
  body += '\n\n';

  body += `return (\n${indent(writeJSXElement(rootLayer, scope, options), 1)}\n);`;

  return ['render() {', indent(body, 1), '};'].join('\n');
}

function writeComponent(component, options) {
  const { name, rootLayer, logic, parameters } = component;

  let body = '';

  // if (parameters.length > 0) {
  //   body += writePropTypes(parameters);
  //   body += '\n\n';
  // }

  if (parameters.filter(p => p.optional).length > 0) {
    body += writeDefaultProps(parameters);
    body += '\n\n';
  }

  body += writeRenderFunction(rootLayer, logic, parameters, options);

  return writeClass(name, 'React.Component', body);
}

const defaultOptions = {
  primitives: false,
  paths: {},
  colors: {},
};

module.exports = function convertComponent(inputFile, options = {}) {
  options = Object.assign({}, defaultOptions, options);

  const { paths } = options;

  const component = readComponent(inputFile);

  const importComponentReference = reference => ({
    source: path.join(paths.workspace, reference.path),
    defaultMember: reference.name,
  });

  let code = '';
  code += writeImports([
    { source: 'react', defaultMember: 'React' },
    {
      source: options.primitives ? 'react-primitives' : 'react-native',
      members: ['View', 'Text', 'Image'],
    },
    { source: 'prop-types', defaultMember: 'PropTypes' },
    { source: paths.colors, defaultMember: 'colors' },
    { source: paths.fonts, defaultMember: 'fonts' },
    ...component.references.components.map(importComponentReference),
  ]);
  code += '\n\n';

  code += writeDefaultExport(writeComponent(component, options));
  code += '\n';

  const transforms = [
    require('./transforms/inline-to-stylesheet'),
    require('./transforms/extract-assignment-in-if'),
    require('./transforms/consolidate-variable-declarations'),
    require('./transforms/required-props-always-defined'),
    require('./transforms/boolean-binary-expressions'),
    require('./transforms/replace-dead-ternary-expressions'),
    require('./transforms/replace-ternary-expressions'),
    require('./transforms/proptype-assumptions'),
    require('./transforms/remove-empty-blocks'),
    require('./transforms/remove-unused-variables'),
    require('./transforms/remove-name-annotation'),
    // // require('./transforms/inline-assets'),
  ];

  code = transform(inputFile, code, transforms, { primitives: options.primitives });
  code = prettier.format(code);

  return code;
};
