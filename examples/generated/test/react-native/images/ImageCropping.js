import React from "react"
import { Image, View, StyleSheet } from "react-native"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class ImageCropping extends React.Component {
  render() {


    return (
      <View style={styles.view}>
        <Image
          style={styles.aspectFit}
          source={require("../assets/icon_128x128.png")}

        />
        <Image
          style={styles.aspectFill}
          source={require("../assets/icon_128x128.png")}

        />
        <Image
          style={styles.stretchFill}
          source={require("../assets/icon_128x128.png")}

        />
        <Image
          style={styles.fixedAspectFill}
          source={require("../assets/icon_128x128.png")}

        />
        <Image
          style={styles.fixedStretch}
          source={require("../assets/icon_128x128.png")}

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
  aspectFit: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flexDirection: "column",
    justifyContent: "flex-start",
    height: 100,
    resizeMode: "contain"
  },
  aspectFill: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flexDirection: "column",
    justifyContent: "flex-start",
    height: 100,
    resizeMode: "cover"
  },
  stretchFill: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flexDirection: "column",
    justifyContent: "flex-start",
    height: 100,
    resizeMode: "fill"
  },
  fixedAspectFill: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 200,
    height: 100,
    resizeMode: "cover"
  },
  fixedStretch: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 200,
    height: 100,
    resizeMode: "fill"
  }
})