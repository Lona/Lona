type direction =
  | Row
  | Column;

type childrenAlignment =
  | Start
  | Center
  | End
  | Unspecified;

type sizingRule =
  | Fill
  | FitContent
  | Fixed(float);

type t = {
  width: sizingRule,
  height: sizingRule,
  direction,
  horizontalAlignment: childrenAlignment,
  verticalAlignment: childrenAlignment,
};

module FromString = {
  let direction = (value: string) =>
    switch (value) {
    | "row" => Row
    | "column" => Column
    | _ => raise(Not_found)
    };

  let childrenAlignment = (value: string) =>
    switch (value) {
    | "flex-start" => Start
    | "center" => Center
    | "flex-end" => End
    | _ => Start
    };
};

module ToString = {
  let direction = (value: direction) =>
    switch (value) {
    | Row => "row"
    | Column => "column"
    };

  let childrenAlignment = (value: childrenAlignment) =>
    switch (value) {
    | Start => "flex-start"
    | Center => "center"
    | End => "flex-end"
    | Unspecified => "flex-start"
    };
};