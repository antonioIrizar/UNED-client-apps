class Plot

    resizeActive: null
    dataPlot: null
    options: null
    chart: null
    time: 0
    options1: null
    initChart: false
    data:[[]]
    realTime: null
    inputCurrent: null
    inputVoltage: null 
    workToDo: null
    stop: true
    experiments: null

    constructor:  ->
        @experiments = []
        @data = [[]]
        #@esd = new Esd idCanvas, img
        @chart = new google.visualization.LineChart(document.getElementById('chart_div'));
        @stop = true
        google.setOnLoadCallback @drawChart()
        #@resize()
        #@init()
            
        ###
        window.addEventListener "resize", =>
            if @resizeActive 
                clearTimeout(@resizeActive)
            @resizeActive = setTimeout( =>
                @resize()
                @chart.draw(@dataPlot, @options)
            ,500)
        ###
    resize: ->
        if window.innerWidth >= 1200
            height =  document.getElementById("div_formula_col").offsetHeight - document.getElementById("webcam").offsetHeight - 90
            height = height - 20
            @options = {
                chartArea:{left:40,top:20,height: height-50, width:"100%"},
                legend: {position: 'none'}   
                series: {
                    0: {color: "red"},
                    1: { color: "green"},
                    2: { color: "blue"},
                    }    
            }
        else
            height = 250
            @options = {
                chartArea:{left:40,top:20,height: "200", width:"100%"},
                legend: {position: 'none'}   
                series: {
                    0: {color: "red"},
                    1: { color: "green"},
                    2: { color: "blue"},
                    }    
            }
        

        if window.innerWidth < 760 
            margin = Math.round((760 - window.innerWidth)*0.12)
            document.getElementById("legend").setAttribute "style", "margin-left: -" + margin + "px"
        else
            document.getElementById("legend").removeAttribute "style"

        #fix this problems with full resolutions
        document.getElementById("chart_div").setAttribute "style","height:"+ height + "px"
        @chart.draw(@dataPlot, @options)

    resizeEvent: (esd) ->
        #fixme
        esd.drawImageInCanvas()
        @resize()
        if @initChart 
            if @time > 18
                @dataPlot.removeRow 17
            else
                @dataPlot.removeRow @time-2
            @chart.draw(@dataPlot, @options)
    
            @dataPlot.addRow @data[@time-2]
            d = new Date()
            b = d.getTime()
            a = @realTime+(1000*(@time-2)*5) - b

            if a >0
                @options1 = {
                    chartArea:{left:40,top:20,height: "80%", width:"100%"},
                    legend: {position: 'none'},
                    animation:{
                        duration: a ,
                        easing: 'linear',
                        }
                    series: {
                        0: {color: "red"},
                        1: { color: "green"},
                        2: { color: "blue"},
                    }    
                }
            else
                @options1 = {
                    chartArea:{left:40,top:20,height: "80%", width:"100%"},
                    legend: {position: 'none'},
                    animation:{
                        duration: 1,
                        easing: 'linear',
                    }
                    series: {
                        0: {color: "red"},
                        1: { color: "green"},
                        2: { color: "blue"},
                    }    
                }
            @chart.draw(@dataPlot, @options1)   

    drawChart: ->
        @dataPlot = google.visualization.arrayToDataTable([
              ['Time', 'Amps', 'Volts', 'Joules'],
              ['0', 0.000, 0.000, 0.000]
            ])
        @data[@time] = ['0', 0.000, 0.000, 0.000]
        @time++
        @options = {
            chartArea:{left:40,top:20,height: "80%", width:"100%"},
            legend: {position: 'none'}   
            series: {
                0: {color: "red"},
                1: { color: "green"},
                2: { color: "blue"},
                }    
        }
        @chart.draw(@dataPlot, @options)

        #@chart = new google.visualization.LineChart(document.getElementById('chart_div'));
        google.visualization.events.addListener @chart, 'animationfinish', => 
            console.log "dentro del lisenet"
            if not @stop
                if @time > 18
                    @dataPlot.removeRow 0
                @data[@time] = [''+(@time), parseFloat(@inputCurrent), parseFloat(@inputVoltage), parseFloat(@workToDo)]
                @dataPlot.addRow @data[@time]
                @time++
                @options1 = {
                    chartArea:{left:40,top:20,height: "80%", width:"100%"},
                    legend: {position: 'none'},
                    animation:{
                        duration: 1900,
                        easing: 'linear',
                    }
                    series: {
                        0: {color: "red"},
                        1: { color: "green"},
                        2: { color: "blue"},
                    }    
                }
                @chart.draw(@dataPlot, @options1)
            #@esd.drawText Math.random().toFixed(3), Math.random().toFixed(3), Math.random().toFixed(3)     

    init: ->
        @timeStart = new Date().toUTCString()
        @data[@time] = [''+(@time), parseFloat(@inputCurrent), parseFloat(@inputVoltage), parseFloat(@workToDo)]
        @dataPlot.addRow @data[@time]
        @time++
        @options1 = {
                chartArea:{left:40,top:20,height: "80%", width:"100%"},
                legend: {position: 'none'},
                animation:{
                    duration: 900,
                    easing: 'linear',
                }
                series: {
                    0: {color: "red"},
                    1: { color: "green"},
                    2: { color: "blue"},
                }    
            }
        @chart.draw(@dataPlot, @options1)
    
    reset: ->
        @saveArrayData()
        @time = 0
        @data = [[]]
        @chart.clearChart()
        google.setOnLoadCallback @drawChart()

    saveArrayData: ->
        aux = 
            timeStart: @timeStart
            timeFinish: new Date().toUTCString()
            data: @data

        @experiments.push aux
        console.log @experiments[0].timeFinish

    save: ->
        $ '#example1' 
            .handsontable
                    data: @data,
                    colHeaders: ["Time", "Amps", "Volts", "Jouls"],
                    maxCols: 4,
                    maxRows: 4,
                    columns: [
                        {readOnly: true,}
                        {readOnly: true,}
                        {readOnly: true,}
                        {readOnly: true,}
                    ],
            
        $ '#myModalCSV'
            .modal 'show'

    saveTextAsFile: ->
        textToWrite = "We don't have real data at this time :(. It's comming soon :)\n caca"
        textToWrite = 'Experiment at'
        textFileAsBlob = new Blob([textToWrite], {type:'text/plain'})
        fileNameToSaveAs = document.getElementById("inputNameOfFile").value + ".txt"
        browserName = navigator.appName
        if browserName == "Microsoft Internet Explorer"
            window.navigator.msSaveBlob(textFileAsBlob, fileNameToSaveAs )
        else
            downloadLink = document.createElement("a")
            downloadLink.download = fileNameToSaveAs
            downloadLink.innerHTML = "Download File"
        if window.webkitURL isnt undefined
            #Chrome allows the link to be clicked
            #without actually adding it to the DOM.
            downloadLink.href = window.webkitURL.createObjectURL(textFileAsBlob)
        else
            #Firefox requires the link to be added to the DOM
            #before it can be clicked.
            downloadLink.href = window.URL.createObjectURL(textFileAsBlob)
            downloadLink.onclick = @destroyClickedElement
            downloadLink.style.display = "none"
            document.body.appendChild(downloadLink)

        downloadLink.click()

    destroyClickedElement: (event) ->
        document.body.removeChild(event.target)

window.Plot = Plot