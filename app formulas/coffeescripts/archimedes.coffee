class Formula
    divFormula: null
    divFormulaWithNumbers: null
    divPanel: null
    liFormula: null
    descriptionVariables: null
    srcImage: null
    textFormula: null
    variables: []
    constantValue: null
    idFormula: "formula_with_numbers"
    equation: null
    valueVariables: []
    positionValueVariableX: null
    graph: null
    graphCloneCanvas: null
    contextCanvasClone: null
    mode: null
    numberInputsFilled: 0
    inputsCorrect: true
    idInputRange: null
    symbols: null
    numberInputsRangeFilled: 0
    inputsRangeCorrect: true
    @inputsRangeOrderCorrect: true

    constructor: (@divPanel, @liFormula, constantValue, descriptionVariables, @srcImage, @symbols, @equation, @graph) ->
        #document.body.setAttribute 'onresize', ""
        #use resize, because google chrome have bug with it.
        window.addEventListener "resize", =>
            @graph.resizeCanvas (x) => 
                @executeEquation x
            ,'blue', 3, @mode
            
        @divFormula = document.createElement 'div'
        @divFormula.height = '300 px'
        @divFormula.width = '300 px'
       
        @divFormulaWithNumbers = document.createElement 'div'

        @divPanel.appendChild @divFormula
        @divPanel.appendChild @divFormulaWithNumbers

        @constantValue = document.getElementById constantValue
        @descriptionVariables = document.getElementById descriptionVariables

        @cloneCanvas()

        img = document.createElement 'img'
        img.src = @srcImage
        @divFormula.appendChild img
        @divFormulaWithNumbers.appendChild @drawFormula()
        MathJax.Hub.Queue(["Typeset",MathJax.Hub])

    drawFormula: ->
        formula = document.createElement 'p'
        formula.setAttribute 'class', "formula-text"
        formula.setAttribute 'id', @idFormula
        text = "`"
        form = document.createElement 'form'
        form.setAttribute 'id', "form-archimedes"
        i = 0 
        for id, variable of @symbols
            if variable instanceof Operator
                text = text + variable.operator
            else
                @variables[i] = variable
                
                @descriptionVariables.appendChild @createDt variable.name, variable.fullName
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
        parent = document.getElementById 'form-archimedes'
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

    createInputRange:  (id)->
        @numberInputsRangeFilled = 0
        @inputsRangeCorrect = true
        @inputsRangeOrderCorrect = true
        divForm = document.createElement 'div'
        divForm.setAttribute 'class', "form-group"
        divForm.setAttribute 'id', "div-form-" + id

        labelErrorOrdRange = document.createElement 'label'
        labelErrorOrdRange.setAttribute 'class', "control-label sr-only"
        text = document.createTextNode "The range is incorrect. It need start the small to the big"
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

        inputStart.oninput = => 
            @variables[id].startRange = @isNumberInRange inputStart, divInputStart, spanControlStart, labelInputStar, @variables[id].startRange, 0, id
            @inputsRangeOrder id, divForm, spanControlStart, spanControlEnd, labelErrorOrdRange

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
        button = document.createElement 'button'
        button.setAttribute 'type', "button"
        button.setAttribute 'class', "btn btn-primary"
        button.setAttribute 'button.setAttribute', ""
        button.addEventListener 'click', => @clickButton()
        text = document.createTextNode "update values"
        button.appendChild text
        divButton.appendChild button
        divButton

    createDt: (name, fullName) ->
        dt = document.createElement 'dt'
        text = document.createTextNode fullName + " (" + name + ")"
        dt.appendChild text
        dt

    createDd: (description) ->
        dd = document.createElement 'dd'
        text = document.createTextNode description
        dd.appendChild text
        dd

    clickButton: ->
        if (@numberInputsFilled == @variables.length-2 and @inputsCorrect and @inputsRangeOrderCorrect and @inputsRangeCorrect and (@numberInputsRangeFilled == 0 or @numberInputsRangeFilled == 2 ))
            @graph.context.clearRect(0, 0, @graph.canvas.width, @graph.canvas.height)
            @graph.context.drawImage(@graphCloneCanvas, 0, 0) 
            
            rads = document.getElementsByName 'modeLine'

            i = 0
            while i < rads.length
                if rads[i].checked
                    @mode = rads[i].value
                    break
                i++

            @drawNumbersFormula()
            @getVariableValues()
            @graph.x = @variables[@positionValueVariableX + 1].name
            @graph.y = @variables[0].name
            @graph.drawEquation (x) => 
                @executeEquation x
                
            ,'blue', 3, @mode
        else
            alert "The form have errors or it's not filled"

    cloneCanvas: -> 

        @graphCloneCanvas  = document.createElement('canvas')
        @contextCanvasClone = @graphCloneCanvas.getContext('2d')

        @graphCloneCanvas.width = @graph.canvas.width
        @graphCloneCanvas.height = @graph.canvas.height
    
        @contextCanvasClone.drawImage(@graph.canvas, 0, 0)

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
                @valueVariables[id] = null
                @positionValueVariableX = new Number(id)
                if variable.startRange isnt null and variable.endRange isnt null
                    @graph.xStart = variable.startRange
                    @graph.xEnd = variable.endRange
                    max = Math.max (Math.abs variable.startRange), (Math.abs variable.endRange)
                    @graph.maxX = @graph.maxY = max
                    @graph.minY = @graph.minX = - max
                    @graph.autoScale = false
                    @graph.resizeCanvas (x) => 
                            @executeEquation x
                        ,'blue', 3, @mode
                else
                    @graph.autoScale = true
                    @graph.resizeCanvas (x) => 
                        @executeEquation x
                    ,'blue', 3, @mode
            else
                @valueVariables[id] = variable.value

    executeEquation: (x) ->
        @valueVariables[@positionValueVariableX] = x
        @equation @valueVariables
    
