## FAQ

(Answered by [@dvnabbott](https://twitter.com/dvnabbott))

### Are you still working on this (now that you're not at Airbnb)?

Yes! A few early adopters are currently supporting my work.

### Is Lona ready for production use?

Not without a lot of effort. It would be hard to use without being a contributor or getting support from me. You'll run into bugs, missing features, and missing documentation. If you're interested in contributing or support, open a GitHub issue or reach out to me on Twitter!

### Is Lona ready for hobby use?

Absolutely! While lacking features, Lona Studio is totally usable, and the generated Swift and JS are working and correct for most Lona Studio features (albeit a little ugly in some cases). If you try it and find the lack of features or documentation frustrating, better wait a little longer though!

### Why a native Mac app rather than Electron?

While Electron is fantastic for cross-platform desktop apps, building cross-platform adds a lot of engineering overhead. Airbnb designers and engineers all work on Macs, so I was able to move much faster by focusing only on the Mac platform.

As an example of how building native helps me move quickly: native code has a much higher threshold before performance becomes a serious issue. In my experience building Deco IDE using Electron, performance was an issue I had to address frequently – it was always solvable, but definitely required time and effort. So far, Lona Studio performance has been mostly fine without any optimizations. The app gets slow with hundreds of canvases, but that's not the core use case at the moment, and I'm sure it can be solved with effort.

As an added bonus, it's also much easier to interop with Sketch. For example, Sketch stores some text styles as encoded `NSAttributedString` objects (or at least, it did when I started the project) and uses native Mac text measurement. Lona Studio is able to read and write these directly. It would be difficult to do so in a non-Mac environment.

### Can we use _just_ Lona Studio, rather than starting in another design tool like Sketch?

Yes, but I don't really recommend it. Sketch pioneered an incredibly effective workflow for rapidly iterating on ideas. The infinite canvas, instant artboard duplication, and intuitive hotkeys are key to translating an idea into digital form. Designing in Sketch should be _easy_ and _playful_.

Designing in Lona Studio, by contrast, is intended to be _powerful_ and _precise_. A much greater degree of rigor is required to _build_ the same thing you _mocked up_ in Sketch. You won't have the same ability to rapidly play with different ideas, look at all 10 of them, and continue moving forward from your favorite. Instead, you get to see your design on 5 screen sizes at once in all possible configurations using real data.

### How does the layout algorithm work?

Lona uses flexbox with under the hood, with a couple key differences:

- Lona Studio applies one major simplification: it automatically handles switching certain properties (`align-items`, `justify-content`, and `flex`) based on `flex-direction`, so you don't have to.
- There is no support for `flex-wrap`. This doesn't translate well to other platforms.

When compiling to Swift, the flexbox layout is converted to autolayout constraints automatically. It's pretty magical!

### Why is this Swift code so weird/bad?

When I started Lona, it was my first time writing a native Mac app, and I had practically no Swift experience. The blame entirely falls on me for this. Contributions are welcome!

### Why is this JavaScript code so weird/bad?

Time constraints 😅
