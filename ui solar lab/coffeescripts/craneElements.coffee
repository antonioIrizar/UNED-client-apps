class CraneElements
    crane: null
    NAMEPARENT: "noCommonElements"

    constructor: ->
        @crane = document.createElement "div"
        @crane.setAttribute "id", "elementsTheCrane"
        document.getElementById(@NAMEPARENT).appendChild @crane
        @distance()

    distance: ->
        smallElementDistance = new Item "img", ["src", "class", "alt"], ["images/bulb.png", "img-responsive", "bulb"], null, false, null
        strong = new Item "strong", [], [], "How much distance do you want?", false, null
        divSlider = new Item "div", ["id", "class"], ["slider-distance", "slider slider-distance"], null, false, null
        div = new Item "div", ["class"], ["slidera"], null, true, [divSlider]
        bigElementDistance = new Item "div", ["class"], ["form-group"], null, true, [strong, div]

        distance = new Element()
        distance.specialElement [smallElementDistance], [bigElementDistance] 

        @crane.appendChild distance.div
    
        $('.slider-distance').noUiSlider({
        start: 0,
        step: 1,
        connect: "lower",
        range: {
          'min': [0],
          'max': [100]
        }
        })
        $(".slider-distance").noUiSlider_pips({
        mode: 'count',
        values: 5,
        density: 2,
        stepped: true,
        format: wNumb({
          postfix: 'cm'
        })
        })
        $(".slider").Link('lower').to("-inline-<div class=\"tooltipe\"></div>", (value) -> $(this).html "<span>" + Math.floor(value) + "</span>")

    remove: ->
        @crane.parentNode.removeChild @crane

window.CraneElements = CraneElements