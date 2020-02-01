import * as serialization from '@lona/serialization'

import { Helpers } from '../../helpers'
import { convertDeclaration } from '../tokens/convert'
import { Token } from '../../types/tokens-ast'
import { nonNullable, assertNever } from '../../utils'

let tokenNameElement = (kind: string, content: string) =>
  `<span class="lona-token-name lona-token-name-${kind}">${content}</span>`

let tokenValueElement = (kind: string, content: string) =>
  `<span class="lona-token-value lona-token-value-${kind}">${content}</span>`

let tokenContainerElement = (kind: string, content: string[]) =>
  `<div class="lona-token lona-token-${kind}">
  ${content.join('\n  ')}
</div>`

let tokenDetailsElement = (kind: string, content: string[]) =>
  `<div class="lona-token-details lona-token-details-${kind}">
    ${content.join('\n    ')}
  </div>`

let tokenPreviewElement = (
  kind: string,
  data: { [key: string]: string | void }
) =>
  `<div  class="lona-token-preview lona-token-preview-${kind}" ${Object.keys(
    data
  )
    .map(k => (data[k] ? `data-${k}="${data[k]}"` : undefined))
    .filter(x => !!x)
    .join(' ')}></div>`

const convertToken = (token: Token): string => {
  const tokenName = token.qualifiedName.join('.')

  if (token.value.type === 'color') {
    return tokenContainerElement(token.value.type, [
      tokenPreviewElement(token.value.type, { color: token.value.value.css }),
      tokenDetailsElement(token.value.type, [
        tokenNameElement(token.value.type, tokenName),
        tokenValueElement(token.value.type, token.value.value.css),
      ]),
    ])
  }

  if (token.value.type === 'shadow') {
    return tokenContainerElement(token.value.type, [
      tokenPreviewElement(token.value.type, {
        x: `${token.value.value.x}`,
        y: `${token.value.value.y}`,
        blur: `${token.value.value.blur}`,
        radius: `${token.value.value.radius}`,
        color: `${token.value.value.color.css}`,
      }),
      tokenDetailsElement(token.value.type, [
        tokenNameElement(token.value.type, tokenName),
        tokenValueElement(
          token.value.type,
          `${token.value.value.x}px ${token.value.value.y}px ${token.value.value.blur}px ${token.value.value.radius}px ${token.value.value.color.css}`
        ),
      ]),
    ])
  }

  if (token.value.type === 'textStyle') {
    const { value } = token.value
    return tokenContainerElement(token.value.type, [
      tokenPreviewElement(token.value.type, {
        fontFamily: value.fontFamily,
        fontWeight: value.fontWeight,
        fontSize:
          typeof value.fontSize !== 'undefined'
            ? `${value.fontSize}`
            : undefined,
        lineHeight:
          typeof value.lineHeight !== 'undefined'
            ? `${value.lineHeight}`
            : undefined,
        letterSpacing:
          typeof value.letterSpacing !== 'undefined'
            ? `${value.letterSpacing}`
            : undefined,
        color: value.color ? `${value.color.css}` : undefined,
      }),
      tokenDetailsElement(token.value.type, [
        tokenNameElement(token.value.type, tokenName),
        tokenValueElement(
          token.value.type,
          `${value.fontFamily} ${value.fontWeight}${
            typeof value.fontSize !== 'undefined' ? ` ${value.fontSize}px` : ''
          }${
            typeof value.lineHeight !== 'undefined'
              ? ` ${value.lineHeight}px`
              : ''
          }${
            typeof value.letterSpacing !== 'undefined'
              ? ` ${value.letterSpacing}px`
              : ''
          }${value.color ? ` ${value.color.css}` : ''}`
        ),
      ]),
    ])
  }

  assertNever(token.value)
}

export const convert = (
  root: { children: serialization.MDXAST.Content[] },
  helpers: Helpers
) => {
  return root.children
    .map(child => {
      if (child.type === 'code' && child.data.parsed) {
        return child.data.parsed.data.declarations
          .map(x => convertDeclaration(x, helpers))
          .filter(nonNullable)
          .map(convertToken)
          .join('')
      }
      return serialization.printMdxNode(child)
    })
    .join('\n\n')
}
