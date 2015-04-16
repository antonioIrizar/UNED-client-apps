class SolarElements extends Part
    solar: null
    NAMEPARENT: "noCommonElements"
    lumens: null
    horizontalAxis: null
    verticalAxis: null
    startExperiment: false

    constructor: ->
        super 
        @lumens = null
        @horizontalAxis = null
        @verticalAxis = null
        @startExperiment = false
        document.addEventListener 'reciveData', @reciveDataEvent, false
        @solar = document.createElement "div"
        @solar.setAttribute "id", "solarElements"
        document.getElementById(@NAMEPARENT).appendChild @solar
        @bulb()
        @solarPanel()        

    bulb: ->
        smallElementBulb = new Item "img", ["src", "class", "alt"], ["images/bulb.png", "img-responsive", "bulb"], null, false, null
        strong = new Item "strong", [], [], "Lumens ", false, null
        span = new Item "span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null
        #data-content put any
        a = new Item "a", ['href', 'onclick'], ['#', 'varInit.solar.selectModalText(\'lumens\')'], null, true, [span]

        #carefully with function onclick need put name var of init and the name of var solar 
        button = new Item "button", ["onclick", "type", "class"], ["varInit.solar.sendLumens()", "button", "btn btn-info btn-xs button-accept"], "Accept", false, null
        divSlider = new Item "div", ["id", "class"], ["slider-lumens", "slider slider-lumens"], null, false, null
        div = new Item "div", ["class"], ["slidera"], null, true, [divSlider]
        bigElementBulb = new Item "div", ["class"], ["form-group"], null, true, [strong, a, button, div]

        bulb = new Element()
        bulb.specialElement [smallElementBulb], [bigElementBulb]

        @solar.appendChild bulb.div

        new Slider 'slider-lumens', 0, 20, [0], [700], 8, 3, 'lm'
        
    solarPanel: ->
        smallElementSolar = new Item "img", ["src", "class", "alt"], ["images/solar_panel.png", "img-responsive", "solar panel"], null, false, null

        strong1 = new Item "strong", [], [], "Spin of the solar panel on:", false, null
        p = new Item "p", ["class"], ["text-center"], null, true, [strong1]

        strong2 = new Item "strong", [], [], "Horizontal axis ", false, null

        span = new Item "span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null
        #data-content put any
        a = new Item "a", ['href', 'onclick'], ['#', 'varInit.solar.selectModalText(\'horizontal\')'], null, true, [span]
        #carefully with function onclick need put name var of init and the name of var solar 
        button1 = new Item "button", ["onclick", "type", "class"], ["varInit.solar.sendHorizontalAxis()", "button", "btn btn-info btn-xs button-accept"], "Accept", false, null
        divSlider1 = new Item "div", ["id", "class"], ["slider-horizontal-axis", "slider slider-horizontal-axis"], null, false, null
        div1 = new Item "div", ["class"], ["slidera"], null, true, [divSlider1]

        divForm1 = new Item "div", ["class"], ["form-group"], null, true, [strong2, a, button1, div1]

        strong3 = new Item "strong", [], [], "Vertical axis ", false, null
        span = new Item "span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null
        #data-content put any
        a = new Item "a", ['href', 'onclick'], ['#', 'varInit.solar.selectModalText(\'vertical\')'], null, true, [span]
        #carefully with function onclick need put name var of init and the name of var solar 
        button2 = new Item "button", ["onclick", "type", "class"], ["varInit.solar.sendVerticalAxis()", "button", "btn btn-info btn-xs button-accept"], "Accept", false, null
        divSlider2 = new Item "div", ["id", "class"], ["slider-vertical-axis", "slider slider-vertical-axis"], null, false, null
        div2 = new Item "div", ["class"], ["slidera"], null, true, [divSlider2]

        divForm2 = new Item "div", ["class"], ["form-group"], null, true, [strong3, a, button2, div2]    

        solar = new Element()
        solar.specialElement [smallElementSolar], [p, divForm1, divForm2]

        @solar.appendChild solar.div

        new Slider 'slider-horizontal-axis', 0, 1, [-150], [150], 11, 2, 'º'
        new Slider 'slider-vertical-axis', 0, 1, [0], [60], 10, 3, 'º'
        
    selectModalText: (type) =>
        switch type
            when 'lumens'
                @modalText 'Decide the lumens you want for the bulb', 'First select how many lumens you want for the bulb and you can click in accept to turn on the bulb or you can click on start to turn on the bulb and start experiment (You can\'t have 0 lumens to start experiment). You can always change the lumens at any time, you only need select the lumens and click accept.'
            when 'horizontal'
                @modalText 'Decide the degree you want for the horizontal panel', 'First select how many degree you want for the horizontal panel and you can click in accept to move the horizontal panel or you can click on start to move the horizontal panel and start experiment. You can always change the degree at any time, you only need select the degree and click accept.'
            when 'vertical'
                @modalText 'Decide the degree you want for the vertical panel', 'First select how many degree you want for the vertical panel and you can click in accept to move the vertical panel or you can click on start to move the vertical panel and start experiment. You can always change the degree at any time, you only need select the degree and click accept.'
             
        $ @INFOMODAL
            .modal 'show'
    remove: ->
        @solar.parentNode.removeChild @solar

    realValueToSend: (oldNumber, newNumber) ->
        if oldNumber is null
            return newNumber
        
        return newNumber - oldNumber

    sendLumens: =>
        auxLumens = parseInt $('.slider-lumens').val()
        #block 680 for problems with it
        if auxLumens is 680
            auxLumens = 660

        if auxLumens isnt 0
            @wsData.sendActuatorChange 'Sun', auxLumens.toString()
            myApp.showPleaseWait()
  
    sendHorizontalAxis: ->
        oldHorizontalAxis = @horizontalAxis
        console.log @horizontalAxis
        auxHorizontalAxis = parseInt $('.slider-horizontal-axis').val()
        move = @realValueToSend oldHorizontalAxis, auxHorizontalAxis
        console.log "move "+ move
        if move isnt 0
            @wsData.sendActuatorChange 'Panelrot', move.toString()
            myApp.showPleaseWait()
  
    sendVerticalAxis: ->
        oldVerticalAxis = @verticalAxis
        auxVerticalAxis = parseInt $('.slider-vertical-axis').val()
        move = @realValueToSend oldVerticalAxis, auxVerticalAxis
        if move isnt 0
            @wsData.sendActuatorChange 'Paneltilt', move.toString()
            myApp.showPleaseWait()

    reciveDataEvent: (e) =>
        switch e.detail.actuatorId
            when 'Sun'
                @lumens = parseInt(e.detail.value)
                $ '.slider-lumens'
                    .val @lumens
            when 'Panelrot'
                @horizontalAxis = @resultReciveData parseInt(e.detail.value), @horizontalAxis
                $ '.slider-horizontal-axis'
                    .val @horizontalAxis
            when 'Paneltilt'
                @verticalAxis = @resultReciveData parseInt(e.detail.value), @verticalAxis
                $ '.slider-vertical-axis'
                    .val @verticalAxis
        if not @startExperiment
            console.log "entro en el recive"
            myApp.hidePleaseWait()

    resultReciveData: (dataRecive, dataActuator) ->
        if dataActuator is null
            result = dataRecive
        else 
            result = dataRecive + dataActuator

    enable: ->
        $ '.slider-lumens' 
            .removeAttr 'disabled'
        $ '.slider-horizontal-axis'
            .removeAttr 'disabled'
        $ '.slider-vertical-axis'
            .removeAttr 'disabled'
        $ '.button-accept'
            .removeAttr 'disabled'

    disable: ->
        $ '.slider-lumens'
            .attr 'disabled', 'disabled'
        $ '.slider-horizontal-axis'
            .attr 'disabled', 'disabled'
        $ '.slider-vertical-axis'
            .attr 'disabled', 'disabled'
        $ '.button-accept'
            .attr 'disabled', 'disabled'


window.SolarElements = SolarElements