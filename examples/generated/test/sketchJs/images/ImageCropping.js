import React from "react"
import { Image, View, StyleSheet, TextStyles } from
  "@mathieudutour/react-sketchapp"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"

export default class ImageCropping extends React.Component {
  render() {


    return (
      <View style={styles.view}>
        <View style={styles.aspectFit}>
          <Image
            style={{
              width: "100%",
              height: "100%",
              resizeMode: "contain",
              position: "absolute"
            }}
            source={require("../assets/icon_128x128.png")}

          />
        </View>
        <View style={styles.aspectFill}>
          <Image
            style={{
              width: "100%",
              height: "100%",
              resizeMode: "cover",
              position: "absolute"
            }}
            source={require("../assets/icon_128x128.png")}

          />
        </View>
        <View style={styles.stretchFill}>
          <Image
            style={{
              width: "100%",
              height: "100%",
              resizeMode: "stretch",
              position: "absolute"
            }}
            source={require("../assets/icon_128x128.png")}

          />
        </View>
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
    height: 100
  },
  aspectFill: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flexDirection: "column",
    justifyContent: "flex-start",
    height: 100
  },
  stretchFill: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flexDirection: "column",
    justifyContent: "flex-start",
    height: 100
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
    resizeMode: "stretch"
  }
})