// Generated by CoffeeScript 1.8.0
(function() {
  var Archimedes, Formula,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Formula = (function() {
    Formula.prototype.divFormula = null;

    Formula.prototype.divFormulaWithNumbers = null;

    Formula.prototype.divPanel = null;

    Formula.prototype.liFormula = null;

    Formula.prototype.srcImage = null;

    function Formula(divPanel, liFormula, srcImage) {
      var text;
      this.srcImage = srcImage;
      this.drop = __bind(this.drop, this);
      this.allowDrop = __bind(this.allowDrop, this);
      this.liFormula = document.getElementById(liFormula);
      console.log("fuera");

      /*
      @ondragstartHandler = => liFormula.addEventListener 'ondragstart' , 
          (e) ->
              console.log "dentro"
              @ondragstartHandler(e)
       */
      this.liFormula.addEventListener('ondragstart', (function(_this) {
        return function(e) {
          console.log("start");
          return _this.drag(e);
        };
      })(this));
      console.log(this.liFormula);
      this.divPanel = document.getElementById(divPanel);
      this.divFormula = document.createElement('div');
      this.divFormula.addEventListener('ondrop', (function(_this) {
        return function(e) {
          console.log("ondrop");
          return _this.drop(e);
        };
      })(this));
      this.divFormula.addEventListener('ondragover', (function(_this) {
        return function(e) {
          console.log("ondrag");
          return _this.allowDrop(e);
        };
      })(this));
      this.divFormula.height = '300 px';
      this.divFormula.width = '300 px';
      text = document.createTextNode("Hello World");
      this.divFormula.appendChild(text);
      this.divFormulaWithNumbers = document.createElement('div');
      this.divPanel.appendChild(this.divFormula);
      this.divPanel.appendChild(this.divFormulaWithNumbers);
    }

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

    Formula.prototype.drag = function(ev) {
      console.log("dada");
      return ev.dataTransfer.setData('text/html', ev.target.id);
    };

    Formula.prototype.drop = function(ev) {
      var img;
      console.log("drop");
      ev.preventDefault();
      img = document.createElement("img");
      img.src = this.srcImage;
      return ev.target.appendChild(img);
    };

    return Formula;

  })();

  Archimedes = (function(_super) {
    __extends(Archimedes, _super);

    Archimedes.prototype.newtowns = null;

    Archimedes.prototype.density = null;

    Archimedes.prototype.volume = null;

    Archimedes.prototype.gravity = null;

    function Archimedes(divPanel, liFormula) {
      Archimedes.__super__.constructor.call(this, divPanel, liFormula, 'images/archimedesFormula.png');
    }

    return Archimedes;

  })(Formula);

  window.Archimedes = Archimedes;

  window.Formula = Formula;

}).call(this);
