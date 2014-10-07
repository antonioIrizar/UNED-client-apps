// Generated by CoffeeScript 1.8.0
(function() {
  var Archimedes, Formula, Graph, Variable,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Formula = (function() {
    Formula.prototype.divFormula = null;

    Formula.prototype.divFormulaWithNumbers = null;

    Formula.prototype.divPanel = null;

    Formula.prototype.liFormula = null;

    Formula.prototype.descriptionVariables = null;

    Formula.prototype.srcImage = null;

    Formula.prototype.textFormula = null;

    Formula.prototype.variables = null;

    Formula.prototype.constantValue = null;

    Formula.prototype.idFormula = "prueba";

    Formula.prototype.equation = null;

    Formula.prototype.valueVariables = [];

    Formula.prototype.positionValueVariableX = null;

    Formula.prototype.graph = null;

    Formula.prototype.graphCloneCanvas = null;

    Formula.prototype.contextCanvasClone = null;

    Formula.prototype.mode = null;

    Formula.prototype.resizeTimer = null;

    function Formula(divPanel, liFormula, constantValue, descriptionVariables, srcImage, variables, equation, graph) {
      var paragraph, text;
      this.srcImage = srcImage;
      this.variables = variables;
      this.equation = equation;
      this.graph = graph;
      this.drop = __bind(this.drop, this);
      this.allowDrop = __bind(this.allowDrop, this);
      document.body.setAttribute('onresize', "");
      document.body.onresize = (function(_this) {
        return function() {
          if (_this.resizeTimer !== null) {
            clearTimeout(_this.resizeTimer);
          }
          return _this.resizeTimer = setTimeout(_this.graph.resizeCanvas(), 250);
        };
      })(this);
      this.liFormula = document.getElementById(liFormula);
      this.liFormula.setAttribute('ondragstart', "");
      this.liFormula.ondragstart = (function(_this) {
        return function(e) {
          return _this.drag(e);
        };
      })(this);
      this.divPanel = document.getElementById(divPanel);
      this.divFormula = document.createElement('div');
      this.divPanel.setAttribute('ondrop', "");
      this.divPanel.ondrop = (function(_this) {
        return function(e) {
          return _this.drop(e);
        };
      })(this);
      this.divPanel.setAttribute('ondragover', "");
      this.divPanel.ondragover = (function(_this) {
        return function(e) {
          return _this.allowDrop(e);
        };
      })(this);
      this.divFormula.height = '300 px';
      this.divFormula.width = '300 px';
      paragraph = document.createElement('p');
      text = document.createTextNode("Please drop your formula here");
      paragraph.appendChild(text);
      this.divPanel.appendChild(paragraph);
      this.divFormulaWithNumbers = document.createElement('div');
      this.divPanel.appendChild(this.divFormula);
      this.divPanel.appendChild(this.divFormulaWithNumbers);
      this.addListenerToFormula(this.srcImage);
      this.constantValue = document.getElementById(constantValue);
      this.descriptionVariables = document.getElementById(descriptionVariables);
      this.cloneCanvas();
    }

    Formula.prototype.prueba = function() {
      return console.log("blabla");
    };

    Formula.prototype.addListenerToFormula = function(srcImage) {
      return this.liFormula.addEventListener('dragstart', (function(_this) {
        return function(e) {
          var img;
          img = document.createElement("img");
          img.src = srcImage;
          return e.dataTransfer.setDragImage(img, 0, 0);
        };
      })(this), false);
    };

    Formula.prototype.allowDrop = function(ev) {
      return ev.preventDefault();
    };

    Formula.prototype.drag = function(ev) {};

    Formula.prototype.drop = function(ev) {
      var img;
      ev.preventDefault();
      img = document.createElement('img');
      img.src = this.srcImage;
      this.divFormula.appendChild(img);
      return this.divFormulaWithNumbers.appendChild(this.drawFormula());
    };

    Formula.prototype.drawFormula = function() {
      var form, formula, id, text, variable, _ref;
      formula = document.createElement('p');
      formula.setAttribute('class', "formula-text");
      formula.setAttribute('id', this.idFormula);
      form = document.createElement('form');
      _ref = this.variables;
      for (id in _ref) {
        variable = _ref[id];
        this.descriptionVariables.appendChild(this.createDt(variable.name, variable.fullName));
        this.descriptionVariables.appendChild(this.createDd(variable.description));
        if (id === "0") {
          text = document.createTextNode(variable.name + " = ");
          formula.appendChild(text);
        } else {
          form.appendChild(this.createInput(variable));
          text = document.createTextNode(variable.name);
          formula.appendChild(text);
        }
      }
      form.appendChild(this.createRadio("line", true));
      form.appendChild(this.createRadio("dots", false));
      form.appendChild(this.createButton());
      this.constantValue.appendChild(form);
      return formula;
    };

    Formula.prototype.createInput = function(variable) {
      var divInput, input, spanInput, text;
      divInput = document.createElement('div');
      divInput.setAttribute('class', "input-group");
      spanInput = document.createElement('span');
      spanInput.setAttribute('class', "input-group-addon");
      text = document.createTextNode(variable.name);
      spanInput.appendChild(text);
      divInput.appendChild(spanInput);
      input = document.createElement('input');
      input.setAttribute('class', "form-control");
      input.setAttribute('type', "text");
      input.setAttribute('id', variable.fullName);
      input.setAttribute('placeholder', variable.fullName);
      divInput.appendChild(input);
      return divInput;
    };

    Formula.prototype.createRadio = function(name, checked) {
      var divRadio, input, label, text;
      divRadio = document.createElement('div');
      divRadio.setAttribute('class', "radio");
      label = document.createElement('label');
      input = document.createElement('input');
      input.setAttribute('type', "radio");
      input.setAttribute('name', "modeLine");
      input.setAttribute('value', name);
      if (checked) {
        input.setAttribute('checked', true);
      }
      text = document.createTextNode("Graph with form: " + name);
      label.appendChild(input);
      label.appendChild(text);
      divRadio.appendChild(label);
      return divRadio;
    };

    Formula.prototype.createButton = function() {
      var button, divButton, text;
      divButton = document.createElement('div');
      divButton.setAttribute('class', "btn-group");
      button = document.createElement('button');
      button.setAttribute('type', "button");
      button.setAttribute('class', "btn btn-primary");
      button.setAttribute('button.setAttribute', "");
      button.addEventListener('click', (function(_this) {
        return function() {
          return _this.clickButton();
        };
      })(this));
      text = document.createTextNode("update values");
      button.appendChild(text);
      divButton.appendChild(button);
      return divButton;
    };

    Formula.prototype.createDt = function(name, fullName) {
      var dt, text;
      dt = document.createElement('dt');
      text = document.createTextNode(fullName + " (" + name + ")");
      dt.appendChild(text);
      return dt;
    };

    Formula.prototype.createDd = function(description) {
      var dd, text;
      dd = document.createElement('dd');
      text = document.createTextNode(description);
      dd.appendChild(text);
      return dd;
    };

    Formula.prototype.clickButton = function() {
      var aux, i, id, rads, variable, _ref;
      this.graph.context.clearRect(0, 0, this.graph.canvas.width, this.graph.canvas.height);
      this.graph.context.drawImage(this.graphCloneCanvas, 0, 0);
      _ref = this.variables.slice(1);
      for (id in _ref) {
        variable = _ref[id];
        aux = document.getElementById(variable.fullName);
        id++;
        if (aux.value !== "") {
          this.variables[id].value = new Number(aux.value);
        } else {
          this.variables[id].value = null;
        }
      }
      rads = document.getElementsByName('modeLine');
      i = 0;
      while (i < rads.length) {
        if (rads[i].checked) {
          this.mode = rads[i].value;
          break;
        }
        i++;
      }
      this.drawNumbersFormula();
      this.getVariableValues();
      this.graph.drawVariables(this.variables[this.positionValueVariableX + 1].name, this.variables[0].name);
      return this.graph.drawEquation((function(_this) {
        return function(x) {
          return _this.executeEquation(x);
        };
      })(this), 'blue', 3, this.mode);
    };

    Formula.prototype.cloneCanvas = function() {
      this.graphCloneCanvas = document.createElement('canvas');
      this.contextCanvasClone = this.graphCloneCanvas.getContext('2d');
      this.graphCloneCanvas.width = this.graph.canvas.width;
      this.graphCloneCanvas.height = this.graph.canvas.height;
      return this.contextCanvasClone.drawImage(this.graph.canvas, 0, 0);
    };

    Formula.prototype.drawNumbersFormula = function() {
      var formula, id, text, variable, _ref;
      formula = document.getElementById(this.idFormula);
      text = "";
      _ref = this.variables;
      for (id in _ref) {
        variable = _ref[id];
        if (variable.value !== null) {
          if (id === "1") {
            text = text + " = " + variable.value;
          } else {
            text = text + variable.value;
          }
        } else {
          if (id === "1") {
            text = text + " = " + variable.name;
          } else {
            text = text + variable.name;
          }
        }
      }
      return formula.innerHTML = text;
    };

    Formula.prototype.getVariableValues = function() {
      var id, variable, _ref;
      _ref = this.variables.slice(1);
      for (id in _ref) {
        variable = _ref[id];
        if (variable.value === null) {
          this.valueVariables[id] = null;
          this.positionValueVariableX = new Number(id);
        } else {
          this.valueVariables[id] = variable.value;
        }
      }
      return console.log(this.valueVariables);
    };

    Formula.prototype.executeEquation = function(x) {
      this.valueVariables[this.positionValueVariableX] = x;
      return this.equation(this.valueVariables);
    };

    return Formula;

  })();

  Archimedes = (function(_super) {
    __extends(Archimedes, _super);

    function Archimedes(divPanel, liFormula, constantValue, descriptionVariables) {
      var density, graph, gravity, newtowns, panel, variables, volume;
      newtowns = new Variable("E", "newtowns", "description", null);

      /*
      paragraph = document.createElement 'p'
      text1 = document.createTextNode "\u03C1"
      subTag = document.createElement 'sub'
      text2 = document.createTextNode "f"
      subTag.appendChild text2
      paragraph.appendChild text1
      paragraph.appendChild subTag
      console.log "aqui"
       */
      panel = document.getElementById('caca');
      console.log(window.innerWidth);
      graph = new Graph();
      density = new Variable("\u03C1", "density", "description", null);
      gravity = new Variable("g", "gravity", "description", null);
      volume = new Variable("V", "volume", "description", null);
      variables = [newtowns, density, gravity, volume];
      Archimedes.__super__.constructor.call(this, divPanel, liFormula, constantValue, descriptionVariables, 'images/archimedesFormula.png', variables, this.archimedesEquation, graph);
    }

    Archimedes.prototype.archimedesEquation = function(arrayVariables) {
      return arrayVariables[0] * arrayVariables[1] * arrayVariables[2];
    };


    /*
    archimedesEquation: (a,b,c) ->
        a*b*c
     */

    return Archimedes;

  })(Formula);

  Variable = (function() {
    Variable.prototype.name = null;

    Variable.prototype.fullName = null;

    Variable.prototype.description = null;

    Variable.prototype.value = null;

    function Variable(name, fullName, description, value) {
      this.name = name;
      this.fullName = fullName;
      this.description = description;
      this.value = value;
    }

    return Variable;

  })();

  Graph = (function() {
    Graph.prototype.canvas = null;

    Graph.prototype.minX = -10;

    Graph.prototype.minY = -10;

    Graph.prototype.maxX = 10;

    Graph.prototype.maxY = 10;

    Graph.prototype.unitsPerTick = 1;

    Graph.prototype.axisColor = "#aaa";

    Graph.prototype.font = "8pt Calibri";

    Graph.prototype.tickSize = 20;

    Graph.prototype.context = null;

    Graph.prototype.rangeX = null;

    Graph.prototype.rangeY = null;

    Graph.prototype.unitX = null;

    Graph.prototype.unitY = null;

    Graph.prototype.centerX = null;

    Graph.prototype.centerY = null;

    Graph.prototype.iteration = null;

    Graph.prototype.scaleX = null;

    Graph.prototype.scaleY = null;

    function Graph() {
      this.canvas = document.getElementById("graph");
      this.context = this.canvas.getContext('2d');
      console.log((window.innerWidth / 12) * 0.85 * 5);
      this.canvas.width = (window.innerWidth / 12) * 0.85 * 5;
      this.canvas.height = this.canvas.width;
      this.rangeX = this.maxX - this.minX;
      this.rangeY = this.maxY - this.minY;
      this.unitX = this.canvas.width / this.rangeX;
      this.unitY = this.canvas.height / this.rangeY;
      this.centerX = Math.round(Math.abs(this.minX / this.rangeX) * this.canvas.width);
      this.centerY = Math.round(Math.abs(this.minY / this.rangeY) * this.canvas.height);
      this.iteration = (this.maxX - this.minX) / 1000;
      this.scaleX = this.canvas.width / this.rangeX;
      this.scaleY = this.canvas.height / this.rangeY;
      this.drawXAxis();
      this.drawYAxis();
    }

    Graph.prototype.drawXAxis = function() {
      var context, unit, xPos, xPosIncrement;
      context = this.context;
      context.save();
      context.beginPath();
      context.moveTo(0, this.centerY);
      context.lineTo(this.canvas.width, this.centerY);
      context.strokeStyle = this.axisColor;
      context.lineWidth = 2;
      context.stroke();
      xPosIncrement = this.unitsPerTick * this.unitX;
      context.font = this.font;
      context.textAlign = 'center';
      context.textBaseline = 'top';
      xPos = this.centerX - xPosIncrement;
      unit = -1 * this.unitsPerTick;
      while (xPos > 0) {
        context.moveTo(xPos, this.centerY - this.tickSize / 2);
        context.lineTo(xPos, this.centerY + this.tickSize / 2);
        context.stroke();
        context.fillText(unit, xPos, this.centerY + this.tickSize / 2 + 3);
        unit -= this.unitsPerTick;
        xPos = Math.round(xPos - xPosIncrement);
      }
      xPos = this.centerX + xPosIncrement;
      unit = this.unitsPerTick;
      while (xPos < this.canvas.width) {
        context.moveTo(xPos, this.centerY - this.tickSize / 2);
        context.lineTo(xPos, this.centerY + this.tickSize / 2);
        context.stroke();
        context.fillText(unit, xPos, this.centerY + this.tickSize / 2 + 3);
        unit += this.unitsPerTick;
        xPos = Math.round(xPos + xPosIncrement);
      }
      return context.restore();
    };

    Graph.prototype.drawYAxis = function() {
      var context, unit, yPos, yPosIncrement;
      context = this.context;
      context.save();
      context.beginPath();
      context.moveTo(this.centerX, 0);
      context.lineTo(this.centerX, this.canvas.height);
      context.strokeStyle = this.axisColor;
      context.lineWidth = 2;
      context.stroke();
      yPosIncrement = this.unitsPerTick * this.unitY;
      context.font = this.font;
      context.textAlign = 'right';
      context.textBaseline = 'middle';
      yPos = this.centerY - yPosIncrement;
      unit = this.unitsPerTick;
      while (yPos > 0) {
        context.moveTo(this.centerX - this.tickSize / 2, yPos);
        context.lineTo(this.centerX + this.tickSize / 2, yPos);
        context.stroke();
        context.fillText(unit, this.centerX - this.tickSize / 2 - 3, yPos);
        unit += this.unitsPerTick;
        yPos = Math.round(yPos - yPosIncrement);
      }
      yPos = this.centerY + yPosIncrement;
      unit = -1 * this.unitsPerTick;
      while (yPos < this.canvas.height) {
        context.moveTo(this.centerX - this.tickSize / 2, yPos);
        context.lineTo(this.centerX + this.tickSize / 2, yPos);
        context.stroke();
        context.fillText(unit, this.centerX - this.tickSize / 2 - 3, yPos);
        unit -= this.unitsPerTick;
        yPos = Math.round(yPos + yPosIncrement);
      }
      return context.restore();
    };

    Graph.prototype.drawVariables = function(x, y) {
      var context;
      context = this.context;
      context.save();
      context.font = "20px Georgia";
      context.fillText(y, this.centerX - 20, 15);
      context.fillText(x, this.canvas.width - 15, this.centerY + 20);
      return context.restore();
    };

    Graph.prototype.resizeCanvas = function() {
      var width;
      width = window.innerWidth;
      if (width > 991) {
        width = (width / 12) * 5;
      }
      this.canvas.width = width * 0.85;
      this.canvas.height = this.canvas.width;
      this.unitX = this.canvas.width / this.rangeX;
      this.unitY = this.canvas.height / this.rangeY;
      this.centerX = Math.round(Math.abs(this.minX / this.rangeX) * this.canvas.width);
      this.centerY = Math.round(Math.abs(this.minY / this.rangeY) * this.canvas.height);
      this.scaleX = this.canvas.width / this.rangeX;
      this.scaleY = this.canvas.height / this.rangeY;
      this.drawXAxis();
      return this.drawYAxis();
    };

    Graph.prototype.drawEquation = function(equation, color, thickness, mode) {
      var context, endAngle, iteration, x, y;
      context = this.context;
      context.save();
      context.save();
      this.transformContext();
      context.beginPath();
      iteration = this.iteration * 10;
      x = this.minX + iteration;
      if (mode === "line") {
        context.moveTo(this.minX, equation(this.minX));
        y = equation(x);
        while (x <= this.maxX && y <= this.maxY) {
          context.lineTo(x, equation(x));
          x += iteration;
          y = equation(x);
        }
        context.restore();
        context.lineJoin = 'round';
        context.lineWidth = thickness;
        context.strokeStyle = color;
        context.stroke();
      }
      if (mode === "dots") {
        endAngle = 2 * Math.PI;
        y = equation(x);
        while (x <= this.maxX && y <= this.maxY) {
          context.arc(x, y, 0.09, 0, endAngle);
          x += iteration;
          y = equation(x);
        }
        context.restore();
        context.fillStyle = color;
        context.fill();
      }
      return context.restore();
    };

    Graph.prototype.transformContext = function() {
      var context;
      context = this.context;
      this.context.translate(this.centerX, this.centerY);
      return context.scale(this.scaleX, -this.scaleY);
    };

    return Graph;

  })();

  window.Archimedes = Archimedes;

  window.Formula = Formula;

}).call(this);
