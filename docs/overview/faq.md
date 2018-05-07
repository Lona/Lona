## FAQ

(Answered by [@dvnabbott](https://twitter.com/dvnabbott))

### Why a native Mac app rather than Electron?

While Electron is fantastic for cross-platform desktop apps, building cross-platform adds a lot of engineering overhead. Airbnb designers and engineers all work on Macs, so we can move much faster by focusing only on the Mac platform.

As an example of how building native helps us move quickly: native code has a much higher threshold before performance becomes a serious issue. In my experience building Deco IDE using Electron, performance was an issue I had to address frequently -- it was always solvable, but definitely required time and effort. So far, Lona Studio performance has been mostly fine without any optimizations. The app gets slow with hundreds of canvases, but that's not the core use case at the moment, and I'm sure it can be solved with effort.

As an added bonus, it's also much easier to interop with Sketch. For example, Sketch stores some text styles as encoded `NSAttributedString` objects. Lona Studio is able to read and write these directly. It would be difficult to do so in a non-Mac environment.

### Can we use _just_ Lona Studio, rather than starting in another design tool like Sketch?

Yes, but I don't really recommend it. Sketch pioneered an incredibly effective workflow for rapidly iterating on ideas. The infinite canvas, instant artboard duplication, and intuitive hotkeys are key to translating an idea into digital form. Designing in Sketch should be _easy_ and _playful_.

Designing in Lona Studio, by contrast, is intended to be _powerful_ and _precise_. A much greater degree of rigor is required to _build_ the same thing you _mocked up_ in Sketch. You won't have the same ability to rapidly play with different ideas, look at all 10 of them, and continue moving forward from your favorite. Instead, you get to see your design on 5 screen sizes at once in all possible configurations using real data.

### How does the layout algorithm work?

Lona uses flexbox with [Yoga](https://github.com/facebook/yoga) under the hood. Lona Studio applies one major simplification: it automatically handles switching certain properties (`align-items`, `justify-content`, and `flex`) based on `flex-direction`, so you don't have to.

### Why is this Swift code so weird/bad?

This is my first time writing a native mac app, and I have practically no Swift experience. The blame entirely falls on me for this. Contributions are welcome!

### Why is this JavaScript code so weird/bad?

Time constraints 😅
