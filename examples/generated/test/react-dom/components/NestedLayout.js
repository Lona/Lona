import React from "react"
import styled, { ThemeProvider } from "styled-components"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"
import LocalAsset from "../images/LocalAsset"

export default class NestedLayout extends React.Component {
  render() {


    let theme = {
      "view": { "normal": {} },
      "topRow": { "normal": {} },
      "column1": { "normal": {} },
      "view1": { "normal": {} },
      "localAsset": { "normal": {} },
      "view2": { "normal": {} },
      "localAsset2": { "normal": {} },
      "view3": { "normal": {} },
      "localAsset3": { "normal": {} },
      "column2": { "normal": {} },
      "view4": { "normal": {} },
      "localAsset4": { "normal": {} },
      "view5": { "normal": {} },
      "localAsset5": { "normal": {} },
      "view6": { "normal": {} },
      "localAsset6": { "normal": {} },
      "column3": { "normal": {} },
      "view7": { "normal": {} },
      "localAsset7": { "normal": {} },
      "view8": { "normal": {} },
      "localAsset8": { "normal": {} },
      "view9": { "normal": {} },
      "localAsset9": { "normal": {} },
      "bottomRow": { "normal": {} },
      "column4": { "normal": {} },
      "view10": { "normal": {} },
      "localAsset10": { "normal": {} },
      "view11": { "normal": {} },
      "localAsset11": { "normal": {} },
      "view12": { "normal": {} },
      "localAsset12": { "normal": {} },
      "column5": { "normal": {} },
      "view13": { "normal": {} },
      "localAsset13": { "normal": {} },
      "view14": { "normal": {} },
      "localAsset14": { "normal": {} },
      "view15": { "normal": {} },
      "localAsset15": { "normal": {} },
      "column6": { "normal": {} },
      "view16": { "normal": {} },
      "localAsset16": { "normal": {} },
      "view17": { "normal": {} },
      "localAsset17": { "normal": {} },
      "view18": { "normal": {} },
      "localAsset18": { "normal": {} }
    }
    return (
      <ThemeProvider theme={theme}>
        <div style={Object.assign({}, styles.view, {})}>
          <div style={Object.assign({}, styles.topRow, {})}>
            <div style={Object.assign({}, styles.column1, {})}>
              <div style={Object.assign({}, styles.view1, {})}>
                <div style={Object.assign({}, styles.localAsset, {})}>
                  <LocalAsset />
                </div>
              </div>
              <div style={Object.assign({}, styles.view2, {})}>
                <div style={Object.assign({}, styles.localAsset2, {})}>
                  <LocalAsset />
                </div>
              </div>
              <div style={Object.assign({}, styles.view3, {})}>
                <div style={Object.assign({}, styles.localAsset3, {})}>
                  <LocalAsset />
                </div>
              </div>
            </div>
            <div style={Object.assign({}, styles.column2, {})}>
              <div style={Object.assign({}, styles.view4, {})}>
                <div style={Object.assign({}, styles.localAsset4, {})}>
                  <LocalAsset />
                </div>
              </div>
              <div style={Object.assign({}, styles.view5, {})}>
                <div style={Object.assign({}, styles.localAsset5, {})}>
                  <LocalAsset />
                </div>
              </div>
              <div style={Object.assign({}, styles.view6, {})}>
                <div style={Object.assign({}, styles.localAsset6, {})}>
                  <LocalAsset />
                </div>
              </div>
            </div>
            <div style={Object.assign({}, styles.column3, {})}>
              <div style={Object.assign({}, styles.view7, {})}>
                <div style={Object.assign({}, styles.localAsset7, {})}>
                  <LocalAsset />
                </div>
              </div>
              <div style={Object.assign({}, styles.view8, {})}>
                <div style={Object.assign({}, styles.localAsset8, {})}>
                  <LocalAsset />
                </div>
              </div>
              <div style={Object.assign({}, styles.view9, {})}>
                <div style={Object.assign({}, styles.localAsset9, {})}>
                  <LocalAsset />
                </div>
              </div>
            </div>
          </div>
          <div style={Object.assign({}, styles.bottomRow, {})}>
            <div style={Object.assign({}, styles.column4, {})}>
              <div style={Object.assign({}, styles.view10, {})}>
                <LocalAsset />
              </div>
              <div style={Object.assign({}, styles.view11, {})}>
                <LocalAsset />
              </div>
              <div style={Object.assign({}, styles.view12, {})}>
                <LocalAsset />
              </div>
            </div>
            <div style={Object.assign({}, styles.column5, {})}>
              <div style={Object.assign({}, styles.view13, {})}>
                <LocalAsset />
              </div>
              <div style={Object.assign({}, styles.view14, {})}>
                <LocalAsset />
              </div>
              <div style={Object.assign({}, styles.view15, {})}>
                <LocalAsset />
              </div>
            </div>
            <div style={Object.assign({}, styles.column6, {})}>
              <div style={Object.assign({}, styles.view16, {})}>
                <LocalAsset />
              </div>
              <div style={Object.assign({}, styles.view17, {})}>
                <LocalAsset />
              </div>
              <div style={Object.assign({}, styles.view18, {})}>
                <LocalAsset />
              </div>
            </div>
          </div>
        </div>
      </ThemeProvider>
    );
  }
};

