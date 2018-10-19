const svgson = require("svgson-next").default;
const svgpath = require("svgpath");

const BEZIER_CIRCLE_CONTROL = 0.552284749831;

const Path = {
  lerp: (v0, v1, t) => {
    return (1 - t) * v0 + t * v1;
  },

  circularCurveXFirst: (from, to) => {
    const control = BEZIER_CIRCLE_CONTROL;
    const control1 = `${Path.lerp(from.x, to.x, control)} ${from.y}`;
    const control2 = `${to.x} ${Path.lerp(to.y, from.y, control)}`;
    const endPoint = `${to.x} ${to.y}`;
    return `C${control1} ${control2} ${endPoint}`;
  },

  circularCurveYFirst(from, to) {
    const control = BEZIER_CIRCLE_CONTROL;
    const control1 = `${from.x} ${Path.lerp(from.y, to.y, control)}`;
    const control2 = `${Path.lerp(to.x, from.x, control)} ${to.y}`;
    const endPoint = `${to.x} ${to.y}`;
    return `C${control1} ${control2} ${endPoint}`;
  },

  generateRect: (x, y, width, height, rx, ry) => {
    const path = [
      `M${x + rx} ${y}`,
      `L${x + width - rx} ${y}`,
      Path.circularCurveXFirst(
        { x: x + width - rx, y },
        { x: x + width, y: y + ry }
      ),
      `L${x + width} ${y + height - ry}`,
      Path.circularCurveYFirst(
        { x: x + width, y: y + height - ry },
        { x: x + width - rx, y: y + height }
      ),
      `L${x + rx} ${y + height}`,
      Path.circularCurveXFirst(
        { x: x + rx, y: y + height },
        { x: x, y: y + height - ry }
      ),
      `L${x} ${y + ry}`,
      Path.circularCurveYFirst({ x: x, y: y + ry }, { x: x + rx, y: y }),
      `Z`
    ].join("");

    return path;
  }
};

const Builders = {
  point: (x, y) => ({ x, y }),
  rect: (x, y, width, height) => ({ x, y, width, height }),
  style: (fill, stroke, strokeWidth, strokeLineCap) => ({
    ...(fill !== "none" && { fill: fill || "black" }),
    ...(stroke && stroke !== "none" && { stroke }),
    strokeWidth: strokeWidth != null ? strokeWidth : 1,
    strokeLineCap: strokeLineCap || "butt"
  }),

  circle: (style, center, radius) => ({
    type: "circle",
    data: {
      params: {
        center,
        radius,
        style
      }
    }
  }),
  path: (style, commands) => ({
    type: "path",
    data: {
      params: {
        commands,
        style
      }
    }
  }),
  svg: viewBox => ({
    type: "svg",
    data: {
      params: {
        ...(viewBox && { viewBox })
      }
    }
  }),

  Path: {
    move: to => ({ type: "move", data: { to } }),
    line: to => ({ type: "line", data: { to } }),
    quadCurve: (to, controlPoint) => ({
      type: "quadCurve",
      data: {
        to,
        controlPoint
      }
    }),
    cubicCurve: (to, controlPoint1, controlPoint2) => ({
      type: "cubicCurve",
      data: {
        to,
        controlPoint1,
        controlPoint2
      }
    }),
    close: () => ({ type: "close" })
  }
};

function convertPathCommand(segment, index, x, y) {
  const [command, ...parameters] = segment;

  switch (command) {
    case "M": {
      const [x, y] = parameters;
      return Builders.Path.move(Builders.point(x, y));
    }
    case "L": {
      const [x, y] = parameters;
      return Builders.Path.line(Builders.point(x, y));
    }
    case "H": {
      const [x] = parameters;
      return Builders.Path.line(Builders.point(x, y));
    }
    case "V": {
      const [y] = parameters;
      return Builders.Path.line(Builders.point(x, y));
    }
    case "Z": {
      return Builders.Path.close();
    }
    case "Q": {
      let [qx1, qy1, qx2, qy2] = parameters;

      return Builders.Path.quadCurve(
        Builders.point(qx2, qy2),
        Builders.point(qx1, qy1)
      );
    }
    case "C": {
      const [x1, y1, x2, y2, x3, y3] = parameters;

      return Builders.Path.cubicCurve(
        Builders.point(x3, y3),
        Builders.point(x1, y1),
        Builders.point(x2, y2)
      );
    }
    default:
      console.log("not used", segment);
      return null;
  }
}

function convertPath(string) {
  const parsed = svgpath(string);

  parsed.unarc();
  parsed.unshort();
  parsed.abs();

  const drawCommands = [];

  parsed.iterate((...args) => {
    const command = convertPathCommand(...args);

    if (!command) return;

    drawCommands.push(command);
  });

  return drawCommands;
}

function numberValue(value, defaultValue = 0) {
  if (typeof value === "string") {
    return parseFloat(value);
  } else if (value == null) {
    return defaultValue;
  }
  return value;
}

