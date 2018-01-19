[@bs.val] [@bs.module "csscolorparser"] [@bs.return nullable]
external _parseCSSColor : string => option(array(float)) =
  "parseCSSColor";

type cssColor = {
  r: float,
  g: float,
  b: float,
  a: float
};

let parseColor = (value: string) =>
  switch (_parseCSSColor(value)) {
  | Some(arr) =>
    let [r, g, b, a] = Array.to_list(arr);
    Some({r, g, b, a})
  | None => None
  };

let parseColorDefault = (default, value) =>
  switch (parseColor(value)) {
  | Some(color) => color
  | None =>
    switch (parseColor(default)) {
    | Some(color) => color
    | None => {r: 0.0, g: 0.0, b: 0.0, a: 0.0}
    }
  };