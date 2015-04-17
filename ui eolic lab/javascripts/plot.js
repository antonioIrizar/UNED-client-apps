// Generated by CoffeeScript 1.8.0
(function() {
  var Plot;

  Plot = (function() {
    Plot.prototype.resizeActive = null;

    Plot.prototype.dataPlot = null;

    Plot.prototype.options = null;

    Plot.prototype.chart = null;

    Plot.prototype.time = 0;

    Plot.prototype.alarma = null;

    Plot.prototype.options1 = null;

    Plot.prototype.initChart = false;

    Plot.prototype.data = [[]];

    Plot.prototype.realTime = null;

    Plot.prototype.inputCurrent = null;

    Plot.prototype.inputVoltage = null;

    Plot.prototype.workToDo = null;

    Plot.prototype.stop = true;

    function Plot() {
      this.data = [[]];
      this.chart = new google.visualization.LineChart(document.getElementById('chart_div'));
      this.stop = true;
      google.setOnLoadCallback(this.drawChart());

      /*
      window.addEventListener "resize", =>
          if @resizeActive 
              clearTimeout(@resizeActive)
          @resizeActive = setTimeout( =>
              @resize()
              @chart.draw(@dataPlot, @options)
          ,500)
       */
    }

    Plot.prototype.resize = function() {
      var height, margin;
      if (window.innerWidth >= 1200) {
        height = document.getElementById("div_formula_col").offsetHeight - document.getElementById("webcam").offsetHeight - 90;
        height = height - 20;
        this.options = {
          chartArea: {
            left: 40,
            top: 20,
            height: height - 50,
            width: "100%"
          },
          legend: {
            position: 'none'
          },
          series: {
            0: {
              color: "red"
            },
            1: {
              color: "green"
            },
            2: {
              color: "blue"
            }
          }
        };
      } else {
        height = 250;
        this.options = {
          chartArea: {
            left: 40,
            top: 20,
            height: "200",
            width: "100%"
          },
          legend: {
            position: 'none'
          },
          series: {
            0: {
              color: "red"
            },
            1: {
              color: "green"
            },
            2: {
              color: "blue"
            }
          }
        };
      }
      if (window.innerWidth < 760) {
        margin = Math.round((760 - window.innerWidth) * 0.12);
        document.getElementById("legend").setAttribute("style", "margin-left: -" + margin + "px");
      } else {
        document.getElementById("legend").removeAttribute("style");
      }
      document.getElementById("chart_div").setAttribute("style", "height:" + height + "px");
      return this.chart.draw(this.dataPlot, this.options);
    };

    Plot.prototype.resizeEvent = function(esd) {
      var a, b, d;
      esd.drawImageInCanvas();
      this.resize();
      if (this.initChart) {
        if (this.time > 18) {
          this.dataPlot.removeRow(17);
        } else {
          this.dataPlot.removeRow(this.time - 2);
        }
        this.chart.draw(this.dataPlot, this.options);
        this.dataPlot.addRow(this.data[this.time - 2]);
        d = new Date();
        b = d.getTime();
        a = this.realTime + (1000 * (this.time - 2) * 5) - b;
        if (a > 0) {
          this.options1 = {
            chartArea: {
              left: 40,
              top: 20,
              height: "80%",
              width: "100%"
            },
            legend: {
              position: 'none'
            },
            animation: {
              duration: a,
              easing: 'linear'
            },
            series: {
              0: {
                color: "red"
              },
              1: {
                color: "green"
              },
              2: {
                color: "blue"
              }
            }
          };
        } else {
          this.options1 = {
            chartArea: {
              left: 40,
              top: 20,
              height: "80%",
              width: "100%"
            },
            legend: {
              position: 'none'
            },
            animation: {
              duration: 1,
              easing: 'linear'
            },
            series: {
              0: {
                color: "red"
              },
              1: {
                color: "green"
              },
              2: {
                color: "blue"
              }
            }
          };
        }
        return this.chart.draw(this.dataPlot, this.options1);
      }
    };

    Plot.prototype.drawChart = function() {
      this.dataPlot = google.visualization.arrayToDataTable([['Time', 'Amps', 'Volts', 'Joules'], ['0', 0.000, 0.000, 0.000]]);
      this.data[this.time] = ['0', 0.000, 0.000, 0.000];
      this.time++;
      this.options = {
        chartArea: {
          left: 40,
          top: 20,
          height: "80%",
          width: "100%"
        },
        legend: {
          position: 'none'
        },
        series: {
          0: {
            color: "red"
          },
          1: {
            color: "green"
          },
          2: {
            color: "blue"
          }
        }
      };
      this.chart.draw(this.dataPlot, this.options);
      return google.visualization.events.addListener(this.chart, 'animationfinish', (function(_this) {
        return function() {
          console.log("dentro del lisenet");
          if (!_this.stop) {
            if (_this.time > 18) {
              _this.dataPlot.removeRow(0);
            }
            _this.data[_this.time] = ['' + _this.time, parseFloat(_this.inputCurrent), parseFloat(_this.inputVoltage), parseFloat(_this.workToDo)];
            _this.dataPlot.addRow(_this.data[_this.time]);
            _this.time++;
            _this.options1 = {
              chartArea: {
                left: 40,
                top: 20,
                height: "80%",
                width: "100%"
              },
              legend: {
                position: 'none'
              },
              animation: {
                duration: 1900,
                easing: 'linear'
              },
              series: {
                0: {
                  color: "red"
                },
                1: {
                  color: "green"
                },
                2: {
                  color: "blue"
                }
              }
            };
            return _this.chart.draw(_this.dataPlot, _this.options1);
          }
        };
      })(this));
    };

    Plot.prototype.init = function() {
      this.data[this.time] = ['' + this.time, parseFloat(this.inputCurrent), parseFloat(this.inputVoltage), parseFloat(this.workToDo)];
      this.dataPlot.addRow(this.data[this.time]);
      this.time++;
      this.options1 = {
        chartArea: {
          left: 40,
          top: 20,
          height: "80%",
          width: "100%"
        },
        legend: {
          position: 'none'
        },
        animation: {
          duration: 900,
          easing: 'linear'
        },
        series: {
          0: {
            color: "red"
          },
          1: {
            color: "green"
          },
          2: {
            color: "blue"
          }
        }
      };
      return this.chart.draw(this.dataPlot, this.options1);

      /*
      @alarma = setTimeout(=>
          @init = true
      
          @options1 = {
              chartArea:{left:40,top:20,height: "80%", width:"85%"},
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
       */
    };

    return Plot;

  })();

  window.Plot = Plot;

}).call(this);
