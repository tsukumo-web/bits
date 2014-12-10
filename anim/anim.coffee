(( root, product ) ->

    # register for amd
    if typeof define is 'function' and define.amd
        define 'anim', [ 'easing' ], product
    # register for commonjs
    else if typeof exports is 'object'
        module.exports = product require 'easing'
    # register to root (assume dependencies also in root)
    else
        name = 'anim'
        conflict = root[name]
        root[name] = product root.easing
        # provide no conflict to remove from root
        root[name].noConflict = ( ) ->
            tmp = root[name]
            root[name] = conflict
            return tmp

)(window or this, (( easing ) ->

    ##
    # Animates anything by providing a step callback
    #
    # @param {Object}   options          settings for animation
    # @param {Function} options.step     callback for step update
    # @param {Number}   options.step.percent percent completion
    # @param {Number}   options.step.time    time of step
    # @param {String}   [options.ease]   easing function (defined by easing)
    # @param {Number}   [options.speed]  speed of animation
    # @param {Boolean}  [options.auto]   auto start animation
    # @param {Funciton} [options.before] callback for before animation
    # @param {Function} [options.after]  callback for after animation
    # @return {Object} start and stop functions for animation
    anim = ( options ) ->
        if not options
            return console.error 'options are required for anim'
        if not options.step
            return console.error 'step callback is requred for anim'

        options.ease = 'linear' if not options.ease
        options.speed = 500 if not options.speed

        time = 0
        interval = null

        ease = easing[options.ease]
        if not easing
            console.warn 'easing function ', options.ease, 'not found'
            ease = ( t ) -> t


        stop = ( ) ->
            return if not interval
            clearInterval interval
            time = 0
            interval = null
            options.after?()

        keep = ( ) ->
            percentage = Math.min (time += 16) / options.speed, 1
            options.step ease(percentage), time
            stop() if percentage is 1

        start = ( ) ->
            stop() if interval
            options.before?()
            interval = setInterval keep, 16

        if options.auto
            start()

        start: start
        stop: stop

))