function convertChild(child, index, context) {
  const { type, name, attributes, children } = child;

  // console.log("child", name);

  switch (name) {
    case "title":
    case "desc":
      return null;
    case "svg": {
      const { viewBox } = attributes;

      const [vx, vy, vw, vh] = viewBox.split(" ").map(parseFloat);

      return Builders.svg(Builders.rect(vx, vy, vw, vh));
    }
    case "path": {
      const { d } = attributes;

      const {
        fill,
        stroke,
        ["stroke-width"]: strokeWidth,
        ["stroke-linecap"]: strokeLineCap
      } = { ...context, ...attributes };

      // console.log("context", context, "attr", attributes);

      return Builders.path(
        Builders.style(
          fill,
          stroke,
          strokeWidth != null ? parseFloat(strokeWidth) : undefined,
          strokeLineCap
        ),
        convertPath(d)
      );
    }
    // Convert polylines to paths
    case "polyline": {
      const { points: rawPoints } = attributes;

      const points = rawPoints.split(" ").reduce((acc, item, index) => {
        if (index % 2 === 0) {
          return [...acc, { x: item }];
        } else {
          acc[acc.length - 1].y = item;
          return acc;
        }
      }, []);

      let path = points
        .map(
          (point, index) => `${index === 0 ? "M" : "L"}${point.x} ${point.y}`
        )
        .join("");

      return convertChild(
        { name: "path", attributes: { d: path, ...attributes } },
        index,
        context
      );
    }
    case "circle": {
      const { cx: rawCx, cy: rawCy, r: rawR } = attributes;
      // const { fill, stroke } = { ...context, ...attributes };

      // return Builders.circle(
      //   Builders.style(fill, stroke),
      //   Builders.point(parseFloat(cx), parseFloat(cy)),
      //   parseFloat(r)
      // );

      let [cx, cy, r] = [rawCx, rawCy, rawR].map(numberValue);

      const path = Path.generateRect(cx - r, cy - r, r * 2, r * 2, r, r);

      return convertChild(
        { name: "path", attributes: { d: path, ...attributes } },
        index,
        context
      );
    }
    case "rect": {
      const {
        x: rawX,
        y: rawY,
        width: rawWidth,
        height: rawHeight,
        rx: rawRx,
        ry: rawRy
      } = attributes;

      let [x, y, width, height, rx, ry] = [
        rawX,
        rawY,
        rawWidth,
        rawHeight,
        rawRx,
        rawRy
      ].map(numberValue);

      if ("ry" in attributes && !("rx" in attributes)) {
        rx = ry;
      } else if ("rx" in attributes && !("ry" in attributes)) {
        ry = rx;
      }

      const path = Path.generateRect(x, y, width, height, rx, ry);

      return convertChild(
        { name: "path", attributes: { d: path, ...attributes } },
        index,
        context
      );
    }
    case "g": {
      return {
        type: "group",
        context: attributes
      };
    }
    default:
      console.log("Unused svg", type, name);
      return;
  }
}

function convertChildren(children, parentElementPath, context) {
  return children.reduce((acc, child, index) => {
    const converted = convertNode(
      child,
      [...parentElementPath, child.name + index.toString()],
      context
    );

    if (!converted) return acc;

    if (converted.type === "group") {
      return [...acc, ...converted.data.children];
    }

    return [...acc, converted];
  }, []);
}

function convertNode(node, elementPath = [], context = {}) {
  const { children } = node;

  const converted = convertChild(node, elementPath, context);

  if (!converted) return null;

  return Object.assign({}, converted, {
    data: {
      ...converted.data,
      elementPath,
      ...(children && {
        children: convertChildren(
          children,
          elementPath,
          converted.context || context
        )
      })
    }
  });
}

function convert(data) {
  return svgson(data).then(parsed => {
    // console.log(parsed);

    const result = convertNode(parsed);
    // console.log(JSON.stringify(result, null, 2));

    return result;
  });
}

// const svgdata = `<?xml version="1.0" encoding="UTF-8"?>
// <svg width="24px" height="24px" viewBox="0 0 24 24" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
//     <!-- Generator: Sketch 52.2 (67145) - http://www.bohemiancoding.com/sketch -->
//     <title>Checkmark</title>
//     <desc>Created with Sketch.</desc>
//     <g id="Checkmark" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
//         <circle id="Oval" fill="#00C121" cx="12" cy="12" r="12"></circle>
//         <polyline id="Path" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" points="6.5 12.6 9.75 15.85 17.25 8.35"></polyline>
//     </g>
// </svg>`;
// const svgdata = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path d="M504 256c0 136.967-111.033 248-248 248S8 392.967 8 256 119.033 8 256 8s248 111.033 248 248zM227.314 387.314l184-184c6.248-6.248 6.248-16.379 0-22.627l-22.627-22.627c-6.248-6.249-16.379-6.249-22.628 0L216 308.118l-70.059-70.059c-6.248-6.248-16.379-6.248-22.628 0l-22.627 22.627c-6.248 6.248-6.248 16.379 0 22.627l104 104c6.249 6.249 16.379 6.249 22.628.001z"/></svg>`;

// convert(svgdata).then(x => {
//   const result = JSON.stringify(x, null, 2);
//   console.log(result);
// });

module.exports = convert;
