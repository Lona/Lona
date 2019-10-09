# Lona Serialization

Convert Lona files between XML, JSON, and source code (Swift + MDX).

## Overview

Lona token files are typically stored as [MDX](https://mdxjs.com/) (Markdown with embedded React components).

Token files support a special kind of code block, marked with the language "tokens", that contains Lona token definitions. These definitions can be stored as XML, JSON, or (a small subset of) Swift. This utility converts between the different formats.

### API

#### `convertDocument: (String, Format) -> String`

Supported formats: `'json'`, `'source'`

Example: Convert a `.md` document to JSON

```js
import serialization from '@lona/serialization'

const lonaDocument = '...' // source code of a Lona document

const lonaXml = serialization.convertDocument(lonaDocument, 'json')
```

#### `convertLogic: (String, Format) -> String`

Supported formats: `'json'`, `'xml'`, `'source'`

Example: Convert a `.tokens` file to JSON

```js
import serialization from '@lona/serialization'

const lonaTokens = '...' // source code of a Lona tokens file

const lonaXml = serialization.convertDocument(lonaDocument, 'json')
```
