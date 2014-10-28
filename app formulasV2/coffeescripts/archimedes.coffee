class Formula
    divFormula: null
    divFormulaWithNumbers: null
    divPanel: null
    liFormula: null
    descriptionVariables: null
    textFormula: null
    variables: []
    constantValue: null
    idFormula: "formula_with_numbers"
    equation: null
    valueVariables: {}
    positionValueVariableX: null
    graph: null
    contextCanvasClone: null
    mode: null
    numberInputsFilled: 0
    inputsCorrect: true
    idInputRange: null
    symbols: null
    numberInputsRangeFilled: 0
    inputsRangeCorrect: true
    inputsRangeOrderCorrect: true
    button: null

    constructor: (@divPanel, @liFormula, divFormulaCol, @symbols, @equation, @graph) ->
        #document.body.setAttribute 'onresize', ""
        #use resize, because google chrome have bug with it.
        window.addEventListener "resize", =>
            @graph.resizeCanvas 'blue', 3, @mode

        @variables = []
        @valueVariables = {}
        
        divAllFormulas = document.createElement 'div'
        divAllFormulas.setAttribute 'id', "formula-created"
        
        @divFormula = document.createElement 'div'
        @divFormula.height = '300 px'
        @divFormula.width = '300 px'
       
        @divFormulaWithNumbers = document.createElement 'div'

        
        divAllFormulas.appendChild @divFormula
        divAllFormulas.appendChild @divFormulaWithNumbers
        @divPanel.appendChild divAllFormulas

        divConstant = document.createElement 'div'
        divConstant.setAttribute 'class', "row panel panel-info"
        divConstant.setAttribute 'id', "divConstant"
        divConstantHeading = document.createElement 'div'
        divConstantHeading.setAttribute 'class', "panel-heading"
        panelTitle = document.createElement 'h3'
        panelTitle.setAttribute 'class', "panel-title"
        text = document.createTextNode "Give a numerical value to all except one of the following elements"

        panelTitle.appendChild text
        divConstantHeading.appendChild panelTitle

        @constantValue = document.createElement 'div'
        @constantValue.setAttribute 'class', "panel-body"
        @constantValue.setAttribute 'id', "constant_value"

        divConstant.appendChild divConstantHeading
        divConstant.appendChild @constantValue

        divDescription = document.createElement 'div'
        divDescription.setAttribute 'class', "row panel panel-warning"
        divDescription.setAttribute 'id', "divDescription"
        divDescriptionHeading = document.createElement 'div'
        divDescriptionHeading.setAttribute 'class', "panel-heading"
        panelTitle = document.createElement 'h3'
        panelTitle.setAttribute 'class', "panel-title"
        text = document.createTextNode "Information variables in formula"

        panelTitle.appendChild text
        divDescriptionHeading.appendChild panelTitle

        divDescriptionBody = document.createElement 'div'
        divDescriptionBody.setAttribute 'class', "panel-body"
        @descriptionVariables = document.createElement 'dl'
        @descriptionVariables.setAttribute 'class', "dl-horizontal"
      
        divDescriptionBody.appendChild @descriptionVariables

        divDescription.appendChild divDescriptionHeading
        divDescription.appendChild divDescriptionBody

        divFormulaCold = document.getElementById divFormulaCol
        divFormulaCold.appendChild divConstant
        divFormulaCold.appendChild divDescription

        @divFormulaWithNumbers.appendChild @drawFormula()
        MathJax.Hub.Queue(["Typeset",MathJax.Hub])

    drawFormula: ->
        formula = document.createElement 'p'
        formula.setAttribute 'class', "formula-text"
        formula.setAttribute 'id', @idFormula
        text = "`"
        form = document.createElement 'form'
        form.setAttribute 'id', "form-formula"
        i = 0 
        for id, variable of @symbols
            if variable instanceof Operator
                text = text + variable.operator
            else
                @variables[i] = variable
                
                @descriptionVariables.appendChild @createDt variable.name
                @descriptionVariables.appendChild @createDd variable.description
                if i != 0
                    form.appendChild @createInput i
                text = text + variable.name
                i++

        text = text + "`"
        formula.appendChild document.createTextNode text
        form.appendChild @createRadio("line", true)
        form.appendChild @createRadio("dots", false)
        form.appendChild @createButton()
        @constantValue.appendChild form

        formula

    createInput: (id) ->
        divForm = document.createElement 'div'
        divForm.setAttribute 'class', "form-group"
        divForm.setAttribute 'id', "div-form-" + id

        divInput = document.createElement 'div'
        divInput.setAttribute 'class' , "input-group"

        labelForm = document.createElement 'label'
        labelForm.setAttribute 'class', "control-label sr-only"
        text = document.createTextNode "A number is required"
        labelForm.appendChild text
        divForm.appendChild labelForm

        labelInput = document.createElement 'label'
        labelInput.setAttribute 'class', "control-label sr-only"
        divInput.appendChild labelInput

        spanInput = document.createElement 'span'
        spanInput.setAttribute 'class' , "input-group-addon"
        text = document.createTextNode @variables[id].name
        spanInput.appendChild text
        divInput.appendChild spanInput

        input = document.createElement 'input'
        input.setAttribute 'class' , "form-control"
        input.setAttribute 'type' , "text"
        input.setAttribute 'id', @variables[id].fullName
        input.setAttribute 'placeholder' , @variables[id].fullName

        spanControl = document.createElement 'span'
        spanControl.setAttribute 'id', "span-control-" + id

        input.setAttribute 'oninput', ""
        input.oninput = => @isNumber input, divForm, id, spanControl, labelForm
        divInput.appendChild input
        divInput.appendChild spanControl
        divForm.appendChild divInput

        divForm

    isNumber: (input, divForm, id, spanControl, labelForm) ->
        newNumberInputsFilled = @numberInputsFilled

        if input.value.length > 0

            if isNaN input.value
                @inputError divForm, spanControl, labelForm
                if @variables[id].value isnt null
                    newNumberInputsFilled--
                @variables[id].correct = false
                @variables[id].value = null
                inputsCorrect = false
            else
                @inputSuccess divForm, spanControl, labelForm
                if (@variables[id].value is null and @variables[id].correct) or (@variables[id].value is null and not @variables[id].correct)
                    newNumberInputsFilled++
                @variables[id].correct = true
                @variables[id].value = new Number input.value
                inputsCorrect = true
        else
            if @variables[id].value isnt null 
                newNumberInputsFilled--
            @variables[id].correct = true
            @variables[id].value = null
            inputsCorrect = true
            @inputNothing divForm, spanControl, labelForm
        
        if @inputsCorrect and inputsCorrect
            if newNumberInputsFilled != @numberInputsFilled
                if newNumberInputsFilled == (@variables.length - 2) 
                    @idInputRange = @searchIdInputRange()
                    @remplaceInputs @createInputRange(@idInputRange), @idInputRange
                else
                    if @idInputRange isnt null and @valid()
                        @remplaceInputs @createInput(@idInputRange), @idInputRange
                        @variables[@idInputRange].startRange = null
                        @variables[@idInputRange].endRange = null
                        @idInputRange = null
        else
            if @inputsCorrect and not inputsCorrect
                @disabledInputs id
            if not @inputsCorrect and inputsCorrect
                @eneableInputs id

        @inputsCorrect = inputsCorrect
        @numberInputsFilled = newNumberInputsFilled

    inputError: (divForm, spanControl, labelForm) ->
        divForm.setAttribute 'class', "form-group has-error has-feedback"
        spanControl.setAttribute 'class', "glyphicon glyphicon-remove form-control-feedback"
        labelForm.setAttribute 'class', "control-label"

    inputSuccess: (divForm, spanControl, labelForm) ->
        divForm.setAttribute 'class', "form-group has-success has-feedback"
        spanControl.setAttribute 'class', "glyphicon glyphicon-ok form-control-feedback"
        labelForm.setAttribute 'class', "control-label sr-only"

    inputNothing: (divForm, spanControl, labelForm) ->
        divForm.setAttribute 'class', "form-group"
        spanControl.setAttribute 'class', ""
        labelForm.setAttribute 'class', "control-label sr-only"

    valid: ->
        idInputRange = 1
        valid = true
        while @variables.length > idInputRange
            if (not @variables[idInputRange].correct and @variables[idInputRange].value is null)
                valid = false
                break
            idInputRange++

        valid

    remplaceInputs: (newChild, id) ->
        oldChild = document.getElementById 'div-form-' + id
        parent = document.getElementById 'form-formula'
        parent.replaceChild newChild, oldChild

    searchIdInputRange: ->
        idInputRange = 1
        while idInputRange < @variables.length and  not(@variables[idInputRange].value is null and @variables[idInputRange].correct)
            idInputRange++

        idInputRange

    disabledInputs: (id) ->
        i = 1
        while i < @variables.length
            if i != Number(id) and i != @idInputRange
                input = document.getElementById @variables[i].fullName
                input.setAttribute 'disabled', ""
            if i == @idInputRange
                inputStart = document.getElementById 'input-range-0'
                inputStart.setAttribute 'disabled', ""
                inputEnd = document.getElementById 'input-range-1'
                inputEnd.setAttribute 'disabled', ""
            i++
        @button.setAttribute 'disabled', ""

    eneableInputs: (id) ->
        i = 1
        while i < @variables.length
            if i != Number(id) and i != @idInputRange
                input = document.getElementById @variables[i].fullName
                input.removeAttribute 'disabled'
            if i == @idInputRange
                inputStart = document.getElementById 'input-range-0'
                inputStart.removeAttribute 'disabled'
                inputEnd = document.getElementById 'input-range-1'
                inputEnd.removeAttribute 'disabled'
            i++
        @button.removeAttribute 'disabled'

    createInputRange:  (id)->
        @numberInputsRangeFilled = 0
        @inputsRangeCorrect = true
        @inputsRangeOrderCorrect = true
        divForm = document.createElement 'div'
        divForm.setAttribute 'class', "form-group"
        divForm.setAttribute 'id', "div-form-" + id

        labelErrorOrdRange = document.createElement 'label'
        labelErrorOrdRange.setAttribute 'class', "control-label sr-only"
        text = document.createTextNode "Range must go in order from lowest to highest"
        labelErrorOrdRange.appendChild text
        divForm.appendChild labelErrorOrdRange

        divLabel = document.createElement 'div'
        divLabel.setAttribute 'class', "form-group"

        labelText = document.createElement 'label'
        text = document.createTextNode "Range of " + @variables[id].name + " (optional):"
        labelText.appendChild text

        divLabel.appendChild labelText
        divForm.appendChild divLabel

        divInputStart = document.createElement 'div'
        divInputStart.setAttribute 'class' , "form-group"

        labelInputStar = document.createElement 'label'
        labelInputStar.setAttribute 'class', "control-label sr-only"
        text = document.createTextNode "A number is required"
        labelInputStar.appendChild text
        divInputStart.appendChild labelInputStar

        inputStart = document.createElement 'input'
        #i put this id, because it's more easy to get it, when eneable or disable
        inputStart.setAttribute 'id', "input-range-0"
        inputStart.setAttribute 'type', "text"
        inputStart.setAttribute 'class', "form-control"

        spanControlStart = document.createElement 'span'
        spanControlStart.setAttribute 'id', "span-control-start"

        inputStart.setAttribute 'oninput', ""
        
        divInputStart.appendChild inputStart
        divInputStart.appendChild spanControlStart
        divForm.appendChild divInputStart

        divLabel = document.createElement 'div'
        divLabel.setAttribute 'class', "form-group"

        labelText = document.createElement 'label'
        text = document.createTextNode " to "
        labelText.appendChild text

        divLabel.appendChild labelText
        divForm.appendChild divLabel

        divInputEnd = document.createElement 'div'
        divInputEnd.setAttribute 'class' , "form-group"

        labelInputEnd = document.createElement 'label'
        labelInputEnd.setAttribute 'class', "control-label sr-only"
        text = document.createTextNode "A number is required"
        labelInputEnd.appendChild text
        divInputEnd.appendChild labelInputEnd

        inputEnd = document.createElement 'input'
        #i put this id, because it's more easy to get it, when eneable or disabled
        inputEnd.setAttribute 'id', "input-range-1"
        inputEnd.setAttribute 'type', "text"
        inputEnd.setAttribute 'class', "form-control"
        
        spanControlEnd = document.createElement 'span'
        spanControlEnd.setAttribute 'id', "span-control-end"

        inputEnd.setAttribute 'oninput', ""

        inputEnd.oninput = => 
            @variables[id].endRange = @isNumberInRange inputEnd, divInputEnd, spanControlEnd, labelInputEnd, @variables[id].endRange, 1, id
            @inputsRangeOrder id, divForm, spanControlStart, spanControlEnd, labelErrorOrdRange
            @disabledEneabledButtonInRange()

        inputStart.oninput = => 
            @variables[id].startRange = @isNumberInRange inputStart, divInputStart, spanControlStart, labelInputStar, @variables[id].startRange, 0, id
            @inputsRangeOrder id, divForm, spanControlStart, spanControlEnd, labelErrorOrdRange
            @disabledEneabledButtonInRange()

        divInputEnd.appendChild inputEnd
        divInputEnd.appendChild spanControlEnd
        divForm.appendChild divInputEnd

        divForm

    inputsRangeOrder: (id, divForm, spanControlStart, spanControlEnd, labelErrorOrdRange) ->
        if @numberInputsRangeFilled == 2  and @inputsRangeCorrect
            if @variables[id].startRange > @variables[id].endRange
                @inputsRangeOrderCorrect = false
                divForm.setAttribute 'class', "form-group has-error has-feedback"
                spanControlStart.setAttribute 'class', "glyphicon glyphicon-remove form-control-feedback"
                spanControlEnd.setAttribute 'class', "glyphicon glyphicon-remove form-control-feedback"
                labelErrorOrdRange.setAttribute 'class', "control-label"
            else
                @inputsRangeOrderCorrect = true
                divForm.setAttribute 'class', "form-group"
                spanControlStart.setAttribute 'class', "glyphicon glyphicon-ok form-control-feedback"
                spanControlEnd.setAttribute 'class', "glyphicon glyphicon-ok form-control-feedback"
                labelErrorOrdRange.setAttribute 'class', "control-label sr-only"
        if @numberInputsRangeFilled == 1
            divForm.setAttribute 'class', "form-group"
            labelErrorOrdRange.setAttribute 'class', "control-label sr-only"
        if @numberInputsRangeFilled == 0
            @inputsRangeOrderCorrect = true

    isNumberInRange: (input, divForm, spanControl, labelForm, value, idInput, id) ->
        inputsRangeCorrect = @inputsRangeCorrect
        if input.value.length > 0

            if isNaN input.value
                @inputError divForm, spanControl, labelForm
                if value isnt null
                    value = null
                    @numberInputsRangeFilled--
                inputsRangeCorrect = false
            else
                @inputSuccess divForm, spanControl, labelForm
                if value is null
                    @numberInputsRangeFilled++
                    inputsRangeCorrect = true
                value = new Number input.value
        else
            if value isnt null
                value = null
                @numberInputsRangeFilled--
            inputsRangeCorrect = true
            @inputNothing divForm, spanControl, labelForm

        if inputsRangeCorrect != @inputsRangeCorrect
            inputAux = document.getElementById 'input-range-'+ ((idInput + 1) % 2)
            if inputsRangeCorrect
                inputAux.removeAttribute 'disabled'
            else
                inputAux.setAttribute 'disabled', ""
            @inputsRangeCorrect = inputsRangeCorrect
            
        value

    disabledEneabledButtonInRange: ()->
        if 0 < @numberInputsRangeFilled < 2 or not @inputsRangeCorrect or not @inputsRangeOrderCorrect
            @button.setAttribute 'disabled', ""
        else
            @button.removeAttribute 'disabled'

    createRadio: (name, checked) ->
        divRadio = document.createElement 'div'
        divRadio.setAttribute 'class', "radio"
        label = document.createElement 'label'
        input = document.createElement 'input'
        input.setAttribute 'type', "radio"
        input.setAttribute 'name', "modeLine"
        input.setAttribute 'value', name
        if checked
            input.setAttribute 'checked', true
        text = document.createTextNode "Graph with form: " + name
        label.appendChild input
        label.appendChild text
        divRadio.appendChild label
        divRadio

    createButton:  ->
        divButton = document.createElement 'div'
        divButton.setAttribute 'class', "btn-group"
        @button = document.createElement 'button'
        @button.setAttribute 'type', "button"
        @button.setAttribute 'class', "btn btn-primary"
        @button.setAttribute 'button.setAttribute', ""
        @button.addEventListener 'click', => @clickButton()
        text = document.createTextNode "update values"
        @button.appendChild text
        divButton.appendChild @button
        divButton

    createDt: (name) ->
        dt = document.createElement 'dt'
        text = document.createTextNode name
        dt.appendChild text
        dt

    createDd: (description) ->
        dd = document.createElement 'dd'
        text = document.createTextNode description
        dd.appendChild text
        dd

    clickButton: ->
        if @numberInputsFilled == @variables.length-2
            
            rads = document.getElementsByName 'modeLine'

            i = 0
            while i < rads.length
                if rads[i].checked
                    @mode = rads[i].value
                    break
                i++

            @drawNumbersFormula()
            @getVariableValues()
            @graph.y = @variables[0].name
            @graph.drawEquation @equation, @valueVariables, @positionValueVariableX, 'blue', 3, @mode
        else
            alert "Fill in all values"

    drawNumbersFormula: () ->
        formula = document.getElementById @idFormula
        text = "`"
        i = 0
        for id, variable of @symbols
            if variable instanceof Operator
                text = text + variable.operator
            else
                if variable.value isnt  null
                    text = text + @variables[i].value
                else
                    text = text + @variables[i].name
                i++
        text = text + "`"

        formula.innerHTML = text
        MathJax.Hub.Queue(["Typeset",MathJax.Hub])
        
    #Can optimize this function with refactor searchInputRange
    getVariableValues: ->
        for id, variable of @variables[1..]
            if variable.value is null
                @valueVariables[variable.id] = null
                @positionValueVariableX = variable.id
                @graph.x = variable.name
                if variable.startRange isnt null and variable.endRange isnt null
                    @graph.minX = @graph.xStart = variable.startRange
                    @graph.maxX = @graph.xEnd = variable.endRange
                else
                    @graph.minX = @graph.xStart = -10
                    @graph.maxX = @graph.xEnd = 10
            else
                @valueVariables[variable.id] = variable.value
   
