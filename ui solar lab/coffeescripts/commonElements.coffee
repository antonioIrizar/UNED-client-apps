class CommonElements
    solar:true
    timeText: null
    batteryText: null
    wsData: null
    time: 0

    constructor: (@wsData, @solar) ->
        @selectNameVar()
        @battery()
        @time()
        @buttons()
        document.addEventListener 'ESDOn', () => 
            if @time isnt 0
                $('#countdown').timeTo 
                    seconds: @time
                    start: true
                @time = 0
        , false

    battery: ->
        p = new Item "p", ["id", "class"], ["textBattery", "text-center"], "10%", false, null
        imgBattery = new Item "img", ["src", "class", "alt"], ["images/battery1.png", "img-responsive", "battery"], null, false, null

        strong = new Item "strong", ["id"], ["batteryText"], @batteryText, false, null
        span = new Item "span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null
        #data-content put any
        a = new Item "a", ["class", "data-container", "data-toggle", "tabindex", "data-trigger", "data-content"], ["info-pop-up", "body", "popover", "0", "focus", "And here's some amazing content. It's very engaging. Right?"], null, true, [span]
       
        divSlider = new Item "div", ["id", "class"], ["slider-battery", "slider slider-battery"], null, false, null
        div = new Item "div", ["class"], ["slidera"], null, true, [divSlider]

        bigElementBattery = new Item "div", ["class"], ["form-group"], null, true, [strong, a, div]

        battery = new Element()
        battery.specialElement [p, imgBattery], [bigElementBattery]

        parent = document.getElementById "elementsCommons"
        parent.appendChild battery.div

        new Slider 'slider-battery', 10, 1, [10], [100], 10, 2, '%'

    time: ->
        #chargin mode the minimun time is 300 seconds and max 1800
        #dischragin mode the minimun time is 10 seconds and max 90

        smallElementTime = new Item "div", ["id"], ["countdown"], null, false, null

        strong = new Item "strong", ["id"], ["timeText"], @timeText, false, null
        span = new Item "span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null
        #data-content put any
        a = new Item "a", ["href", "data-toggle","data-target"], ["#", "modal", "#myModal"], null, true, [span]
       
        divSlider = new Item "div", ["id", "class"], ["slider-time", "slider slider-time"], null, false, null
        div = new Item "div", ["class"], ["slidera"], null, true, [divSlider]

        bigElementTime = new Item "div", ["class"], ["form-group"], null, true, [strong, a, div]

        time = new Element()
        time.specialElement [smallElementTime], [bigElementTime] 

        parent = document.getElementById "elementsCommons"
        parent.appendChild time.div

        if not @solar 
            minTime = [0, 10]
            maxTime = [90]
            middle = 10
            values = [0, 10, 30, 60, 90]
        else
            minTime = [0, 300]
            maxTime = [1800]
            middle = 300
            values = [0, 300, 600, 900, 1200, 1500, 1800]

        @espacialSlider 'slider-time', 0, minTime, middle, maxTime, values, 3, '\'\'' 

        $('#countdown').timeTo({
            seconds:1,
            fontSize: 14
        })
        
    buttons: ->
        div1 = new Item "div", ["id"], ["adaptToHeight"], null, false, null

        #remember varinit in onclick event for function. Improve this
        buttonStart = new Item "button", ["id", "class", "type", "onclick"], ["startExperiment", "btn btn-success", "button", "varInit.startExperiments()"], "Start", false, null
        buttonStop = new Item "button", ["id", "class", "type","style", "onclick"], ["stop", "btn btn-primary", "button", "margin-left: 4px", "varInit.stopExperiment()"], "Stop", false, null
        buttonReset = new Item "button", ["id", "class", "type","style", "onclick"], ["reset", "btn btn-danger", "button", "margin-left: 4px", "varInit.resetExperiment()"], "Reset", false, null
        
        form = new Item "form", ["class", "role", "autocomplete"], ["form", "form", "off"], null, true, [buttonStart, buttonStop, buttonReset]
        div2 = new Item "div", ["class"], ["center-block text-center"], null, true, [form]

        button = new Element()
        button.standardElement [div1, div2]

        parent = document.getElementById "elementsCommons"
        parent.appendChild button.div

    selectNameVar: ->
        if @solar
            @timeText = "Time charging"
            @batteryText = "How much charge do you want?"
           
        else
            @timeText = "Time discharging"
            @batteryText = "How much discharge do you want?" 
            
    mySwitch: (@solar)->
        @selectNameVar()
        if not @solar 
            minTime = [0, 10]
            maxTime = [90]
            middle = 10
            values = [0, 10, 30, 60, 90]
        else
            minTime = [0, 300]
            maxTime = [1800]
            middle = 300
            values = [0, 300, 600, 900, 1200, 1500, 1800]

        @espacialSlider 'slider-time', 0, minTime, middle, maxTime, values, 3, '\'\'' 
        
        $('.slider-time').val 0
    
        document.getElementById("timeText").innerHTML = @timeText
        document.getElementById("batteryText").innerHTML = @batteryText

    sendTime: ->
        @time = parseInt $('.slider-time').val()
        if @time isnt 0
            $('#countdown').timeTo
                seconds: @time
                start: false
            @wsData.sendActuatorChange 'Elapsed', @time.toString()

    sendJouls: ->
        jouls = realValueToSend(@wsData.battery, parseInt $(".slider-battery").val())
        if jouls isnt 0
            @wsData.sendActuatorChange 'TOgetJ', jouls.toString()

    sendJoulsToUse: ->
        jouls = realValueToSend(@wsData.battery, parseInt $(".slider-battery").val())
        if jouls isnt 0
            @wsData.sendActuatorChange 'TOuseJ', jouls.toString()

    espacialSlider: (name, start, min, middle, max, values, density, postfix) ->
     
        $('.' + name).noUiSlider
            'start': start
            'connect': 'lower'
            'range': 
                'min': min
                '10%': middle
                'max': max       
        , true 
        # the true is for we can rewrite slider
        $('.' + name).noUiSlider_pips
            'mode': 'values'
            'density': density
            'stepped': true
            'values': values
            'format': wNumb
                'postfix': postfix
            
        $("."+ name).Link('lower').to("-inline-<div class=\"tooltipe\"></div>", (value) -> $(this).html "<span>" + Math.floor(value) + "</span>")

    enableStart: ->
        $ '#startExperiment'
            .removeAttr 'disabled'

    disableStart: ->
        $ '#startExperiment'
            .attr 'disabled', 'disabled'

    enableStop: ->
        $ '#stop'
            .removeAttr 'disabled'

    disableStop: ->
        $ '#stop'
            .attr 'disabled', 'disabled'

    enableReset: ->
        $ '#reset'
            .removeAttr 'disabled'

    disableReset: ->
        $ '#reset'
            .attr 'disabled', 'disabled'

    enableSliders: ->
        $ '.slider-battery'
            .removeAttr 'disabled'
        $ '.slider-time'
            .removeAttr 'disabled'

    disableSliders: ->
        $ '.slider-battery'
            .attr 'disabled', 'disabled'
        $ '.slider-time'
            .attr 'disabled', 'disabled'

    disable: -> 
        @disableStart()
        @disableStop()
        @disableReset()
        @disableSliders()

 
window.CommonElements = CommonElements