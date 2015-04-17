class EolicElements extends Part
    eolic: null
    NAMEPARENT: "noCommonElements"
    wind: null
    millRot: null
    startExperiment: false

    constructor: ->
        super 
        @wind = null
        @millRot = null
        @startExperiment = false
        document.addEventListener 'reciveData', @reciveDataEvent, false
        @eolic = document.createElement "div"
        @eolic.setAttribute "id", "eolicElements"
        document.getElementById(@NAMEPARENT).appendChild @eolic
        @createWind()
        @createMillRot()        

    createWind: ->
        smallElementBulb = new Item "img", ["src", "class", "alt"], ["images/wind.jpg", "img-responsive", "bulb"], null, false, null
        strong = new Item "strong", [], [], "Wind ", false, null
        span = new Item "span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null
        #data-content put any
        a = new Item "a", ['href', 'onclick'], ['#', 'varInit.eolic.selectModalText(\'wind\')'], null, true, [span]

        #carefully with function onclick need put name var of init and the name of var solar 
        button = new Item "button", ["onclick", "type", "class"], ["varInit.eolic.sendWind()", "button", "btn btn-info btn-xs button-accept"], "Accept", false, null
        divSlider = new Item "div", ["id", "class"], ["slider-wind", "slider slider-wind"], null, false, null
        div = new Item "div", ["class"], ["slidera"], null, true, [divSlider]
        bigElementBulb = new Item "div", ["class"], ["form-group"], null, true, [strong, a, button, div]

        wind = new Element()
        wind.specialElement [smallElementBulb], [bigElementBulb]

        @eolic.appendChild wind.div

        new Slider 'slider-wind', 0, 1, [0], [168], 8, 3, 'W'

    createMillRot: ->
        smallElementBulb = new Item "img", ["src", "class", "alt"], ["images/mill.jpg", "img-responsive", "bulb"], null, false, null
        strong = new Item "strong", [], [], "Mill horizontal rot ", false, null
        span = new Item "span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null
        #data-content put any
        a = new Item "a", ['href', 'onclick'], ['#', 'varInit.solar.selectModalText(\'millRot\')'], null, true, [span]

        #carefully with function onclick need put name var of init and the name of var solar 
        button = new Item "button", ["onclick", "type", "class"], ["varInit.eolic.sendMillRot()", "button", "btn btn-info btn-xs button-accept"], "Accept", false, null
        divSlider = new Item "div", ["id", "class"], ["slider-eolic-rot", "slider slider-eolic-rot"], null, false, null
        div = new Item "div", ["class"], ["slidera"], null, true, [divSlider]
        bigElementBulb = new Item "div", ["class"], ["form-group"], null, true, [strong, a, button, div]

        millRot = new Element()
        millRot.specialElement [smallElementBulb], [bigElementBulb]

        @eolic.appendChild millRot.div

        new Slider 'slider-eolic-rot', 0, 1, [-150], [150], 11, 2, 'º'
        
    selectModalText: (type) =>
        switch type
            when 'wind'
                @modalText 'Decide the lumens you want for the bulb', 'First select how many lumens you want for the bulb and you can click in accept to turn on the bulb or you can click on start to turn on the bulb and start experiment (You can\'t have 0 lumens to start experiment). You can always change the lumens at any time, you only need select the lumens and click accept.'
            when 'millRot'
                @modalText 'Decide the degree you want for the horizontal panel', 'First select how many degree you want for the horizontal panel and you can click in accept to move the horizontal panel or you can click on start to move the horizontal panel and start experiment. You can always change the degree at any time, you only need select the degree and click accept.'

        $ @INFOMODAL
            .modal 'show'
    remove: ->
        @eolic.parentNode.removeChild @eolic

    realValueToSend: (oldNumber, newNumber) ->
        if oldNumber is null
            return newNumber
        
        return newNumber - oldNumber

    sendWind: =>
        auxWind = parseInt $('.slider-wind').val()

        if auxWind isnt 0
            @wsData.sendActuatorChange 'Wind', auxWind.toString()
            myApp.showPleaseWait()
  
    sendMillRot: ->
        oldEolicRot = @millRot
        auxEolicRot = parseInt $('.slider-eolic-rot').val()
        move = @realValueToSend oldEolicRot, auxEolicRot
        if move isnt 0
            @wsData.sendActuatorChange 'Millrot', move.toString()
            myApp.showPleaseWait()

    reciveDataEvent: (e) =>
        switch e.detail.actuatorId
            when 'Wind'
                @wind = parseInt(e.detail.value)
                $ '.slider-wind'
                    .val @wind
            when 'Millrot'
                @millRot = @resultReciveData parseInt(e.detail.value), @millRot
                $ '.slider-eolic-rot'
                    .val @millRot

        if not @startExperiment
            console.log "entro en el recive"
            myApp.hidePleaseWait()

    resultReciveData: (dataRecive, dataActuator) ->
        if dataActuator is null
            result = dataRecive
        else 
            result = dataRecive + dataActuator

    enable: ->
        $ '.slider-wind' 
            .removeAttr 'disabled'
        $ '.slider-eolic-rot'
            .removeAttr 'disabled'
        $ '.button-accept'
            .removeAttr 'disabled'

    disable: ->
        $ '.slider-wind'
            .attr 'disabled', 'disabled'
        $ '.slider-eolic-rot'
            .attr 'disabled', 'disabled'
        $ '.button-accept'
            .attr 'disabled', 'disabled'


window.EolicElements = EolicElements