class Archimedes extends Formula

    constructor: (divPanel, liFormula, divFormulaCol, graph) ->
        newtowns = new Variable("e", "E" , "Newtowns" , "Buoyant force of a given body." , null)
        equals = new Operator "="
        density = new Variable("ro", "\u03C1" , "Density" , "Density of the fluid." , null)
        mult = new Operator "*"
        gravity = new Variable("g", "g" , "Gravity" , "Acceleration due to gravity." , null)
        volume = new Variable("v", "V" , "Volume" , "Volume of the displaced fluid." , null)
        variables = [newtowns, equals, density, mult, gravity, mult, volume]
        equation = 'e=ro*g*v'
        super(divPanel, liFormula, divFormulaCol, variables, math.parse(equation).compile(math), graph)

class Newton1 extends Formula

    constructor: (divPanel, liFormula, divFormulaCol, graph) ->
        force = new Variable "f", "F" , "Force" , "Weight expressed in Newtons." , null
        equals = new Operator "="
        mass = new Variable "m", "m" , "Mass" , "Mass of the object." , null
        mult = new Operator "*"
        aceleration = new Variable "a", "a" , "Acceleration" , "Acceleration of the object." , null
        simbols = [force, equals, mass, mult, aceleration]
        equation = 'f=m*a'
        super(divPanel, liFormula, divFormulaCol, simbols, math.parse(equation).compile(math), graph)

