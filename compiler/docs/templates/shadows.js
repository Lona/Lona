import React from 'react'
import Layout from '../src/components/Layout'

export default function Template({ pageContext: { shadows }, location }) {
  return (
    <Layout location={location}>
      <div
        dangerouslySetInnerHTML={{
          __html: JSON.stringify(shadows, null, '  '),
        }}
      />
    </Layout>
  )
}
