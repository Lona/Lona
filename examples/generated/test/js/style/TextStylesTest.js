class TextStylesTest extends React.Component {
  render() {
    return (
      <View style={[ styles.View, {} ]}>
        <Text style={[ styles.Text, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.Text 1, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.Text 2, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.Text 3, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.Text 4, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.Text 5, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.Text 6, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.Text 7, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.Text 8, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.Text 9, {} ]} text={"Text goes here"}>

        </Text>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  View: { alignSelf: "stretch" },
  Text: { font: "display4" },
  Text 1: { font: "display3" },
  Text 2: { font: "display2" },
  Text 3: { font: "display1" },
  Text 4: { font: "headline" },
  Text 5: { font: "subheading2" },
  Text 6: { font: "subheading1" },
  Text 7: { font: "body2" },
  Text 8: { font: "body1" },
  Text 9: { font: "caption" }
});