class Archimedes extends Formula

    constructor: (divPanel, liFormula, constantValue, descriptionVariables, graph, srcImage) ->
        newtowns = new Variable("E" , "Newtowns" , "description" , null)
        equals = new Operator "="
        ###
        paragraph = document.createElement 'p'
        text1 = document.createTextNode "\u03C1"
        subTag = document.createElement 'sub'
        text2 = document.createTextNode "f"
        subTag.appendChild text2
        paragraph.appendChild text1
        paragraph.appendChild subTag
        console.log "aqui"
        ###
        #todo problems with sub tags
        density = new Variable("\u03C1" , "Density" , "description" , null)
        mult = new Operator "*"
        gravity = new Variable("g" , "Gravity" , "description" , null)
        volume = new Variable("V" , "Volume" , "description" , null)
        variables = [newtowns, equals, density, mult, gravity, mult, volume]
        
        super(divPanel, liFormula, constantValue, descriptionVariables, srcImage, variables, @archimedesEquation, graph)
    
    archimedesEquation: (arrayVariables) ->
        arrayVariables[0] * arrayVariables[1] * arrayVariables[2]


class Newton1 extends Formula

    constructor: (divPanel, liFormula, constantValue, descriptionVariables, graph, srcImage) ->
        force = new Variable "F" , "Force" , "description" , null
        equals = new Operator "="
        mass = new Variable "m" , "Mass" , "description" , null
        mult = new Operator "*"
        aceleration = new Variable "a" , "Aceleration" , "description" , null
        simbols = [force, equals, mass, mult, aceleration]
        
        super(divPanel, liFormula, constantValue, descriptionVariables, srcImage, simbols, @newtowEquation, graph)
    
    newtowEquation: (arrayVariables) ->
        arrayVariables[0] * arrayVariables[1]

