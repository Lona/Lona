// Generated by BUCKLESCRIPT VERSION 2.1.0, PLEASE EDIT WITH CARE
'use strict';

var $$Map                      = require("bs-platform/lib/js/map.js");
var List                       = require("bs-platform/lib/js/list.js");
var Block                      = require("bs-platform/lib/js/block.js");
var Curry                      = require("bs-platform/lib/js/curry.js");
var Caml_string                = require("bs-platform/lib/js/caml_string.js");
var Logic$LonaCompilerCore     = require("./logic.bs.js");
var Caml_builtin_exceptions    = require("bs-platform/lib/js/caml_builtin_exceptions.js");
var StringMap$LonaCompilerCore = require("./stringMap.bs.js");
var StringSet$LonaCompilerCore = require("./stringSet.bs.js");

function compare(a, b) {
  return Caml_string.caml_string_compare(a[1], b[1]);
}

var include = $$Map.Make(/* module */[/* compare */compare]);

var empty = include[0];

var add = include[3];

var find = include[21];

function find_opt(key, map) {
  var exit = 0;
  var item;
  try {
    item = Curry._2(find, key, map);
    exit = 1;
  }
  catch (exn){
    if (exn === Caml_builtin_exceptions.not_found) {
      return /* None */0;
    } else {
      throw exn;
    }
  }
  if (exit === 1) {
    return /* Some */[item];
  }
  
}

var LayerMap_001 = /* is_empty */include[1];

var LayerMap_002 = /* mem */include[2];

var LayerMap_004 = /* singleton */include[4];

var LayerMap_005 = /* remove */include[5];

var LayerMap_006 = /* merge */include[6];

var LayerMap_007 = /* compare */include[7];

var LayerMap_008 = /* equal */include[8];

var LayerMap_009 = /* iter */include[9];

var LayerMap_010 = /* fold */include[10];

var LayerMap_011 = /* for_all */include[11];

var LayerMap_012 = /* exists */include[12];

var LayerMap_013 = /* filter */include[13];

var LayerMap_014 = /* partition */include[14];

var LayerMap_015 = /* cardinal */include[15];

var LayerMap_016 = /* bindings */include[16];

var LayerMap_017 = /* min_binding */include[17];

var LayerMap_018 = /* max_binding */include[18];

var LayerMap_019 = /* choose */include[19];

var LayerMap_020 = /* split */include[20];

var LayerMap_022 = /* map */include[22];

var LayerMap_023 = /* mapi */include[23];

var LayerMap = /* module */[
  /* empty */empty,
  LayerMap_001,
  LayerMap_002,
  /* add */add,
  LayerMap_004,
  LayerMap_005,
  LayerMap_006,
  LayerMap_007,
  LayerMap_008,
  LayerMap_009,
  LayerMap_010,
  LayerMap_011,
  LayerMap_012,
  LayerMap_013,
  LayerMap_014,
  LayerMap_015,
  LayerMap_016,
  LayerMap_017,
  LayerMap_018,
  LayerMap_019,
  LayerMap_020,
  /* find */find,
  LayerMap_022,
  LayerMap_023,
  /* find_opt */find_opt
];

