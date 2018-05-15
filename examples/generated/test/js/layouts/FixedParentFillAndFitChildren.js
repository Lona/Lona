import { View } from "react-native"

import colors from "../../colors"
import textStyles from "../../textStyles"

class FixedParentFillAndFitChildren extends React.Component {
  render() {
    return (
      <View style={[ styles.View, {} ]}>
        <View style={[ styles.View 1, {} ]} backgroundColor={"red50"}>
          <View style={[ styles.View 4, {} ]} backgroundColor={"red200"}>

          </View>
          <View style={[ styles.View 5, {} ]} backgroundColor={"deeporange200"}>

          </View>
        </View>
        <View style={[ styles.View 2, {} ]} backgroundColor={"indigo100"}>

        </View>
        <View style={[ styles.View 3, {} ]} backgroundColor={"teal100"}>

        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  View: {
    alignSelf: "stretch",
    height: 600,
    paddingBottom: 24,
    paddingLeft: 24,
    paddingRight: 24,
    paddingTop: 24
  },
  View 1: {
    alignSelf: "stretch",
    flexDirection: "row",
    paddingBottom: 24,
    paddingLeft: 24,
    paddingRight: 24,
    paddingTop: 24
  },
  View 4: { height: 100, width: 60 },
  View 5: { height: 60, marginLeft: 12, width: 60 },
  View 2: { alignSelf: "stretch", flex: 1 },
  View 3: { alignSelf: "stretch", flex: 1 }
});