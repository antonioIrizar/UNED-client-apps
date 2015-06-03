class WebsocketData
    wsData: null
    URLWS: "ws://62.204.201.218:8082"
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
                        if @lab is 'wind'
                            varInit.observer()
                            @getSensorData("WindPower", "observer")
                        else
                            varInit.observer()
                return

            if msg.payload.actuatorId is "WindLab" and msg.payload.responseData.data[0] is "1"

                if @firstTimeBattery or @lab is null
                    @lab = 'wind'
                    @alwaysObserver = true
                    return
                
                if not @wsDataIsReady and @switchUi 
                    @lab = 'wind'
                    @abort = false
                    @windInterfaz()
                    @getSensorData("WindPower", "observer")
                    return

                if not @wsDataIsReady and @lab isnt null
                    @lab = 'wind'
                    @role  = "controller"
                    eve = document.createEvent 'CustomEvent'
                    eve.initCustomEvent 'selectInterface', true, false, {'role' : @role, 'battery' : @battery, 'lab' : 'wind'}
                    document.dispatchEvent eve
                    @wsDataIsReady = true
                    eve = document.createEvent 'Event'
                    eve.initEvent 'allWsAreReady', true, false
                    document.dispatchEvent eve
                else
                    @lab = 'wind'
                    eve = document.createEvent 'CustomEvent'
                    eve.initCustomEvent 'switchLab', true, false, {'modeLab' : 'charge'}
                    document.dispatchEvent eve
                return

            if msg.payload.actuatorId is "FWheelLab" and msg.payload.responseData.data[0] is "1"
                
                if @firstTimeBattery or @lab is null
                    @lab = 'wheel'
                    @alwaysObserver = true
                    return

                if not @wsDataIsReady and @switchUi
                    @lab = 'wheel'
                    @abort = true
                    @wheelInterfaz()
                    return

                if not @wsDataIsReady
                    @lab = 'wheel'
                    @role  = "controller" 
                    eve = document.createEvent 'CustomEvent'
                    eve.initCustomEvent 'selectInterface', true, false, {'role' : @role, 'battery' : @battery, 'lab' : 'wheel'}
                    document.dispatchEvent eve
                    @wsDataIsReady = true
                    eve = document.createEvent 'Event'
                    eve.initEvent 'allWsAreReady', true, false
                    document.dispatchEvent eve
                else
                    @lab = 'wheel'
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

        if (msg.method == "sendActuatorData" && msg.payload.actuatorId == "Millrot")

            eve = document.createEvent 'CustomEvent'
            eve.initCustomEvent 'reciveData', true, false, {'actuatorId' : msg.payload.actuatorId, 'value' : msg.payload.responseData.data[0]}
            document.dispatchEvent eve

            return

        if msg.method == "sendActuatorData" && msg.payload.actuatorId == "Wind"
            eve = document.createEvent 'CustomEvent'
            eve.initCustomEvent 'reciveData', true, false, {'actuatorId' : msg.payload.actuatorId, 'value' : msg.payload.responseData.data[0]}
            document.dispatchEvent eve

            return

        if msg.method == "sendActuatorData" && ( msg.payload.actuatorId == "Elapsed" or  msg.payload.actuatorId == 'TOuseJ' or  msg.payload.actuatorId == 'TOgetJ' or msg.payload.actuatorId == 'Turns')
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
                    if @lab is 'wind'
                        @windInterfaz()
                        @getSensorData("WindPower", "observer")
                    else
                        @wheelInterfaz()  
                    
            return
            #finishInitLoading(msg.responseData.data[0])

        if msg.method == "getSensorData" && msg.sensorId == "Doing"

            if @alwaysObserver and not @errorWithControler
                @switchUi = true
                if @lab is 'wind'
                    @windInterfaz()
                    @getSensorData("WindPower", "observer")
                    return
                else
                    @wheelInterfaz()
                    return
            else
                if @errorWithControler
                    @switchUi = true
                    if @lab is 'none' and msg.responseData.data[0] is 'none'
                        if @battery < 90
                            @lab = 'wind'
                            @windInterfaz()
                            @getSensorData("WindPower", "observer")
                            return
                        else
                            @lab = 'wheel'
                            @wheelInterfaz()
                            return
                    else
                        if msg.responseData.data[0] is 'none'
                            if @lab is 'wind'
                                @windInterfaz()
                                @getSensorData("WindPower", "observer")
                                return
                            else
                                @wheelInterfaz()
                                return
                        else
                            if msg.responseData.data[0] is 'wind'
                                @windInterfaz()
                                @getSensorData("WindPower", "observer")
                                return
                            else
                                @wheelInterfaz()
                                return
                else
                    if msg.responseData.data[0] is 'none'
                        if @lab is null
                            if @battery < 90
                                @sendActuatorChange 'WindLab', "1"
                            else
                                @sendActuatorChange 'FWheelLab', "1" 
                            @lab = 'none'

                    
                    if msg.responseData.data[0] is 'wheel'
                        @alwaysObserver = true
                        @lab = 'wheel'
                        @switchUi = true
                        @wheelInterfaz()
                        return

                    if msg.responseData.data[0] is 'wind'
                        @alwaysObserver = true
                        @lab = 'wind'
                        @switchUi = true
                        @windInterfaz()
                        @getSensorData("WindPower", "observer")
                        return

            return

        if msg.method == "getSensorData" && msg.sensorId == "WindPower"
            if @abort
                @abort = false
                return
            $(".slider-lumens").val(parseInt(msg.responseData.data[0]))
            if @switchUi 
                @getSensorData("MillRot", "observer")
            return

        if msg.method == "getSensorData" && msg.sensorId == "MillRot"
            if @abort
                @abort = false
                return
            $(".slider-vertical-axis").val(parseInt(msg.responseData.data[0]))
            if not @wsDataIsReady 
                @wsDataIsReady = true
                eve = document.createEvent 'Event'
                eve.initEvent 'allWsAreReady', true, false
                document.dispatchEvent eve
            return

    wheelInterfaz: =>
        eve = document.createEvent 'CustomEvent'
        eve.initCustomEvent 'selectInterface', true, false, {'role' : @role, 'battery' : @battery, 'lab' : 'wheel'}
        document.dispatchEvent eve
        if not @wsDataIsReady 
            @wsDataIsReady = true
            @switchUi = false
            eve = document.createEvent 'Event'
            eve.initEvent 'allWsAreReady', true, false
            document.dispatchEvent eve

    windInterfaz: =>
        eve = document.createEvent 'CustomEvent'
        eve.initCustomEvent 'selectInterface', true, false, {'role' : @role, 'battery' : @battery, 'lab' : 'wind'}
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