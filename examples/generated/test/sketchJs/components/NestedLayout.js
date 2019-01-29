import React from "react"
import { View, StyleSheet, TextStyles } from "react-sketchapp"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"
import LocalAsset from "../images/LocalAsset"

export default class NestedLayout extends React.Component {
  render() {


    return (
      <View style={styles.view}>
        <View style={styles.topRow}>
          <View style={styles.column1}>
            <View style={styles.view1}>
              <LocalAsset />
            </View>
            <View style={styles.view2}>
              <LocalAsset />
            </View>
            <View style={styles.view3}>
              <LocalAsset />
            </View>
          </View>
          <View style={styles.column2}>
            <View style={styles.view4}>
              <LocalAsset />
            </View>
            <View style={styles.view5}>
              <LocalAsset />
            </View>
            <View style={styles.view6}>
              <LocalAsset />
            </View>
          </View>
          <View style={styles.column3}>
            <View style={styles.view7}>
              <LocalAsset />
            </View>
            <View style={styles.view8}>
              <LocalAsset />
            </View>
            <View style={styles.view9}>
              <LocalAsset />
            </View>
          </View>
        </View>
        <View style={styles.bottomRow}>
          <View style={styles.column4}>
            <View style={styles.view10}>
              <View style={styles.localAsset10}>
                <LocalAsset />
              </View>
            </View>
            <View style={styles.view11}>
              <View style={styles.localAsset11}>
                <LocalAsset />
              </View>
            </View>
            <View style={styles.view12}>
              <View style={styles.localAsset12}>
                <LocalAsset />
              </View>
            </View>
          </View>
          <View style={styles.column5}>
            <View style={styles.view13}>
              <View style={styles.localAsset13}>
                <LocalAsset />
              </View>
            </View>
            <View style={styles.view14}>
              <View style={styles.localAsset14}>
                <LocalAsset />
              </View>
            </View>
            <View style={styles.view15}>
              <View style={styles.localAsset15}>
                <LocalAsset />
              </View>
            </View>
          </View>
          <View style={styles.column6}>
            <View style={styles.view16}>
              <View style={styles.localAsset16}>
                <LocalAsset />
              </View>
            </View>
            <View style={styles.view17}>
              <View style={styles.localAsset17}>
                <LocalAsset />
              </View>
            </View>
            <View style={styles.view18}>
              <View style={styles.localAsset18}>
                <LocalAsset />
              </View>
            </View>
          </View>
        </View>
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
  topRow: {
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  bottomRow: {
    alignItems: "flex-start",
    flex: 0,
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  column1: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 150
  },
  column2: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 150
  },
  column3: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 150
  },
  view1: {
    alignItems: "flex-start",
    backgroundColor: colors.grey50,
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 150,
    height: 150
  },
  view2: {
    alignItems: "flex-start",
    backgroundColor: "transparent",
    flexDirection: "column",
    justifyContent: "center",
    width: 150,
    height: 150
  },
  view3: {
    alignItems: "flex-start",
    backgroundColor: colors.grey50,
    flexDirection: "column",
    justifyContent: "flex-end",
    width: 150,
    height: 150
  },
  localAsset: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  localAsset2: {
    alignItems: "center",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  localAsset3: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  view4: {
    alignItems: "center",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 150,
    height: 150
  },
  view5: {
    alignItems: "center",
    backgroundColor: colors.grey50,
    flexDirection: "column",
    justifyContent: "center",
    width: 150,
    height: 150
  },
  view6: {
    alignItems: "center",
    flexDirection: "column",
    justifyContent: "flex-end",
    width: 150,
    height: 150
  },
  localAsset4: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "center"
  },
  localAsset5: {
    alignItems: "center",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "center"
  },
  localAsset6: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "center"
  },
  view7: {
    alignItems: "flex-end",
    backgroundColor: colors.grey50,
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 150,
    height: 150
  },
  view8: {
    alignItems: "flex-end",
    flexDirection: "column",
    justifyContent: "center",
    width: 150,
    height: 150
  },
  view9: {
    alignItems: "flex-end",
    backgroundColor: colors.grey50,
    flexDirection: "column",
    justifyContent: "flex-end",
    width: 150,
    height: 150
  },
  localAsset7: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "flex-end"
  },
  localAsset8: {
    alignItems: "center",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "flex-end"
  },
  localAsset9: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "flex-end"
  },
  column4: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 150
  },
  column5: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 150
  },
  column6: {
    alignItems: "flex-start",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: 150
  },
  view10: {
    alignItems: "flex-start",
    backgroundColor: colors.grey50,
    flexDirection: "row",
    justifyContent: "flex-start",
    width: 150,
    height: 150
  },
  view11: {
    alignItems: "center",
    backgroundColor: "transparent",
    flexDirection: "row",
    justifyContent: "flex-start",
    width: 150,
    height: 150
  },
  view12: {
    alignItems: "flex-end",
    backgroundColor: colors.grey50,
    flexDirection: "row",
    justifyContent: "flex-start",
    width: 150,
    height: 150
  },
  localAsset10: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  localAsset11: {
    alignItems: "center",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  localAsset12: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  view13: {
    alignItems: "flex-start",
    flexDirection: "row",
    justifyContent: "center",
    width: 150,
    height: 150
  },
  view14: {
    alignItems: "center",
    backgroundColor: colors.grey50,
    flexDirection: "row",
    justifyContent: "center",
    width: 150,
    height: 150
  },
  view15: {
    alignItems: "flex-end",
    flexDirection: "row",
    justifyContent: "center",
    width: 150,
    height: 150
  },
  localAsset13: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "center"
  },
  localAsset14: {
    alignItems: "center",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "center"
  },
  localAsset15: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "center"
  },
  view16: {
    alignItems: "flex-start",
    backgroundColor: colors.grey50,
    flexDirection: "row",
    justifyContent: "flex-end",
    width: 150,
    height: 150
  },
  view17: {
    alignItems: "center",
    flexDirection: "row",
    justifyContent: "flex-end",
    width: 150,
    height: 150
  },
  view18: {
    alignItems: "flex-end",
    backgroundColor: colors.grey50,
    flexDirection: "row",
    justifyContent: "flex-end",
    width: 150,
    height: 150
  },
  localAsset16: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "flex-end"
  },
  localAsset17: {
    alignItems: "center",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "flex-end"
  },
  localAsset18: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    flex: 1,
    flexDirection: "row",
    justifyContent: "flex-end"
  }
})