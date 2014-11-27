# Scroll

A smooth scrolling javascript module based on Smooth Scroll by cferdinandi and Easing by photonstorm.

- [Getting Started](#getting-started)
- [How To Use](#how-to-use)
- [Options & Settings](#options-and-settings)
- [License](#license)

## Getting Started

Stable build is `scroll.min.js`, development code is `scroll.coffee`

### Include

```jade
script(src="path/to/scroll.min.js")
```

### Initialize

Ensure this process happens after the dom has loaded - it may be done again at any point to reset the dom options

```jade
script.
    scroll.init({ /* options */ });
```

## How To Use

### Option 1 - JS (Programmatic)

```coffee
    ##
    # Animates the current page to the position of the destination given by selector
    #
    # Note: this will ignore inline options

    scroll.animate '#to', { ###options### }
```

### Option 2 - HTML (Templated)

```jade
    a(data-scroll="#to") <!-- options -->
```

> Note: inline (templated) options will always override programatic options

## Options & Settings

### Defaults

```coffee
speed       : 500
easing      : 'cubic'
offset      : 0
url         : true
before      : null
after       : null
```

### Initialization Object

```coffee
speed       : # Number
easing      : # String
offset      : # Number
url         : # Boolean
before      : # Function ( String[to] )
after       : # Function ( String[to] )
page        : # DOM Element
direction   : # Number (scroll.HORIZONTAL | scroll.VERTICAL)
```

### Animation Object

```coffee
speed       : # Number
easing      : # String
offset      : # Number
url         : # Boolean
before      : # Function ( String[to] )
after       : # Function ( String[to] )
```

### Initialization Inline

```jade
data-scroll-page="required"
data-scroll-direction="horizontal|vertical"
data-scroll-speed="number"
data-scroll-ease="string"
data-scroll-offset="number"
data-scroll-url="boolean"
```

### Animation Inline

```jade
data-scroll-speed="number"
data-scroll-ease="string"
data-scroll-offset="number"
data-scroll-url="boolean"
```

### Easing Options

#### Defaults

 - linear
 - quad
 - quad-in
 - quad-out
 - cubic
 - cubic-in
 - cubic-out
 - quart
 - quart-in
 - quart-out
 - quint
 - quint-in
 - quint-out
 - sin
 - sin-in
 - sin-out
 - expo
 - expo-in
 - expo-out
 - circ
 - circ-in
 - circ-out
 - elastic
 - elastic-in
 - elastic-out
 - back
 - back-in
 - back-out
 - bounce
 - bounce-in
 - bounce-out

#### Custom

```coffee
    scroll.addEasing 'linear', ( t ) -> t
```

## License

[MIT License](http://gomakethings.com/mit/)
