class Init

    plot: null
    resizeActive: null
    esd: null
    solar: null
    crane: null
    common: null

    constructor: (idCanvas, img)->
        @plot = new Plot
        sliders()
        @esd = new Esd idCanvas, img
        @plot.resize()


        ### stop working in firefox
        window.addEventListener "resize", => 
            console.log "mierda puta"
            if @resizeActive 
                clearTimeout(@resizeActive)
            @resizeActive = setTimeout( =>
                @plot.resizeEvent(@esd)
                console.log "resize"
            , 250)
        ###
        window.onresize = @resize
    changeNumbers: (inputCurrent, inputVoltage, workToDo) ->
        @esd.drawText inputCurrent, inputVoltage, workToDo
        @plot.inputCurrent = inputCurrent
        @plot.inputVoltage = inputVoltage
        @plot.workToDo = workToDo
        if @plot.initChart is false
            console.log "iniciando"
            @plot.initChart = true
            @plot.init()
        if @plot.stop
            @plot.initChart = false
        

    resize: =>
        if @resizeActive 
                clearTimeout(@resizeActive)
            @resizeActive = setTimeout( =>
                adapt = document.getElementById("adaptToHeight")
                if adapt isnt null
                    height = window.innerHeight - document.getElementById("panel-elements").offsetHeight 
                    height = height-20
                    adapt.setAttribute "style","height:"+ height + "px"
                @plot.resizeEvent(@esd)
                
            , 250)

    stopTrue: ->
        @plot.stop = true

    stopFalse: ->
        @plot.stop = false

    selectCharge: ->
        if @crane is null
            @common = new CommonElements true
        else
            @crane.remove()
            delete @crane
            @crane = null
            @common.mySwitch true
        @solar = new SolarElements()
        
    selectDischarge: ->
        if @solar is null
            @common = new CommonElements false
        else
            @solar.remove()
            delete @solar
            @solar = null
            @common.mySwitch false
        @crane = new CraneElements()

window.Init = Init