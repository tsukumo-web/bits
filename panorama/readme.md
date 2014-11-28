# Panorama

Pure css panorama layout (don't be fooled by the js files, keep reading)

- [Getting Started](#getting-started)
- [How To Use](#how-to-use)
- [License](#license)

## Getting Started

### Option 1

```jade
    link(rel="stylesheet" href="path/to/panorama.min.css")
```

### Option 2

```js
    script(src="path/to/panorama.min.js")
    script.
        panorama.init()
```

### Optional Scroll Fix

Fix scrolling with mouse to move horizontal on panorama

```js
    script(src="path/to/panorama-fix.min.js")
    script.
        panorama-fix.init()
        // note: panorama-fix will not work on its own, this
        //       may come from window['panorama-fix'] or your
        //       require system
```

## How To Use

```jade
// container holds panels
.panorama
    .panel
        // contents here...
```

## License

[MIT License](http://gomakethings.com/mit/)
