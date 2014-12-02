class Init

    plot: null
    resizeActive: null

    constructor: (idCanvas, img)->
        console.log "lalalalala"
        @plot = new Plot idCanvas, img
        sliders()

        window.addEventListener "resize", => 
            if @resizeActive 
                clearTimeout(@resizeActive)
            @resizeActive = setTimeout( =>
                @esd.drawImageInCanvas()
                @plot.resizeEvent()
            , 250)

window.Init = Init