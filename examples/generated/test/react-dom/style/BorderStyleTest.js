// Compiled by Lona Version 0.5.2

import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class BorderStyleTest extends React.Component {
  render() {


    let customBorderStyle
    let Inner$borderStyle
    let Other$borderStyle
    let View$borderStyle
    Inner$borderStyle = ""
    View$borderStyle = "dashed"

    if (this.props.showDottedBorder) {

      Inner$borderStyle = "dotted"
    }
    if (this.props.customBorderStyle != null) {

      let customBorderStyle = this.props.customBorderStyle

      View$borderStyle = customBorderStyle
    }
    Other$borderStyle = this.props.requiredBorderStyle
    return (
      <View style={{ borderStyle: View$borderStyle }}>
        <Inner style={{ borderStyle: Inner$borderStyle }} />
        <Other style={{ borderStyle: Other$borderStyle }} />
      </View>
    );
  }
};

let View = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "row",
  justifyContent: "flex-start",
  borderColor: colors.greena700,
  borderStyle: "dashed",
  borderWidth: "2px"
})

let Inner = styled.div({
  alignItems: "flex-start",
  backgroundColor: colors.blue50,
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  borderColor: colors.bluea700,
  borderStyle: "solid",
  borderWidth: "10px",
  width: "100px",
  height: "100px"
})

let Other = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  borderColor: colors.reda700,
  borderStyle: "dotted",
  borderWidth: "4px",
  width: "100px",
  height: "100px"
})