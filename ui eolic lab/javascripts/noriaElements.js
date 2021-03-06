// Generated by CoffeeScript 1.8.0
(function() {
  var NoriaElements,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  NoriaElements = (function(_super) {
    __extends(NoriaElements, _super);

    NoriaElements.prototype.noria = null;

    NoriaElements.prototype.NAMEPARENT = "noCommonElements";

    function NoriaElements() {
      this.selectModalText = __bind(this.selectModalText, this);
      NoriaElements.__super__.constructor.apply(this, arguments);
      this.noria = document.createElement("div");
      this.noria.setAttribute("id", "elementsNoria");
      document.getElementById(this.NAMEPARENT).appendChild(this.noria);
      this.turns();
    }

    NoriaElements.prototype.turns = function() {
      var a, bigElementDistance, div, divSlider, smallElementDistance, span, strong, turns;
      smallElementDistance = new Item("img", ["src", "class", "alt"], ["images/noria.jpg", "img-responsive", "crane image"], null, false, null);
      strong = new Item("strong", [], [], "How many turns do you want? ", false, null);
      span = new Item("span", ["class"], ["glyphicon glyphicon-info-sign"], null, false, null);
      a = new Item("a", ['href', 'onclick'], ['#', 'varInit.noria.selectModalText(\'turns\')'], null, true, [span]);
      divSlider = new Item("div", ["id", "class"], ["slider-turns", "slider slider-turns"], null, false, null);
      div = new Item("div", ["class"], ["slidera"], null, true, [divSlider]);
      bigElementDistance = new Item("div", ["class"], ["form-group"], null, true, [strong, a, div]);
      turns = new Element();
      turns.specialElement([smallElementDistance], [bigElementDistance]);
      this.noria.appendChild(turns.div);
      return new Slider('slider-turns', 0, 1, [0], [20], 5, 2, '');
    };

    NoriaElements.prototype.selectModalText = function(type) {
      if (type === 'turns') {
        this.modalText('How many turns do you want?', 'Keep in mind that if you select turns, charge and time, the process will end when the first value is reached.');
      }
      return $(this.INFOMODAL).modal('show');
    };

    NoriaElements.prototype.remove = function() {
      return this.noria.parentNode.removeChild(this.noria);
    };

    NoriaElements.prototype.sendTurns = function() {
      var auxTurns;
      auxTurns = parseInt($(".slider-turns").val());
      if (auxTurns !== 0) {
        return this.wsData.sendActuatorChange('Turns', auxTurns.toString());
      }
    };

    NoriaElements.prototype.disable = function() {
      return $('.slider-turns').attr('disabled', 'disabled');
    };

    NoriaElements.prototype.enable = function() {
      return $('.slider-turns').removeAttr('disabled');
    };

    return NoriaElements;

  })(Part);

  window.NoriaElements = NoriaElements;

}).call(this);
