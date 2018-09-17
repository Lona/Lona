import React from "react"
import { Image, View, StyleSheet, TextStyles } from
  "@mathieudutour/react-sketchapp"

import colors from "../colors"
import textStyles from "../textStyles"

export default class LocalAsset extends React.Component {
  render() {


    return (
      <View style={[ styles.view, {} ]}>
        <Image
          style={[ styles.image, {} ]}
          source={require("../assets/icon_128x128.png")}
        >

        </Image>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: { alignSelf: "stretch" },
  image: { backgroundColor: "#D8D8D8", width: 100, height: 100 }
})