import React from 'react'

let id = 0
const nextId = () => ++id // eslint-disable-line

export default function displayName(Component: React.ComponentType) {
  return Component.displayName || Component.name || `UnknownSymbol${nextId()}`
}
