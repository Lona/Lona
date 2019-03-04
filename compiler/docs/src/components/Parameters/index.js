import React from 'react'
import PropTypes from 'prop-types'
import styled from 'styled-components'

import SectionHeader from '../../../lona-workspace/components/SectionHeader.component'
import Ghost from '../../../lona-workspace/components/Ghost.component'
import H3 from '../../../lona-workspace/components/markdown/H3.component'
import Code from '../../../lona-workspace/components/markdown/Code.component'
import P from '../../../lona-workspace/components/markdown/P.component'

const Table = styled.table`
  width: 100%;

  tr {
    border-bottom: 1px solid #e7e7e7;
  }

  td {
    padding: 25px 16px;
  }

  thead {
    text-transform: uppercase;
    border-top: 1px solid #e7e7e7;

    th {
      padding: 18px 16px 7px;
    }
  }
`

function Parameters({ parameters }) {
  if (!parameters.length) {
    return null
  }
  return (
    <div>
      <H3 text="Parameters" />
      <Table>
        <colgroup>
          <col span="1" style={{ width: '12.5%' }} />
          <col span="1" style={{ width: '12.5%' }} />
          <col span="1" style={{ width: '62.5%' }} />
          <col span="1" style={{ width: '12.5%' }} />
        </colgroup>

        <thead>
          <tr>
            <th>
              <SectionHeader text="Name" />
            </th>
            <th>
              <SectionHeader text="Type" />
            </th>
            <th>
              <SectionHeader text="Decription" />
            </th>
            <th>
              <SectionHeader text="Default" />
            </th>
          </tr>
        </thead>
        <tbody>
          {parameters.map(param => {
            return (
              <tr key={param.name}>
                <td>
                  <Code text={param.name} />
                </td>
                <td>
                  <Code text={param.type} highlighted />
                </td>
                <td>
                  {param.description ? (
                    <P text={param.description} />
                  ) : (
                    <Ghost text="No description" />
                  )}
                </td>
                <td>
                  {param.defaultValue ? (
                    <P text={param.defaultValue} />
                  ) : (
                    <Ghost text="No default" />
                  )}
                </td>
              </tr>
            )
          })}
        </tbody>
      </Table>
    </div>
  )
}

Parameters.propTypes = {
  parameters: PropTypes.arrayOf(
    PropTypes.shape({
      name: PropTypes.string,
      description: PropTypes.string,
      type: PropTypes.string,
      defaultValue: PropTypes.any, // eslint-disable-line react/forbid-prop-types
    })
  ).isRequired,
}

export default Parameters
