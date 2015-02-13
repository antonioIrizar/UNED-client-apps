class Init

    plot: null
    resizeActive: null
    Esd: null

    constructor: (idCanvas, img)->
        console.log "lalalalala"
        @plot = new Plot
        sliders()
        @esd = new Esd idCanvas, img

        window.addEventListener "resize", => 
            if @resizeActive 
                clearTimeout(@resizeActive)
            @resizeActive = setTimeout( =>
                @plot.resizeEvent()
            , 250)

    changeNumbers: (inputCurrent, inputVoltage, workToDo) ->
        @esd.drawText inputCurrent.toFixed(3), inputVoltage.toFixed(3), workToDo.toFixed(3)
        @plot.inputCurrent = inputCurrent
        @plot.inputVoltage = inputVoltage
        @plot.workToDo = workToDo
        if @plot.initChart is false
            console.log "iniciando"
            @plot.initChart = true
            @plot.init()

window.Init = Init