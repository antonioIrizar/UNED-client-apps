class Esd

    canvas: null
    img: null
    width: null
    height: null
    plot: null
    current: "0.0000"
    voltage: "0.0000" 
    workToDo: "0"
    charge: true

    constructor: (idCanvas, img) ->
       
        @canvas = document.getElementById idCanvas
        @img = document.getElementById img
        @canvas.width = @img.width
        @canvas.height = @img.height
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
        if @charge
            @drawTextCharge @current, @voltage, @workToDo
        else
            @drawTextDischarge @current, @voltage, @workToDo

    drawTextCharge: (@current, @voltage, @workToDo) ->
        ctx = @canvas.getContext "2d"
        ctx.clearRect 3.4*(@width/11), (7*(@height/20)), @width, @height
        ctx.fillText @current, 4*(@width/11), (8*(@height/20)) 
        ctx.fillText @voltage, 4*(@width/11), (11*(@height/20))
        ctx.fillText @workToDo, 4*(@width/11), (14*(@height/20))

    drawTextDischarge: (@current, @voltage, @workToDo) ->
        ctx = @canvas.getContext "2d"
        ctx.clearRect 3.4*(@width/11), (7*(@height/20)), @width, @height
        ctx.fillText @current, 7*(@width/11), (8*(@height/20)) 
        ctx.fillText @voltage, 7*(@width/11), (11*(@height/20))
        ctx.fillText @workToDo, 7*(@width/11), (14*(@height/20))

        
window.Esd = Esd