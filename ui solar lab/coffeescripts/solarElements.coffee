class SolarElements
  solar: null
  NAMEPARENT: "noCommonElements"

  constructor: ->
      @solar = document.createElement "div"
      @solar.setAttribute "id", "solarElements"
      document.getElementById(@NAMEPARENT).appendChild @solar
      @bulb()
      @solarPanel()        

  bulb: ->
      smallElementBulb = new Item "img", ["src", "class", "alt"], ["images/bulb.png", "img-responsive", "bulb"], null, false, null
      strong = new Item "strong", [], [], "Lumens", false, null
      button = new Item "button", ["onclick", "type", "class"], ["sendLumens()", "button", "btn btn-info btn-xs button-accept"], "Accept", false, null
      divSlider = new Item "div", ["id", "class"], ["slider-lumens", "slider slider-lumens"], null, false, null
      div = new Item "div", ["class"], ["slidera"], null, true, [divSlider]
      bigElementBulb = new Item "div", ["class"], ["form-group"], null, true, [strong, button, div]
      
      bulb = new Element()
      bulb.specialElement [smallElementBulb], [bigElementBulb]

      @solar.appendChild bulb.div
  
      $('.slider-lumens').noUiSlider({
      start: 0,
      step: 20,
      connect: "lower",
      range: {
        'min': [0],
        'max': [700]
      }
      })
      $(".slider-lumens").noUiSlider_pips({
      mode: 'count',
      values: 8,
      density: 3,
      stepped: true,
      format: wNumb({
        postfix: 'lm'
      })
      })
      $(".slider").Link('lower').to("-inline-<div class=\"tooltipe\"></div>", (value) -> $(this).html "<span>" + Math.floor(value) + "</span>")

  solarPanel: ->
      smallElementSolar = new Item "img", ["src", "class", "alt"], ["images/solar_panel.png", "img-responsive", "solar panel"], null, false, null
      
      strong1 = new Item "strong", [], [], "Spin of the solar panel on:", false, null
      p = new Item "p", ["class"], ["text-center"], null, true, [strong1]
      
      strong2 = new Item "strong", [], [], "Horizontal axis", false, null
      button1 = new Item "button", ["onclick", "type", "class"], ["sendHorizontalAxis()", "button", "btn btn-info btn-xs button-accept"], "Accept", false, null
      divSlider1 = new Item "div", ["id", "class"], ["slider-horizontal-axis", "slider slider-horizontal-axis"], null, false, null
      div1 = new Item "div", ["class"], ["slidera"], null, true, [divSlider1]
      
      divForm1 = new Item "div", ["class"], ["form-group"], null, true, [strong1, button1, div1]

      strong3 = new Item "strong", [], [], "Vertical axis", false, null
      button2 = new Item "button", ["onclick", "type", "class"], ["sendVerticalAxis()", "button", "btn btn-info btn-xs button-accept"], "Accept", false, null
      divSlider2 = new Item "div", ["id", "class"], ["slider-vertical-axis", "slider slider-vertical-axis"], null, false, null
      div2 = new Item "div", ["class"], ["slidera"], null, true, [divSlider2]
      
      divForm2 = new Item "div", ["class"], ["form-group"], null, true, [strong2, button2, div2]    

      solar = new Element()
      solar.specialElement [smallElementSolar], [p, divForm1, divForm2]

      @solar.appendChild solar.div

      $('.slider-horizontal-axis').noUiSlider({
      start: 0,
      step: 1,
      connect: "lower",
      range: {
      'min': [-150],
      'max': [150]
      }
      })

      $('.slider-vertical-axis').noUiSlider({
      start: 0,
      step: 1,
      connect: "lower",
      range: {
      'min': [0],
      'max': [60]
      }
      })
      $(".slider-vertical-axis").noUiSlider_pips({
      mode: 'count',
      values: 10,
      density: 3,
      stepped: true,
      format: wNumb({
      postfix: 'º'
      })
      })

      $(".slider-horizontal-axis").noUiSlider_pips({
      mode: 'count',
      values: 11,
      density: 2,
      stepped: true,
      format: wNumb({
      postfix: 'º'
      })
      })
      $(".slider").Link('lower').to("-inline-<div class=\"tooltipe\"></div>", (value) -> $(this).html "<span>" + Math.floor(value) + "</span>")

    remove: ->
      @solar.parentNode.removeChild @solar



window.SolarElements = SolarElements