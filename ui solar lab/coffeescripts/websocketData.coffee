class WebsocketData
    wsData: null
    URLWS: "ws://62.204.201.214:8081"
    firstTimeBattery: true
    wsDataIsReady: false
    role: "observer"
    battery: null
    token: null
    lab: null
    switchUi: false
    oneNone: false
    alwaysObserver: false
    errorWithControler: false

    constructor: (@token) ->
        @wsDataIsReady = false
        @firstTimeBattery = true
        @role = "observer"
        @lab = null
        @switchUi = false
        @oneNone = false
        @alwaysObserver = false
        @errorWithControler = false

        @wsData = new WebSocket @URLWS

        @wsData.onopen = @onopen
        @wsData.onmessage = @onmessage
        @wsData.onclose = @onclose
        @wsData.onerror = @onerror

    onopen: =>
        console.log "ws open"
        @getSensorData("ESDval", "observer")

    onclose: (event) =>
        console.log "close"
        switch event.code
            when 1000
                myApp.hidePleaseWait()
                myApp.showError "Time expire", "The connection was close because your time to use the laboratory was expire."
            when 1001
                myApp.hidePleaseWait()
                myApp.showError "Server go to maintenance", "Sorry the connection was close because the server go to maintenance. Please try later"
            when 1002 or 1003
                myApp.hidePleaseWait()
                myApp.showError "Something's not right", "Sorry a error happened."
            when 1006 
                myApp.hidePleaseWait()
                myApp.showError "Something's not right", "Sorry impossible to conect to the server. If it's the first time reload the web, it isn't maybe the server is down. Please try later."

    onmessage: (event) =>
        data = event.data+""
        console.log data
        msg = JSON.parse data
        console.log msg

        ##improve this with case
        if msg.method == "sendActuatorData"
            if msg.responseMessages isnt undefined && msg.responseMessages.code == 409
                console.log "code 409"
                if msg.responseMessages.message is "AccesRole controller already assigned."
                    myApp.showPleaseWait()
                    @alwaysObserver = true
                    @errorWithControler = true
                    @role = 'observer' 
                    @wsDataIsReady = false
                    if @lab is 'none'
                        @getSensorData("Doing", "observer") 
                    else
                        @switchUi = true
                        if @lab is 'solar'
                            varInit.observer()
                            @getSensorData("Light", "observer")
                        else
                            varInit.observer()
                return

            if msg.payload.actuatorId is "SolarLab" and msg.payload.responseData.data[0] is "1"

                if @firstTimeBattery or @lab is null
                    @lab = 'solar'
                    @alwaysObserver = true
                    return
                
                if not @wsDataIsReady and @switchUi 
                    @lab = 'solar'
                    @abort = false
                    @solarInterfaz()
                    @getSensorData("Light", "observer")
                    return
               
                if not @wsDataIsReady and @lab isnt null
                    @lab = 'solar' 
                    @role = "controller"
                    eve = document.createEvent 'CustomEvent'
                    eve.initCustomEvent 'selectInterface', true, false, {'role' : @role, 'battery' : @battery, 'lab' : 'solar'}
                    document.dispatchEvent eve
                    @wsDataIsReady = true
                    eve = document.createEvent 'Event'
                    eve.initEvent 'allWsAreReady', true, false
                    document.dispatchEvent eve
                    #getSensorData("ESDval", "controller")
                else 
                    @lab = 'solar'
                    eve = document.createEvent 'CustomEvent'
                    eve.initCustomEvent 'switchLab', true, false, {'modeLab' : 'charge'}
                    document.dispatchEvent eve
                return

            if msg.payload.actuatorId is "CraneLab" and msg.payload.responseData.data[0] is "1"

                if @firstTimeBattery or @lab is null
                    @lab = 'crane'
                    @alwaysObserver = true
                    return

                @lab = 'crane'
                if not @wsDataIsReady and @switchUi 
                    @abort = true
                    @craneInterfaz()
                    return
               
                if not @wsDataIsReady
                    @role = "controller" 
                    eve = document.createEvent 'CustomEvent'
                    eve.initCustomEvent 'selectInterface', true, false, {'role' : @role, 'battery' : @battery, 'lab' : 'crane'}
                    document.dispatchEvent eve
                    @wsDataIsReady = true
                    eve = document.createEvent 'Event'
                    eve.initEvent 'allWsAreReady', true, false
                    document.dispatchEvent eve
                    #getSensorData("ESDval", "controller")
                else
                    eve = document.createEvent 'CustomEvent'
                    eve.initCustomEvent 'switchLab', true, false, {'modeLab' : 'discharge'}
                    document.dispatchEvent eve

                return

        if msg.method == "sendActuatorData" && msg.payload.actuatorId == "ESD"
            if msg.payload.responseData.data[0] == "1" and not @alwaysObserver and @wsDataIsReady
                eve = document.createEvent 'Event'
                eve.initEvent 'ESDOn', true, false
                document.dispatchEvent eve
                @getSensorData("ESDval", "controller")
                $("#stop").removeAttr('disabled')
                $("#reset").removeAttr('disabled')
                return

        if (msg.method == "sendActuatorData" && msg.payload.actuatorId == "Panelrot")
            eve = document.createEvent 'CustomEvent'
            eve.initCustomEvent 'reciveData', true, false, {'actuatorId' : msg.payload.actuatorId, 'value' : msg.payload.responseData.data[0]}
            document.dispatchEvent eve

            return

        if msg.method == "sendActuatorData" && msg.payload.actuatorId == "Paneltilt"
            eve = document.createEvent 'CustomEvent'
            eve.initCustomEvent 'reciveData', true, false, {'actuatorId' : msg.payload.actuatorId, 'value' : msg.payload.responseData.data[0]}
            document.dispatchEvent eve
           
            return

        if msg.method == "sendActuatorData" && msg.payload.actuatorId == "Sun"
            eve = document.createEvent 'CustomEvent'
            eve.initCustomEvent 'reciveData', true, false, {'actuatorId' : msg.payload.actuatorId, 'value' : msg.payload.responseData.data[0]}
            document.dispatchEvent eve

            return

        if msg.method == "sendActuatorData" && ( msg.payload.actuatorId == "Elapsed" or  msg.payload.actuatorId == 'TOuseJ' or  msg.payload.actuatorId == 'TOgetJ' or msg.payload.actuatorId == 'WeightTrip')
            eve = document.createEvent 'CustomEvent'
            eve.initCustomEvent 'finishExperiment', true, false, msg.payload.responseData
            document.dispatchEvent eve
            return

        if msg.method == "getSensorData" && msg.sensorId == "ESDval"
            if (msg.responseData.valueNames.length == 7)
                #fix this
                if @role is 'observer'
                    varInit.stopFalse()
                @battery = msg.responseData.data[6]
                varInit.changeNumbers(msg.responseData.data[1], msg.responseData.data[0], msg.responseData.data[4], msg.responseData.data[3], @battery)

            if @firstTimeBattery 
                #fix this
                @firstTimeBattery = false
                @battery = msg.responseData.data[0]
                if @lab is null
                    @getSensorData("Doing", "observer")
                else
                    @switchUi = true
                    if @lab is 'solar'
                        @solarInterfaz()
                        @getSensorData("Light", "observer")
                    else
                        @craneInterfaz()

            return
            #finishInitLoading(msg.responseData.data[0])

        if msg.method == "getSensorData" && msg.sensorId == "Doing"

            if @alwaysObserver and not @errorWithControler
                @switchUi = true
                if @lab is 'solar'
                    @solarInterfaz()
                    @getSensorData("Light", "observer")
                    return
                else
                    @craneInterfaz()
                    return
            else
                if @errorWithControler
                    @switchUi = true
                    if @lab is 'none' and msg.responseData.data[0] is 'none'
                        if @battery < 90
                            @lab = 'solar'
                            @solarInterfaz()
                            @getSensorData("Light", "observer")
                            return
                        else
                            @lab = 'crane'
                            @craneInterfaz()
                            return
                    else
                        if msg.responseData.data[0] is 'none'
                            if @lab is 'solar'
                                @solarInterfaz()
                                @getSensorData("Light", "observer")
                                return
                            else
                                @craneInterfaz()
                                return
                        else
                            if msg.responseData.data[0] is 'solar'
                                @solarInterfaz()
                                @getSensorData("Light", "observer")
                                return
                            else
                                @craneInterfaz()
                                return
                else
                    if msg.responseData.data[0] is 'none'
                        if @lab is null
                            if @battery < 90
                                @sendActuatorChange 'SolarLab', "1"
                            else
                                @sendActuatorChange 'CraneLab', "1" 
                            @lab = 'none'

                    
                    if msg.responseData.data[0] is 'crane'
                        @alwaysObserver = true
                        @lab = 'crane'
                        @switchUi = true
                        @craneInterfaz()
                        return

                    if msg.responseData.data[0] is 'solar'
                        @alwaysObserver = true
                        @lab = 'solar'
                        @switchUi = true
                        @solarInterfaz()
                        @getSensorData("Light", "observer")
                        return

            return
            

        if msg.method == "getSensorData" && msg.sensorId == "Light"
            if @abort
                @abort = false
                return
            $(".slider-lumens").val(parseInt(msg.responseData.data[0]))
            if @switchUi 
                @getSensorData("PanelRot", "observer")
            return
        
        if msg.method == "getSensorData" && msg.sensorId == "PanelRot"
            if @abort
                @abort = false
                return
            $(".slider-horizontal-axis").val(parseInt(msg.responseData.data[0]))
            if @switchUi
                @getSensorData("PanelTilt", "observer")
            return

        if msg.method == "getSensorData" && msg.sensorId == "PanelTilt"
            if @abort
                @abort = false
                return
            $(".slider-vertical-axis").val(parseInt(msg.responseData.data[0]))
            if @switchUi
                @switchUi = false
            if not @wsDataIsReady 
                @wsDataIsReady = true
                eve = document.createEvent 'Event'
                eve.initEvent 'allWsAreReady', true, false
                document.dispatchEvent eve
            return

    craneInterfaz: =>
        eve = document.createEvent 'CustomEvent'
        eve.initCustomEvent 'selectInterface', true, false, {'role' : @role, 'battery' : @battery, 'lab' : 'crane'}
        document.dispatchEvent eve
        if not @wsDataIsReady 
            @wsDataIsReady = true
            @switchUi = false
            eve = document.createEvent 'Event'
            eve.initEvent 'allWsAreReady', true, false
            document.dispatchEvent eve

    solarInterfaz: =>
        eve = document.createEvent 'CustomEvent'
        eve.initCustomEvent 'selectInterface', true, false, {'role' : @role, 'battery' : @battery, 'lab' : 'solar'}
        document.dispatchEvent eve

    sendActuatorChange: (actuatorId, data) -> 
        actuatorRequest = 
            'method': 'sendActuatorData'
            'authToken': @token.toString()
            'accessRole': 'controller'
            'actuatorId': actuatorId
            'valueNames': ''
            'data': data
        
        jsonRequest = JSON.stringify actuatorRequest
        @wsData.send jsonRequest
    
    getSensorData: (sensorId, accessRole) ->
        sensorRequest = 
            'method': 'getSensorData'
            'authToken': @token.toString()
            'accessRole': accessRole
            'updateFrequency': '1' 
            'sensorId': sensorId

        jsonRequest = JSON.stringify sensorRequest
        @wsData.send jsonRequest


window.WebsocketData = WebsocketData