let findChildPages = (root: MdxTypes.root): list(string) => {
  root.children
  |> List.map((child: MdxTypes.blockNode) =>
       switch (child) {
       | Page({value}) => Some(value)
       | _ => None
       }
     )
  |> Sequence.compact;
};