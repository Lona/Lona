import React from "react"
import { View, StyleSheet } from "react-native"

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
    Inner$borderStyle = "dashed"
    Inner$borderWidth = 20

    if (this.props.alternativeStyle) {

      Inner$borderColor = colors.reda400
      Inner$borderWidth = 4
      Inner$borderRadius = 20
      Inner$borderStyle = "solid"
    }
    return (
      <View style={styles.view}>
        <View
          style={[
            styles.inner,
            {
              borderColor: Inner$borderColor,
              borderRadius: Inner$borderRadius,
              borderStyle: Inner$borderStyle,
              borderWidth: Inner$borderWidth
            }
          ]}

        />
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  inner: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    borderColor: colors.blue300,
    borderRadius: 10,
    borderStyle: "dashed",
    borderWidth: 20,
    width: 100,
    height: 100
  }
})