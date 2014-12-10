(( root, product ) ->

    product = product()

    # register for amd
    if typeof define is 'function' and define.amd
        define 'easing', product
    # register for commonjs
    else if typeof exports is 'object'
        module.exports = product
    # register to root
    else
        name = 'easing'
        conflict = root[name]
        root[name] = product
        # provide no conflict to remove from root
        root[name].noConflict = ( ) ->
            tmp = root[name]
            root[name] = conflict
            return tmp

)(window or this, () ->

    # Elastic easing values
    elastic = { }
    elastic.a = 0.1
    elastic.p = 0.4
    if not elastic.a or elastic.a < 1
        elastic.a = 1
        elastic.s = elastic.p / 4
    else
        elastic.s = elastic.p * Math.asin( 1 / elastic.a ) / ( 2 * Math.PI )

    # Back easing values
    back = { }
    back.s = 1.70158
    back.h = 1.70158 * 1.525

    # Bounce easing values
    bounce = { }
    bounce.k = 7.5625
    bounce.a = 1 / 2.75
    # bounce.oa = 0
    # bounce.sa = 0
    bounce.b = 2 / 2.75
    bounce.ob = 0.75
    bounce.sb = 1.5 / 2.75
    bounce.c = 2.5 / 2.75
    bounce.oc = 0.9375
    bounce.sc = 2.25 / 2.75
    # bounce.d = else
    bounce.od = 0.984375
    bounce.sd = 2.625 / 2.75

    bounce.f = ( k ) ->
        switch
            when k < bounce.a then bounce.k * k * k
            when k < bounce.b then bounce.k * ( k -= bounce.sb ) * k + bounce.ob
            when k < bounce.c then bounce.k * ( k -= bounce.sc ) * k + bounce.oc
            else bounce.k * ( k -= bounce.sd ) * k + bounce.od

    'linear'        : ( t ) -> t

    'quad-in'       : ( t ) -> t * t
    'quad-out'      : ( t ) -> t * (2 - t)
    'quad'          : ( t ) ->
        return 0.5 * t * t if ( t *= 2 ) < 1
        return - 0.5 * ( --t * ( t - 2 ) - 1 )

    'cubic-in'      : ( t ) -> t * t * t
    'cubic-out'     : ( t ) -> (--t) * t * t + 1
    'cubic'         : ( t ) ->
        return 0.5 * t * t * t if ( t *= 2 ) < 1
        return 0.5 * ( ( t -= 2 ) * t * t + 2 )

    'quart-in'      : ( t ) -> t * t * t * t
    'quart-out'     : ( t ) -> 1 - (--t) * t * t * t
    'quart'         : ( t ) ->
        return 0.5 * t * t * t * t if ( t *= 2 ) < 1
        return - 0.5 * ( ( t -= 2 ) * t * t * t - 2 )

    'quint-in'      : ( t ) -> t * t * t * t * t
    'quint-out'     : ( t ) -> 1 + (--t) * t * t * t * t
    'quint'         : ( t ) ->
        return 0.5 * t * t * t * t * t if ( t *= 2 ) < 1
        return 0.5 * ( ( t -= 2 ) * t * t * t * t + 2 )

    'sin-in'        : ( t ) -> 1 - Math.cos t * Math.PI / 2
    'sin-out'       : ( t ) -> Math.sin t * Math.PI / 2
    'sin'           : ( t ) ->
        0.5 * ( 1 - Math.cos( Math.PI * t ) )

    'expo-in'       : ( t ) -> if t is 0 then 0 else Math.pow 1024, t - 1
    'expo-out'      : ( t ) -> if t is 1 then 1 else 1 - Math.pow 2, - 10 * t
    'expo'          : ( t ) ->
        return t if t in [0, 1]
        return 0.5 * Math.pow 1024, t - 1 if (t *= 2) < 1
        return 0.5 * ( - Math.pow( 2, - 10 * ( t - 1 ) ) + 2 )

    'circ-in'       : ( t ) -> 1 - Math.sqrt 1 - t * t
    'circ-out'      : ( t ) -> Math.sqrt  1 - ( --t * t )
    'circ'          : ( t ) ->
        return - 0.5 * ( Math.sqrt( 1 - t * t) - 1) if ( t *= 2 ) < 1
        return 0.5 * ( Math.sqrt( 1 - ( t -= 2) * t) + 1 )

    'elastic-in'    : ( t ) ->
        return t if t in [0, 1]
        return - ( elastic.a * Math.pow( 2, 10 * ( t -= 1 ) ) * Math.sin( ( t - elastic.s ) * ( 2 * Math.PI ) / elastic.p ) )
    'elastic-out'   : ( t ) ->
        return t if t in [0, 1]
        return ( elastic.a * Math.pow( 2, - 10 * t) * Math.sin( ( t - elastic.s ) * ( 2 * Math.PI ) / elastic.p ) + 1 )
    'elastic'       : ( t ) ->
        return - 0.5 * ( elastic.a * Math.pow( 2, 10 * ( t -= 1 ) ) * Math.sin( ( t - elastic.s ) * ( 2 * Math.PI ) / elastic.p ) ) if ( t *= 2 ) < 1
        return elastic.a * Math.pow( 2, -10 * ( t -= 1 ) ) * Math.sin( ( t - elastic.s ) * ( 2 * Math.PI ) / elastic.p ) * 0.5 + 1

    'back-in'       : ( t ) -> t * t * ( ( back.s + 1 ) * t - back.s )
    'back-out'      : ( t ) -> --t * t * ( ( back.s + 1 ) * t + back.s ) + 1
    'back'          : ( t ) ->
        return 0.5 * ( t * t * ( ( back.h + 1 ) * t - back.h ) ) if ( t *= 2 ) < 1
        return 0.5 * ( ( t -= 2 ) * t * ( ( back.h + 1 ) * t + back.h ) + 2 )

    'bounce-in'     : ( t ) -> 1 - bounce.f 1 - t
    'bounce-out'    : bounce.f
    'bounce'        : ( t ) ->
        return 1 - bounce.f( 1 - t * 2) * 0.5 if t < 0.5
        return bounce.f( t * 2 - 1 ) * 0.5 + 0.5
)

# inspired by Easing, photonstorm