class FrictionForce extends Formula

    constructor: (divPanel, liFormula, divFormulaCol, graph) ->
        force = new Variable("f", "F", "Friction force", "Magnitude of friction.", null)
        equals = new Operator("=")
        coefficientFriction = new Variable("mic", "\u00B5", "Coefficient of friction", "Friction coefficient.", null)
        mult = new Operator "*"
        normalForce = new Variable("n", "N", "Normal force", "Weight of a given body.", null)
        variables = [force, equals, coefficientFriction, mult, normalForce]
        equation = 'f=mic * n'
        super(divPanel, liFormula, divFormulaCol, variables, math.parse(equation).compile(math), graph)

class Impulse extends Formula

    constructor: (divPanel, liFormula, divFormulaCol, graph) ->
        improve = new Variable("i", "i", "Impulse", "Description", null)
        equals = new Operator("=")
        force = new Variable("f", "F", "Force", "Description", null)
        mult = new Operator "*"
        time = new Variable("t", "T", "Time", "Description", null)
        variables = [force, equals, force, mult, time]
        equation = 'i=f * t'
        super(divPanel, liFormula, divFormulaCol, variables, math.parse(equation).compile(math), graph)

class Momentum extends Formula

    constructor: (divPanel, liFormula, divFormulaCol, graph) ->
        momentum = new Variable("p", "\u03C1", "Momentum", "Description", null)
        equals = new Operator("=")
        mass = new Variable("m", "m", "Mass", "Description", null)
        mult = new Operator "*"
        velocity = new Variable("v", "V", "Velocity of the body", "Description", null)
        variables = [momentum, equals, mass, mult,velocity]
        equation = 'p=m * v'
        super(divPanel, liFormula, divFormulaCol, variables, math.parse(equation).compile(math), graph)

