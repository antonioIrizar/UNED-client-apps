class CommonElements
    solar:true
    timeText: null
    batteryText: null
    wsData: null

    constructor: (@wsData, @solar) ->
        @selectNameVar()
        @battery()
        @time()
        @buttons()

    battery: ->
        p = new Item "p", ["id", "class"], ["textBattery", "text-center"], "10%", false, null
        smallElementBatery = new Item "img", ["src", "class", "alt"], ["images/battery1.png", "img-responsive", "battery"], null, true, [p]

        strong = new Item "strong", ["id"], ["batteryText"], @batteryText, false, null
        span = new Item "span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null
        #data-content put any
        a = new Item "a", ["class", "data-container", "data-toggle", "tabindex", "data-trigger", "data-content"], ["info-pop-up", "body", "popover", "0", "focus", "And here's some amazing content. It's very engaging. Right?"], null, true, [span]
       
        divSlider = new Item "div", ["id", "class"], ["slider-battery", "slider slider-battery"], null, false, null
        div = new Item "div", ["class"], ["slidera"], null, true, [divSlider]

        bigElementBatery = new Item "div", ["class"], ["form-group"], null, true, [strong, a, div]

        battery = new Element()
        battery.specialElement [smallElementBatery], [bigElementBatery]

        parent = document.getElementById "elementsCommons"
        parent.appendChild battery.div

        new Slider 'slider-battery', 10, 1, [10], [100], 10, 2, '%'

    time: ->

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

        maxTime = [1800]
        if not @solar 
            maxTime = [180]

        new Slider 'slider-time', 0, 10, [0], maxTime, 7, 3, '\'\'' 
        
    buttons: ->
        div1 = new Item "div", ["id"], ["adaptToHeight"], null, false, null
        buttonStart = new Item "button", ["id", "class", "type", "onclick"], ["startExperiment", "btn btn-success", "button", "varInit.startExperiments()"], "Start", false, null
        buttonStop = new Item "button", ["id", "class", "type","style", "onclick"], ["stop", "btn btn-primary", "button", "margin-left: 4px", "stopExperiment()"], "Stop", false, null
        buttonReset = new Item "button", ["id", "class", "type","style", "onclick"], ["reset", "btn btn-danger", "button", "margin-left: 4px", "resetExperiment()"], "Reset", false, null
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
        
        maxTime = [1800]
        if not @solar 
            maxTime = [180]

        $('.slider-time').noUiSlider
            range:
                min: [0],
                max: maxTime
        , true

        $('.slider-time').noUiSlider_pips(
            'mode': 'count'
            'values': 7
            'density': 3
            'stepped': true,
            'format': wNumb(
                'postfix': '\'\'' 
            )
        )

        $('.slider-time').val 0
    
        document.getElementById("timeText").innerHTML = @timeText
        document.getElementById("batteryText").innerHTML = @batteryText

    sendTime: ->
        time = parseInt $('.slider-time').val()
        if time isnt 0
            console.log time
            @wsData.sendActuatorChange 'Elapsed', time.toString()

    sendJouls: ->
        jouls = realValueToSend(@wsData.battery, parseInt $(".slider-battery").val())
        if jouls isnt 0
            @wsData.sendActuatorChange 'TOgetJ', jouls.toString()

    sendJoulsToUse: ->
        jouls = realValueToSend(@wsData.battery, parseInt $(".slider-battery").val())
        if jouls isnt 0
            sendActuatorChange 'TOuseJ', jouls.toString()

 
window.CommonElements = CommonElements