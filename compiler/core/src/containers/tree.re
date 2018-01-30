module type TREE_ITEM = {
  type t;
  let children: t => list(t);
  let restore: (t, list(t)) => t;
};

module Make = (Item: TREE_ITEM) => {
  type node('a) =
    | Node(Item.t, list(node('a)));
  let rec reduce = (f, initialValue, item) =>
    List.fold_left(
      (acc, item) => reduce(f, acc, item),
      f(item, initialValue),
      Item.children(item)
    );
  let rec map = (f, item) =>
    f(Item.restore(item, Item.children(item) |> List.map(map(f))));
  let rec iter = (f, item) => {
    f(item);
    Item.children(item) |> List.iter(iter(f));
  };
  let find_opt = (f, node) => {
    let rec findList = items =>
      switch items {
      | [] => None
      | [head] => f(head) ? Some(head) : findList(Item.children(head))
      | [head, ...tail] => f(head) ? Some(head) : findList(tail)
      };
    findList([node]);
  };
  let find = (f, item) =>
    switch (find_opt(f, item)) {
    | Some(item) => item
    | None => raise(Not_found)
    };
  let replace_all = (f, root) =>
    map(
      item =>
        switch (f(item)) {
        | Some(a) => a
        | None => item
        },
      root
    );
  let replace = (f, root) => {
    let found = ref(false);
    map(
      item =>
        if (found^) {
          item;
        } else {
          switch (f(item)) {
          | Some(a) =>
            found := true;
            a;
          | None => item
          };
        },
      root
    );
  };
  let replaceWith = (original, updated, root) =>
    replace(item => item == original ? Some(updated) : None, root);
  let insert_child = (f, root) => {
    let found = ref(false);
    map(
      item =>
        if (found^) {
          item;
        } else {
          switch (f(item)) {
          | Some(a) =>
            found := true;
            Item.restore(item, [a, ...Item.children(item)]);
          | None => item
          };
        },
      root
    );
  };
};
