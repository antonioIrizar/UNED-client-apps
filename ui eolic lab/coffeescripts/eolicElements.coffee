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
        strong = new Item "strong", [], [], "Fan electrical power ", false, null
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
        strong = new Item "strong", [], [], "Windmill blades rotation ", false, null
        span = new Item "span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null
        #data-content put any
        a = new Item "a", ['href', 'onclick'], ['#', 'varInit.eolic.selectModalText(\'millRot\')'], null, true, [span]

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
                @modalText 'Fan electrical power', 'The more electrical power, the faster the battery will charge. You can modify this value at any time.'
            when 'millRot'
                @modalText 'Windmill blades rotation', 'Allow to modify the blades position in relation to the fun, simulating the different directions of the wind in real nature.'

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

        if parseInt(@realValueToSend @wind, auxWind) isnt 0
            @wind = auxWind
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