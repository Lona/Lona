import React from "react"
import { Text, View, StyleSheet, TextStyles } from
  "@mathieudutour/react-sketchapp"

import colors from "../colors"
import textStyles from "../textStyles"

export default class PressableRootView extends React.Component {
  render() {

    let InnerText$text
    let Inner$backgroundColor
    let Inner$hovered
    let Inner$onPress
    let Inner$pressed
    let Outer$backgroundColor
    let Outer$hovered
    let Outer$onPress
    let Outer$pressed
    Inner$backgroundColor = colors.blue500
    InnerText$text = ""
    Outer$backgroundColor = colors.grey50

    Outer$onPress = this.props.onPressOuter
    Inner$onPress = this.props.onPressInner
    if (Outer$hovered) {
      Outer$backgroundColor = colors.grey100
    }
    if (Outer$pressed) {
      Outer$backgroundColor = colors.grey300
    }
    if (Inner$hovered) {
      Inner$backgroundColor = colors.blue300
      InnerText$text = "Hovered"
    }
    if (Inner$pressed) {
      Inner$backgroundColor = colors.blue800
      InnerText$text = "Pressed"
    }
    if (Inner$hovered) {
      if (Inner$pressed) {
        InnerText$text = "Hovered & Pressed"
      }
    }
    return (
      <View
        style={[ styles.outer, { backgroundColor: Outer$backgroundColor } ]}
        onPress={Outer$onPress}
      >
        <View
          style={[ styles.inner, { backgroundColor: Inner$backgroundColor } ]}
          onPress={Inner$onPress}
        >
          <Text style={[ styles.innerText, {} ]}>
            {InnerText$text}
          </Text>
        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  outer: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    backgroundColor: colors.grey50,
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start",
    paddingTop: 24,
    paddingRight: 24,
    paddingBottom: 24,
    paddingLeft: 24
  },
  inner: {
    alignItems: "flex-start",
    backgroundColor: colors.blue500,
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 100,
    height: 100
  },
  innerText: {
    ...TextStyles.get("headline"),
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "column",
    justifyContent: "flex-start"
  }
})