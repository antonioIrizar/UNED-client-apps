class CraneElements
    crane: null
    NAMEPARENT: "noCommonElements"
    wsData: null

    constructor: (@wsData) ->
        @crane = document.createElement "div"
        @crane.setAttribute "id", "elementsTheCrane"
        document.getElementById(@NAMEPARENT).appendChild @crane
        @distance()

    distance: ->
        smallElementDistance = new Item "img", ["src", "class", "alt"], ["images/crane.png", "img-responsive", "crane image"], null, false, null
        strong = new Item "strong", [], [], "How much distance do you want?", false, null
        divSlider = new Item "div", ["id", "class"], ["slider-distance", "slider slider-distance"], null, false, null
        div = new Item "div", ["class"], ["slidera"], null, true, [divSlider]
        bigElementDistance = new Item "div", ["class"], ["form-group"], null, true, [strong, div]

        distance = new Element()
        distance.specialElement [smallElementDistance], [bigElementDistance] 

        @crane.appendChild distance.div

        new Slider 'slider-distance', 0, 1, [0], [100], 5, 2, 'cm' 

    remove: ->
        @crane.parentNode.removeChild @crane

    sendDistance: ->
        auxDistance = parseInt $(".slider-distance").val()
        if auxDistance isnt 0
            @wsData.sendActuatorChange 'WeightTrip', auxDistance.toString()
  

window.CraneElements = CraneElements