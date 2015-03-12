class SolarElements

    constructor: ->
        @bulb()
        @solarPanel()
        ###
        smallElementBulb = 
            typeElement: "img"
            attr:
                nameAttr: ["src", "class", "alt"]
                dataAttr: ["images/bulb.png", "img-responsive", "bulb"]

        bigElementBulb = 
            typeElement: "div"
            atrr:
                nameAttr: ["class"]
                dataAttr: []
        ###
        

    bulb: ->
        smallElementBulb = new Item "img", ["src", "class", "alt"], ["images/bulb.png", "img-responsive", "bulb"], null, false, null
        strong = new Item "strong", [], [], "Lumens", false, null
        button = new Item "button", ["onclick", "type", "class"], ["sendLumens()", "button", "btn btn-info btn-xs button-accept"], "Accept", false, null
        divSlider = new Item "div", ["id", "class"], ["slider-lumens", "slider slider-lumens"], null, false, null
        div = new Item "div", ["class"], ["slidera"], null, true, [divSlider]
        bigElementBulb = new Item "div", ["class"], ["form-group"], null, true, [strong, button, div]
        bulb = new Element [smallElementBulb], [bigElementBulb]

        a = document.getElementById "not-common-elements"
        a.appendChild bulb.div
    
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

        solar= new Element [smallElementSolar], [p, divForm1, divForm2]

        a = document.getElementById "not-common-elements"
        a.appendChild solar.div

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



window.SolarElements = SolarElements


###
<div id="not-common-elements">

              <div class="row vertical-align">
                <div class="col-xs-3 col-lg-3">
                  <img src="images/solar_panel.png" class="img-responsive" alt="solar panel">
                </div>
                <div class="col-xs-9 col-lg-9">
                 
                  <form class="form" role="form" autocomplete="off">
                     <p class="text-center"><strong>Spin of the solar panel on:</strong></p>
                    <div class="form-group">
                      <strong>Horizontal axis</strong>
                      <button onclick="sendHorizontalAxis()" type="button" class="btn btn-info btn-xs button-accept">Accept</button>
                      <div class="slidera">
                        <div id="slider-horizontal-axis" class="slider slider-horizontal-axis"></div>
                      </div>
                    </div>
                    <div class="form-group">
                      <strong>Vertical axis</strong>
                      <button onclick="sendVerticalAxis()" type="button" class="btn btn-info btn-xs button-accept">Accept</button>
                      <div class="slidera">
                        <div id="slider-vertical-axis" class="slider slider-vertical-axis"></div>
                      </div>
                    </div>
                  </form>
                </div>
              </div>

              </div>
              <div id="elements-commons">

              <div class="row vertical-align">
                <div class="col-xs-3 col-lg-3">
                  <p id="textBattery" class="text-center">10%</p>
                  <img id="img-battery" src="images/battery1.png" class="img-responsive" alt="battery">
                </div>
                <div class="col-xs-9 col-lg-9">
                  <form class="form" role="form">
                    <div class="form-group">
                      <strong>
                        How much charge do you want? 
                      </strong>
                      <a class="info-pop-up" data-container="body" data-toggle="popover"  tabindex="0" data-trigger="focus"  data-content="And here's some amazing content. It's very engaging. Right?">
                        <span class="glyphicon glyphicon-info-sign"></span>
                      </a>
                      <div class="slidera">
                        <div id="slider-battery" class="slider slider-battery"></div>
                      </div>
                    </div>
                  </form>
                </div>
              </div>
              <div class="row vertical-align">
                <div class="col-xs-3 col-lg-3">
         
                  <div id="countdown"></div>
    
                </div>
                <div class="col-xs-9 col-lg-9">
                  <form class="form" role="form">
                    <div class="form-group">
                      <strong>
                        Time charging
                      </strong>
                      <a href="#" data-toggle="modal" data-target="#myModal">
                        <span class="glyphicon glyphicon-info-sign"></span>
                      </a>       



                      <div class="slidera">
                        <div id="slider-time" class="slider slider-time"></div>
                      </div>
                    </div>
###