class Plot

    resizeActive: null
    dataPlot: null
    options: null
    chart: null
    time: 0
    options1: null
    initChart: false
    data:[[]]
    current: null
    voltage: null 
    workToDo: null
    stop: true
    experiments: null
    timeStart: null

    constructor:  ->
        @experiments = []
        @data = [[]]
        @chart = new google.visualization.LineChart(document.getElementById('chart_div'));
        @stop = true
        google.setOnLoadCallback @drawChart()
        
    resize: ->
        if window.innerWidth >= 1200
            height =  document.getElementById("div_formula_col").offsetHeight - document.getElementById("experiment-real-time-data").offsetHeight - 90
            height = height - 20
            @options = {
                chartArea:{left:40,top:20,height: height-52, width:"100%"},
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
        if not @stop 
            if @time > 18
                @dataPlot.removeRow 17
            else
                @dataPlot.removeRow @time-1
            @chart.draw(@dataPlot, @options)
    
            @dataPlot.addRow [@data[@time-1][0], parseFloat(@data[@time-1][1]), parseFloat(@data[@time-1][2]), parseFloat(@data[@time-1][3])]
            d = new Date()
            b = d.getTime()
            a = (1000*(@time-1)*5) - b

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
        @data[@time] = ['0', '0.0000', '0.0000', '0']
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
                @data[@time] = [''+(@time), @current, @voltage, @workToDo]
                @dataPlot.addRow [''+(@time), parseFloat(@current), parseFloat(@voltage), parseFloat(@workToDo)]
                @time++
                @options1 = {
                    chartArea:{left:40,top:20,height: "80%", width:"100%"},
                    legend: {position: 'none'},
                    animation:{
                        duration: 985,
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
        @time = 0
        @data = [[]]
        @chart.clearChart()
        @chart = new google.visualization.LineChart(document.getElementById('chart_div'))
        google.setOnLoadCallback @drawChart()

        @timeStart = new Date().toUTCString()
        @data[@time] = [''+(@time), @current, @voltage, @workToDo]
        @dataPlot.addRow [''+(@time), parseFloat(@current), parseFloat(@voltage), parseFloat(@workToDo)]
        @time++
        @options1 = {
                chartArea:{left:40,top:20,height: "80%", width:"100%"},
                legend: {position: 'none'},
                animation:{
                    duration: 985,
                    easing: 'linear',
                }
                series: {
                    0: {color: "red"},
                    1: { color: "green"},
                    2: { color: "blue"},
                }    
            }
        @chart.draw(@dataPlot, @options1)
    
    reset: (text)->
        @saveArrayData text

    saveArrayData: (text) =>
        aux = 
            timeStart: @timeStart
            timeFinish: new Date().toUTCString()
            data: @data
            result: text

        @experiments.push aux

    save: ->
        $ '#tableCSV' 
            .handsontable
                data: @data,
                colHeaders: ["Time", "Amps", "Volts", "Jouls"],
                maxCols: 4,
                height: 396,
                stretchH: 'all',
                columnSorting: true,
                contextMenu: true,
                columns: [
                    {readOnly: true,}
                    {readOnly: true,}
                    {readOnly: true,}
                    {readOnly: true,}
                ],
            
        $ '#myModalCSV'
            .modal 'show'

    saveTextAsFile: ->
        length = @experiments.length
        textToWrite = 'Report experiments \r\n\r\nYou have made ' + length + ' experiments. You can see the results for each of them in this document. \r\n'
        for information, i in @experiments
            number = i+1
            textToWrite = textToWrite + '\r\nExperiment ' + number + ' was executed at ' + information.timeStart + ' and finish at ' + information.timeFinish + '.\r\n' + information.result + '\r\n\t* Data generate during the experiment were following:\r\n'
            line = '\t\t ----------------------------------\r\n'
            textToWrite = textToWrite + line + '\t\t| Time |  Amps  |  Volts  |  Jouls |\r\n' + line
            for data, j in information.data
                switch data[0].length
                    when 1
                        dataText = '\t\t|   ' + j + '  | '
                    when 2
                        dataText = '\t\t|  ' + j + '  | '
                    when 3
                        dataText = '\t\t| ' + j + '  | '
                    when 4
                        dataText = '\t\t| ' + j + ' | '

                dataText = dataText + data[1] + ' | ' + data[2]

                switch data[3].length
                    when 1
                        dataText = dataText + '  |    ' + data[3] + '   |\r\n'
                    when 2
                        dataText = dataText + '  |   ' + data[3] + '   |\r\n'
                    when 3
                        dataText = dataText + '  |  ' + data[3] + '   |\r\n'

                textToWrite = textToWrite + dataText + line
        
        textFileAsBlob = new Blob([textToWrite], {type:'text/plain'})
        fileNameToSaveAs = document.getElementById("inputNameOfFile").value + ".txt"
        ie = navigator.userAgent.match(/MSIE\s([\d.]+)/)
        ie11 = navigator.userAgent.match(/Trident\/7.0/) and navigator.userAgent.match(/rv:11/)
        if ie or ie11
            window.navigator.msSaveBlob textFileAsBlob, fileNameToSaveAs 
        else
            downloadLink = document.createElement "a"
            downloadLink.download = fileNameToSaveAs
            downloadLink.innerHTML = "Download File"
            if window.webkitURL isnt undefined
                #Chrome allows the link to be clicked
                #without actually adding it to the DOM.
                downloadLink.href = window.webkitURL.createObjectURL textFileAsBlob
            else
                #Firefox requires the link to be added to the DOM
                #before it can be clicked.
                downloadLink.href = window.URL.createObjectURL textFileAsBlob
                downloadLink.onclick = @destroyClickedElement
                downloadLink.style.display = "none"
                document.body.appendChild downloadLink

            downloadLink.click()

    destroyClickedElement: (event) ->
        document.body.removeChild(event.target)

window.Plot = Plot