var parameterTypeMap = StringMap$LonaCompilerCore.fromList(/* :: */[
      /* tuple */[
        "text",
        /* Reference */Block.__(0, ["String"])
      ],
      /* :: */[
        /* tuple */[
          "visible",
          /* Reference */Block.__(0, ["Boolean"])
        ],
        /* :: */[
          /* tuple */[
            "alignItems",
            /* Reference */Block.__(0, ["String"])
          ],
          /* :: */[
            /* tuple */[
              "alignSelf",
              /* Reference */Block.__(0, ["String"])
            ],
            /* :: */[
              /* tuple */[
                "flex",
                /* Reference */Block.__(0, ["Number"])
              ],
              /* :: */[
                /* tuple */[
                  "flexDirection",
                  /* Reference */Block.__(0, ["String"])
                ],
                /* :: */[
                  /* tuple */[
                    "font",
                    /* Reference */Block.__(0, ["String"])
                  ],
                  /* :: */[
                    /* tuple */[
                      "justifyContent",
                      /* Reference */Block.__(0, ["String"])
                    ],
                    /* :: */[
                      /* tuple */[
                        "marginTop",
                        /* Reference */Block.__(0, ["Number"])
                      ],
                      /* :: */[
                        /* tuple */[
                          "marginRight",
                          /* Reference */Block.__(0, ["Number"])
                        ],
                        /* :: */[
                          /* tuple */[
                            "marginBottom",
                            /* Reference */Block.__(0, ["Number"])
                          ],
                          /* :: */[
                            /* tuple */[
                              "marginLeft",
                              /* Reference */Block.__(0, ["Number"])
                            ],
                            /* :: */[
                              /* tuple */[
                                "paddingTop",
                                /* Reference */Block.__(0, ["Number"])
                              ],
                              /* :: */[
                                /* tuple */[
                                  "paddingRight",
                                  /* Reference */Block.__(0, ["Number"])
                                ],
                                /* :: */[
                                  /* tuple */[
                                    "paddingBottom",
                                    /* Reference */Block.__(0, ["Number"])
                                  ],
                                  /* :: */[
                                    /* tuple */[
                                      "paddingLeft",
                                      /* Reference */Block.__(0, ["Number"])
                                    ],
                                    /* [] */0
                                  ]
                                ]
                              ]
                            ]
                          ]
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]);

var stylesSet = Curry._1(StringSet$LonaCompilerCore.of_list, /* :: */[
      "alignItems",
      /* :: */[
        "alignSelf",
        /* :: */[
          "flex",
          /* :: */[
            "flexDirection",
            /* :: */[
              "font",
              /* :: */[
                "justifyContent",
                /* :: */[
                  "marginTop",
                  /* :: */[
                    "marginRight",
                    /* :: */[
                      "marginBottom",
                      /* :: */[
                        "marginLeft",
                        /* :: */[
                          "paddingTop",
                          /* :: */[
                            "paddingRight",
                            /* :: */[
                              "paddingBottom",
                              /* :: */[
                                "paddingLeft",
                                /* [] */0
                              ]
                            ]
                          ]
                        ]
                      ]
                    ]
                  ]
                ]
              ]
            ]
          ]
        ]
      ]
    ]);

function parameterType(name) {
  try {
    return Curry._2(StringMap$LonaCompilerCore.find, name, parameterTypeMap);
  }
  catch (exn){
    if (exn === Caml_builtin_exceptions.not_found) {
      console.log("Unknown built-in parameter when deserializing:", name);
      return /* Reference */Block.__(0, ["Null"]);
    } else {
      throw exn;
    }
  }
}

function flatten(layer) {
  var inner = function (acc, layer) {
    return List.flatten(/* :: */[
                acc,
                /* :: */[
                  /* :: */[
                    layer,
                    /* [] */0
                  ],
                  List.map((function (param) {
                          return inner(/* [] */0, param);
                        }), layer[3])
                ]
              ]);
  };
  return inner(/* [] */0, layer);
}

function find$1(name, layer) {
  var matches = function (item) {
    return +(name === item[1]);
  };
  var exit = 0;
  var item;
  try {
    item = List.find(matches, flatten(layer));
    exit = 1;
  }
  catch (exn){
    if (exn === Caml_builtin_exceptions.not_found) {
      return /* None */0;
    } else {
      throw exn;
    }
  }
  if (exit === 1) {
    return /* Some */[item];
  }
  
}

function parameterAssignments(layer, node) {
  var identifiers = Logic$LonaCompilerCore.undeclaredIdentifiers(node);
  return List.fold_left((function (acc, item) {
                if (typeof item === "number") {
                  return acc;
                } else if (item.tag) {
                  return acc;
                } else {
                  var match = item[1];
                  if (match) {
                    var match$1 = match[1];
                    if (match$1) {
                      var match$2 = match$1[1];
                      if (match$2 && !match$2[1]) {
                        var layerName = match$1[0];
                        var propertyName = match$2[0];
                        var logicValue = item;
                        var acc$1 = acc;
                        console.log(find$1(layerName, layer));
                        console.log(layerName);
                        var match$3 = find$1(layerName, layer);
                        if (match$3) {
                          var found = match$3[0];
                          var match$4 = find_opt(found, acc$1);
                          if (match$4) {
                            return Curry._3(add, found, Curry._3(StringMap$LonaCompilerCore.add, propertyName, logicValue, match$4[0]), acc$1);
                          } else {
                            return Curry._3(add, found, Curry._3(StringMap$LonaCompilerCore.add, propertyName, logicValue, StringMap$LonaCompilerCore.empty), acc$1);
                          }
                        } else {
                          return acc$1;
                        }
                      } else {
                        return acc;
                      }
                    } else {
                      return acc;
                    }
                  } else {
                    return acc;
                  }
                }
              }), empty, List.map((function (param) {
                    return /* Identifier */Block.__(0, [
                              param[0],
                              param[1]
                            ]);
                  }), Curry._1(Logic$LonaCompilerCore.IdentifierSet[/* elements */19], identifiers)));
}

function parameterIsStyle(name) {
  return StringSet$LonaCompilerCore.has(name, stylesSet);
}

function splitParamsMap(params) {
  return Curry._2(StringMap$LonaCompilerCore.partition, (function (key, _) {
                return StringSet$LonaCompilerCore.has(key, stylesSet);
              }), params);
}

function parameterMapToLogicValueMap(params) {
  return Curry._2(StringMap$LonaCompilerCore.map, (function (item) {
                return /* Literal */Block.__(1, [item]);
              }), params);
}

function layerTypeToString(x) {
  switch (x) {
    case 0 : 
        return "View";
    case 1 : 
        return "Text";
    case 2 : 
        return "Image";
    case 3 : 
        return "Animation";
    case 4 : 
        return "Children";
    case 5 : 
        return "Component";
    case 6 : 
        return "Unknown";
    
  }
}

function mapBindings(f, map) {
  return List.map(f, Curry._1(StringMap$LonaCompilerCore.bindings, map));
}

function createStyleAttributeAST(layerName, styles) {
  return /* JSXAttribute */Block.__(6, [
            "style",
            /* ArrayLiteral */Block.__(12, [/* :: */[
                  /* Identifier */Block.__(2, [/* :: */[
                        "styles",
                        /* :: */[
                          layerName,
                          /* [] */0
                        ]
                      ]]),
                  /* :: */[
                    /* ObjectLiteral */Block.__(13, [List.map((function (param) {
                                return /* ObjectProperty */Block.__(14, [
                                          /* Identifier */Block.__(2, [/* :: */[
                                                param[0],
                                                /* [] */0
                                              ]]),
                                          Logic$LonaCompilerCore.logicValueToJavaScriptAST(param[1])
                                        ]);
                              }), Curry._1(StringMap$LonaCompilerCore.bindings, styles))]),
                    /* [] */0
                  ]
                ]])
          ]);
}

function toJavaScriptAST(variableMap, layer) {
  var params = Curry._2(StringMap$LonaCompilerCore.map, (function (item) {
          return /* Literal */Block.__(1, [item]);
        }), layer[2]);
  var match = Curry._2(StringMap$LonaCompilerCore.partition, (function (key, _) {
          return StringSet$LonaCompilerCore.has(key, stylesSet);
        }), params);
  var match$1 = find_opt(layer, variableMap);
  var params$1 = match$1 ? match$1[0] : StringMap$LonaCompilerCore.empty;
  var match$2 = Curry._2(StringMap$LonaCompilerCore.partition, (function (key, _) {
          return StringSet$LonaCompilerCore.has(key, stylesSet);
        }), params$1);
  var main = StringMap$LonaCompilerCore.assign(match[1], match$2[1]);
  var styleAttribute = createStyleAttributeAST(layer[1], match$2[0]);
  var attributes = List.map((function (param) {
          return /* JSXAttribute */Block.__(6, [
                    param[0],
                    Logic$LonaCompilerCore.logicValueToJavaScriptAST(param[1])
                  ]);
        }), Curry._1(StringMap$LonaCompilerCore.bindings, main));
  return /* JSXElement */Block.__(7, [
            layerTypeToString(layer[0]),
            /* :: */[
              styleAttribute,
              attributes
            ],
            List.map((function (param) {
                    return toJavaScriptAST(variableMap, param);
                  }), layer[3])
          ]);
}

function toJavaScriptStyleSheetAST(layer) {
  var createStyleObjectForLayer = function (layer) {
    var styleParams = Curry._2(StringMap$LonaCompilerCore.filter, (function (key, _) {
            return StringSet$LonaCompilerCore.has(key, stylesSet);
          }), layer[2]);
    return /* ObjectProperty */Block.__(14, [
              /* Identifier */Block.__(2, [/* :: */[
                    layer[1],
                    /* [] */0
                  ]]),
              /* ObjectLiteral */Block.__(13, [List.map((function (param) {
                          return /* ObjectProperty */Block.__(14, [
                                    /* Identifier */Block.__(2, [/* :: */[
                                          param[0],
                                          /* [] */0
                                        ]]),
                                    /* Literal */Block.__(1, [param[1]])
                                  ]);
                        }), Curry._1(StringMap$LonaCompilerCore.bindings, styleParams))])
            ]);
  };
  var styleObjects = List.map(createStyleObjectForLayer, flatten(layer));
  return /* VariableDeclaration */Block.__(8, [/* AssignmentExpression */Block.__(9, [
                /* Identifier */Block.__(2, [/* :: */[
                      "styles",
                      /* [] */0
                    ]]),
                /* CallExpression */Block.__(5, [
                    /* Identifier */Block.__(2, [/* :: */[
                          "StyleSheet",
                          /* :: */[
                            "create",
                            /* [] */0
                          ]
                        ]]),
                    /* :: */[
                      /* ObjectLiteral */Block.__(13, [styleObjects]),
                      /* [] */0
                    ]
                  ])
              ])]);
}

exports.LayerMap                    = LayerMap;
exports.parameterTypeMap            = parameterTypeMap;
exports.stylesSet                   = stylesSet;
exports.parameterType               = parameterType;
exports.flatten                     = flatten;
exports.find                        = find$1;
exports.parameterAssignments        = parameterAssignments;
exports.parameterIsStyle            = parameterIsStyle;
exports.splitParamsMap              = splitParamsMap;
exports.parameterMapToLogicValueMap = parameterMapToLogicValueMap;
exports.layerTypeToString           = layerTypeToString;
exports.mapBindings                 = mapBindings;
exports.createStyleAttributeAST     = createStyleAttributeAST;
exports.toJavaScriptAST             = toJavaScriptAST;
exports.toJavaScriptStyleSheetAST   = toJavaScriptStyleSheetAST;
/* include Not a pure module */
