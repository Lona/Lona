import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class BorderWidthColor extends React.Component {
  render() {


    let Inner$borderColor
    let Inner$borderRadius
    let Inner$borderStyle
    let Inner$borderWidth
    Inner$borderColor = colors.blue300
    Inner$borderRadius = 10
    Inner$borderStyle = "dotted"
    Inner$borderWidth = 2

    if (this.props.alternativeStyle) {

      Inner$borderColor = colors.reda400
      Inner$borderWidth = 4
      Inner$borderRadius = 20
      Inner$borderStyle = "solid"
    }
    return (
      <View>
        <Inner
          style={{
            borderColor: Inner$borderColor,
            borderRadius: Inner$borderRadius + "px",
            borderStyle: Inner$borderStyle,
            borderWidth: Inner$borderWidth + "px"
          }}

        />
      </View>
    );
  }
};

let View = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flex: "1 1 0%",
  flexDirection: "column",
  justifyContent: "flex-start"
})

let Inner = styled.div({
  alignItems: "flex-start",
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  borderColor: colors.blue300,
  borderRadius: "10px",
  borderStyle: "dotted",
  borderWidth: "2px",
  width: "100px",
  height: "100px"
})