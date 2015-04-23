class NoriaElements extends Part
    noria: null
    NAMEPARENT: "noCommonElements"

    constructor: ->
        super
        @noria = document.createElement "div"
        @noria.setAttribute "id", "elementsNoria"
        document.getElementById(@NAMEPARENT).appendChild @noria
        @turns()

    turns: ->
        smallElementDistance = new Item "img", ["src", "class", "alt"], ["images/noria.jpg", "img-responsive", "crane image"], null, false, null
        strong = new Item "strong", [], [], "How many turns do you want? ", false, null
        span = new Item "span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null
        #data-content put any
        a = new Item "a", ['href', 'onclick'], ['#', 'varInit.noria.selectModalText(\'turns\')'], null, true, [span]
        divSlider = new Item "div", ["id", "class"], ["slider-turns", "slider slider-turns"], null, false, null
        div = new Item "div", ["class"], ["slidera"], null, true, [divSlider]
        bigElementDistance = new Item "div", ["class"], ["form-group"], null, true, [strong, a, div]

        turns = new Element()
        turns.specialElement [smallElementDistance], [bigElementDistance] 

        @noria.appendChild turns.div

        new Slider 'slider-turns', 0, 1, [0], [20], 5, 2, '' 

    selectModalText: (type) =>
        if type is 'turns'
            @modalText 'How many turns do you want?', 'Keep in mind that if you select turns, charge and time, the process will end when the first value is reached.'
               
        $ @INFOMODAL
            .modal 'show'

    remove: ->
        @noria.parentNode.removeChild @noria

    sendTurns: ->
        auxTurns = parseInt $(".slider-turns").val()
        if auxTurns isnt 0
            @wsData.sendActuatorChange 'Turns', auxTurns.toString()

    disable: ->
        $ '.slider-turns'
            .attr 'disabled', 'disabled'

    enable: ->
        $ '.slider-turns'
            .removeAttr 'disabled'


window.NoriaElements = NoriaElements