class Pendulum extends Formula

    constructor: (divPanel, liFormula, constantValue, descriptionVariables, graph, srcImage) ->
        force = new Variable("F" , "Force" , "description" , null)
        equals = new Operator("=")
        parenthesisOpen = new Operator "("
        weight = new Variable("P" , "Weight pendulum" , "description" , null)
        mult = new Operator "*"
        elongation = new Variable("e" , "Elongation" , "description" , null)
        parenthesisClose = new Operator ")"
        division = new Operator "/"
        length = new Variable("\u03C1" , "Length pendulum" , "description" , null)
        variables = [force, equals, parenthesisOpen, weight, mult, elongation, parenthesisClose, division, length]
        
        super(divPanel, liFormula, constantValue, descriptionVariables, srcImage, variables, @pendulumEquation, graph)
    
    pendulumEquation: (arrayVariables) ->
       (arrayVariables[0] * arrayVariables[1]) / arrayVariables[2]


class Variable 
    name: null #string but pass in htlm , if it need for example sub tag
    fullName: null #string to put in constant value
    description: null # small description of variable
    value: null #float
    correct: true #value is float or it is null
    startRange: null #float star range
    endRange: null #float end range

    constructor: (@name,@fullName,@description,@value) ->


class Operator
    operator: null

    constructor: (@operator) ->


