
(( root, product ) ->

    # register for amd
    if typeof define is 'function' and define.amd
        define 'datepicker', [ 'moment' ], product
    # register for commonjs
    else if typeof exports is 'object'
        module.exports = product require 'moment'
    # register to root (assume dependencies also in root)
    else
        name = 'datepicker'
        conflict = root[name]
        root[name] = product root.moment
        # provide no conflict to remove from root
        root[name].noConflict = ( ) ->
            tmp = root[name]
            root[name] = conflict
            return tmp

)(window or this, (( template, moment ) ->

    constants =
        range:
            years: 12
        yy: 'yy'
        mm: 'mm'
        dd: 'dd'


    class DatePicker

        @moment = moment

        constructor: ( dom, options ) ->
            that = this
            @now = moment()

            dom.style.overflow = 'hidden'

            options = { } if not options
            options.size = 'short' if not options.size
            options.start = @now if not options.start
            @options = options

            weekdays = (options.size is 'min' and moment.weekdaysMin or options.size is 'short' and moment.weekdaysShort or moment.weekdays)()
            weekdays = weekdays.concat weekdays.splice 0, moment.localeData()._week.dow
            @view = template.create(
                ((options.size in ['min', 'short'] and moment.monthsShort or moment.months) '-MMM-'),
                weekdays
            )
            dom.appendChild @view.dom

            @page = constants.yy # yy, mm, dd

            bound_prev = @prev.bind this
            bound_next = @next.bind this
            @view.yy.controls.prev.dom.parentNode.onclick = bound_prev
            @view.yy.controls.next.dom.parentNode.onclick = bound_next
            for child in @view.yy.content.children
                child.parentNode.onclick = ( ) ->
                    that.click.call that, this
            @view.mm.header.dom.parentNode.onclick = @gotoYear.bind this
            @view.mm.controls.prev.dom.parentNode.onclick = bound_prev
            @view.mm.controls.next.dom.parentNode.onclick = bound_next
            for child in @view.mm.content.children
                child.parentNode.onclick = ( ) ->
                    that.click.call that, this
            @view.dd.header.dom.parentNode.onclick = @gotoMonth.bind this
            @view.dd.controls.prev.dom.parentNode.onclick = bound_prev
            @view.dd.controls.next.dom.parentNode.onclick = bound_next
            for child, i in @view.dd.content.children
                continue if i < 7
                child.parentNode.onclick = ( ) ->
                    that.click.call that, this

            @selected =
                yy: options.start.year()
                mm: options.start.month()
                dd: options.start.date()

            @viewing =
                yy: options.start.year()
                mm: options.start.month()

            @gotoDay()


        prev: ( ) ->
            switch @page
                when constants.yy
                    @viewing.yy -= constants.range.years
                    @renderYear()
                when constants.mm
                    @viewing.yy--
                    @renderMonth()
                when constants.dd
                    @viewing.mm--
                    if @viewing.mm < 0
                        @viewing.mm = 11
                        @viewing.yy--
                    @renderDay()
        next: ( ) ->
            switch @page
                when constants.yy
                    @viewing.yy += constants.range.years
                    @renderYear()
                when constants.mm
                    @viewing.yy++
                    @renderMonth()
                when constants.dd
                    @viewing.mm++
                    if @viewing.mm > 11
                        @viewing.mm = 0
                        @viewing.yy++
                    @renderDay()

        setYear: ( yy ) ->
            @selected.yy = yy
            @viewing.mm = mm
            @onchange? @getMoment()
            @render()
        setMonth: ( mm ) ->
            @selected.mm = mm
            @viewing.mm = mm
            @onchange? @getMoment()
            @render()
        setDay: ( dd ) ->
            @selected.dd = dd
            @onchange? @getMoment()
            @render()
        set: ( yy, mm, dd ) ->
            if not mm and not dd
                if typeof yy is 'string'
                    split = yy.split '-'
                    yy = parseInt split[0], 10
                    mm = (parseInt split[1], 10) - 1
                    dd = parseInt split[2], 10
                else
                    time = yy
                    yy = time.year()
                    mm = time.month()
                    dd = time.date()

            @selected.yy = yy
            @viewing.yy = yy
            @selected.mm = mm
            @viewing.mm = mm
            @selected.dd = dd
            @onchange? @getMoment()
            @render()

        get: ( ) -> @selected

        getMoment: ( ) ->
            mm = ('0' + (@selected.mm + 1)).substr -2
            dd = ('0' + @selected.dd).substr -2

            return moment "#{@selected.yy}-#{mm}-#{dd}"


        click: ( elem ) ->
            switch @page
                when constants.yy
                    @viewing.yy = Number elem.className.match(/yy-(\d+)/)[1]
                    @gotoMonth()
                when constants.mm
                    @viewing.mm = Number elem.className.match(/mm-(\d+)/)[1]
                    @gotoDay()
                when constants.dd
                    @selected.yy = Number elem.className.match(/yy-(\d+)/)[1]
                    @selected.mm = Number elem.className.match(/mm-(\d+)/)[1]
                    @selected.dd = Number elem.className.match(/dd-(\d+)/)[1]

                    diff = @selected.mm - @viewing.mm
                    if diff is -1 or diff > 1
                        @prev()
                    else if diff is 1 or diff < -1
                        @next()
                    else # diff is 0
                        for child in elem.parentNode.children
                            child.classList.remove 'selected'
                        elem.classList.add 'selected'

                    @onchange? @getMoment()


        renderYear: ( ) ->
            start = @viewing.yy - constants.range.years / 2
            @view.yy.header.dom.innerHTML = start + ' - ' + (start + constants.range.years - 1)
            for child in @view.yy.content.children
                child.parentNode.className = "yy yy-#{start}"
                child.innerHTML = start
                if @now.year() is start
                    child.parentNode.classList.add 'today'
                if @selected.yy is start
                    child.parentNode.classList.add 'selected'
                start++

        renderMonth: ( ) ->
            @view.mm.header.dom.innerHTML = @viewing.yy
            for child, i in @view.mm.content.children
                child.parentNode.className = "yy-#{@viewing.yy} mm mm-#{i}"
                if @now.year() is @viewing.yy and @now.month() is i
                    child.parentNode.classList.add 'today'
                if @selected.yy is @viewing.yy and @selected.mm is i
                    child.parentNode.classList.add 'selected'

        renderDay: ( ) ->
            start = moment("""#{@viewing.yy}-#{"0#{@viewing.mm + 1}".substr -2}-01""").startOf 'week'
            @view.dd.header.dom.innerHTML =  ((@options.size in ['min', 'short'] and moment.monthsShort or moment.months) '-MMM-', @viewing.mm) + ' ' + @viewing.yy
            for child, i in @view.dd.content.children
                continue if i < 7
                child.parentNode.className = "yy-#{start.year()} mm-#{start.month()} dd dd-#{start.date()}"
                child.innerHTML = start.date()
                if @viewing.mm < start.month()
                    child.parentNode.classList.add 'mm-next'
                else if @viewing.mm > start.month()
                    child.parentNode.classList.add 'mm-prev'
                if @now.year() is start.year() and @now.month() is start.month() and @now.date() is start.date()
                    child.parentNode.classList.add 'today'
                if @selected.yy is start.year() and @selected.mm is start.month() and @selected.dd is start.date()
                    child.parentNode.classList.add 'selected'
                start.add 1, 'd'


        render: ( ) ->
            switch @page
                when constants.yy then return @renderYear()
                when constants.mm then return @renderMonth()
                when constants.dd then return @renderDay()

        gotoYear: ( ) ->
            @page = constants.yy
            @renderYear()
            @view.yy.dom.classList.remove 'hide'
            @view.yy.dom.classList.remove 'below'
            @view.mm.dom.classList.add 'hide'
            @view.mm.dom.classList.remove 'below'
            @view.mm.dom.classList.add 'above'
            @view.dd.dom.classList.add 'hide'
            @view.dd.dom.classList.add 'above'
        gotoMonth: ( ) ->
            @page = constants.mm
            @renderMonth()
            @view.yy.dom.classList.add 'hide'
            @view.yy.dom.classList.add 'below'
            @view.mm.dom.classList.remove 'hide'
            @view.mm.dom.classList.remove 'below'
            @view.mm.dom.classList.remove 'above'
            @view.dd.dom.classList.add 'hide'
            @view.dd.dom.classList.add 'above'
        gotoDay: ( ) ->
            @page = constants.dd
            @renderDay()
            @view.yy.dom.classList.add 'hide'
            @view.yy.dom.classList.add 'below'
            @view.mm.dom.classList.add 'hide'
            @view.mm.dom.classList.add 'below'
            @view.mm.dom.classList.remove 'above'
            @view.dd.dom.classList.remove 'hide'
            @view.dd.dom.classList.remove 'above'


).bind(this, (() ->

    t_controls =
        "
        <div class='controls'>
            <div class='prev'>
                <div>
                    <div>&lt;</div>
                </div>
            </div>
            <div class='next'>
                <div>
                    <div>&gt;</div>
                </div>
            </div>
        </div>
        ".replace /> </g, '><'

    t_header =
        "<header><div></div></header>"

    t_content = ( page, cnt ) ->
        """<ul>#{("<li class='#{page}'><div></div></li>" while cnt--).join ''}</ul>"""

    t_page = ( page, cnt ) ->
        "
        <section class='page #{page}s'>
            #{t_header}
            #{t_controls}
            #{t_content page, cnt}
        </section>
        ".replace /> </g, '><'

    template = document.createElement 'div'
    template.className = 'datepicker'
    template.innerHTML = "#{t_page 'yy',12}#{t_page 'mm',12}#{t_page 'dd',49}"
    map = ( o, d ) ->

        o.controls = dom: o.dom.children[1]
        o.controls.prev = dom: o.controls.dom.children[0].firstChild
        o.controls.next = dom: o.controls.dom.children[1].firstChild
        o.header = dom: o.dom.children[0].firstChild
        o.content = dom: o.dom.children[2]
        o.content.children = (c.firstChild for c in o.content.dom.children)
        o.content.children[i].innerHTML = data for data, i in d if d
        undefined

    create: ( months, weekdays ) ->

        view = dom: template.cloneNode true

        view.yy = dom: view.dom.children[0]
        map view.yy

        view.mm = dom: view.dom.children[1]
        map view.mm, months

        view.dd = dom: view.dom.children[2]
        map view.dd, weekdays
        for child, i in view.dd.content.children
            break if i > 6
            child.parentNode.className = 'ww ww-' + i

        return view

)()))
