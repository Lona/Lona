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

let firstIndexWhere = (f: 'a => bool, items: list('a)): option(int) => {
  let enumerated = items |> List.mapi((i, item) => (i, item));
  let found = enumerated |> firstWhere(((_, item)) => f(item));
  switch (found) {
  | Some((index, _)) => Some(index)
  | None => None
  };
};

let firstIndexMem = (item: 'a, items: list('a)): option(int) =>
  items |> firstIndexWhere(x => item == x);

let rejectWhere = (f: 'a => bool, items: list('a)) =>
  items |> List.filter(item => !f(item));

let rec compact = (items: list(option('a))): list('a) =>
  switch (items) {
  | [Some(x), ...xs] => [x] @ compact(xs)
  | [None, ...xs] => compact(xs)
  | [] => []
  };

let compactMap = (f: 'a => option('b), items: list('a)): list('b) =>
  items |> List.map(f) |> compact;

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

let intersectBy =
    (f: ('a, 'a) => bool, list1: list('a), list2: list('a)): list('a) => {
  let list1Contents =
    list1 |> List.filter(a => list2 |> List.exists(b => f(a, b)));
  let list2Contents =
    list2 |> List.filter(a => list1 |> List.exists(b => f(a, b)));
  dedupeMem(list1Contents @ list2Contents);
};

let intersectMem = (list1: list('a), list2: list('a)): list('a) =>
  intersectBy((a, b) => a == b, list1, list2);

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

let replaceAt = (targetIndex: int, newItem: 'a, list: list('a)): list('a) =>
  list |> List.mapi((index, item) => targetIndex == index ? newItem : item);