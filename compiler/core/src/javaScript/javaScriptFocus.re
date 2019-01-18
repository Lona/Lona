module Methods = {
  let getFocusElements = (rootLayer: Types.layer): JavaScriptAst.node =>
    AssignmentExpression({
      left: Identifier(["_getFocusElements"]),
      right:
        ArrowFunctionExpression({
          id: None,
          params: [],
          body: [
            Return(
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
            IfStatement({
              test:
                BinaryExpression({
                  left: Identifier(["focusElements[0]"]),
                  operator: And,
                  right: Identifier(["focusElements[0]", "focus"]),
                }),
              consequent: [
                CallExpression({
                  callee: Identifier(["focusElements[0]", "focus"]),
                  arguments: [],
                }),
              ],
              alternate: [],
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
            VariableDeclaration(
              AssignmentExpression({
                left: Identifier(["nextIndex"]),
                right:
                  BinaryExpression({
                    left:
                      CallExpression({
                        callee: Identifier(["focusElements", "indexOf"]),
                        arguments: [
                          Identifier(["document", "activeElement"]),
                        ],
                      }),
                    operator: Plus,
                    right: Literal(LonaValue.number(1.)),
                  }),
              }),
            ),
            Empty,
            IfStatement({
              test:
                BinaryExpression({
                  left: Identifier(["nextIndex"]),
                  operator: Gte,
                  right: Identifier(["focusElements", "length"]),
                }),
              consequent: [
                BinaryExpression({
                  left: Identifier(["this", "props", "onFocusNext"]),
                  operator: And,
                  right:
                    CallExpression({
                      callee: Identifier(["this", "props", "onFocusNext"]),
                      arguments: [],
                    }),
                }),
                Return(Empty),
              ],
              alternate: [],
            }),
            Empty,
            BinaryExpression({
              left: Identifier(["focusElements[nextIndex]", "focus"]),
              operator: And,
              right:
                CallExpression({
                  callee: Identifier(["focusElements[nextIndex]", "focus"]),
                  arguments: [],
                }),
            }),
          ],
        }),
    });

  let focusPrevious = (): JavaScriptAst.node =>
    AssignmentExpression({
      left: Identifier(["focusPrevious"]),
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
            VariableDeclaration(
              AssignmentExpression({
                left: Identifier(["previousIndex"]),
                right:
                  BinaryExpression({
                    left:
                      CallExpression({
                        callee: Identifier(["focusElements", "indexOf"]),
                        arguments: [
                          Identifier(["document", "activeElement"]),
                        ],
                      }),
                    operator: Minus,
                    right: Literal(LonaValue.number(1.)),
                  }),
              }),
            ),
            Empty,
            IfStatement({
              test:
                BinaryExpression({
                  left: Identifier(["previousIndex"]),
                  operator: Lt,
                  right: Literal(LonaValue.number(0.)),
                }),
              consequent: [
                BinaryExpression({
                  left: Identifier(["this", "props", "onFocusPrevious"]),
                  operator: And,
                  right:
                    CallExpression({
                      callee:
                        Identifier(["this", "props", "onFocusPrevious"]),
                      arguments: [],
                    }),
                }),
                Return(Empty),
              ],
              alternate: [],
            }),
            Empty,
            BinaryExpression({
              left: Identifier(["focusElements[previousIndex]", "focus"]),
              operator: And,
              right:
                CallExpression({
                  callee:
                    Identifier(["focusElements[previousIndex]", "focus"]),
                  arguments: [],
                }),
            }),
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
                IfStatement({
                  test: Identifier(["event", "shiftKey"]),

                  consequent: [
                    CallExpression({
                      callee: Identifier(["this", "focusPrevious"]),
                      arguments: [],
                    }),
                  ],
                  alternate: [
                    CallExpression({
                      callee: Identifier(["this", "focusNext"]),
                      arguments: [],
                    }),
                  ],
                }),
                Empty,
                CallExpression({
                  callee: Identifier(["event", "stopPropagation"]),
                  arguments: [],
                }),
                CallExpression({
                  callee: Identifier(["event", "preventDefault"]),
                  arguments: [],
                }),
              ],
              alternate: [],
            }),
          ],
        }),
    });
};

let focusMethods = (rootLayer: Types.layer): list(JavaScriptAst.node) =>
  Methods.[
    focus(),
    focusNext(),
    focusPrevious(),
    handleKeyDown(),
    getFocusElements(rootLayer),
  ];