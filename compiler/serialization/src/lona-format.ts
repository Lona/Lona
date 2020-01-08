export enum SERIALIZATION_FORMAT {
  JSON = 'json',
  XML = 'xml',
  SOURCE = 'source',
}

export function detectFormat(contents: string) {
  if (contents.startsWith('{') || contents.startsWith('[')) {
    return SERIALIZATION_FORMAT.JSON
  }
  if (contents.startsWith('<')) {
    return SERIALIZATION_FORMAT.XML
  }
  return SERIALIZATION_FORMAT.SOURCE
}

export function normalizeFormat(
  contents: string,
  sourceFormat?: SERIALIZATION_FORMAT
) {
  const normalized = sourceFormat || detectFormat(contents)

  if (!Object.values(SERIALIZATION_FORMAT).includes(normalized)) {
    throw new Error(
      `Invalid source serialization format specified: ${normalized}`
    )
  }

  return normalized
}
