export default `
.prism-code {
  display: block;
  white-space: pre;

  background-color: transparent;
  color: #C5C8C6;

  padding: 8px;
  margin: 0;

  box-sizing: border-box;
  vertical-align: baseline;
  outline: none;
  text-shadow: none;
  hyphens: none;
  word-wrap: normal;
  word-break: normal;
  text-align: left;
  word-spacing: normal;
  tab-size: 2;
}

.token.comment,
.token.prolog,
.token.doctype,
.token.cdata {
  color: hsl(30, 20%, 50%);
}

.token.punctuation {
  opacity: .7;
}

.namespace {
  opacity: .7;
}

.token.property,
.token.tag,
.token.boolean,
.token.number,
.token.constant,
.token.symbol {
  color: #08ABEA;
}

.token.selector,
.token.attr-name {
  color: #01B490;
}

.token.string,
.token.char,
.token.builtin,
.token.inserted {
  color: #3E57AB;
}

.token.operator,
.token.entity,
.token.url,
.language-css .token.string,
.style .token.string,
.token.variable {
  color: #626262;
}

.token.atrule,
.token.attr-value,
.token.keyword {
  color: hsl(350, 40%, 70%);
}

.token.regex,
.token.important {
  color: #e90;
}

.token.important,
.token.bold {
  font-weight: bold;
}
.token.italic {
  font-style: italic;
}

.token.entity {
  cursor: help;
}

.token.deleted {
  color: red;
}
`
