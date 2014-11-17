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

        window.addEventListener "resize", =>
            @drawImageInCanvas()
        
    drawImageInCanvas: ->
        @width = @canvas.width = @img.width-1
        @height = @canvas.height = @img.height-2
  
        ctx = @canvas.getContext "2d"
        a = window.innerHeight - document.getElementById("panel-elements").offsetHeight 
        a = a-20
        console.log screen.availHeight
        document.getElementById("adapt-to-height").setAttribute "style","height:"+ a + "px"
        
        ctx.font = Math.floor(@width*0.05)+"px monospace"
        ctx.fillText "Amps", (@width/11), (8*(@height/20)) 
        ctx.fillText "Volts", (@width/11), (11*(@height/20))
        ctx.fillText "Joules", (@width/11), (14*(@height/20))
        ctx.fillText "Charging", 3.5*(@width/11), (5*(@height/20))
        ctx.fillText "Discharging", 6.5*(@width/11), (5*(@height/20))

window.Esd = Esd