import React from "react"

import colors from "../colors"
import shadows from "../shadows"
import textStyles from "../textStyles"
import LocalAsset from "../images/LocalAsset"

export default class NestedLayout extends React.Component {
  render() {


    return (
      <div style={styles.view}>
        <div style={styles.topRow}>
          <div style={styles.column1}>
            <div style={styles.view1}>
              <div style={styles.localAsset}>
                <LocalAsset />
              </div>
            </div>
            <div style={styles.view2}>
              <div style={styles.localAsset2}>
                <LocalAsset />
              </div>
            </div>
            <div style={styles.view3}>
              <div style={styles.localAsset3}>
                <LocalAsset />
              </div>
            </div>
          </div>
          <div style={styles.column2}>
            <div style={styles.view4}>
              <div style={styles.localAsset4}>
                <LocalAsset />
              </div>
            </div>
            <div style={styles.view5}>
              <div style={styles.localAsset5}>
                <LocalAsset />
              </div>
            </div>
            <div style={styles.view6}>
              <div style={styles.localAsset6}>
                <LocalAsset />
              </div>
            </div>
          </div>
          <div style={styles.column3}>
            <div style={styles.view7}>
              <div style={styles.localAsset7}>
                <LocalAsset />
              </div>
            </div>
            <div style={styles.view8}>
              <div style={styles.localAsset8}>
                <LocalAsset />
              </div>
            </div>
            <div style={styles.view9}>
              <div style={styles.localAsset9}>
                <LocalAsset />
              </div>
            </div>
          </div>
        </div>
        <div style={styles.bottomRow}>
          <div style={styles.column4}>
            <div style={styles.view10}>
              <LocalAsset />
            </div>
            <div style={styles.view11}>
              <LocalAsset />
            </div>
            <div style={styles.view12}>
              <LocalAsset />
            </div>
          </div>
          <div style={styles.column5}>
            <div style={styles.view13}>
              <LocalAsset />
            </div>
            <div style={styles.view14}>
              <LocalAsset />
            </div>
            <div style={styles.view15}>
              <LocalAsset />
            </div>
          </div>
          <div style={styles.column6}>
            <div style={styles.view16}>
              <LocalAsset />
            </div>
            <div style={styles.view17}>
              <LocalAsset />
            </div>
            <div style={styles.view18}>
              <LocalAsset />
            </div>
          </div>
        </div>
      </div>
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