let styles = {
  view: {
    alignItems: "flex-start",
    display: "flex",
    flex: "1 1 0%",
    flexDirection: "column",
    justifyContent: "flex-start"
  },
  topRow: {
    alignItems: "flex-start",
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  bottomRow: {
    alignItems: "flex-start",
    display: "flex",
    flex: "0 0 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  column1: {
    alignItems: "flex-start",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "150px"
  },
  column2: {
    alignItems: "flex-start",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "150px"
  },
  column3: {
    alignItems: "flex-start",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "150px"
  },
  view1: {
    alignItems: "flex-start",
    backgroundColor: colors.grey50,
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "150px",
    height: "150px"
  },
  view2: {
    alignItems: "flex-start",
    backgroundColor: "transparent",
    display: "flex",
    flexDirection: "column",
    justifyContent: "center",
    width: "150px",
    height: "150px"
  },
  view3: {
    alignItems: "flex-start",
    backgroundColor: colors.grey50,
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-end",
    width: "150px",
    height: "150px"
  },
  localAsset: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  localAsset2: {
    alignItems: "center",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  localAsset3: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  view4: {
    alignItems: "center",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "150px",
    height: "150px"
  },
  view5: {
    alignItems: "center",
    backgroundColor: colors.grey50,
    display: "flex",
    flexDirection: "column",
    justifyContent: "center",
    width: "150px",
    height: "150px"
  },
  view6: {
    alignItems: "center",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-end",
    width: "150px",
    height: "150px"
  },
  localAsset4: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "center"
  },
  localAsset5: {
    alignItems: "center",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "center"
  },
  localAsset6: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "center"
  },
  view7: {
    alignItems: "flex-end",
    backgroundColor: colors.grey50,
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "150px",
    height: "150px"
  },
  view8: {
    alignItems: "flex-end",
    display: "flex",
    flexDirection: "column",
    justifyContent: "center",
    width: "150px",
    height: "150px"
  },
  view9: {
    alignItems: "flex-end",
    backgroundColor: colors.grey50,
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-end",
    width: "150px",
    height: "150px"
  },
  localAsset7: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-end"
  },
  localAsset8: {
    alignItems: "center",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-end"
  },
  localAsset9: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-end"
  },
  column4: {
    alignItems: "flex-start",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "150px"
  },
  column5: {
    alignItems: "flex-start",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "150px"
  },
  column6: {
    alignItems: "flex-start",
    display: "flex",
    flexDirection: "column",
    justifyContent: "flex-start",
    width: "150px"
  },
  view10: {
    alignItems: "flex-start",
    backgroundColor: colors.grey50,
    display: "flex",
    flexDirection: "row",
    justifyContent: "flex-start",
    width: "150px",
    height: "150px"
  },
  view11: {
    alignItems: "center",
    backgroundColor: "transparent",
    display: "flex",
    flexDirection: "row",
    justifyContent: "flex-start",
    width: "150px",
    height: "150px"
  },
  view12: {
    alignItems: "flex-end",
    backgroundColor: colors.grey50,
    display: "flex",
    flexDirection: "row",
    justifyContent: "flex-start",
    width: "150px",
    height: "150px"
  },
  localAsset10: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  localAsset11: {
    alignItems: "center",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  localAsset12: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-start"
  },
  view13: {
    alignItems: "flex-start",
    display: "flex",
    flexDirection: "row",
    justifyContent: "center",
    width: "150px",
    height: "150px"
  },
  view14: {
    alignItems: "center",
    backgroundColor: colors.grey50,
    display: "flex",
    flexDirection: "row",
    justifyContent: "center",
    width: "150px",
    height: "150px"
  },
  view15: {
    alignItems: "flex-end",
    display: "flex",
    flexDirection: "row",
    justifyContent: "center",
    width: "150px",
    height: "150px"
  },
  localAsset13: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "center"
  },
  localAsset14: {
    alignItems: "center",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "center"
  },
  localAsset15: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "center"
  },
  view16: {
    alignItems: "flex-start",
    backgroundColor: colors.grey50,
    display: "flex",
    flexDirection: "row",
    justifyContent: "flex-end",
    width: "150px",
    height: "150px"
  },
  view17: {
    alignItems: "center",
    display: "flex",
    flexDirection: "row",
    justifyContent: "flex-end",
    width: "150px",
    height: "150px"
  },
  view18: {
    alignItems: "flex-end",
    backgroundColor: colors.grey50,
    display: "flex",
    flexDirection: "row",
    justifyContent: "flex-end",
    width: "150px",
    height: "150px"
  },
  localAsset16: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-end"
  },
  localAsset17: {
    alignItems: "center",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-end"
  },
  localAsset18: {
    alignItems: "flex-end",
    alignSelf: "stretch",
    display: "flex",
    flex: "1 1 auto",
    flexDirection: "row",
    justifyContent: "flex-end"
  }
}