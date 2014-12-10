
(( root, product ) ->

    product = product()

    # register for amd
    if typeof define is 'function' and define.amd
        define 'panorama', product
    # register for commonjs
    else if typeof exports is 'object'
        module.exports = product
    # register to root
    else
        name = 'panorama'
        conflict = root[name]
        root[name] = product
        # provide no conflict to remove from root
        root[name].noConflict = ( ) ->
            tmp = root[name]
            root[name] = conflict
            return tmp

)(window or this, () ->

    css = ".panorama{-webkit-overflow-scrolling:touch;white-space:nowrap;height:100%;overflow-y:hidden;font-size:0;box-sizing:border-box}.panorama .panel{position:relative;display:inline-block;font-size:initial;white-space:initial;vertical-align:top;overflow:auto;height:100%}"

    style = null

    api =
        destroy: ( ) ->
            return if not style
            document.getElementsByTagName('head')[0].removeChild style

        init: ( ) ->
            return if style
            style = document.createElement 'style'
            style.innerHTML = css
            document.getElementsByTagName('head')[0].appendChild style

)
