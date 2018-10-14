import React from "react"
import { View, StyleSheet } from "react-native"

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
      <View style={[ styles.view, {} ]}>
        <View
          style={[
            styles.inner,
            {
              borderRadius: Inner$borderRadius,
              borderWidth: Inner$borderWidth,
              borderColor: Inner$borderColor
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
    borderRadius: 10,
    borderWidth: 20,
    borderColor: colors.blue300,
    width: 100,
    height: 100
  }
})