class PotentialEnergy extends Formula

    constructor: (divPanel, liFormula, divFormulaCol, graph) ->
        potentialEnergy = new Variable("u", "U", "Potential Energy", "Potential Energy.", null)
        equals = new Operator("=")
        mass = new Variable("m", "m", "Mass", "Mass of the body.", null)
        mult = new Operator "*"
        gravity = new Variable("g", "g" , "Gravity", "Acceleration due to gravity." , null)
        height = new Variable("h", "h", "Height", "Height at which the body is.", null)
        variables = [potentialEnergy, equals, mass, mult, gravity, mult, height]
        equation = 'u=m * g * h'
        super(divPanel, liFormula, divFormulaCol, variables, math.parse(equation).compile(math), graph)

class OhmLaw extends Formula

    constructor: (divPanel, liFormula, divFormulaCol, graph) ->
        current = new Variable("i", "I", "Electric current", "Current flowing through the conductor, in Amperes.", null)
        equals = new Operator("=")
        potential = new Variable("v", "V", "potential difference", "Voltage measured, in Volts.", null)
        division = new Operator "/"
        resistance = new Variable("r", "R" , "Resistance", "Resistance, measured in Ohms" , null)
        variables = [current, equals, potential, division, resistance]
        equation = 'i=v / r'
        super(divPanel, liFormula, divFormulaCol, variables, math.parse(equation).compile(math), graph)

