const jscodeshift = require('jscodeshift');

module.exports = jscodeshift.withParser('babylon');
