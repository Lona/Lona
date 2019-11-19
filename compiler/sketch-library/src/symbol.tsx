import React from 'react'
import { makeSymbol, getSymbolMasterByName } from 'react-sketchapp/lib/symbol'

import displayName from './display-name'

export default function createSymbol(
  Component: React.ComponentType,
  props: { [name: string]: any },
  name?: string,
  symbolStyle: { width?: number } = {}
) {
  const componentName = displayName(Component)
  const masterName = name ? `${componentName}/${name}` : componentName

  makeSymbol(
    () => <Component {...props} />,
    { name: masterName, style: symbolStyle },
    undefined
  )

  return getSymbolMasterByName(masterName)
}
