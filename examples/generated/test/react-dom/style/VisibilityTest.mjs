import React from "react"
import styled from "styled-components"

import colors from "../foundation/colors"
import shadows from "../foundation/shadows"
import textStyles from "../foundation/textStyles"

export default class VisibilityTest extends React.Component {
  render() {


    let Title$visible

    Title$visible = this.props.enabled
    return (
      <Container>
        {false && <Inner />}
        {Title$visible && <Title> {"Enabled"} </Title>}
        <View />
      </Container>
    );
  }
};

let Container = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Inner = styled.div({
  alignItems: "flex-start",
  backgroundColor: colors.green300,
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  width: "100px",
  height: "100px"
})

let Title = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let View = styled.div({
  alignItems: "flex-start",
  backgroundColor: colors.blue300,
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  width: "100px",
  height: "100px"
})