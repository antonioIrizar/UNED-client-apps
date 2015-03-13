class Esd

    canvas: null
    img: null
    width: null
    height: null
    plot: null
    inputCurrent: "0.000"
    inputVoltage: "0.000" 
    workToDo: "0.000"

    constructor: (idCanvas, img) ->
       
        @canvas = document.getElementById idCanvas
        @img = document.getElementById img
        @canvas.width = @img.width
        @canvas.height = @img.height
        #a.noUiSlider({start:[0], step: 20, range:{'min': [0], 'max': [700]}}) 
        ###
        if @img.complete  #check if image was already loaded by the browser
            @drawImageInCanvas()
        else 
            @img.onload  = => 
                console.log "caa"
                @drawImageInCanvas()
                new Plot()
        ###
        @drawImageInCanvas()

    drawImageInCanvas: ->
        @width = @canvas.width = @img.width
        @height = @canvas.height = @img.height
  
        ctx = @canvas.getContext "2d"
        
        ctx.font = Math.floor(@width*0.05)+"px monospace"
        ctx.fillText "Amps", (@width/11), (8*(@height/20)) 
        ctx.fillText "Volts", (@width/11), (11*(@height/20))
        ctx.fillText "Joules", (@width/11), (14*(@height/20))
        ctx.fillText "Charging", 3.5*(@width/11), (5*(@height/20))
        ctx.fillText "Discharging", 6.5*(@width/11), (5*(@height/20))
        ctx.fillText @inputCurrent, 4*(@width/11), (8*(@height/20)) 
        ctx.fillText @inputVoltage, 4*(@width/11), (11*(@height/20))
        ctx.fillText @workToDo, 4*(@width/11), (14*(@height/20))

    drawText: (@inputCurrent, @inputVoltage, @workToDo) ->
        ctx = @canvas.getContext "2d"
        ctx.clearRect 3.4*(@width/11), (7*(@height/20)), @width, @height
        ctx.fillText @inputCurrent, 4*(@width/11), (8*(@height/20)) 
        ctx.fillText @inputVoltage, 4*(@width/11), (11*(@height/20))
        ctx.fillText @workToDo, 4*(@width/11), (14*(@height/20))

        
window.Esd = Esd