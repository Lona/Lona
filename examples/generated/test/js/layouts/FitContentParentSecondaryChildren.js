class FitContentParentSecondaryChildren extends React.Component {
  render() {
    return (
      <View style={[ styles.Container, {} ]} backgroundColor={"bluegrey50"}>
        <View style={[ styles.View 1, {} ]} backgroundColor={"blue500"}>

        </View>
        <View style={[ styles.View 3, {} ]} backgroundColor={"lightblue500"}>

        </View>
        <View style={[ styles.View 2, {} ]} backgroundColor={"cyan500"}>

        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  Container: {
    alignSelf: "stretch",
    flex: 0,
    flexDirection: "row",
    paddingBottom: 24,
    paddingLeft: 24,
    paddingRight: 24,
    paddingTop: 24
  },
  View 1: { height: 60, width: 60 },
  View 3: { height: 120, width: 100 },
  View 2: { height: 180, width: 100 }
});