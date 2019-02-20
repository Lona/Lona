// Compiled by Lona Version 0.5.2

import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class FixedParentFitChild extends React.Component {
  render() {



    return <View> <View1> <View4 /> <View5 /> </View1> </View>;
  }
};

let View = styled.div({
  alignItems: "flex-start",
  backgroundColor: colors.bluegrey100,
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start",
  paddingTop: "24px",
  paddingRight: "24px",
  paddingBottom: "24px",
  paddingLeft: "24px",
  height: "600px"
})

let View1 = styled.div({
  alignItems: "flex-start",
  alignSelf: "stretch",
  backgroundColor: colors.red50,
  display: "flex",
  flex: "0 0 auto",
  flexDirection: "row",
  justifyContent: "flex-start",
  paddingTop: "24px",
  paddingRight: "24px",
  paddingBottom: "24px",
  paddingLeft: "24px"
})

let View4 = styled.div({
  alignItems: "flex-start",
  backgroundColor: colors.red200,
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  width: "60px",
  height: "100px"
})

let View5 = styled.div({
  alignItems: "flex-start",
  backgroundColor: colors.deeporange200,
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  marginLeft: "12px",
  width: "60px",
  height: "60px"
})