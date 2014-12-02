class Plot

    resizeActive: null
    dataPlot: null
    options: null
    chart: null
    time: 0
    alarma: null
    options1: null
    init: false
    data:[[]]
    realTime: null
    esd: null

    constructor: (idCanvas, img) ->
        @data = [[]]
        @esd = new Esd idCanvas, img
        @resize()
        google.setOnLoadCallback @drawChart()
        @init()
            
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
            height =  document.getElementById("div_formula_col").offsetHeight - document.getElementById("experiment-real-time-data").offsetHeight - 90
            height = height - 20
        else
            height = document.getElementById("chart_div").offsetWidth *0.6
        document.getElementById("chart_div").setAttribute "style","height:"+ height + "px"

    resizeEvent: ->
        @esd.drawImageInCanvas()
        @resize()
        if @init 
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
                    chartArea:{height: "80%"},
                    legend: {position: 'none'},
                    animation:{
                        duration: a ,
                        easing: 'linear',
                        }
                }
            else
                @options1 = {
                    chartArea:{height: "80%"},
                    legend: {position: 'none'},
                    animation:{
                        duration: 1,
                        easing: 'linear',
                    }
                }
            @chart.draw(@dataPlot, @options1)
                

    drawChart: ->
        @dataPlot = google.visualization.arrayToDataTable([
          ['Time', 'Amps', 'Joules'],
          ['0', 0.00, 0.00]
        ])
        @data[@time] = ['0', 0.00, 0.00]
        @time++
        @options = {
            chartArea:{height: "80%"},
            legend: {position: 'none'}       
        }

        @chart = new google.visualization.LineChart(document.getElementById('chart_div'));

        @chart.draw(@dataPlot, @options)

        google.visualization.events.addListener @chart, 'animationfinish', => 

            @dataPlot.addRow @data[@time-1]
           
            @options1 = {
                chartArea:{height: "80%"},
                legend: {position: 'none'},
                animation:{
                    duration: 5000,
                    easing: 'linear',
                }
            }
            @chart.draw(@dataPlot, @options1)
            @esd.drawText Math.random().toFixed(3), Math.random().toFixed(3), Math.random().toFixed(3)
            if @time > 18
                @dataPlot.removeRow 0
            @data[@time] = [''+(@time*5), parseFloat((10*Math.random()).toFixed(2)), parseFloat((10*Math.random()).toFixed(2))]
            @time++

        
    init: =>
        @alarma = setTimeout(=>
            @init = true
            @options1 = {
                chartArea:{height: "80%"},
                legend: {position: 'none'},
                
                animation:{
                    duration: 5000,
                    easing: 'linear',
                }
            }
            @data[@time] = [''+(@time*5), parseFloat((10*Math.random()).toFixed(2)) ,parseFloat((10*Math.random()).toFixed(2))]
            console.log @data[@time]
            @dataPlot.addRow @data[@time]
            @time++
            d = new Date()
            @realTime = d.getTime()
            @chart.draw(@dataPlot, @options1)
            @data[@time] = [''+(@time*5), parseFloat((10*Math.random()).toFixed(2)) ,parseFloat((10*Math.random()).toFixed(2))]
            @time++
        , 3000)
    
window.Plot = Plot