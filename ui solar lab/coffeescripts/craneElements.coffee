class CraneElements extends Part
    crane: null
    NAMEPARENT: "noCommonElements"

    constructor: ->
        super
        @crane = document.createElement "div"
        @crane.setAttribute "id", "elementsTheCrane"
        document.getElementById(@NAMEPARENT).appendChild @crane
        @distance()

    distance: ->
        smallElementDistance = new Item "img", ["src", "class", "alt"], ["images/crane.png", "img-responsive", "crane image"], null, false, null
        strong = new Item "strong", [], [], "How much distance do you want? ", false, null
        span = new Item "span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null
        #data-content put any
        a = new Item "a", ['href', 'onclick'], ['#', 'varInit.crane.selectModalText(\'distance\')'], null, true, [span]
        divSlider = new Item "div", ["id", "class"], ["slider-distance", "slider slider-distance"], null, false, null
        div = new Item "div", ["class"], ["slidera"], null, true, [divSlider]
        bigElementDistance = new Item "div", ["class"], ["form-group"], null, true, [strong, a, div]

        distance = new Element()
        distance.specialElement [smallElementDistance], [bigElementDistance] 

        @crane.appendChild distance.div

        new Slider 'slider-distance', 0, 1, [0], [100], 5, 2, 'cm' 

    selectModalText: (type) =>
        if type is 'distance'
            @modalText 'Decide how many centimetres you want move the weight', 'First select how many centimetres you want move the weith you should click on start to move the weith and start experiment. You can always stop the experiment clicking in button stop.'
               
        $ @INFOMODAL
            .modal 'show'

    remove: ->
        @crane.parentNode.removeChild @crane

    sendDistance: ->
        auxDistance = parseInt $(".slider-distance").val()
        if auxDistance isnt 0
            @wsData.sendActuatorChange 'WeightTrip', auxDistance.toString()

    disable: ->
        $ '.slider-distance'
            .attr 'disabled', 'disabled'

    enable: ->
        $ '.slider-distance'
            .removeAttr 'disabled'


window.CraneElements = CraneElements