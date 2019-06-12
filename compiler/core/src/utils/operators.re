let (%?) = (x: option('a), y: 'a) =>
  switch (x) {
  | Some(value) => value
  | None => y
  };

let b = Some(3) %? 4;