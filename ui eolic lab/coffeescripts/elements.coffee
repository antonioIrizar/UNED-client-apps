class Element
  div:null

  constructor: ->
    @div = document.createElement "div"

   standardElement: (args)->
    @div.setAttribute "class", "row"
    for item in args
      @div.appendChild @createMyElement @div, item

  specialElement: (smallArgs, bigArgs) ->
    @div.setAttribute "class", "row vertical-align"
    @div.appendChild @smallElement smallArgs
    @div.appendChild @bigElement bigArgs

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
