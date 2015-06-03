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
    interruptExperiment: false
    role: 'observer'
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
                @eolic.startExperiment = false
            myApp.hidePleaseWait()
        , false

        document.addEventListener 'switchLab', (e) =>
            if @role is 'observer'
                if e.detail.modeLab is 'charge'
                    @createUiCharge()
                else
                    @createUiDischarge()
            else 
                if @switchLab
                    @switchLab = false
                    myApp.hidePleaseWait()
        , false

        @change = false
        #same id for websocket data and video. It is for close correctly in backned.
        #token = Math.random()
        token = 1001
        @wsData = new WebsocketData token
        @wsCamera = new WebSocketCamera token
        @plot = new Plot()
        @esd = new Esd idCanvas, img
        
        window.onresize = @resize

    changeNumbers: (inputCurrent, inputVoltage, outputCurrent, outputVoltage, workToDo) =>
        if @charge
            @esd.drawTextCharge inputCurrent, inputVoltage, workToDo
            @plot.current = inputCurrent
            @plot.voltage = inputVoltage
        else
            @esd.drawTextDischarge outputCurrent, outputVoltage, workToDo
            @plot.current = outputCurrent
            @plot.voltage = outputVoltage
        @plot.workToDo = workToDo
        $("p#textBattery").text workToDo + "%"
        if @plot.initChart is false
            @plot.initChart = true
            @plot.init()
        
    resize: =>
        if @resizeActive 
                clearTimeout(@resizeActive)
            @resizeActive = setTimeout( =>
                adapt = document.getElementById("adaptToHeight")
                if adapt isnt null
                    adapt.setAttribute "style","height: 0px"
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
        @esd.charge = true
        @esd.drawTextCharge '0.0000', '0.0000', '0'
        if @common is null
            @common = new CommonElements @wsData, true
        else
            if @role is 'controller'
                @wsData.sendActuatorChange 'FWheelLab', "0"
            @noria.remove()
            delete @noria
            document.getElementById 'dischargeButton'
                .removeAttribute 'disabled'
            @noria = null
            @common.mySwitch true
            if @role is 'controller'
                @wsData.sendActuatorChange 'WindLab', "1"
        @eolic = new EolicElements @wsData
        @charge = true

        @common.enableSliders()
        @common.enableStart()
        @common.disableStop()
        @common.disableReset()

        document.getElementById "panelHeadingElements"
            .innerHTML = 'Elements you can interact with: Mode charge'        
        document.getElementById 'chargeButton'
            .setAttribute 'disabled', 'disabled'
        @resize()

    createUiCharge: ->
        @esd.charge = true
        @esd.drawTextCharge '0.0000', '0.0000', '0'
        @noria.remove()
        delete @noria
        @noria = null
        @common.mySwitch true
        @common.disable()
        @eolic = new EolicElements @wsData
        @charge = true
        @eolic.disable()
        document.getElementById "panelHeadingElements"
            .innerHTML = 'Elements you can interact with: Mode charge'
        @resize()
        
    selectDischarge: =>
        @switchLab = true
        myApp.showPleaseWait()
        @esd.charge = false
        @esd.drawTextDischarge '0.0000', '0.0000', '0'
        if @common is null
            @common = new CommonElements @wsData, false
        else
            if @role is "controller"
                @wsData.sendActuatorChange 'WindLab', "0"
            @eolic.remove()
            delete @eolic
            document.getElementById 'chargeButton'
                .removeAttribute 'disabled'
            @eolic = null
            @common.mySwitch false
            if @role is "controller"
                @wsData.sendActuatorChange 'FWheelLab', "1"
        @noria = new NoriaElements @wsData
        @charge = false       

        @common.enableSliders()
        @common.enableStart()
        @common.disableStop()
        @common.disableReset()

        document.getElementById "panelHeadingElements" 
            .innerHTML = 'Elements you can interact with: Mode discharge'
        document.getElementById 'dischargeButton'
            .setAttribute 'disabled', 'disabled'
        @resize()

    createUiDischarge: ->
        @esd.charge = false
        @esd.drawTextDischarge '0.0000', '0.0000', '0'

        @eolic.remove()
        delete @eolic
        @eolic = null
        @common.mySwitch false
        @common.disable()
        @noria = new NoriaElements @wsData
        @charge = false
        @noria.disable()

        document.getElementById "panelHeadingElements" 
            .innerHTML = 'Elements you can interact with: Mode discharge'
        @resize()

    selectInterface: (e) =>
        battery = e.detail.battery
        @role = e.detail.role
        role = document.getElementById 'yourRole'
        if e.detail.lab is 'wind'
            @selectCharge()
        else
            @selectDischarge()
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
            role.innerHTML = 'You are an observer'
        else
            @common.disableStop()
            @common.disableReset()
            role.innerHTML = 'You are the controller'

        $(".slider-battery").val battery
        $("p#textBattery").text battery + "%"

    observer: ->
        @role = 'observer'
        if @charge
                @eolic.disable()
            else
                @noria.disable()
        role = document.getElementById 'yourRole'
        @common.disable()
        document.getElementById 'dischargeButton'
            .setAttribute 'disabled', 'disabled'
        document.getElementById 'chargeButton'
            .setAttribute 'disabled', 'disabled'
        role.innerHTML = 'You are mode observer'

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
        @eolic.wind = null
        @common.enableSliders()
        @common.enableStart()
        @common.disableStop()
        @common.resetTimer()
        $(".slider-battery").val(@wsData.battery)
        $('.slider-time').val 0
        if not @charge
            @noria.enable()

    resetExperiment: ->
        @interruptExperiment = true

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

    finishExperiment: (e) =>
        $ @INFOMODALTITLE
            .empty()
        $ @INFOMODALBODY
            .empty()
        $ @INFOMODALTITLE 
            .append 'Experiment has been finished'
        if @charge
            textToSend = 'You get the results followings, for charging the battery with the windmill: \r\n\t* Duration of the experiment: ' + e.detail.data[0] + ' seconds \r\n\t* Jouls won from the experiment: ' + e.detail.data[1] + ' J'
            text = 'You get the results followings, for charging the battery with the windmill:' + '<ul><li>Duration of the experiment: ' + e.detail.data[0] + ' seconds</li>' + '<li>Jouls won from the experiment: ' + e.detail.data[1] + ' J</li></ul>'
        else
            textToSend = 'You get the results followings, for discharging the battery with the noria: \r\n\t* Duration of the experiment: ' + e.detail.data[0] + ' seconds \r\n\t* Jouls used from the experiment: ' + e.detail.data[1] + ' J \r\n\t* Turns given by the noria in the experiment: ' + e.detail.data[2] + ' Turns'
            text = 'You get the results followings, for discharging the battery with the noria:' + '<ul><li>Duration of the experiment: ' + e.detail.data[0] + ' seconds</li>' + '<li>Jouls used from the experiment: ' + e.detail.data[1] + ' J</li>' + '<li>Turns given by the noria in the experiment: ' + e.detail.data[2] + ' Turns</li></ul>'
            if not @interruptExperiment and @role is 'controller'
                $(".slider-turns").val(0)
                @noria.enable()
                document.getElementById 'chargeButton'
                    .removeAttribute 'disabled'

        $ @INFOMODALBODY
            .append  '<p>'+ text + '</p>'
        $(@INFOMODAL).modal('show')

        @stopTrue()
        @plot.initChart = false

        if not @interruptExperiment and @role is 'controller'
            $(".slider-battery").val(@wsData.battery)
            @common.disableStop()
            @common.disableReset()
            @common.enableSliders()
            @common.enableStart()

        if @charge
            @esd.drawTextCharge '0.0000', '0.0000', @wsData.battery
        else
            @esd.drawTextDischarge '0.0000', '0.0000', @wsData.battery

        @interruptExperiment = false
        @plot.reset textToSend

    chargeStart: =>
        if ((@eolic.wind isnt null || @eolic.wind is 0) and parseInt($(".slider-wind").val()) is 0)
            $('#myModalError').modal('show')
        else
            modal = false;
            if (@eolic.wind isnt null and @eolic.wind isnt  parseInt($(".slider-wind").val()))
                @newForm("wind-form-confirm", "Wind", $(".slider-wind").val().toString() , @eolic.wind.toString(), "wind")
                modal = true

            if (@eolic.millRot isnt null and @eolic.millRot isnt parseInt($(".slider-eolic-rot").val()))
                @newForm("mill-rot-form-confirm", "Mill horizontal rot", $(".slider-eolic-rot").val().toString() , @eolic.millRot.toString(), "millRot")
                modal = true;

            if (modal)
                $('#myModalConfirm').modal('show')
            else
                @eolic.startExperiment = true

                @eolic.sendWind()
                @eolic.sendMillRot()
                @common.sendTime()
                @common.sendJouls()

                @wsData.sendActuatorChange 'ESD', '1'

                @common.disableSliders()
                @common.disableStart()
                @common.enableStop()
                @common.enableReset()

    dischargeStart: -> 
        myApp.showPleaseWait()
        @noria.sendTurns()
        @common.sendJoulsToUse()
        @common.sendTime()

        @wsData.sendActuatorChange 'ESD', '1'

        document.getElementById 'chargeButton'
                .setAttribute 'disabled', 'disabled'
        @noria.disable()
        @common.disableSliders()
        @common.disableStart()
        @common.enableStop()
        @common.enableReset()

    confirmAccept: ->
        auxWind = @getValueRadius 'Wind'
        auxMillRot = @getValueRadius 'Mill horizontal rot'

        if auxWind isnt null and @eolic.wind isnt auxWind
            @eolic.sendWind()
        else
            $ '.slider-wind'
                .val @eolic.wind

        if auxMillRot isnt null and @eolic.millRot isnt auxMillRot
            @eolic.sendMillRot()
        else
            $ '.slider-eolic-rot'
                .val @eolic.millRot

        @eolic.startExperiment = true
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