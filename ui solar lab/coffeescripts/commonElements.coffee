class CommonElements
    solar:true
    timeText: null
    batteryText: null

    constructor: (@solar) ->
        if @solar
            @timeText = "Time charging"
            @batteryText =  "How much charge do you want?"
        else
            @timeText = "Time discharging"
            @batteryText = "How much discharge do you want?" 

        @battery()
        @time()

    battery: ->
        p = new Item "p", ["id", "class"], ["textBattery", "text-center"], "10%", false, null
        smallElementBatery = new Item "img", ["src", "class", "alt"], ["images/battery1.png", "img-responsive", "battery"], null, true, [p]

        strong = new Item "strong", [], [], @batteryText, false, null
        span = new Item "span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null
        #data-content put any
        a = new Item "a", ["class", "data-container", "data-toggle", "tabindex", "data-trigger", "data-content"], ["info-pop-up", "body", "popover", "0", "focus", "And here's some amazing content. It's very engaging. Right?"], null, true, [span]
       
        divSlider = new Item "div", ["id", "class"], ["slider-battery", "slider slider-battery"], null, false, null
        div = new Item "div", ["class"], ["slidera"], null, true, [divSlider]

        bigElementBatery = new Item "div", ["class"], ["form-group"], null, true, [strong, a, div]
        battery = new Element [smallElementBatery], [bigElementBatery]

        b = document.getElementById "elements-commons"
        b.appendChild battery.div

        $('.slider-battery').noUiSlider({
        start: 10,
        step: 1,
        connect: "lower",
        range: {
        'min': [10],
        'max': [100]
        }
        })
        $(".slider-battery").noUiSlider_pips({
        mode: 'count',
        values: 10,
        density: 2,
        stepped: true,
        format: wNumb({
        postfix: '%'
        })
        })

    time: ->

        smallElementTime = new Item "div", ["id"], ["countdown"], null, false, null

        strong = new Item "strong", [], [], @timeText, false, null
        span = new Item "span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null
        #data-content put any
        a = new Item "a", ["href", "data-toggle","data-target"], ["#", "modal", "#myModal"], null, true, [span]
       
        divSlider = new Item "div", ["id", "class"], ["slider-time", "slider slider-time"], null, false, null
        div = new Item "div", ["class"], ["slidera"], null, true, [divSlider]

        bigElementTime = new Item "div", ["class"], ["form-group"], null, true, [strong, a, div]
        time = new Element [smallElementTime], [bigElementTime]

        a = document.getElementById "elements-commons"
        a.appendChild time.div

        $('.slider-time').noUiSlider({
        start: 0,
        step: 1,
        connect: "lower",
        range: {
        'min': [0],
        'max': [30]
        }
        })
        $(".slider-time").noUiSlider_pips({
        mode: 'count',
        values: 7,
        density: 3,
        stepped: true,
        format: wNumb({
        postfix: '\''
        })
        })

        $('#countdown').timeTo({ 
        seconds: 3,
        countdown:true,
        fontSize: 14,
        });



window.CommonElements = CommonElements