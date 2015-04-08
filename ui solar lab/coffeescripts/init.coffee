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

    constructor: (idCanvas, img)->
        #Listen for the event wsDataReady
        document.addEventListener 'selectInterface', @selectInterface, false
        document.addEventListener 'allWsAreReady', @eventReadyAll, false
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

        document.getElementById "panelHeadingElements" 
            .innerHTML = 'Elements you can interact with: Mode charge'
        document.getElementById 'chargeButton'
            .setAttribute 'disabled', 'disabled'
        
    selectDischarge: =>
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
            console.log "entro por aqui y no se porque"
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
        @plot.resize()

    eventReadyAll: (e) =>
        if @wsData.wsDataIsReady and @wsCamera.wsCameraIsReady
            myApp.hidePleaseWait()

    startExperiments: =>
        if @charge
            console.log "cargarrr"
            @chargeStart()
        else
            @dischargeStart()

        @stopFalse()

    stopExperiment: -> 
        @wsData.sendActuatorChange 'ESD', '0'
        @stopTrue()
        enable()
    ###
    function stopExperiment(){
  sendActuatorChange('ESD', "0");
  //var jsonRequest = JSON.stringify({"method":"getSensorData","sensorId":"ESDval"});
  //ws.send(jsonRequest);
  varInit.stopTrue();
  enable();
};
    ###
    chargeStart: ->
        if ((lumens == null || lumens == 0) && $(".slider-lumens").val() == 0)
            $('#myModalError').modal('show')
        else
            modal = false;
            if (lumens != null && lumens != $(".slider-lumens").val())
                console.log(lumens)
                console.log($(".slider-lumens").val())
                newForm("lumens-axis-form-confirm", "Lumens", $(".slider-lumens").val().toString() , lumens.toString(), "lumens")
                modal = true

            if (horizontalAxis != null && horizontalAxis!= $(".slider-horizontal-axis").val())
                newForm("horizontal-axis-form-confirm", "Horizontal axis", $(".slider-horizontal-axis").val().toString() , horizontalAxis.toString(), "horizontalAxis")
                modal = true;

            if (verticalAxis != null && verticalAxis != $(".slider-vertical-axis").val())
                newForm("vertical-axis-form-confirm", "Vertical axis", $(".slider-vertical-axis").val().toString() , verticalAxis.toString(), "verticalAxis")
                modal = true

            if (modal)
                $('#myModalConfirm').modal('show')
            else
                startExperiment = true
                # revisar esto *
                ###
                sendLumens()
                sendHorizontalAxis()
                sendVerticalAxis()
                ###
                if (lumens != $(".slider-lumens").val())
                    @solar.sendLumens();
                if (horizontalAxis != $(".slider-horizontal-axis").val())
                    @solar.sendHorizontalAxis()
                if (verticalAxis != $(".slider-vertical-axis").val())
                    @solar.sendVerticalAxis()
                @common.sendTime()
                @common.sendJouls()
                ###
                //sendActuatorChange('Sun', $(".slider-lumens").val());
                //sendActuatorChange('Panelrot', $(".slider-horizontal-axis").val());
                //try this line with minus
                //sendActuatorChange('Paneltilt',"-" + $(".slider-vertical-axis").val());
                //sendActuatorChange('ESDJ', $(".slider-battery").val());
                //sendActuatorChange('Elapsed', $(".slider-time").val());
                ###
                disable()
                @wsData.sendActuatorChange('ESD', "1")

    dischargeStart: -> 
        @crane.sendDistance()
        @common.sendJoulsToUse()
        @common.sendTime()
        @wsData.sendActuatorChange('ESD', "1")


window.Init = Init