(( root, product ) ->

    name = 'scroll'

    # register for amd
    if typeof define is 'function' and define.amd
        define name, [ 'easing' ], product
    # register for commonjs
    else if typeof exports is 'object'
        module.exports = product require 'easing'
    # register to root (assume dependencies also in root)
    else
        conflict = root[name]
        root[name] = product root.easing
        # provide no conflict to remove from root
        root[name].noConflict = ( ) ->
            tmp = root[name]
            root[name] = conflict
            return tmp

)(window or this, (( helper, easing ) ->

    ##
    # scroll properties and functions
    # @module scroll
    api =

        ##
        # scroll direction horizontal
        # @memberOf scroll
        # @property HORIZONTAL
        # @type Number
        HORIZONTAL  : 0

        ##
        # scroll direction vertical
        # @memberOf scroll
        # @property VERTICAL
        # @type Number
        VERTICAL    : 1

        ##
        # flag set if all dependencies are found
        # @memberOf scroll
        # @property supported
        # @type Boolean
        supported   : !!document.querySelector and !!document.addEventListener and !!document.removeEventListener



    ##
    # private global vriables for scroll
    # @module g
    # @private
    g =

        ##
        # easing functions
        # @memberOf g
        # @property easing
        # @type Object
        # private
        easing: easing

        ##
        # cached settings used by new scroll instances
        # @memberOf g
        # @property settings
        # @type Object
        # @private
        settings    : null

        ##
        # page to scroll when animating
        #
        # this may only be set at the time of init
        #
        # @memberOf g
        # @property page
        # @type Object
        # @private
        page        : document.body

        ##
        # direction to scroll when animating
        #
        # this may only be set at the time of init
        #
        # @memberOf g
        # @property direction
        # @type Object
        # @private
        direction   : api.VERTICAL

        ##
        # cached default settings
        # @memberOf g
        # @property defaults
        # @type Object
        # @private
        defaults    :
            speed       : 500
            easing      : 'cubic'
            offset      : 0
            url         : true
            before      : null
            after       : null

    ##
    # adds an easing function
    # @memberOf api
    # @method addEasing
    # @param {String} name key for easing function
    # @param {Function} func easing function
    # @param {Number} func.t time of completion in percent
    api.addEasing = ( name, func ) -> g.easing[name] = func


    ##
    # scrolls the page in the set direction
    # @private
    # @param {Number} amount distance to scroll
    scroll = ( amount ) ->
        if g.direction is api.VERTICAL
            g.page.scrollTop = amount
        else
            g.page.scrollLeft = amount

    ##
    # retrieves the current scroll offset of the page in the proper direction
    # @private
    # @return {Number} scroll offset
    offset = ( ) ->
        if g.direction is api.VERTICAL
            return g.page.scrollTop
        else
            return g.page.scrollLeft

    ##
    # retrieves the size of the page in the proper direction
    # @private
    # @return {Number} full size of the page
    #size = ( ) ->
    #    if g.direction is api.VERTICAL
    #        return Math.max g.page.scrollHeight, g.page.offsetHeight, g.page.offsetWidth
    #    else
    #        return Math.max g.page.scrollWidth, g.page.offsetWidth, g.page.clientWidth

    ##
    # retrieves the position to end scrolling at
    # @private
    # @param {Object} to dom element to scroll to
    # @param {Number} offset to factor in
    findEnd = ( to, offset ) ->
        pos = 0
        if to.offsetParent
            while to
                pos += if g.direction is api.VERTICAL then to.offsetTop else to.offsetLeft
                to = to.offsetParent
        pos -= offset
        Math.max pos, 0

    ##
    # changes the url to match the scroll position
    # @private
    # @param {String} element to scroll to
    # @param {Boolean} if url should be updated
    updateUrl = ( to, url ) ->
        if url or String(url) is 'true'
            history.pushState? { pos: to.id }, '', window.location.pathname + to

    ##
    # gather potential options from an element
    # @private
    # @param {Object} el element from the dom to check for options in
    # @return {Object} filled object of options if they exist
    getOptionsFromElement = ( el ) ->
        ret = { }
        attr = el.getAttribute 'data-scroll-ease'
        ret['easing'] = attr if attr
        attr = el.getAttribute 'data-scroll-speed'
        ret['speed'] = Number attr if attr
        attr = el.getAttribute 'data-scroll-offset'
        ret['offset'] = Number attr if attr
        attr = el.getAttribute 'data-scroll-url'
        ret['url'] = String(attr) is 'true' if attr
        ret

    ##
    # animates a scroll
    # @param {String} to        selector for element to scroll to
    # @param {Object} [options] inline options
    # @param {String} [options.easing] name of easing function to use
    # @param {Number} [options.speed]  duration of animation
    # @param {Number} [options.offset] distance to offset scroll
    # @return {Object} object with stop function
    api.animate = ( to, options ) ->

        # setup
        settings = helper.merge g.settings or g.defaults, options or { }

        # defaults
        settings.offset = parseInt settings.offset, 10 # enforce integer
        settings.speed  = parseInt settings.speed,  10 # enforce integer
        settings.easing   = String settings.easing     # enforce string

        # find elements elem
        elem = document.querySelector to

        # warn if the element to scroll to could not be found
        return console.warn 'element not found matching', to if not elem

        # position and distance
        start_pos = offset()
        distance = findEnd(elem, g.settings.offset) - start_pos
        # percentage = 0

        # timing
        time = 0
        interval = null

        easing = g.easing[settings.easing]
        if not easing
            console.warn 'easing function ', settings.easing, 'not found'
            easing = g.easing['linear']

        # stops animation
        stop = ( ) ->
            clearInterval interval
            elem.focus()
            settings.after? to

        # keeps animation going
        keep = ( ) ->
            percentage = Math.min (time += 16) / settings.speed, 1
            scroll Math.floor start_pos + distance * easing percentage
            stop() if percentage is 1

        # starts animation
        start = ( ) ->
            settings.before? to
            interval = setInterval keep, 16

        # clear fix hehe
        scroll 0 if offset() is 0

        # update the url and begin animation
        updateUrl to, settings.url
        start()

        return stop : stop

    ##
    # document handler begins animation on data-scroll element click / tap
    # @private
    # @param {Object} evt dom event triggered by event listener
    handler = ( evt ) ->
        el = helper.closest evt.target, '[data-scroll]'
        if el
            evt.preventDefault()
            g.scrolling.stop() if g.scrolling
            g.scrolling = api.animate el.getAttribute('data-scroll'), getOptionsFromElement el

    ##
    # removes event bindings and resets settings
    api.destroy = ( ) ->
        return if not g.settings
        document.removeEventListener 'click', handler, false
        g.settings = null

    ##
    # initializes settings and event bindings
    #
    # settings oop: inline[to] > inline[page] > options > defaults
    #
    # @param {Object} [options] potential options
    # @param {String} [options.easing] name of easing function to use
    # @param {Number} [options.speed]  duration of animation
    # @param {Number} [options.offset] distance to offset scroll
    # @param {Object} [options.page]   dom element to scroll
    # @param {Number} [options.direction] direction to scroll in
    api.init = ( options ) ->
        return console.warn 'module not supported' if not api.supported

        # remove any previous settings and event handlers
        api.destroy()

        # find the page by selector
        page = document.querySelector '[data-scroll-page]'
        # retrieve inline options if the element existed
        inline = getOptionsFromElement page if page

        # merge settings in oop and store them
        g.settings = helper.merge g.defaults, options or { }, inline

        # set page and direction based on settings
        if g.settings.page
            g.page = g.settings.page
        if g.settings.direction
            g.direction = g.settings.direction

        # override page and direction with inline options
        if page
            g.page = page
            dir = page.getAttribute 'data-scroll-direction'
            if dir and dir is 'horizontal'
                g.direction = api.HORIZONTAL
            else if dir and dir is 'vertical'
                g.direction = api.VERTICAL

        # bind click handler
        document.addEventListener 'click', handler, false

    # return the public api (from factory)
    return api

).bind(this, (() ->

    ##
    # helper function - merge objects
    # @private
    # @param {Object} obj... multiple objects to merge
    # @return {Object} merged result
    merge: ( obj... ) ->
        result = { }
        for o in obj
            for key, val of o
                result[key] = val
        return result

    ##
    # helper function - find closest parent with selector
    # @private
    # @param
    closest: ( el, selector ) ->
        type = selector.charAt 0
        selector = selector.substr 1
        while el and el isnt document
            switch type
                when '.'
                    return el if el.classList.contains selector
                when '#'
                    return el if el.id is selector
                when '['
                    return el if el.hasAttribute selector.substr 0, selector.length - 1
            el = el.parentNode
        false

)()))

# inspired by Smooth Scroll, cferdinandi
