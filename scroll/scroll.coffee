(( root, product ) ->

    # register for amd
    if typeof define is 'function' and define.amd
        define 'scroll', [ 'hammer', 'anim' ], product
    # register for commonjs
    else if typeof exports is 'object'
        module.exports = product require('hammer'), require('anim')
    # register to root (assume dependencies also in root)
    else
        name = 'scroll'
        conflict = root[name]
        root[name] = product root.Hammer, root.anim
        # provide no conflict to remove from root
        root[name].noConflict = ( ) ->
            tmp = root[name]
            root[name] = conflict
            return tmp

)(window or this, (( helper, Hammer, anim ) ->

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
        supported   : !!document.querySelector and !!document.querySelectorAll and !!document.addEventListener and !!document.removeEventListener



    ##
    # private global vriables for scroll
    # @module g
    # @private
    g =

        ##
        # event manager
        #
        # @memberOf g
        # @property events
        # @type Object
        # @private
        events      : new Hammer.Manager document.body

        ##
        # pages to scroll when animating
        #
        # this may only be set at the time of init
        #
        # @memberOf g
        # @property pages
        # @type Object
        # @private
        pages       : null

        ##
        # cached default settings
        # @memberOf g
        # @property defaults
        # @type Object
        # @private
        defaults    :
            speed       : 500
            easing      : 'expo'
            offset      : 0
            url         : true
            before      : null
            after       : null

    ##
    # scrolls the page in the set direction
    # @private
    # @param {Object} page information
    # @param {Number} dir direction of scroll
    # @param {Number} amount distance to scroll
    scroll = ( page, dir, amount ) ->
        if dir is api.VERTICAL
            page.scrollTop = amount
        else
            page.scrollLeft = amount

    ##
    # retrieves the current scroll offset of the page in the proper direction
    # @private
    # @param {Object} page element being scrolled
    # @param {Number} dir direction of scroll
    # @return {Number} scroll offset
    offset = ( page, dir ) ->
        if dir is api.VERTICAL
            return page.scrollTop
        else
            return page.scrollLeft

    ##
    # retrieves the position to end scrolling at
    # @private
    # @param {Object} page element being scrolled
    # @param {Number} dir direction of scroll
    # @param {Object} to dom element to scroll to
    # @param {Number} offset to factor in
    findEnd = ( page, dir, to, offset ) ->
        pos = 0
        if to.offsetParent
            while to
                pos += if dir is api.VERTICAL then to.offsetTop else to.offsetLeft
                to = to.offsetParent
        Math.max (pos - offset), 0

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
        attr = el.getAttribute 'data-scroll-what'
        ret['page'] = String attr if attr
        attr = el.getAttribute 'data-scroll-direction'
        if attr
            ret['direction'] = if attr is 'horizontal' then api.HORIZONTAL else api.VERTICAL
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
        return console.warn 'module not initialized' if not g.pages

        page = g.pages[options.page] or g.pages.body
        # setup
        settings = helper.merge page.settings or { }, options or { }

        # defaults
        settings.offset = parseInt settings.offset, 10 # enforce integer
        settings.speed  = parseInt settings.speed,  10 # enforce integer
        settings.easing = String settings.easing       # enforce string

        # find elements elem
        elem = document.querySelector to

        # warn if the element to scroll to could not be found
        return console.warn 'element not found matching', to if not elem

        # position and distance
        start_pos = offset page.elem, page.direction
        distance = findEnd(page.elem, page.direction, elem, settings.offset) - start_pos
        # percentage = 0

        return if not distance

        # clear fix hehe
        scroll 0 if start_pos is 0

        # update the url
        updateUrl to, settings.url

        return anim
            auto: true,
            ease: settings.easing
            speed: settings.speed
            next: ( t ) ->
                scroll page.elem, page.direction, Math.floor start_pos + distance * t


    touchdown = false
    touchmove = false

    ##
    # document handler begins timer for click or tap
    # @private
    # @param {Object} evt dom event triggered by event listener
    start_handler = ( evt ) ->
        touchdown = true
        touchmove = false
        setTimeout ( ) ->
            return if touchdown or touchmove
            el = helper.closest evt.target, '[data-scroll]'
            if el
                evt.preventDefault()
                g.scrolling.stop() if g.scrolling
                g.scrolling = api.animate el.getAttribute('data-scroll'), getOptionsFromElement el
        , 200

    ##
    # document handler ends touch or mouse down flag
    # @private
    # @param {Object} evt dom event triggered by event listener
    end_handler = ( evt ) ->
        touchdown = false

    ##
    # document handler touch or mouse moved flag
    # @private
    # @param {Object} evt dom event triggered by event listener
    move_handler = ( evt ) ->
        touchmove = true

    ##
    # removes event bindings and resets settings
    api.destroy = ( ) ->
        document.removeEventListener 'mousedown', start_handler, false
        document.removeEventListener 'touchstart', start_handler, false
        document.removeEventListener 'mouseup', end_handler, false
        document.removeEventListener 'touchend', end_handler, false
        document.removeEventListener 'touchcancel', end_handler, false
        document.removeEventListener 'mousemove', move_handler, false
        document.removeEventListener 'touchmove', move_handler, false

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

        # remove any previous and event handlers
        api.destroy()
        # remove any previous page settings
        g.pages =
            body:
                elem: document.body
                direction: api.VERTICAL
                settings: g.defaults

        # find the page by selector
        pages = document.querySelectorAll '[data-scroll-page]'

        for page in pages
            name = page.getAttribute 'data-scroll-page'
            # retrieve inline options if the element existed
            settings = helper.merge g.defaults, options or { }, getOptionsFromElement page

            direction = page.getAttribute 'data-scroll-direction'
            direction = if direction is 'horizontal' then api.HORIZONTAL else api.VERTICAL

            g.pages[name] =
                elem: page
                direction: direction
                settings: settings

        # bind click handler
        events.on 'tap', start_handler

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
