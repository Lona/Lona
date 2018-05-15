import { Text, View } from "react-native"

import colors from "../../colors"
import textStyles from "../../textStyles"

class TextStylesTest extends React.Component {
  render() {
    return (
      <View style={[ styles.view, {} ]}>
        <Text style={[ styles.text, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.text1, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.text2, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.text3, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.text4, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.text5, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.text6, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.text7, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.text8, {} ]} text={"Text goes here"}>

        </Text>
        <Text style={[ styles.text9, {} ]} text={"Text goes here"}>

        </Text>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  view: { alignSelf: "stretch" },
  text: { font: "display4" },
  text1: { font: "display3" },
  text2: { font: "display2" },
  text3: { font: "display1" },
  text4: { font: "headline" },
  text5: { font: "subheading2" },
  text6: { font: "subheading1" },
  text7: { font: "body2" },
  text8: { font: "body1" },
  text9: { font: "caption" }
});