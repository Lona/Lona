let focusOptionsParam = (): JavaScriptAst.node =>
  AssignmentExpression({
    left:
      ObjectLiteral([
        AssignmentExpression({
          left: Identifier(["focusRing"]),
          right: Literal(LonaValue.boolean(true)),
        }),
      ]),
    right:
      ObjectLiteral([
        Property({
          key: Identifier(["focusRing"]),
          value: Some(Literal(LonaValue.boolean(true))),
        }),
      ]),
  });

module Methods = {
  let getFocusElements = (rootLayer: Types.layer): JavaScriptAst.node =>
    AssignmentExpression({
      left: Identifier(["_getFocusElements"]),
      right:
        ArrowFunctionExpression({
          id: None,
          params: [],
          body: [
            VariableDeclaration(
              AssignmentExpression({
                left: Identifier(["elements"]),
                right:
                  ArrayLiteral(
                    rootLayer
                    |> JavaScriptLayer.Hierarchy.accessibilityElements
                    |> List.map((layer: Types.layer) =>
                         JavaScriptAst.Identifier([
                           "this",
                           "_" ++ JavaScriptFormat.elementName(layer.name),
                         ])
                       ),
                  ),
              }),
            ),
            Return(
              CallExpression({
                callee: Identifier(["elements.filter"]),
                arguments: [Identifier(["Boolean"])],
              }),
            ),
          ],
        }),
    });

  let setFocusRing = (): JavaScriptAst.node =>
    AssignmentExpression({
      left: Identifier(["setFocusRing"]),
      right:
        ArrowFunctionExpression({
          id: None,
          params: [Identifier(["focusRing"])],
          body: [
            CallExpression({
              callee: Identifier(["this", "setState"]),
              arguments: [
                ObjectLiteral([
                  Property({key: Identifier(["focusRing"]), value: None}),
                ]),
              ],
            }),
          ],
        }),
    });

  let isFocused = (): JavaScriptAst.node =>
    AssignmentExpression({
      left: Identifier(["isFocused"]),
      right:
        ArrowFunctionExpression({
          id: None,
          params: [],
          body: [
            VariableDeclaration(
              AssignmentExpression({
                left: Identifier(["focusElements"]),
                right:
                  CallExpression({
                    callee: Identifier(["this", "_getFocusElements"]),
                    arguments: [],
                  }),
              }),
            ),
            Empty,
            Return(
              UnaryExpression({
                prefix: true,
                operator: "!",
                argument:
                  UnaryExpression({
                    prefix: true,
                    operator: "!",
                    argument:
                      CallExpression({
                        callee: Identifier(["focusElements", "find"]),
                        arguments: [Identifier(["isFocused"])],
                      }),
                  }),
              }),
            ),
          ],
        }),
    });

  let focus = (): JavaScriptAst.node =>
    AssignmentExpression({
      left: Identifier(["focus"]),
      right:
        ArrowFunctionExpression({
          id: None,
          params: [focusOptionsParam()],
          body: [
            CallExpression({
              callee: Identifier(["this", "setFocusRing"]),
              arguments: [Identifier(["focusRing"])],
            }),
            Empty,
            CallExpression({
              callee: Identifier(["focusFirst"]),
              arguments: [
                CallExpression({
                  callee: Identifier(["this", "_getFocusElements"]),
                  arguments: [],
                }),
              ],
            }),
          ],
        }),
    });

  let focusLast = (): JavaScriptAst.node =>
    AssignmentExpression({
      left: Identifier(["focusLast"]),
      right:
        ArrowFunctionExpression({
          id: None,
          params: [focusOptionsParam()],
          body: [
            CallExpression({
              callee: Identifier(["this", "setFocusRing"]),
              arguments: [Identifier(["focusRing"])],
            }),
            Empty,
            CallExpression({
              callee: Identifier(["focusLast"]),
              arguments: [
                CallExpression({
                  callee: Identifier(["this", "_getFocusElements"]),
                  arguments: [],
                }),
              ],
            }),
          ],
        }),
    });

