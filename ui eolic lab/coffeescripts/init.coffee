class Init

    plot: null
    resizeActive: null
    esd: null
    eolic: null
    noria: null
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
                @eolic.startExperiment = false
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
            @wsData.sendActuatorChange 'FWheelLab', "0"
            @noria.remove()
            delete @noria
            document.getElementById 'dischargeButton'
                .removeAttribute 'disabled'
            @noria = null
            @common.mySwitch true
            @wsData.sendActuatorChange 'WindLab', "1"
        @eolic = new EolicElements @wsData
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
            @wsData.sendActuatorChange 'WindLab', "0"
            @eolic.remove()
            delete @eolic
            document.getElementById 'chargeButton'
                .removeAttribute 'disabled'
            @eolic = null
            @common.mySwitch false
            @wsData.sendActuatorChange 'FWheelLab', "1"
        @noria = new NoriaElements @wsData
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
                @eolic.disable()
            else
                @noria.disable()
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
        @common.resetTimer()
        $('.slider-time').val 0
        if not @charge
            @noria.enable()

    resetExperiment: ->

        if @charge
            @eolic.wind = null
            $('.slider-wind').val 0

            @eolic.millRot = null
            $('.slider-eolic-rot').val 0

            #fix battery
            #$('.slider-battery').val 10
            $('.slider-time').val 0

            #Reset experiment
            @wsData.sendActuatorChange 'WindLab', '0'
            @wsData.sendActuatorChange 'WindLab', '1'
        else 
            @noria.enable()
            @wsData.sendActuatorChange 'FWheelLab', '0'
            @wsData.sendActuatorChange 'FWheelLab', '1'

        @common.resetTimer()
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
            $(".slider-turns").val(0)
            $(".slider-battery").val(@wsData.battery)
            @noria.enable()
            @common.disableStop()
            @common.disableReset()
            document.getElementById 'chargeButton'
                .removeAttribute 'disabled'

        @common.enableSliders()
        @common.enableStart()
        @stopTrue()

    chargeStart: =>
        if ((@eolic.wind isnt null || @eolic.wind is 0) and parseInt($(".slider-wind").val()) is 0)
            $('#myModalError').modal('show')
        else
            modal = false;
            if (@eolic.wind isnt null and @eolic.wind isnt  parseInt($(".slider-wind").val()))
                newForm("wind-form-confirm", "Wind", $(".slider-wind").val().toString() , @eolic.wind.toString(), "wind")
                modal = true

            if (@eolic.millRot isnt null and @eolic.millRot isnt parseInt($(".slider-eolic-rot").val()))
                newForm("mill-rot-form-confirm", "Mill horizontal rot", $(".slider-eolic-rot").val().toString() , @eolic.millRot.toString(), "millRot")
                modal = true;

            if (modal)
                $('#myModalConfirm').modal('show')
            else
                @eolic.startExperiment = true

                @eolic.sendWind();
                @eolic.sendMillRot()
                @common.sendTime()
                @common.sendJouls()

                @wsData.sendActuatorChange('ESD', "1")

                @common.disableSliders()
                @common.disableStart()
                @common.enableStop()
                @common.enableReset()

    dischargeStart: -> 
        myApp.showPleaseWait()
        @noria.sendTurns()
        @common.sendJoulsToUse()
        @common.sendTime()

        @wsData.sendActuatorChange('ESD', "1")

        document.getElementById 'chargeButton'
                .setAttribute 'disabled', 'disabled'
        @noria.disable()
        @common.disableSliders()
        @common.disableStart()
        @common.enableStop()
        @common.enableReset()


window.Init = Init