type flexLayout('a) = {
  alignItems: 'a,
  alignSelf: 'a,
  display: 'a,
  justifyContent: 'a,
  flex: 'a,
  flexDirection: 'a,
  width: 'a,
  height: 'a,
};

type edgeInsets('a) = {
  top: 'a,
  right: 'a,
  bottom: 'a,
  left: 'a,
};

type layout('a) = {
  flex: flexLayout('a),
  padding: edgeInsets('a),
  margin: edgeInsets('a),
};

type border('a) = {
  borderRadius: 'a,
  borderWidth: 'a,
  borderColor: 'a,
};

type textStyles('a) = {
  textAlign: 'a,
  textStyle: 'a,
};

type viewLayerStyles('a) = {
  layout: layout('a),
  border: border('a),
  backgroundColor: 'a,
  textStyles: textStyles('a),
};

/* type styleValues = styles(Types.lonaValue); */
type namedStyles('a) = {
  name: string,
  styles: viewLayerStyles('a),
};

type styleSets('a) = list(namedStyles('a));

let foo = 123;

let print = (styleSets: styleSets('a)) =>
  styleSets
  |> List.iter(set => Js.log2(set.name, Js.String.make(set.styles)));

/* let map = (set: layerStyles('a)): layerStyles('b) => {
     {

     };
   }; */