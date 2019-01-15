let first = (items: list('a)): option('a) =>
  switch (items) {
  | [] => None
  | [a, ..._] => Some(a)
  };

let firstWhere = (f: 'a => bool, items: list('a)): option('a) =>
  switch (List.filter(f, items)) {
  | [] => None
  | [a, ..._] => Some(a)
  };

let rec compact = (items: list(option('a))): list('a) =>
  switch (items) {
  | [Some(x), ...xs] => [x] @ compact(xs)
  | [None, ...xs] => compact(xs)
  | [] => []
  };

let choose = (k: int, items: list('a)): list(list('a)) => {
  let rec inner = (acc, k, items) =>
    switch (k) {
    | 0 => [[]]
    | _ =>
      switch (items) {
      | [] => acc
      | [x, ...xs] =>
        let rec accmap = (acc, f) => (
          fun
          | [] => acc
          | [x, ...xs] => accmap([f(x), ...acc], f, xs)
        );

        let newacc = accmap(acc, z => [x, ...z], inner([], k - 1, xs));

        inner(newacc, k, xs);
      }
    };

  inner([], k, items);
};

let combinations = (items: list('a)): list(list('a)) => {
  let rec inner = (k, items) =>
    if (k >= 0) {
      choose(k, items) @ inner(k - 1, items);
    } else {
      [];
    };

  inner(List.length(items), items);
};

let rec permutations = (items: list('a)): list(list('a)) => {
  let distribute = (c, l) => {
    let rec insert = (acc1, acc2) =>
      fun
      | [] => acc2
      | [hd, ...tl] =>
        insert(
          [hd, ...acc1],
          [List.rev_append(acc1, [hd, c, ...tl]), ...acc2],
          tl,
        );

    insert([], [[c, ...l]], l);
  };

  switch (items) {
  | [] => [[]]
  | [hd, ...tl] =>
    List.fold_left(
      (acc, x) => List.rev_append(distribute(hd, x), acc),
      [],
      permutations(tl),
    )
  };
};

let cons_uniq = (f, list, item) =>
  if (f(item, list)) {
    list;
  } else {
    [item, ...list];
  };

let dedupe = (f: ('a, list('a)) => bool, list: list('a)): list('a) =>
  List.rev(List.fold_left(cons_uniq(f), [], list));

let dedupeMem = (list: list('a)): list('a) =>
  dedupe((item, list) => List.mem(item, list), list);

let occurrences = (f: 'a => bool, list: list('a)): int =>
  List.fold_right((item, acc) => f(item) ? acc + 1 : acc, list, 0);

let join = (sep: 'a, list: list('a)): list('a) =>
  switch (list) {
  | [] => []
  | [hd, ...tl] =>
    tl |> List.fold_left((acc, node) => acc @ [sep, node], [hd])
  };

let joinGroups = (sep: 'a, groups: list(list('a))): list('a) => {
  let nonEmpty = groups |> List.filter(x => List.length(x) > 0);
  switch (nonEmpty) {
  | [] => []
  | [hd, ...tl] =>
    tl |> List.fold_left((acc, nodes) => acc @ [sep] @ nodes, hd)
  };
};