class ResistivityConductivity extends Formula

    constructor: (divPanel, liFormula, divFormulaCol, graph) ->
        resistance = new Variable("r", "R", "Resistance", "Description", null)
        equals = new Operator("=")
        electricalResistivity = new Variable("p", "\u03C1", "Electrical resistivity", "Description", null)
        mult = new Operator "*"
        length = new Variable("l", "l", "length", "Description", null)
        division = new Operator "/"
        section = new Variable("a", "A" , "Cross-sectional area", "Description" , null)
        variables = [resistance, equals, electricalResistivity, mult, length, division, section]
        equation = 'r=p * l / a'
        super(divPanel, liFormula, divFormulaCol, variables, math.parse(equation).compile(math), graph)


class Variable 
    id: null #string with id to library mathjs, it can't use special chars example ñ,ç...
    name: null #string but pass in htlm , if it need for example sub tag
    fullName: null #string to put in constant value
    description: null # small description of variable
    value: null #float
    correct: true #value is float or it is null
    startRange: null #float star range
    endRange: null #float end range

    constructor: (@id, @name, @fullName, @description, @value) ->


class Operator
    operator: null

    constructor: (@operator) ->


class Graph
    margin : top: 20, right: 20, bottom: 20, left: 20
    padding: top: 30, right: 30, bottom: 30, left: 30
    width: null
    height: null
    xScale: null
    yScale: null
    xAxisFunction: null
    yAxisFunction: null
    svg: null
    panelGraph: null
    widthPanel: null
    heightPanel: null
    minX: -10
    minY: -10
    maxX: 10
    maxY: 10
    lineFunction: null
    plotdata: []
    oldMode: null
    xAxis: null
    yAxis: null
    xStart: -10
    xEnd: 10
    numberVerticalAsymptote: 0
    x: null
    y: null
    textX: null
    textY: null

    constructor: ->
        @plotdata = [[]]
        @panelGraph = document.getElementById "panelGraph"
        width = window.innerWidth
        if width > 991
            width = ((width/12) * 5)

        width = width *0.90
        @widthPanel = width
        @heightPanel = width

        @width = width - @padding.left - @padding.right - @margin.left - @margin.right
        @height = width - @padding.top - @padding.bottom - @margin.top - @margin.bottom
        
        @xScale = d3.scale.linear()
            .domain [@minX,@maxX]
            .range [0,@width]

        @yScale = d3.scale.linear()
            .domain [@minY,@maxY]
            .range [@height,0]

        @xAxisFunction = d3.svg.axis()
            .scale @xScale 
            .orient "bottom"

        @yAxisFunction = d3.svg.axis()
            .scale @yScale
            .orient "left"

        @svg = d3.select(@panelGraph).append "svg"
            .attr "width", @widthPanel 
            .attr "height", @heightPanel
        
        aux = @svg.append "g"
            .attr "transform", "translate(" + @margin.left + "," + @margin.top + ")"

        @xAxisFunction.tickValues(@xScale.ticks(@xAxisFunction.ticks()).filter((x) -> x != 0))
        @yAxisFunction.tickValues(@yScale.ticks(@yAxisFunction.ticks()).filter((x) -> x != 0))

        g = aux.append "g"
            .attr "transform", "translate(" + @padding.left + "," + @padding.top + ")"

        @xAxis= g.append("g")
            .attr("id", "xAxis")
            .attr("class", "x axis")
            .attr("transform", "translate(0," + @yScale(0)+ ")")
            .call @xAxisFunction

        @yAxis = g.append("g")
            .attr("id", "yAxis")
            .attr "class", "y axis"
            .attr "transform", "translate(" + @xScale(0) + ",0)"
            .call @yAxisFunction

        @textX = @xAxis.append("text")
            .attr("class", "textX")

        @textY = @yAxis.append("text")
            .attr("class", "textY")

    remove: ->

        @svg.remove()

    drawVariables: ->
        switch
            when @minY is 0 and @minX is 0 
                @writeVar(@textY, @y, 6, 15)
                @writeVar(@textX, @x, 26, @width)
            when @minY is 0 and @maxX is 0 
                @writeVar(@textY, @y, 6, 15)
                @writeVar(@textX, @x, 26, 6)
            when @maxY is 0 and @maxX is 0 
                @writeVar(@textY, @y, @height, 15)
                @writeVar(@textX, @x, 26, 6)
            when @maxY is 0 and @minX is 0 
                @writeVar(@textY, @y, @height, 15)
                @writeVar(@textX, @x, 26, @width)
            else
                @writeVar(@textY, @y, 6, 15)
                @writeVar(@textX, @x, 26, @width)

    writeVar: (place, text, cordY, cordX) ->

        place
            .attr("transform", "rotate(0)")
            .attr("y", cordY)
            .attr("x", cordX)
            .attr("dy", ".71em")
            .style("text-anchor", "end")
            .text(text)
        
    resizeCanvas:  (color, thickness, mode)->
        width = window.innerWidth
        if width > 991
            width = ((width/12) * 5)

        width = width *0.90

        @widthPanel = width
        @heightPanel = width

        @width = width - @padding.left - @padding.right - @margin.left - @margin.right
        @height = width - @padding.top - @padding.bottom - @margin.top - @margin.bottom

        @xScale.range [0,@width]

        @yScale.range [@height,0]

        @svg.attr "width", @widthPanel 
            .attr "height", @heightPanel

        t0 = @svg.transition().duration(750)

        t0.selectAll(".x.axis").attr("transform", "translate(0," + @yScale(0)+ ")")
            .call @xAxisFunction
        
        t1 =t0
        t1.selectAll(".y.axis").attr("transform", "translate(" + @xScale(0) + ",0)")
            .call @yAxisFunction
        
        if (@x and @y)
            t2=t0
            if mode is "line"
                t2.selectAll(".line")
                .attr("d", @lineFunction)
            else
                t2.selectAll(".line")
                .attr("transform", (d) =>
                    x = @xScale(d.x) + @padding.left + @margin.left
                    y = @yScale(d.y) + @padding.top + @margin.top
                    "translate(" + x + "," + y + ")")
                .attr("d", @lineFunction)

    drawEquation: (equation, valueVariables, positionValueVariableX, color, thickness, mode) ->
        iteration = Math.abs (@xEnd - @xStart) / 50
        error = false
        x = @xStart
        @plotdata = [[]]
        numberVerticalAsymptote = 0
        verticalAsymptote = false
        valueVariables[positionValueVariableX] = x
        #coffeScript can't traslate correcly with function eval
        y =  `equation.eval(valueVariables)`
        lastY = y

        if lastY is Number.POSITIVE_INFINITY or lastY is Number.NEGATIVE_INFINITY
            if iteration isnt 0
                x += iteration
                valueVariables[positionValueVariableX] = x
                y =  `equation.eval(valueVariables)`
                if y is Number.POSITIVE_INFINITY or y is Number.NEGATIVE_INFINITY
                    error = true
            else 
                error = true

        if not error
            maxY = 0
            minY = 0
            @minY = minY = Math.min minY, y
            @maxY = maxY = Math.max maxY, y

            aux = 
                "x": x
                "y": y
            @plotdata[numberVerticalAsymptote].push aux
            x += iteration

            #TODO problems with precision error. 
            while x < (@xEnd+iteration)
                #think from this scale of asyntotes. NEED IMPROVE
                if verticalAsymptote
                    numberVerticalAsymptote++
                    @plotdata[numberVerticalAsymptote] = new Array()
                    verticalAsymptote = false
                #coffeScript can't traslate correcly with function eval
                valueVariables[positionValueVariableX] = x
                y =  `equation.eval(valueVariables)`

                if y is Number.POSITIVE_INFINITY or y is Number.NEGATIVE_INFINITY
                    x += iteration
                    verticalAsymptote = true
                else
                    if (lastY < 0 and y > 0 ) or (lastY > 0 and y < 0)
                        auxY = y
                        lastAuxY= lastY
                        smallX = x - iteration
                        bigX = x
                        smallIteration = Math.abs(bigX - smallX) / 2
                        while true

                            if smallIteration is Number.MIN_VALUE
                                break

                            valueVariables[positionValueVariableX] = smallX + smallIteration
                            
                            tmpY = `equation.eval(valueVariables)`

                            if tmpY is Number.POSITIVE_INFINITY or tmpY is Number.NEGATIVE_INFINITY
                                verticalAsymptote = true
                                break

                            if (lastAuxY < 0 and tmpY > 0 ) or (lastAuxY > 0 and tmpY < 0)
                                auxY = tmpY
                                bigX = smallX + smallIteration

                            else
                                if (auxY < 0 and tmpY > 0 ) or (auxY > 0 and tmpY < 0)

                                    lastAuxY = tmpY
                                    smallX = smallX + smallIteration
                                else
                                    break

                            smallIteration = Math.abs(bigX - smallX) / 2

                #think from this scale of asyntotes. NEED IMPROVE
                if verticalAsymptote

                    if ((minY/1000) < @minY && (minY/1000)< @minX) or ((maxY/1000) > @maxY && (maxY/1000) > @maxX)
                            @plotdata[numberVerticalAsymptote].pop()
                    else
                            @minY = minY
                            @maxY = maxY
                else
                    #if x <= @xEnd
                    #console.log x
                    @minY = minY
                    @maxY = maxY

                    minY = Math.min minY, y
                    maxY = Math.max maxY, y

                    aux = 
                        "x": x
                        "y": y
                    @plotdata[numberVerticalAsymptote].push aux

                lastY = y
                x += iteration

            ###
            i = 0
            while i< @plotdata.length
                console.log  @plotdata[i]
                i++
            ###
            ### todo this don't work correctly. I think put with a percent formula
            if Math.abs(minY) >  5
                @minY = Math.round minY
            else
                @minY = minY

            if Math.abs(maxY) > 5
                @maxY = Math.round maxY
            else
                @maxY = maxY
            
            if Math.abs(@maxY) isnt Math.abs(@minY)
                if Math.min(Math.abs(@maxY),Math.abs(@minY)) * 1.1 >= Math.max(Math.abs(@maxY),Math.abs(@minY))
                    if  
            ###
            if not (@minX < 0 < @maxX)
                if @maxX > 0
                    @minX = 0
                else
                    @maxX = 0

            #console.log "miny "+ Math.round @minY
            #console.log "maxy "+ Math.round @maxY

            @xScale.domain [@minX,@maxX]
            @yScale.domain [@minY,@maxY]

            @xAxisFunction.tickValues(@xScale.ticks(@xAxisFunction.ticks()).filter((x) -> x != 0))
            @yAxisFunction.tickValues(@yScale.ticks(@yAxisFunction.ticks()).filter((x) -> x != 0))

            t0 = @svg.transition().duration(750)

            t0.selectAll(".x.axis").attr("transform", "translate(0," + @yScale(0)+ ")")
                .call @xAxisFunction
            
            t1 =t0
            t1.selectAll(".y.axis").attr("transform", "translate(" + @xScale(0) + ",0)")
                .call @yAxisFunction
           
            ###
            i = -2
            @plotdata = []
            while i<10
                a =(Math.random() *10)
                aux = 
                    "x": i
                    "y": a
                @plotdata.push aux
                i++
            ###
            if mode == "line" and iteration isnt 0
               
                if @oldMode is "line"

                    if @numberVerticalAsymptote > numberVerticalAsymptote
                        i = numberVerticalAsymptote + 1
                        while i <= @numberVerticalAsymptote
                            d3.selectAll(".line"+i)
                            .remove()
                            i++
                    i = 0
                    while i <= numberVerticalAsymptote
                        d3.selectAll(".line"+i )
                            .datum(@plotdata[i])
                            .transition()
                            .duration(750)
                            .attr('d', @lineFunction)
                        i++
        
                    
                else
                    if @oldMode isnt null
                        d3.selectAll(".dot")
                        .remove()

                    @lineFunction = d3.svg.line()
                    .interpolate('basis')
                    .x((d) =>
                        #console.log "x: " + d.x
                        #if d.x <= @xEnd and (@minY<=d.y<=@maxY)
                            @xScale(d.x)+@padding.left+@margin.left )

                    .y((d) => 
                        #console.log "y: " + d.y
                        #if d.x <= @xEnd and (@minY<=d.y<=@maxY)
                            @yScale(d.y)+@padding.top+@margin.top ) 

                    i = 0
                    while i <= numberVerticalAsymptote 
                        @svg.append("path")
                        .datum(@plotdata[i])
                        .attr('class', "line line"+i )
                        .style('stroke', "rgb(6, 120, 155)")
                        .style('stroke-width', "2")
                        .style('fill', "none")
                        .attr('d', @lineFunction)
                        i++
                    @oldMode = "line"
                @numberVerticalAsymptote = numberVerticalAsymptote

            if mode == "dots" or iteration is 0

                i = 0
                allData = []
                while i<= numberVerticalAsymptote
                    allData = allData.concat @plotdata[i]
                    i++
                
                if @oldMode is "dots"
                   
                    @lineFunction = d3.svg.symbol()

                    #@lineFunction.type("circle")
                    d3.selectAll(".dot")
                        .data(allData)
                        .transition()
                        .duration(750)
                        .attr("transform", (d) =>
                            x = @xScale(d.x) + @padding.left + @margin.left
                            y = @yScale(d.y) + @padding.top + @margin.top
                            "translate(" + x + "," + y + ")")
                        .attr("d", @lineFunction)
                else
                    # I don't know, but i need put 2 elements of trash because it remove automatically 2 first elements
                    allData.unshift null
                    allData.unshift null

                    if @oldMode isnt null
                        d3.selectAll(".line")
                        .remove()
                    
                    @lineFunction = d3.svg.symbol()

                    @svg.selectAll("path")
                        .data(allData)
                        .enter().append("path")
                        .attr('class', "dot" )
                        .style('stroke', "rgb(6, 120, 155)")
                        .style('stroke-width', "1")
                        .style('fill', "none")
                        .attr("transform", (d) =>
                            x = @xScale(d.x) + @padding.left + @margin.left
                            y = @yScale(d.y) + @padding.top + @margin.top
                            "translate(" + x + "," + y + ")")
                        .attr("d", @lineFunction)
                        
                    @oldMode = "dots"
             
            @drawVariables()
        else
            alert "Impossible calculate the fuction with this numbers"