class Graph
    canvas: null
    minX: null
    minY: null
    maxX: null
    maxY: null
    xStart: null
    xEnd: null
    unitsPerTick: 1
    axisColor:"#aaa"
    font: "8pt Calibri"
    tickSize: 20
    context: null
    rangeX: null
    rangeY: null
    unitX: null
    unitY: null
    centerX: null
    centerY: null
    iteration: null
    scaleX: null
    scaleY: null
    x: null
    y: null
    autoScale : true

    constructor: ->
        @canvas = document.getElementById "graph"
        @context = @canvas.getContext '2d'
        @resizeCanvas()

    drawXAxis: ->
        context = @context
        context.save()
        context.beginPath()
        context.moveTo(0,@centerY)
        context.lineTo(@canvas.width, @centerY)
        context.strokeStyle = @axisColor
        context.lineWidth = 2
        context.stroke()

        xPosIncrement = @unitsPerTick * @unitX * 0.9
        context.font = @font
        context.textAlign = 'center'
        context.textBaseline = 'top'

        xPos = @centerX - xPosIncrement
        unit = -1 * @unitsPerTick
        while xPos > 0
            context.moveTo(xPos, @centerY - @tickSize / 2)
            context.lineTo(xPos, @centerY + @tickSize / 2)
            context.stroke()
            context.fillText(unit, xPos, @centerY + @tickSize / 2 + 3)
            unit -= @unitsPerTick
            xPos = Math.round(xPos - xPosIncrement)

        xPos = @centerX + xPosIncrement
        unit = @unitsPerTick
        while xPos < this.canvas.width 
            context.moveTo(xPos, @centerY - @tickSize / 2)
            context.lineTo(xPos, @centerY + @tickSize / 2)
            context.stroke()
            context.fillText(unit, xPos, @centerY + @tickSize / 2 + 3)
            unit += @unitsPerTick
            xPos = Math.round(xPos + xPosIncrement)     

        context.restore()

    drawYAxis: ->
        context = @context
        context.save()
        context.beginPath()
        context.moveTo(@centerX, 0)
        context.lineTo(@centerX,  @canvas.height)
        context.strokeStyle = @axisColor
        context.lineWidth = 2
        context.stroke()

        yPosIncrement = @unitsPerTick * @unitY * 0.9
        context.font = @font
        context.textAlign = 'right'
        context.textBaseline = 'middle'

        yPos = @centerY - yPosIncrement
        unit = @unitsPerTick
        while yPos > 0
            context.moveTo(@centerX - @tickSize / 2, yPos)
            context.lineTo(@centerX + @tickSize / 2, yPos)
            context.stroke()
            context.fillText(unit, @centerX - @tickSize / 2 - 3, yPos)
            unit += @unitsPerTick
            yPos = Math.round(yPos - yPosIncrement)

        yPos = @centerY + yPosIncrement
        unit = -1 * @unitsPerTick
        while yPos < @canvas.height
            context.moveTo(@centerX - @tickSize / 2, yPos)
            context.lineTo(@centerX + @tickSize / 2, yPos)
            context.stroke()
            context.fillText(unit, @centerX - @tickSize / 2 - 3, yPos)
            unit -= @unitsPerTick
            yPos = Math.round(yPos + yPosIncrement)
        
        context.restore()

    drawVariables: ->
        context = @context
        context.save()
        context.font = "20px Georgia"
        context.fillText(@y, @centerX - 40, 15)
        context.fillText(@x, @canvas.width - 15, @centerY + 40)
        context.restore()       

    resizeCanvas:  (equation, color, thickness, mode)->
        width = window.innerWidth
        if width > 991
            width = (width/12) * 5
        @canvas.width = width * 0.85
        @canvas.height = @canvas.width

        if @autoScale
            @maxX = ~~(width/2 /30)
            @minX = -@maxX
            @minY = @minX
            @maxY = @maxX
            @xStart = @minX
            @xEnd = @maxX 
  
        @rangeX = (Math.abs @maxX + Math.abs @minX)
        @rangeY = (Math.abs @maxY + Math.abs @minY)

        @unitX = @canvas.width / @rangeX 
        @unitY = @canvas.height / @rangeY
        @centerX = Math.round(Math.abs(@minX / @rangeX) * @canvas.width)
        @centerY = Math.round(Math.abs(@minY / @rangeY) * @canvas.height)
        @iteration = (@maxX + Math.abs @minX) / 1000
        @scaleX = @canvas.width / @rangeX
        @scaleY = @canvas.height / @rangeY
        @drawXAxis()
        @drawYAxis()
        if (@x and @y)
            @drawEquation equation, color, thickness, mode

    drawEquation: (equation, color, thickness, mode) ->
        context = @context
        iteration =  @iteration
        x = @xStart + iteration
        verticalAsymptote = false
        console.log @iteration
        if mode == "line"
            #console.log "aqui"
            y = equation(x)
            context.save()
            context.save()
            @transformContext()
            context.beginPath()
            context.moveTo(@xStart, y)
            auxX = x
            aux = y
            
            while x <= @xEnd
                if @minY < y < @maxY
                    #console.log "aqui"
                    context.lineTo(x, y)
                else 
                    if  (auxY < 0 and y > 0 ) or (auxY > 0 and y < 0)
                        verticalAsymptote = true
                        break
                    auxX = x
                    auxY = y
                x += iteration
                y = equation(x)

            context.restore()
            context.lineJoin = 'round'
            context.lineWidth = thickness
            context.strokeStyle = color
            context.stroke()
            context.restore()
            
            if verticalAsymptote

                context.save()
                x = x + iteration
                y = equation(x)
                @transformContext()
                context.beginPath()
                context.moveTo(x, y)
                while x <= @xEnd
                    if @minY < y < @maxY-1
                        context.lineTo(x, y)
                    x += iteration
                    y = equation(x)

                context.restore()
                context.lineJoin = 'round'
                context.lineWidth = thickness
                context.strokeStyle = color
                context.stroke()
                context.restore()
            
        if mode == "dots"
            iteration = 0.2
            endAngle = 2*Math.PI
            y = equation(x)
        
            auxX = x
            aux = y

            while x <= @xEnd
                if @minY < y < @maxY
                    context.save()
                    context.save()
                    @transformContext()
                    context.beginPath()
                    context.arc x, y, 0.09, 0,endAngle
                    context.restore()
                    context.fillStyle = color
                    context.fill()
                    context.restore()
                else 
                    if  (auxY < 0 and y > 0 ) or (auxY > 0 and y < 0)
                        verticalAsymptote = true
                        break
                    auxX = x
                    auxY = y
                
                x += iteration
                y = equation(x)

            if verticalAsymptote
                x = x + iteration
                y = equation(x)
                while x <= @xEnd
                    if @minY < y < @maxY
                        context.save()
                        context.save()
                        @transformContext()
                        context.beginPath()
                        context.arc x, y, 0.09, 0,endAngle
                        context.restore()
                        context.fillStyle = color
                        context.fill()
                        context.restore()  
                    x += iteration
                    y = equation(x)

        @drawVariables()

    transformContext: ->
        context = @context

        #center in graph
        @context.translate(@centerX, @centerY)
        #make more big the line or dots
        context.scale(@scaleX, - @scaleY)


