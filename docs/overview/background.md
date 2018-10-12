## Background

### The Problem

Airbnb created a design system called [DLS](https://airbnb.design/building-a-visual-language/), used across web, iOS, Android, and React Native. This system helps designers and engineers build new features quickly, while ensuring cross-platform consistency throughout the Airbnb product line.

This design system was defined in Sketch. Design files required manual translation to code for each of the 4 platforms. This translation process was time consuming and error prone. The fundamental problem: most design file formats can't encode all of the necessary details needed to make a perfect translation.

We need a tool for dealing with the layouts, constraints, and states of a real application:

- Layout reflow for multiple screen sizes
- Variable-length text
- Error states
- Lists of different kinds and quantities of items: 0, 1, 2, 10…
- Min and max width/height
- Max lines of text
- Pressed/unpressed state
- Themes (inverse, compact)

Since many decisions must be made that can't be recorded in design files, the individual engineer on each platform often makes a judgement call, resulting in subtle inconsistencies and undocumented decisions.

### The Solution

What if we had a single design system specification that encodes _all_ of the detail needed to accurately translate from design to code? This spec would act as the source of truth. An engineer could then write code which captures the design with _100% accuracy_. If the design file is missing a key piece of information, the designer and engineer could work together to add it to the source of truth.

If an engineer can manually translate this file format into UI code with 100% accuracy, then fundamentally we should also be able to use this file format to generate the UI code.

Lona enables us to build this design system specification graphically and compile it into code for multiple targets.

Lona operates on `.component` files. Lona Studio and the command-line compilers both work with these files. We encourage companies to fork the compilers to suit their own development stack.

Lona Studio isn't intended to replace your existing design tools, but rather augment them. Current design tools are extremely powerful when it comes to creating and iterating on new ideas. However, after new ideas have been designed, they need to be stress tested on different screen sizes and with real data. They then need to be translated into UI code. This is where Lona shines.
