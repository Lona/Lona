import pegjs from 'pegjs'
import fs from 'fs'
import path from 'path'

const grammar = fs.readFileSync(
  path.resolve(__dirname, 'logic.swift.pegjs'),
  'utf8'
)
const parser = pegjs.generate(grammar, {
  allowedStartRules: [
    'topLevelDeclarations',
    'program',
    'statement',
    'declaration',
    'expression',
  ],
})

export default parser
