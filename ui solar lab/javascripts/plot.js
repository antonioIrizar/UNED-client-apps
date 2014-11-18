// Generated by CoffeeScript 1.8.0
(function() {
  var Plot;

  Plot = (function() {
    Plot.prototype.resizeActive = null;

    Plot.prototype.data = null;

    Plot.prototype.options = null;

    Plot.prototype.chart = null;

    function Plot() {
      this.resize();
      google.setOnLoadCallback(this.drawChart());

      /*
      window.addEventListener "resize", =>
          if @resizeActive 
              clearTimeout(@resizeActive)
          @resizeActive = setTimeout( =>
              @resize()
              @chart.draw(@data, @options)
          ,500)
       */
    }

    Plot.prototype.resize = function() {
      var height;
      if (window.innerWidth >= 1200) {
        height = document.getElementById("div_formula_col").offsetHeight - document.getElementById("experiment-real-time-data").offsetHeight - 90;
        height = height - 20;
      } else {
        height = document.getElementById("chart_div").offsetWidth * 0.6;
      }
      return document.getElementById("chart_div").setAttribute("style", "height:" + height + "px");
    };

    Plot.prototype.resizeEvent = function() {
      this.resize();
      return this.chart.draw(this.data, this.options);
    };

    Plot.prototype.drawChart = function() {
      this.data = google.visualization.arrayToDataTable([['Year', 'Sales', 'Expenses'], ['2004', 1000, 400], ['2005', 1170, 460], ['2006', 660, 1120], ['2007', 1030, 540]]);
      this.options = {
        title: 'Company Performance'
      };
      this.chart = new google.visualization.LineChart(document.getElementById('chart_div'));
      return this.chart.draw(this.data, this.options);
    };

    return Plot;

  })();

  window.Plot = Plot;

}).call(this);
