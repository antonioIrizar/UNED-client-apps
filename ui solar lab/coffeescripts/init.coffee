class Init

    plot: null
    resizeActive: null
    esd: null
    solar: null
    crane: null
    common: null
    wsData: null
    wsCamera: null
    charge: null
    switchLab: false

    constructor: (idCanvas, img)->
        #Listen for the event wsDataReady
        document.addEventListener 'selectInterface', @selectInterface, false
        document.addEventListener 'allWsAreReady', @eventReadyAll, false
        document.addEventListener 'finishExperiment', @finishExperiment, false
        document.addEventListener 'ESDOn', () => 
            if @charge 
                @solar.startExperiment = false
            myApp.hidePleaseWait()
        , false

        document.addEventListener 'switchLab', () =>
            if @switchLab
                @switchLab = false
                myApp.hidePleaseWait()
        , false

        @change = false
        #same id for websocket data and video. It is for close correctly in backned.
        token = Math.random()
        @wsData = new WebsocketData token
        @wsCamera = new WebSocketCamera token
        @plot = new Plot()
        @esd = new Esd idCanvas, img
        
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

    stopTrue: =>
        @plot.stop = true

    stopFalse: =>
        @plot.stop = false

    selectCharge: =>
        @switchLab = true
        myApp.showPleaseWait()
        if @common is null
            @common = new CommonElements @wsData, true
        else
            @wsData.sendActuatorChange 'CraneLab', "0"
            @crane.remove()
            delete @crane
            document.getElementById 'dischargeButton'
                .removeAttribute 'disabled'
            @crane = null
            @common.mySwitch true
            @wsData.sendActuatorChange 'SolarLab', "1"
        @solar = new SolarElements @wsData
        @charge = true

        @common.enableSliders()
        @common.enableStart()
        @common.disableStop()
        @common.disableReset()
        @stopTrue()

        document.getElementById "panelHeadingElements" 
            .innerHTML = 'Elements you can interact with: Mode charge'
        document.getElementById 'chargeButton'
            .setAttribute 'disabled', 'disabled'
        
    selectDischarge: =>
        @switchLab = true
        myApp.showPleaseWait()
        if @common is null
            @common = new CommonElements @wsData, false
        else
            @wsData.sendActuatorChange 'SolarLab', "0"
            @solar.remove()
            delete @solar
            document.getElementById 'chargeButton'
                .removeAttribute 'disabled'
            @solar = null
            @common.mySwitch false
            @wsData.sendActuatorChange 'CraneLab', "1"
        @crane = new CraneElements @wsData
        @charge = false

        @common.enableSliders()
        @common.enableStart()
        @common.disableStop()
        @common.disableReset()
        @stopTrue()

        document.getElementById "panelHeadingElements" 
            .innerHTML = 'Elements you can interact with: Mode discharge'
        document.getElementById 'dischargeButton'
            .setAttribute 'disabled', 'disabled'

    selectInterface: (e) =>
        battery = e.detail.battery
        role = document.getElementById 'yourRole'
        if battery >= 90
            @selectDischarge()     
        else
            @selectCharge()
        if e.detail.role is 'observer'
            if @charge
                @solar.disable()
            else
                @crane.disable()
            @common.disable()
            document.getElementById 'dischargeButton'
                .setAttribute 'disabled', 'disabled'
            document.getElementById 'chargeButton'
                .setAttribute 'disabled', 'disabled'
            role.appendChild document.createTextNode 'You are mode observer'
        else
            @common.disableStop()
            @common.disableReset()
            role.appendChild document.createTextNode 'You are mode controller'

        $(".slider-battery").val battery
        actualBattery = battery
        $("p#textBattery").text battery + "%"
        @plot.resize()

    eventReadyAll: (e) =>
        if @wsData.wsDataIsReady and @wsCamera.wsCameraIsReady
            myApp.hidePleaseWait()

    startExperiments: ->
        if @charge
            console.log "cargarrr"
            @chargeStart()
        else
            @dischargeStart()

        @stopFalse()

    stopExperiment: -> 
        @wsData.sendActuatorChange 'ESD', '0'
        @stopTrue()
        @common.enableSliders()
        @common.enableStart()
        @common.disableStop()
        if not @charge
            @crane.enable()

    resetExperiment: ->

        if @charge
            lumens = null
            $('.slider-lumens').val 0

            horizontalAxis = null
            $('.slider-horizontal-axis').val 0
     
            verticalAxis = null
            $('.slider-vertical-axis').val 0
            #fix battery
            #$('.slider-battery').val 10
            $('.slider-time').val 0

            #Reset experiment
            @wsData.sendActuatorChange 'SolarLab', '0'
            @wsData.sendActuatorChange 'SolarLab', '1'
        else 
            @crane.enable()
            @wsData.sendActuatorChange 'CraneLab', '0'
            @wsData.sendActuatorChange 'CraneLab', '1'

        @common.enableSliders()
        @common.enableStart()
        @common.disableStop()
        @common.disableReset()
        @stopTrue()

    finishExperiment: (e) =>
        if @charge
            $(".slider-battery").val(@wsData.battery)
            console.log "finish solar experiment"
            @common.disableStop()
            @common.disableReset()
        else
            $(".slider-distance").val(0)
            $(".slider-battery").val(@wsData.battery)
            @crane.enable()
            @common.disableStop()
            @common.disableReset()
            document.getElementById 'chargeButton'
                .removeAttribute 'disabled'

        @common.enableSliders()
        @common.enableStart()
        @stopTrue()

    chargeStart: =>
        if ((@solar.lumens isnt null || @solar.lumens is 0) and $(".slider-lumens").val() is 0)
            $('#myModalError').modal('show')
        else
            modal = false;
            if (@solar.lumens isnt null and @solar.lumens isnt $(".slider-lumens").val())
                newForm("lumens-axis-form-confirm", "Lumens", $(".slider-lumens").val().toString() , @solar.lumens.toString(), "lumens")
                modal = true

            if (@solar.horizontalAxis isnt null and @solar.horizontalAxis isnt $(".slider-horizontal-axis").val())
                newForm("horizontal-axis-form-confirm", "Horizontal axis", $(".slider-horizontal-axis").val().toString() , @solar.horizontalAxis.toString(), "horizontalAxis")
                modal = true;

            if (@solar.verticalAxis isnt null and @solar.verticalAxis isnt $(".slider-vertical-axis").val())
                newForm("vertical-axis-form-confirm", "Vertical axis", $(".slider-vertical-axis").val().toString() , @solar.verticalAxis.toString(), "verticalAxis")
                modal = true

            if (modal)
                $('#myModalConfirm').modal('show')
            else
                @solar.startExperiment = true

                @solar.sendLumens();
                @solar.sendHorizontalAxis()
                @solar.sendVerticalAxis()
                @common.sendTime()
                @common.sendJouls()

                @wsData.sendActuatorChange('ESD', "1")

                @common.disableSliders()
                @common.disableStart()
                @common.enableStop()
                @common.enableReset()

    dischargeStart: -> 
        myApp.showPleaseWait()
        @crane.sendDistance()
        @common.sendJoulsToUse()
        @common.sendTime()

        @wsData.sendActuatorChange('ESD', "1")

        document.getElementById 'chargeButton'
                .setAttribute 'disabled', 'disabled'
        @crane.disable()
        @common.disableSliders()
        @common.disableStart()
        @common.enableStop()
        @common.enableReset()


window.Init = Init