  let focusNext = (): JavaScriptAst.node =>
    AssignmentExpression({
      left: Identifier(["focusNext"]),
      right:
        ArrowFunctionExpression({
          id: None,
          params: [focusOptionsParam()],
          body: [
            CallExpression({
              callee: Identifier(["this", "setFocusRing"]),
              arguments: [Identifier(["focusRing"])],
            }),
            Empty,
            IfStatement({
              test:
                CallExpression({
                  callee: Identifier(["focusNext"]),
                  arguments: [
                    CallExpression({
                      callee: Identifier(["this", "_getFocusElements"]),
                      arguments: [],
                    }),
                  ],
                }),

              consequent: [Return(Literal(LonaValue.boolean(true)))],
              alternate: [],
            }),
            Empty,
            IfStatement({
              test: Identifier(["this", "props", "onFocusNext"]),
              consequent: [
                CallExpression({
                  callee: Identifier(["this", "props", "onFocusNext"]),
                  arguments: [],
                }),
                Empty,
                Return(Literal(LonaValue.boolean(true))),
              ],
              alternate: [],
            }),
            Empty,
            Return(Literal(LonaValue.boolean(false))),
          ],
        }),
    });

  let focusPrevious = (): JavaScriptAst.node =>
    AssignmentExpression({
      left: Identifier(["focusPrevious"]),
      right:
        ArrowFunctionExpression({
          id: None,
          params: [focusOptionsParam()],
          body: [
            CallExpression({
              callee: Identifier(["this", "setFocusRing"]),
              arguments: [Identifier(["focusRing"])],
            }),
            Empty,
            IfStatement({
              test:
                CallExpression({
                  callee: Identifier(["focusPrevious"]),
                  arguments: [
                    CallExpression({
                      callee: Identifier(["this", "_getFocusElements"]),
                      arguments: [],
                    }),
                  ],
                }),

              consequent: [Return(Literal(LonaValue.boolean(true)))],
              alternate: [],
            }),
            Empty,
            IfStatement({
              test: Identifier(["this", "props", "onFocusPrevious"]),
              consequent: [
                CallExpression({
                  callee: Identifier(["this", "props", "onFocusPrevious"]),
                  arguments: [],
                }),
                Empty,
                Return(Literal(LonaValue.boolean(true))),
              ],
              alternate: [],
            }),
            Empty,
            Return(Literal(LonaValue.boolean(false))),
          ],
        }),
    });

  let handleKeyDown = (): JavaScriptAst.node =>
    AssignmentExpression({
      left: Identifier(["_handleKeyDown"]),
      right:
        ArrowFunctionExpression({
          id: None,
          params: [Identifier(["event"])],
          body: [
            IfStatement({
              test:
                BinaryExpression({
                  left: Identifier(["event", "key"]),
                  operator: Eq,
                  right: Literal(LonaValue.string("Tab")),
                }),
              consequent: [
                CallExpression({
                  callee: Identifier(["this", "setFocusRing"]),
                  arguments: [Literal(LonaValue.boolean(true))],
                }),
                Empty,
                IfStatement({
                  test: Identifier(["event", "shiftKey"]),
                  consequent: [
                    IfStatement({
                      test:
                        CallExpression({
                          callee: Identifier(["this", "focusPrevious"]),
                          arguments: [],
                        }),
                      consequent: [
                        CallExpression({
                          callee: Identifier(["event", "stopPropagation"]),
                          arguments: [],
                        }),
                        CallExpression({
                          callee: Identifier(["event", "preventDefault"]),
                          arguments: [],
                        }),
                        Return(Empty),
                      ],
                      alternate: [],
                    }),
                  ],
                  alternate: [
                    IfStatement({
                      test:
                        CallExpression({
                          callee: Identifier(["this", "focusNext"]),
                          arguments: [],
                        }),
                      consequent: [
                        CallExpression({
                          callee: Identifier(["event", "stopPropagation"]),
                          arguments: [],
                        }),
                        CallExpression({
                          callee: Identifier(["event", "preventDefault"]),
                          arguments: [],
                        }),
                        Return(Empty),
                      ],
                      alternate: [],
                    }),
                  ],
                }),
              ],
              alternate: [],
            }),
            Empty,
            IfStatement({
              test: Identifier(["this", "props", "onKeyDown"]),
              consequent: [
                CallExpression({
                  callee: Identifier(["this", "props", "onKeyDown"]),
                  arguments: [Identifier(["event"])],
                }),
              ],
              alternate: [],
            }),
          ],
        }),
    });
};

let initialStateProperties = (): list(JavaScriptAst.node) => [
  Property({
    key: Identifier(["focusRing"]),
    value: Some(Literal(LonaValue.boolean(false))),
  }),
];

let focusMethods = (rootLayer: Types.layer): list(JavaScriptAst.node) =>
  Methods.[
    setFocusRing(),
    isFocused(),
    focus(),
    focusLast(),
    focusNext(),
    focusPrevious(),
    handleKeyDown(),
    getFocusElements(rootLayer),
  ];