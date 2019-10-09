# Lona Serialization

Convert Lona files between XML, JSON, and source code (Swift + MDX).

## Overview

Lona token files are typically stored as [MDX](https://mdxjs.com/) (Markdown with embedded React components).

Token files support a special kind of code block, marked with the language "tokens", that contains Lona token definitions. These definitions can be stored as XML, JSON, or (a small subset of) Swift. This utility converts between the different formats.

### API

Supported formats: `'xml'`, `'json'`, `'source'`

#### `convertDocument: (String, Format) -> String`

Example: Convert a document to XML

```js
import serialization from '@lona/serialization'

const lonaDocument = '...' // XML, JSON, or source code of a Lona file

const lonaXml = serialization.convertDocument(lonaDocument, 'xml')
```
