class CommonElements extends Part
   
    timeText: null
    batteryText: null
    time: 0
    solar:true
    
    constructor: (@solar) ->
        super
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
        a = new Item "a", ['href', 'onclick'], ['#', 'varInit.common.selectModalText(\'time\')'], null, true, [span]
       
        divSlider = new Item "div", ["id", "class"], ["slider-battery", "slider slider-battery"], null, false, null
        div = new Item "div", ["class"], ["slidera"], null, true, [divSlider]

        bigElementBattery = new Item "div", ["class"], ["form-group"], null, true, [strong, a, div]

        battery = new Element()
        battery.specialElement [p, imgBattery], [bigElementBattery]

        parent = document.getElementById "elementsCommons"
        parent.appendChild battery.div

        new Slider 'slider-battery', 0, 1, [0], [100], 11, 2, '%'

        @batteryCorrectValues()

    time: ->
        #chargin mode the minimun time is 300 seconds and max 1800
        #dischragin mode the minimun time is 10 seconds and max 90

        smallElementTime = new Item "div", ["id"], ["countdown"], null, false, null

        strong = new Item "strong", ["id"], ["timeText"], @timeText, false, null
        span = new Item "span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null
        #data-content put any
        a = new Item "a", ["href", 'onclick'], ["#", 'varInit.common.selectModalText(\'time\')'], null, true, [span]

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
            maxTime = [1200]
            middle = 300
            values = [0, 300, 600, 900, 1200]

        @espacialSlider 'slider-time', 0, minTime, middle, maxTime, values, 3, '\'\'' 

        $('#countdown').timeTo({
            seconds:1,
            fontSize: 14
        })
   
    selectModalText: (type) =>
        if @solar
            if type is 'time'
                @modalText 'Decide for how long you want to charge the battery', 'The battery will charge for the selected lapse of time. If you select both (charge and lapse of time), it will charge till it reaches the first of both; or you click on the stop button.'
            if type is 'battery'
                @modalText 'Decide the charge you want in the battery', 'The battery will start charging till it reaches the selected value. If you select both (charge and lapse of time), it will charge till it reaches the first of both; or you click on the stop button.'
        else
            if type is 'time'
                @modalText 'Decide for how long you want to discharge the battery', 'The battery will start discharging for the selected lapse of time. If you select both (charge and lapse of time), it will discharge till it reaches the first of both; or you click on the stop button.'
                @modalText 'Decide the discharge you want in the battery', 'The battery will start discharging till it reaches the selected. If you select both (discharge and lapse of time), it will discharge till it reaches the first of both; or you click on the stop button.'
        $ @INFOMODAL
            .modal 'show'

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
            @timeText = "Time charging "
            @batteryText = "How much charge do you want? "
        else
            @timeText = "Time discharging "
            @batteryText = "How much discharge do you want? " 
            
    mySwitch: (@solar)->
        @selectNameVar()
        if not @solar 
            minTime = [0, 10]
            maxTime = [90]
            middle = 10
            values = [0, 10, 30, 60, 90]
        else
            minTime = [0, 300]
            maxTime = [1200]
            middle = 300
            values = [0, 300, 600, 900, 1200]

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
        jouls = parseInt $('.slider-battery').val() - parseInt @wsData.battery
        if jouls isnt 0
            @wsData.sendActuatorChange 'TOgetJ', jouls.toString()
        else
            if @time is 0
                @wsData.sendActuatorChange 'TOgetJ','0'

    sendJoulsToUse: ->
        jouls = parseInt @wsData.battery - parseInt $('.slider-battery').val() 
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

    resetTimer: ->
        $('#countdown').timeTo({
            seconds:1,
            fontSize: 14
        })
    
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

    batteryCorrectValues: ->
        $ '.slider-battery' 
            .on 'change', (event) =>
                a = parseInt ($ '.slider-battery'
                    .val())

                # need this for bug in library noUIslider
                if a is 100
                    a = 100

                if @solar
                    if a < @wsData.battery
                        $ '.slider-battery'
                            .val @wsData.battery
                    if a > 98
                        $ '.slider-battery'
                            .val 98
                else
                    if a > @wsData.battery
                        $ '.slider-battery'
                            .val @wsData.battery
                    if a < 10
                        $ '.slider-battery'
                            .val 10

 
window.CommonElements = CommonElements