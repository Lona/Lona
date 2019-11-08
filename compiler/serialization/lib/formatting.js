function indentLine(line, indent) {
  return ' '.repeat(indent) + line
}

function indentLines(lines, indent) {
  return lines.map(line => ' '.repeat(indent) + line)
}

function indentBlock(codeblock, indent) {
  return indentLines(codeblock.split('\n'), indent).join('\n')
}

function indentBlockWithFirstLinePrefix(codeblock, prefix) {
  const lines = codeblock.split('\n')
  return [
    prefix + lines[0],
    ...indentLines(lines.slice(1), prefix.length),
  ].join('\n')
}

module.exports = {
  indentLine,
  indentLines,
  indentBlock,
  indentBlockWithFirstLinePrefix,
}
