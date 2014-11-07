class Esd

    canvas: null
    img: null
    width: null
    height: null

    constructor: (idCanvas, img, lumens) ->
       
        @canvas = document.getElementById idCanvas
        @img = document.getElementById img
        @canvas.width = @img.width
        @canvas.height = @img.height
        a = document.getElementById lumens
        #a.noUiSlider({start:[0], step: 20, range:{'min': [0], 'max': [700]}}) 
        
        if @img.complete  #check if image was already loaded by the browser
            @drawImageInCanvas()
        else 
            @img.onload  = => @drawImageInCanvas()
        
    drawImageInCanvas: ->
        @width = @canvas.width = @img.width
        @height = @canvas.height = @img.height
  
        ctx = @canvas.getContext "2d"
        console.log @width
        console.log Math.floor(@width*0.044248)
        ctx.font = Math.floor(@width*0.044248)+"px monospace"
        ctx.fillText "Amps", (@width/8), (5*(@height/25)) 
        ctx.fillText "Volts", (@width/8), (7*(@height/25))
        ctx.fillText "Joules", (@width/8), (9*(@height/25))
        ctx.fillText "Charging", 2.5*(@width/8), (3.5*(@height/25))
        ctx.fillText "Discharging", 4.5*(@width/8), (3.5*(@height/25))

window.Esd = Esd