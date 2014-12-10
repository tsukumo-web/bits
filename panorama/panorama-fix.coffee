(( root, product ) ->

    product = product()

    # register for amd
    if typeof define is 'function' and define.amd
        define 'panorama-fix', product
    # register for commonjs
    else if typeof exports is 'object'
        module.exports = product
    # register to root
    else
        name = 'panorama-fix'
        conflict = root[name]
        root[name] = product
        # provide no conflict to remove from root
        root[name].noConflict = ( ) ->
            tmp = root[name]
            root[name] = conflict
            return tmp

)(window or this, () ->

    getElementsByClass = ( cls ) ->
      cls = ' ' + cls + ' '
      elem for elem in document.getElementsByTagName('*') when (' ' + elem.className + ' ').indexOf(cls) > -1

    handler = ( evt, delta ) ->
      return if delta % 1 isnt 0 or evt.detail
      target = evt.target
      while target?
        break if target is this
        return if target.scrollHeight > target.clientHeight
        target = target.parentNode

      this.scrollLeft -= delta * 120

    dispatcher = ( evt ) ->
      evt = evt or window.event
      delta = 0
      delta = evt.wheelDelta / 120 if evt.wheelDelta
      delta = -evt.detail / 3 if evt.detail
      handler.call this, evt, delta

    listeners = [ ]
    api =
        destroy: ( ) ->
            return if not listeners.length
            for pan in listeners
                if pan.removeEventListener
                    pan.removeEventListener 'mousewheel', dispatcher, false
                    pan.removeEventListener 'DOMMouseScroll', dispatcher, false
                else if pan.detachEvent
                    pan.detachEvent 'onmousewheel', dispatcher, false
            undefined

        init: ( ) ->
            api.destroy()
            listeners = getElementsByClass 'panorama'
            for pan in listeners
                if pan.addEventListener
                    pan.addEventListener 'mousewheel', dispatcher, false
                    pan.addEventListener 'DOMMouseScroll', dispatcher, false
                else if pan.attachEvent
                    pan.attachEvent 'onmousewheel', dispatcher, false
            undefined

)
