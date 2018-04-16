class NestedComponent extends React.Component {
  render() {
    return (
      <View style={[ styles.View, {} ]}>
        <Text style={[ styles.Text, {} ]} text={"Example nested component"}>

        </Text>
        <FitContentParentSecondaryChildren
          style={[ styles.FitContentParentSecondaryChildren, {} ]}
        >

        </FitContentParentSecondaryChildren>
        <Text style={[ styles.Text 1, {} ]} text={"Text below"}>

        </Text>
        <LocalAsset style={[ styles.LocalAsset, {} ]}>

        </LocalAsset>
        <Text style={[ styles.Text 2, {} ]} text={"Very bottom"}>

        </Text>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  View: {
    alignSelf: "stretch",
    paddingBottom: 10,
    paddingLeft: 10,
    paddingRight: 10,
    paddingTop: 10
  },
  Text: { font: "subheading2", marginBottom: 8 },
  FitContentParentSecondaryChildren: {},
  Text 1: { marginTop: 12 },
  LocalAsset: {},
  Text 2: {}
});