import { Text, Image, View } from "react-native"

import colors from "../../colors"
import textStyles from "../../textStyles"

class TextAlignment extends React.Component {
  render() {
    return (
      <View style={[ styles.View, {} ]}>
        <View style={[ styles.View 1, {} ]} backgroundColor={"indigo50"}>
          <Image
            style={[ styles.Image, {} ]}
            image={"file://./assets/icon_128x128.png"}
          >

          </Image>
          <View style={[ styles.View 2, {} ]} backgroundColor={"#D8D8D8"}>

          </View>
          <Text style={[ styles.Text, {} ]} text={"Welcome to Lona Studio"}>

          </Text>
          <Text style={[ styles.Text 1, {} ]} text={"Centered - Width: Fit"}>

          </Text>
          <Text
            style={[ styles.Text 2, {} ]}
            text={"Left aligned - Width: Fill"}
          >

          </Text>
          <Text
            style={[ styles.Text 3, {} ]}
            text={"Right aligned - Width: Fill"}
          >

          </Text>
          <Text style={[ styles.Text 4, {} ]} text={"Centered - Width: 80"}>

          </Text>
        </View>
        <View style={[ styles.View 3, {} ]} backgroundColor={"#D8D8D8"}>
          <Text
            style={[ styles.Text 5, {} ]}
            text={"Left aligned text, Fit w/ secondary centering"}
          >

          </Text>
        </View>
        <View style={[ styles.View 4, {} ]} backgroundColor={"#D8D8D8"}>
          <Text
            style={[ styles.Text 6, {} ]}
            text={"Left aligned text, Fixed w/ secondary centering"}
          >

          </Text>
        </View>
        <View style={[ styles.View 5, {} ]} backgroundColor={"#D8D8D8"}>
          <Text
            style={[ styles.Text 7, {} ]}
            text={"Centered text, Fit parent no centering"}
          >

          </Text>
        </View>
        <View style={[ styles.View 6, {} ]} backgroundColor={"#D8D8D8"}>
          <Text
            style={[ styles.Text 8, {} ]}
            text={"Centered text, Fixed parent no centering"}
          >

          </Text>
        </View>
        <View
          style={[ styles.RightAlignmentContainer, {} ]}
          backgroundColor={"#D8D8D8"}
        >
          <Text style={[ styles.Text 9, {} ]} text={"Fit Text"}>

          </Text>
          <Text
            style={[ styles.Text 10, {} ]}
            text={"Fill and center aligned text"}
          >

          </Text>
          <Image
            style={[ styles.Image 1, {} ]}
            image={"file://./assets/icon_128x128.png"}
          >

          </Image>
        </View>
      </View>
    );
  }
};

let styles = StyleSheet.create({
  View: {
    alignItems: "flex-start",
    alignSelf: "stretch",
    paddingBottom: 10,
    paddingLeft: 10,
    paddingRight: 10,
    paddingTop: 10
  },
  View 1: {
    alignItems: "center",
    alignSelf: "stretch",
    justifyContent: "center"
  },
  Image: { height: 100, width: 100 },
  View 2: {},
  Text: {
    alignSelf: "stretch",
    font: "display1",
    marginTop: 16,
    textAlign: "center"
  },
  Text 1: { font: "subheading2", marginTop: 16, textAlign: "center" },
  Text 2: { alignSelf: "stretch", marginTop: 12 },
  Text 3: { alignSelf: "stretch", textAlign: "right" },
  Text 4: { textAlign: "center", width: 80 },
  View 3: { alignItems: "center", paddingLeft: 12, paddingRight: 12 },
  Text 5: {},
  View 4: {
    alignItems: "center",
    paddingLeft: 12,
    paddingRight: 12,
    width: 400
  },
  Text 6: {},
  View 5: { paddingLeft: 12, paddingRight: 12 },
  Text 7: { textAlign: "center" },
  View 6: { paddingLeft: 12, paddingRight: 12, width: 400 },
  Text 8: { alignSelf: "stretch", textAlign: "center" },
  RightAlignmentContainer: { alignItems: "flex-end", alignSelf: "stretch" },
  Text 9: {},
  Text 10: { alignSelf: "stretch", textAlign: "center" },
  Image 1: { height: 100, width: 100 }
});