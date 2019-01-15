import React from "react"
import styled from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class BorderWidthColor extends React.Component {
  render() {


    let Inner$borderColor
    let Inner$borderRadius
    let Inner$borderWidth
    Inner$borderRadius = 10
    Inner$borderWidth = 20
    Inner$borderColor = colors.blue300

    if (this.props.alternativeStyle) {

      Inner$borderColor = colors.reda400
      Inner$borderWidth = 4
      Inner$borderRadius = 20
    }
    return (
      <View>
        <Inner
          style={{
            borderRadius: Inner$borderRadius + "px",
            borderWidth: Inner$borderWidth + "px",
            borderColor: Inner$borderColor
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
  borderRadius: "10px",
  borderWidth: "20px",
  borderColor: colors.blue300,
  width: "100px",
  height: "100px"
})