class Init
    divPanel: null
    archimedes: null
    imgArchimedes: 'images/archimedesFormula.png'
    newton1: null
    imgNewton1: 'images/newtonFormula.png'
    constantValue: null
    pendulum: null
    imgPendulum: 'images/pendulumFormula.png'
    pendulumOscilation: null
    imgPendulumOscilation: 'images/pendulumOscilationFormula.png'
    descriptionVariables: null
    graph: null
    paragraph: null

    constructor: (divPanel, liArchimedes, liNewton1, lipendulum, @constantValue, @descriptionVariables) ->
        @graph = new Graph()
        @archimedes = document.getElementById liArchimedes
        @archimedes.setAttribute 'ondragstart' , ""
        @archimedes.ondragstart = (e) => @drag(e)
        @addListenerToFormula @archimedes, @imgArchimedes

        @newton1 = document.getElementById liNewton1
        @newton1.setAttribute 'ondragstart' , ""
        @newton1.ondragstart = (e) => @drag(e)
        @addListenerToFormula @newton1, @imgNewton1

        @pendulum = document.getElementById lipendulum
        @pendulum.setAttribute 'ondragstart' , ""
        @pendulum.ondragstart = (e) => @drag(e)
        @addListenerToFormula @pendulum, @imgPendulum

        #document.body.setAttribute 'onresize', ""
        #use resize, because google chrome have bug with it.
        window.addEventListener "resize", =>
            @graph.resizeCanvas (x) => 
                @executeEquation x
            ,'blue', 3, @mode
            
        @divPanel = document.getElementById divPanel

        @divPanel.setAttribute 'ondrop', ""
        @divPanel.ondrop = (e) => @drop(e)
        @divPanel.setAttribute 'ondragover', ""
        @divPanel.ondragover = (e) => @allowDrop(e)
        #Need put ondragenter a false for internet explorer and div, you can see documentation Microsoft for more information
        @divPanel.setAttribute 'ondragenter', "return false"

        @paragraph = document.createElement 'p'
        text = document.createTextNode "Please drop your formula here"
        @paragraph.appendChild text
        @divPanel.appendChild @paragraph

    allowDrop: (ev) => 
        ev.preventDefault()

    drag: (ev) ->
        ev.dataTransfer.setData('text', ev.target.id)

    drop: (ev) =>
        ev.preventDefault()
        data = ev.dataTransfer.getData("text")
        if data is @archimedes.id
            @disabledDrop()
            new Archimedes @divPanel, @archimedes, @constantValue, @descriptionVariables, @graph, @imgArchimedes
        if data is @newton1.id
            @disabledDrop()
            new Newton1 @divPanel, @newton1, @constantValue, @descriptionVariables, @graph, @imgNewton1
        if data is @pendulum.id
            @disabledDrop()
            new Pendulum @divPanel, @pendulum, @constantValue, @descriptionVariables, @graph, @imgPendulum

    disabledDrop: ->
        @divPanel.removeAttribute 'ondrop'
        @divPanel.removeAttribute 'ondragover'
        @divPanel.removeAttribute 'ondragenter'
        @divPanel.removeChild @paragraph

    addListenerToFormula: (formula, srcImage) ->
        formula.addEventListener( 'dragstart' , 
            (e) =>
                img = document.createElement("img")
                img.src = srcImage
                e.dataTransfer.setDragImage(img , 0 , 0)
        ,false)

window.Init = Init
