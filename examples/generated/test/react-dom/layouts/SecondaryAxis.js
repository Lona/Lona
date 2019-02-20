// Compiled by Lona Version 0.5.2

import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class SecondaryAxis extends React.Component {
  render() {



    return (
      <Container>
        <Fixed />
        <Fit>
          <Text>
            {"Text goes here"}
          </Text>
        </Fit>
        <Fill />
      </Container>
    );
  }
};

let Container = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start",
  paddingTop: "24px",
  paddingRight: "24px",
  paddingBottom: "24px",
  paddingLeft: "24px"
})

let Fixed = styled.div({
  alignItems: "flex-start",
  backgroundColor: "#D8D8D8",
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  marginBottom: "24px",
  width: "100px",
  height: "100px"
})

let Fit = styled.div({
  alignItems: "flex-start",
  backgroundColor: "#D8D8D8",
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  marginBottom: "24px",
  paddingTop: "12px",
  paddingRight: "12px",
  paddingBottom: "12px",
  paddingLeft: "12px",
  height: "100px"
})

let Text = styled.span({
  textAlign: "left",
  ...textStyles.body1,
  alignItems: "flex-start",
  display: "block",
  flex: "0 0 auto",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Fill = styled.div({
  alignItems: "flex-start",
  alignSelf: "stretch",
  backgroundColor: "#D8D8D8",
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  height: "100px"
})