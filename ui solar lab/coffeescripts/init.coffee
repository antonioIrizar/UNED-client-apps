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
    interruptExperiment: false
    INFOMODAL: '#infoModal'
    INFOMODALTITLE: '#infoModalTitle'
    INFOMODALBODY: '#infoModalBody'

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
        @interruptExperiment = true
        @wsData.sendActuatorChange 'ESD', '0'
        @stopTrue()
        @common.enableSliders()
        @common.enableStart()
        @common.disableStop()
        @common.resetTimer()
        $(".slider-battery").val(@wsData.battery)
        $('.slider-time').val 0
        if not @charge
            @crane.enable()

    resetExperiment: ->
        @interruptExperiment = true

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

        $(".slider-battery").val(@wsData.battery)
        @common.resetTimer()
        @common.enableSliders()
        @common.enableStart()
        @common.disableStop()
        @common.disableReset()
        @stopTrue()

    finishExperiment: (e) =>
        $ @INFOMODALTITLE
            .empty()
        $ @INFOMODALBODY
            .empty()
        $ @INFOMODALTITLE 
            .append 'Experiment has been finished'
        if @charge
            textToSend = 'You get the results followings, for charging the battery with the windmill:\r\n\t* Duration of the experiment: ' + e.detail.data[0] + ' seconds\r\n\t* Jouls won from the experiment: ' + e.detail.data[1] + ' J'
            text = 'You get the results followings, for charging the battery with the windmill:' + '<ul><li>Duration of the experiment: ' + e.detail.data[0] + ' seconds</li>' + '<li>Jouls won from the experiment: ' + e.detail.data[1] + ' J</li></ul>'
        else
            textToSend = 'You get the results followings, for discharging the battery with the noria:\r\n\t* Duration of the experiment: ' + e.detail.data[0] + ' seconds\r\n\t* Jouls used from the experiment: ' + e.detail.data[1] + ' J\r\n\t* Distance travelled by the weigth in the experiment: ' + e.detail.data[2] + ' cm'
            text = 'You get the results followings, for discharging the battery with the noria:' + '<ul><li>Duration of the experiment: ' + e.detail.data[0] + ' seconds</li>' + '<li>Jouls used from the experiment: ' + e.detail.data[1] + ' J</li>' + '<li>Distance travelled by the weigth in the experiment: ' + e.detail.data[2] + ' cm</li></ul>'
            if not @interruptExperiment
                $(".slider-distance").val(0)
                @crane.enable()
                document.getElementById 'chargeButton'
                    .removeAttribute 'disabled'

        $ @INFOMODALBODY
            .append  '<p>'+ text + '</p>'
        $(@INFOMODAL).modal('show')
        
        if not @interruptExperiment
            $(".slider-battery").val(@wsData.battery)
            @common.disableStop()
            @common.disableReset()
            @common.enableSliders()
            @common.enableStart()
            @stopTrue()

        @interruptExperiment = false
        @plot.reset textToSend

    chargeStart: =>
        if (parseInt($(".slider-lumens").val()) is 0)
            $('#myModalError').modal('show')
        else
            modal = false;
            if (@solar.lumens isnt null and @solar.lumens isnt  parseInt($(".slider-lumens").val()))
                @newForm("lumens-axis-form-confirm", "Lumens", $(".slider-lumens").val().toString() , @solar.lumens.toString(), "lumens")
                modal = true

            if (@solar.horizontalAxis isnt null and @solar.horizontalAxis isnt parseInt($(".slider-horizontal-axis").val()))
                @newForm("horizontal-axis-form-confirm", "Horizontal axis", $(".slider-horizontal-axis").val().toString() , @solar.horizontalAxis.toString(), "horizontalAxis")
                modal = true;

            if (@solar.verticalAxis isnt null and @solar.verticalAxis isnt parseInt($(".slider-vertical-axis").val()))
                @newForm("vertical-axis-form-confirm", "Vertical axis", $(".slider-vertical-axis").val().toString() , @solar.verticalAxis.toString(), "verticalAxis")
                modal = true

            if (modal)
                $('#myModalConfirm').modal('show')
            else
                @solar.startExperiment = true

                @solar.sendLumens()
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

    confirmAccept: ->
        auxLumens = @getValueRadius 'Lumens'
        auxHorizontalAxis = @getValueRadius 'Horizontal axis'
        auxVerticalAxis = @getValueRadius 'Vertical axis'

        if auxLumens isnt null and @solar.lumens isnt auxLumens
            @solar.sendLumens()
        else
            $ '.slider-lumens'
                .val @solar.lumens

        if auxHorizontalAxis isnt null and @solar.horizontalAxis isnt auxHorizontalAxis
            @solar.sendHorizontalAxis()
        else
            $ '.slider-horizontal-axis'
                .val @solar.horizontalAxis

        if auxVerticalAxis isnt null and @solar.verticalAxis isnt auxVerticalAxis
            @solar.sendVerticalAxis()
        else
            $ '.slider-vertical-axis'
                .val @solar.verticalAxis

        @solar.startExperiment = true

        @common.sendTime()
        @common.sendJouls()

        @wsData.sendActuatorChange 'ESD', '1'

        @common.disableSliders()
        @common.disableStart()
        @common.enableStop()
        @common.enableReset()

        @cleanForm()

    getValueRadius: (name) ->
        rads = document.getElementsByName name

        i = 0
        while i < rads.length
            if rads[i].checked 
                return rads[i].value
            i++
        
    cleanForm: ->
        form = document.getElementById 'form-confirm-changes'
        form.removeChild(document.getElementById('div-confirm-changes'))
        divForm = document.createElement 'div'
        divForm.setAttribute 'id', 'div-confirm-changes'
        form.appendChild divForm

    newForm: (id, labelText, newValue, oldValue, name) ->
        divPrincipal = document.getElementById 'div-confirm-changes'
        divForm = document.createElement 'form'
        divForm.setAttribute 'id', id
        divForm.setAttribute 'class', 'form-group'
        labelForm = document.createElement 'label'
        text = document.createTextNode labelText
        labelForm.appendChild text
        divForm.appendChild labelForm
        divForm.appendChild @newRadio(newValue, true, " (New)", name)
        divForm.appendChild @newRadio(oldValue, false, " (Old)", name)
        divPrincipal.appendChild divForm

    newRadio: (value, checked, newOrOld, name) ->
        divRadio = document.createElement 'div'
        divRadio.setAttribute 'class', 'radio'
        labelRadio = document.createElement 'label'
        input = document.createElement 'input'
        input.setAttribute 'type', 'radio'
        input.setAttribute 'name', name
        input.setAttribute 'value', value

        if checked
            input.setAttribute 'checked', true
        
        labelRadio.appendChild input
        text = document.createTextNode value + newOrOld
        labelRadio.appendChild text
        divRadio.appendChild labelRadio
        
        divRadio 


window.Init = Init