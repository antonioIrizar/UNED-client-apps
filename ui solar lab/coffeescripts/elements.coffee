class Element
  div:null

  constructor:(smallArgs, bigArgs) ->
    @div = document.createElement "div"
    @div.setAttribute "class", "row vertical-align"
    @div.appendChild @smallElement smallArgs
    @div.appendChild @bigElement bigArgs
    @div

  smallElement: (args) ->
    div = document.createElement "div"
    div.setAttribute "class", "col-xs-3 col-lg-3"
    for item in args 
      @createMyElement div, item
    div
     
  bigElement: (args) ->
    div = document.createElement "div"
    div.setAttribute "class", "col-xs-9 col-lg-9"
    form = document.createElement "form"
    form.setAttribute "class", "form"
    form.setAttribute "role", "form"
    form.setAttribute "autocomplete", "off"
    div.appendChild form
    for item in args
      @createMyElement form, item

    div

  createMyElement: (parent, item) ->
    element = document.createElement item.typeElement

    for nAttr, i in item.nameAttr
      element.setAttribute nAttr, item.dataAttr[i]

    if item.text isnt null
      element.appendChild document.createTextNode item.text

    if item.parent
      for child in item.child
        @createMyElement element, child

    parent.appendChild element

window.Element = Element







###
<div class="row vertical-align">
                <div class="col-xs-3 col-lg-3">
                  <img src="images/bulb.png" class="img-responsive" alt="bulb">
                </div>
                <div class="col-xs-9 col-lg-9">
                  <form class="form" role="form" autocomplete="off">
                    <div class="form-group">
                      <strong>Lumens</strong>
                      <button onclick="sendLumens()" type="button" class="btn btn-info btn-xs button-accept">Accept</button>
                      <div class="slidera">
                        <div id="slider-lumens" class="slider slider-lumens"></div>
                      </div>
                    </div>
                  </form>
                </div>
              </div>



               <div class="row vertical-align">
                <div class="col-xs-3 col-lg-3">
                  <img src="images/solar_panel.png" class="img-responsive" alt="solar panel">
                </div>
                <div class="col-xs-9 col-lg-9">
                  <p class="text-center"><strong>Spin of the solar panel on:</strong></p>
                  <form class="form" role="form" autocomplete="off">
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
###