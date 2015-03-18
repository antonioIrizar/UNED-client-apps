class Init

    plot: null
    resizeActive: null
    esd: null
    solar: null
    crane: null
    common: null
    wsData: null
    wsCamera: null

    constructor: (idCanvas, img)->
        #Listen for the event wsDataReady
        document.addEventListener 'selectInterface', @selectInterface, false
        document.addEventListener 'allWsAreReady', @eventReadyAll, false
        @wsData = new WebsocketData()
        @wsCamera = new WebSocketCamera()
        @plot = new Plot()
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
            document.getElementById 'dischargeButton'
                .removeAttribute 'disabled'
            @crane = null
            @common.mySwitch true
        @solar = new SolarElements()
        document.getElementById "panelHeadingElements" 
            .innerHTML = 'Elements you can interact with: Mode charge'
        document.getElementById 'chargeButton'
            .setAttribute 'disabled', 'disabled'
        
    selectDischarge: ->
        if @solar is null
            @common = new CommonElements false
        else
            @solar.remove()
            delete @solar
            document.getElementById 'chargeButton'
                .removeAttribute 'disabled'
            @solar = null
            @common.mySwitch false
        @crane = new CraneElements()
        document.getElementById "panelHeadingElements" 
            .innerHTML = 'Elements you can interact with: Mode discharge'
        document.getElementById 'dischargeButton'
            .setAttribute 'disabled', 'disabled'

    selectInterface: (e) =>
        battery = e.detail.battery
        role = document.getElementById 'yourRole'
        if battery >= 90
            @selectCharge()
        else
            @selectDischarge()
        if e.detail.role is 'observer'
            disableAll()
            $("#stop").attr('disabled', 'disabled')
            $("#reset").attr('disabled', 'disabled')
            document.getElementById 'dischargeButton'
                .setAttribute 'disabled', 'disabled'
            document.getElementById 'chargeButton'
                .setAttribute 'disabled', 'disabled'
            role.appendChild document.createTextNode 'You are mode observer'
        else
            $("#stop").attr('disabled', 'disabled')
            $("#reset").attr('disabled', 'disabled')
            role.appendChild document.createTextNode 'You are mode controller'

        $(".slider-battery").val battery
        actualBattery = battery
        $("p#textBattery").text battery + "%"

    eventReadyAll: (e) =>
        if @wsData.wsDataIsReady and @wsCamera.wsCameraIsReady
            myApp.hidePleaseWait()

window.Init = Init