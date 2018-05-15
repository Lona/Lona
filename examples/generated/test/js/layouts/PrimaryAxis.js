import { Text, View } from "react-native"

import colors from "../../colors"
import textStyles from "../../textStyles"

class PrimaryAxis extends React.Component {
  render() {
    return (
      <View style={[ styles.View, {} ]}>
        <View style={[ styles.Fixed, {} ]} backgroundColor={"#D8D8D8"}>

        </View>
        <View style={[ styles.Fit, {} ]} backgroundColor={"#D8D8D8"}>
          <Text style={[ styles.Text, {} ]} text={"Text goes here"}>

          </Text>
        </View>
        <View style={[ styles.Fill1, {} ]} backgroundColor={"cyan500"}>

        </View>
        <View style={[ styles.Fill2, {} ]} backgroundColor={"blue500"}>

        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  View: {
    alignSelf: "stretch",
    height: 500,
    paddingBottom: 24,
    paddingLeft: 24,
    paddingRight: 24,
    paddingTop: 24
  },
  Fixed: { height: 100, marginBottom: 24, width: 100 },
  Fit: { marginBottom: 24, width: 100 },
  Text: {},
  Fill1: { flex: 1, width: 100 },
  Fill2: { flex: 1, width: 100 }
});