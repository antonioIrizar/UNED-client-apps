class Plot

    resizeActive: null
    data: null
    options: null
    chart: null
    constructor: ->
        @resize()
        google.setOnLoadCallback @drawChart()
        window.addEventListener "resize", =>
            if @resizeActive 
                clearTimeout(@resizeActive)
            @resizeActive = setTimeout( =>
                console.log "plot"
                @resize()
                @chart.draw(@data, @options)
            ,500)

    
    resize: ->
        a =  document.getElementById("div_formula_col").offsetHeight - document.getElementById("experiment-real-time-data").offsetHeight - 90
        a = a - 20
        document.getElementById("chart_div").setAttribute "style","height:"+ a + "px"

    doStats: ->
        init: ->
            console.log('init')
            @drawChart()

    drawChart: ->
        @data = google.visualization.arrayToDataTable([
          ['Year', 'Sales', 'Expenses'],
          ['2004',  1000,      400],
          ['2005',  1170,      460],
          ['2006',  660,       1120],
          ['2007',  1030,      540]
        ])

        @options = {
          title: 'Company Performance'
        }

        @chart = new google.visualization.LineChart(document.getElementById('chart_div'));

        @chart.draw(@data, @options)
    
window.Plot = Plot