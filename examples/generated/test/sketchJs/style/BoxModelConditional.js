import React from "react"
import { View, StyleSheet, TextStyles } from "@mathieudutour/react-sketchapp"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class BoxModelConditional extends React.Component {
  render() {

    let Inner$height
    let Inner$marginBottom
    let Inner$marginLeft
    let Inner$marginRight
    let Inner$marginTop
    let Inner$width

    Inner$marginTop = this.props.margin
    Inner$marginRight = this.props.margin
    Inner$marginBottom = this.props.margin
    Inner$marginLeft = this.props.margin
    Inner$height = this.props.size
    Inner$width = this.props.size
    return (
      <View style={styles.outer}>
        <View
          style={[
            styles.inner,
            {
              marginTop: Inner$marginTop,
              marginRight: Inner$marginRight,
              marginBottom: Inner$marginBottom,
              marginLeft: Inner$marginLeft,
              width: Inner$width,
              height: Inner$height
            }
          ]}

        />
      </View>
    );
  }
};

let styles = StyleSheet.create({
  outer: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingTop: 4,
    paddingRight: 4,
    paddingBottom: 4,
    paddingLeft: 4
  },
  inner: {
    alignItems: "flex-start",
    backgroundColor: "#D8D8D8",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 60,
    height: 60
  }
})