class Init
    divPanel: null
    archimedes: null
    newton1: null
    pendulumOscilation: null
    frictionForce: null
    impulse: null
    momentum: null
    potentialEnergy: null
    ohmLaw: null
    resistivityConductivity: null
    divFormulaCol: null
    graph: null
    paragraph: null
    formula: null

    constructor: (divPanel, liArchimedes, liNewton1, liFrictionForce, liImpulse, liMomentum, liPotentialEnergy, liOhmLaw, liResistivityConductivity, @divFormulaCol) ->
        @graph = new Graph()
        @archimedes = document.getElementById liArchimedes
        $(@archimedes).draggable(helper: "clone")
        
        ###deprecated
        @archimedes.setAttribute 'ondragstart' , ""
        @archimedes.ondragstart = (e) => @drag(e)
        @addListenerToFormula @archimedes, @imgArchimedes
        ###
        @newton1 = document.getElementById liNewton1
        $(@newton1).draggable(helper: "clone")
        ###deprecated
        @newton1.setAttribute 'ondragstart' , ""
        @newton1.ondragstart = (e) => @drag(e)
        @addListenerToFormula @newton1, @imgNewton1
        ###
        ###deprecated
        @pendulum.setAttribute 'ondragstart' , ""
        @pendulum.ondragstart = (e) => @drag(e)
        @addListenerToFormula @pendulum, @imgPendulum
        ###
       
        @frictionForce = document.getElementById liFrictionForce
        $(@frictionForce).draggable(helper: "clone")

        @impulse = document.getElementById liImpulse
        $(@impulse).draggable(helper: "clone")

        @momentum = document.getElementById liMomentum
        $(@momentum).draggable(helper: "clone")

        @potentialEnergy = document.getElementById liPotentialEnergy
        $(@potentialEnergy).draggable(helper: "clone")

        @ohmLaw = document.getElementById liOhmLaw
        $(@ohmLaw).draggable(helper: "clone")

        @resistivityConductivity = document.getElementById liResistivityConductivity
        $(@resistivityConductivity).draggable(helper: "clone")

        #document.body.setAttribute 'onresize', ""
        #use resize, because google chrome have bug with it.
        window.addEventListener "resize", =>
            @graph.resizeCanvas 'blue', 3, @mode
            
        @divPanel = document.getElementById divPanel

        ###deprecated
        @divPanel.setAttribute 'ondrop', ""
        @divPanel.ondrop = (e) => @drop(e)
        @divPanel.setAttribute 'ondragover', ""
        @divPanel.ondragover = (e) => @allowDrop(e)
        #Need put ondragenter a false for internet explorer and div, you can see documentation Microsoft for more information
        @divPanel.setAttribute 'ondragenter', "return false"
        ###

        $(@divPanel).droppable(drop: (event, ui) => @drop(event, ui))
        @paragraph = document.createElement 'p'
        text = document.createTextNode "Drag and drop any formula here"
        @paragraph.appendChild text
        @divPanel.appendChild @paragraph

    ###deprecated
    allowDrop: (ev) => 
        ev.preventDefault()
    
    drag: (ev) ->
        ev.dataTransfer.setData('text', ev.target.id)      
    ###

    drop: (event, ui) =>
        #event.preventDefault()
        data = ui.draggable.attr('id')
        #data = ev.dataTransfer.getData("text")
        switch
            when data is @archimedes.id
                @disabledDrop()
                formula = new Archimedes @divPanel, @archimedes, @divFormulaCol, @graph
                @divPanel.appendChild @createButton()
            when data is @newton1.id
                @disabledDrop()
                @formula = new Newton1 @divPanel, @newton1, @divFormulaCol, @graph
                @divPanel.appendChild @createButton()
            when data is @frictionForce.id
                @disabledDrop()
                @formula = new FrictionForce @divPanel, @pendulum, @divFormulaCol, @graph
                @divPanel.appendChild @createButton()
            when data is @impulse.id
                @disabledDrop()
                @formula = new Impulse @divPanel, @pendulum, @divFormulaCol, @graph
                @divPanel.appendChild @createButton()
            when data is @momentum.id
                @disabledDrop()
                @formula = new Momentum @divPanel, @pendulum, @divFormulaCol, @graph
                @divPanel.appendChild @createButton()
            when data is @potentialEnergy.id
                @disabledDrop()
                @formula = new PotentialEnergy @divPanel, @pendulum, @divFormulaCol, @graph
                @divPanel.appendChild @createButton()
            when data is @ohmLaw.id
                @disabledDrop()
                @formula = new OhmLaw @divPanel, @pendulum, @divFormulaCol, @graph
                @divPanel.appendChild @createButton()
            when data is @resistivityConductivity.id
                @disabledDrop()
                @formula = new ResistivityConductivity @divPanel, @pendulum, @divFormulaCol, @graph
                @divPanel.appendChild @createButton()

    disabledDrop: ->
        $(@divPanel).droppable( "option", "disabled", true)
        @divPanel.removeChild @paragraph

    addListenerToFormula: (formula, srcImage) ->
        formula.addEventListener( 'dragstart' , 
            (e) =>
                img = document.createElement("img")
                img.src = srcImage
                e.dataTransfer.setDragImage(img , 0 , 0)
        ,false)

    #improve this
    createButton:  ->
        divButton = document.createElement 'div'
        divButton.setAttribute 'class', "btn-group"
        divButton.setAttribute 'id', "button-remove"
        button = document.createElement 'button'
        button.setAttribute 'type', "button"
        button.setAttribute 'class', "btn btn-danger"
        button.setAttribute 'button.setAttribute', ""
        button.addEventListener 'click', => @clickButton()
        text = document.createTextNode "Remove Formula"
        button.appendChild text
        divButton.appendChild button
        divButton

    clickButton: ()->
        @formula = null
        @graph.remove()
        @graph = new Graph()
        @divPanel.removeChild document.getElementById 'formula-created' 
        @divPanel.removeChild document.getElementById 'button-remove'
        (document.getElementById @divFormulaCol).removeChild document.getElementById 'divConstant'
        (document.getElementById @divFormulaCol).removeChild document.getElementById 'divDescription'
        
        ###deprecated
        @divPanel.setAttribute 'ondrop', ""
        @divPanel.ondrop = (e) => @drop(e)
        @divPanel.setAttribute 'ondragover', ""
        @divPanel.ondragover = (e) => @allowDrop(e)
        #Need put ondragenter a false for internet explorer and div, you can see documentation Microsoft for more information
        @divPanel.setAttribute 'ondragenter', "return false"
        ###
        $(@divPanel).droppable( "option", "disabled", false)
        @paragraph = document.createElement 'p'
        text = document.createTextNode "Please drop your formula here"
        @paragraph.appendChild text
        @divPanel.appendChild @paragraph
        
        window.addEventListener "resize", =>
            @graph.resizeCanvas 'blue', 3, @mode
       
window.Init = Init
