// Generated by CoffeeScript 1.8.0
(function() {
  var Plot,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Plot = (function() {
    Plot.prototype.resizeActive = null;

    Plot.prototype.dataPlot = null;

    Plot.prototype.options = null;

    Plot.prototype.chart = null;

    Plot.prototype.time = 0;

    Plot.prototype.options1 = null;

    Plot.prototype.initChart = false;

    Plot.prototype.data = [[]];

    Plot.prototype.current = null;

    Plot.prototype.voltage = null;

    Plot.prototype.workToDo = null;

    Plot.prototype.stop = true;

    Plot.prototype.experiments = null;

    Plot.prototype.timeStart = null;

    function Plot() {
      this.saveArrayData = __bind(this.saveArrayData, this);
      this.experiments = [];
      this.data = [[]];
      this.chart = new google.visualization.LineChart(document.getElementById('chart_div'));
      this.stop = true;
      google.setOnLoadCallback(this.drawChart());
    }

    Plot.prototype.resize = function() {
      var height, margin;
      if (window.innerWidth >= 1200) {
        height = document.getElementById("div_formula_col").offsetHeight - document.getElementById("experiment-real-time-data").offsetHeight - 90;
        height = height - 20;
        this.options = {
          chartArea: {
            left: 40,
            top: 20,
            height: height - 52,
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
      if (!this.stop) {
        if (this.time > 18) {
          this.dataPlot.removeRow(17);
        } else {
          this.dataPlot.removeRow(this.time - 1);
        }
        this.chart.draw(this.dataPlot, this.options);
        this.dataPlot.addRow([this.data[this.time - 1][0], parseFloat(this.data[this.time - 1][1]), parseFloat(this.data[this.time - 1][2]), parseFloat(this.data[this.time - 1][3])]);
        d = new Date();
        b = d.getTime();
        a = (1000 * (this.time - 1) * 5) - b;
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
      this.data[this.time] = ['0', '0.0000', '0.0000', '0'];
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
            _this.data[_this.time] = ['' + _this.time, _this.current, _this.voltage, _this.workToDo];
            _this.dataPlot.addRow(['' + _this.time, parseFloat(_this.current), parseFloat(_this.voltage), parseFloat(_this.workToDo)]);
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
                duration: 985,
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
      this.time = 0;
      this.data = [[]];
      this.chart.clearChart();
      this.chart = new google.visualization.LineChart(document.getElementById('chart_div'));
      google.setOnLoadCallback(this.drawChart());
      this.timeStart = new Date().toUTCString();
      this.data[this.time] = ['' + this.time, this.current, this.voltage, this.workToDo];
      this.dataPlot.addRow(['' + this.time, parseFloat(this.current), parseFloat(this.voltage), parseFloat(this.workToDo)]);
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
          duration: 985,
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
    };

    Plot.prototype.reset = function(text) {
      return this.saveArrayData(text);
    };

    Plot.prototype.saveArrayData = function(text) {
      var aux;
      aux = {
        timeStart: this.timeStart,
        timeFinish: new Date().toUTCString(),
        data: this.data,
        result: text
      };
      return this.experiments.push(aux);
    };

    Plot.prototype.save = function() {
      $('#tableCSV').handsontable({
        data: this.data,
        colHeaders: ["Time", "Amps", "Volts", "Jouls"],
        maxCols: 4,
        height: 396,
        stretchH: 'all',
        columnSorting: true,
        contextMenu: true,
        columns: [
          {
            readOnly: true
          }, {
            readOnly: true
          }, {
            readOnly: true
          }, {
            readOnly: true
          }
        ]
      });
      return $('#myModalCSV').modal('show');
    };

    Plot.prototype.saveTextAsFile = function() {
      var data, dataText, downloadLink, fileNameToSaveAs, i, ie, ie11, information, j, length, line, number, textFileAsBlob, textToWrite, _i, _j, _len, _len1, _ref, _ref1;
      length = this.experiments.length;
      textToWrite = 'Report experiments \r\n\r\nYou have made ' + length + ' experiments. You can see the results for each of them in this document. \r\n';
      _ref = this.experiments;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        information = _ref[i];
        number = i + 1;
        textToWrite = textToWrite + '\r\nExperiment ' + number + ' was executed at ' + information.timeStart + ' and finish at ' + information.timeFinish + '.\r\n' + information.result + '\r\n\t* Data generate during the experiment were following:\r\n';
        line = '\t\t ----------------------------------\r\n';
        textToWrite = textToWrite + line + '\t\t| Time |  Amps  |  Volts  |  Jouls |\r\n' + line;
        _ref1 = information.data;
        for (j = _j = 0, _len1 = _ref1.length; _j < _len1; j = ++_j) {
          data = _ref1[j];
          switch (data[0].length) {
            case 1:
              dataText = '\t\t|   ' + j + '  | ';
              break;
            case 2:
              dataText = '\t\t|  ' + j + '  | ';
              break;
            case 3:
              dataText = '\t\t| ' + j + '  | ';
              break;
            case 4:
              dataText = '\t\t| ' + j + ' | ';
          }
          dataText = dataText + data[1] + ' | ' + data[2];
          switch (data[3].length) {
            case 1:
              dataText = dataText + '  |    ' + data[3] + '   |\r\n';
              break;
            case 2:
              dataText = dataText + '  |   ' + data[3] + '   |\r\n';
              break;
            case 3:
              dataText = dataText + '  |  ' + data[3] + '   |\r\n';
          }
          textToWrite = textToWrite + dataText + line;
        }
      }
      textFileAsBlob = new Blob([textToWrite], {
        type: 'text/plain'
      });
      fileNameToSaveAs = document.getElementById("inputNameOfFile").value + ".txt";
      ie = navigator.userAgent.match(/MSIE\s([\d.]+)/);
      ie11 = navigator.userAgent.match(/Trident\/7.0/) && navigator.userAgent.match(/rv:11/);
      if (ie || ie11) {
        return window.navigator.msSaveBlob(textFileAsBlob, fileNameToSaveAs);
      } else {
        downloadLink = document.createElement("a");
        downloadLink.download = fileNameToSaveAs;
        downloadLink.innerHTML = "Download File";
        if (window.webkitURL !== void 0) {
          downloadLink.href = window.webkitURL.createObjectURL(textFileAsBlob);
        } else {
          downloadLink.href = window.URL.createObjectURL(textFileAsBlob);
          downloadLink.onclick = this.destroyClickedElement;
          downloadLink.style.display = "none";
          document.body.appendChild(downloadLink);
        }
        return downloadLink.click();
      }
    };

    Plot.prototype.destroyClickedElement = function(event) {
      return document.body.removeChild(event.target);
    };

    return Plot;

  })();

  window.Plot = Plot;

}).call(this);
