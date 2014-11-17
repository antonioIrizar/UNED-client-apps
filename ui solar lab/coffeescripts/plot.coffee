class Plot


    constructor: ->

      google.load("visualization", "1", {packages:["corechart"]})
      google.setOnLoadCallback(@drawChart)
    
    drawChart: ->
        data = google.visualization.arrayToDataTable([
          ['Year', 'Sales', 'Expenses'],
          ['2004',  1000,      400],
          ['2005',  1170,      460],
          ['2006',  660,       1120],
          ['2007',  1030,      540]
        ])

        options = {
          title: 'Company Performance'
        }

        chart = new google.visualization.LineChart(document.getElementById('chart_div'));

        chart.draw(data, options)
    
window.Plot = Plot