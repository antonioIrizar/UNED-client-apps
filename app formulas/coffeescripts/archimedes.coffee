class Formula
    divFormula: null
    divFormulaWithNumbers: null
    divPanel: null
    liFormula: null
    descriptionVariables: null
    srcImage: null
    textFormula: null
    variables: null
    constantValue: null
    idFormula: "prueba"
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

    constructor: (divPanel, liFormula, constantValue, descriptionVariables, @srcImage, @variables, @equation, @graph) ->
        #document.body.setAttribute 'onresize', ""
        #use resize, because google chrome have bug with it.
        window.addEventListener "resize", =>
            @graph.resizeCanvas (x) => 
                @executeEquation x
            ,'blue', 3, @mode
            
        @liFormula = document.getElementById liFormula
        @liFormula.setAttribute 'ondragstart' , ""
        @liFormula.ondragstart = (e) => @drag(e)
        @divPanel = document.getElementById divPanel
        @divFormula = document.createElement 'div'
        @divPanel.setAttribute 'ondrop', ""
        @divPanel.ondrop = (e) => @drop(e)
        @divPanel.setAttribute 'ondragover', ""
        @divPanel.ondragover = (e) => @allowDrop(e)
        #Need put ondragenter a false for internet explorer and div, you can see documentation Microsoft for more information
        @divPanel.setAttribute 'ondragenter', "return false"
        @divFormula.height = '300 px'
        @divFormula.width = '300 px'
        paragraph = document.createElement 'p'
        text = document.createTextNode "Please drop your formula here"
        paragraph.appendChild text
        @divPanel.appendChild paragraph
        @divFormulaWithNumbers = document.createElement 'div'
        @divPanel.appendChild @divFormula
        @divPanel.appendChild @divFormulaWithNumbers
        @addListenerToFormula(@srcImage)
        @constantValue = document.getElementById constantValue
        @descriptionVariables = document.getElementById descriptionVariables
        @cloneCanvas()

    addListenerToFormula: (srcImage) ->
        @liFormula.addEventListener( 'dragstart' , 
            (e) =>
                img = document.createElement("img") 
                img.src = srcImage
                e.dataTransfer.setDragImage(img , 0 , 0)
        ,false)

    allowDrop: (ev) => 
        ev.preventDefault()

    drag: (ev) ->
        #ev.dataTransfer.setData('text/html', ev.target.id)

    drop: (ev) =>
        ev.preventDefault()
        img = document.createElement 'img'
        img.src = @srcImage
        @divFormula.appendChild img
        @divFormulaWithNumbers.appendChild @drawFormula()

    drawFormula: ->
        formula = document.createElement 'p'
        formula.setAttribute 'class', "formula-text"
        formula.setAttribute 'id', @idFormula
        form = document.createElement 'form'
        form.setAttribute 'id', "form-archimedes"
        for id, variable of @variables
            @descriptionVariables.appendChild @createDt variable.name, variable.fullName
            @descriptionVariables.appendChild @createDd variable.description
            if id is "0"
                text = document.createTextNode variable.name + " = " 
                formula.appendChild text
            else
                form.appendChild @createInput id
                text = document.createTextNode variable.name
                formula.appendChild text
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
                divForm.setAttribute 'class', "form-group has-error has-feedback"
                spanControl.setAttribute 'class', "glyphicon glyphicon-remove form-control-feedback"
                labelForm.setAttribute 'class', "control-label"
                if @variables[id].value isnt null
                    newNumberInputsFilled--
                @variables[id].correct = false
                @variables[id].value = null
                inputsCorrect = false
            else
                divForm.setAttribute 'class', "form-group has-success has-feedback"
                spanControl.setAttribute 'class', "glyphicon glyphicon-ok form-control-feedback"
                labelForm.setAttribute 'class', "control-label sr-only"
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
            divForm.setAttribute 'class', "form-group"
            spanControl.setAttribute 'class', ""
            labelForm.setAttribute 'class', "control-label sr-only"

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
                inputStart = document.getElementById 'input-star'
                inputStart.setAttribute 'disabled', ""
                inputEnd = document.getElementById 'input-end'
                inputEnd.setAttribute 'disabled', ""
            i++

    eneableInputs: (id) ->
        i = 1
        while i < @variables.length
            if i != Number(id) and i != @idInputRange
                input = document.getElementById @variables[i].fullName
                input.removeAttribute 'disabled'
            if i == @idInputRange
                inputStart = document.getElementById 'input-star'
                inputStart.removeAttribute 'disabled'
                inputEnd = document.getElementById 'input-end'
                inputEnd.removeAttribute 'disabled'
            i++

    createInputRange:  (id)->
     
        divForm = document.createElement 'div'
        divForm.setAttribute 'class', "form-group"
        divForm.setAttribute 'id', "div-form-" + id

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
        inputStart.setAttribute 'id', "input-star"
        inputStart.setAttribute 'type', "text"
        inputStart.setAttribute 'class', "form-control"

        spanControlStart = document.createElement 'span'
        spanControlStart.setAttribute 'id', "span-control-start"

        inputStart.setAttribute 'oninput', ""
        inputStart.oninput = => 
            @variables[id].startRange = @isNumberInRange inputStart, divInputStart, id, spanControlStart, labelInputStar
        
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
        inputEnd.setAttribute 'id', "input-end"
        inputEnd.setAttribute 'type', "text"
        inputEnd.setAttribute 'class', "form-control"
        
        spanControlEnd = document.createElement 'span'
        spanControlEnd.setAttribute 'id', "span-control-end"

        inputEnd.setAttribute 'oninput', ""
        inputEnd.oninput = => 
            @variables[id].endRange = @isNumberInRange inputEnd, divInputEnd, id, spanControlEnd, labelInputEnd

        divInputEnd.appendChild inputEnd
        divInputEnd.appendChild spanControlEnd
        divForm.appendChild divInputEnd

        divForm

    isNumberInRange: (input, divForm, id, spanControl, labelForm) ->
        value = null

        if input.value.length > 0

            if isNaN input.value
                divForm.setAttribute 'class', "form-group has-error has-feedback"
                spanControl.setAttribute 'class', "glyphicon glyphicon-remove form-control-feedback"
                labelForm.setAttribute 'class', "control-label"
                value = null
            else
                divForm.setAttribute 'class', "form-group has-success has-feedback"
                spanControl.setAttribute 'class', "glyphicon glyphicon-ok form-control-feedback"
                labelForm.setAttribute 'class', "control-label sr-only"
                value = new Number input.value
        else
            @variables[id].value = null
            divForm.setAttribute 'class', "form-group"
            spanControl.setAttribute 'class', ""
            labelForm.setAttribute 'class', "control-label sr-only"

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
        if (@numberInputsFilled == @variables.length-2 and @inputsCorrect)
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
        text = ""
        for id, variable of @variables
            if variable.value isnt  null
                if id is "1"
                    text = text + " = " + variable.value
                else
                    text = text + variable.value
            else
                if id is "1"
                    text = text + " = " + variable.name
                else
                    text = text + variable.name
        formula.innerHTML = text

    #Can optimize this function with refactor searchInputRange
    getVariableValues: ->
        for id, variable of @variables[1..]
            if variable.value is null
                @valueVariables[id] = null
                @positionValueVariableX = new Number(id)
            else
                @valueVariables[id] = variable.value

    executeEquation: (x) ->
        @valueVariables[@positionValueVariableX] = x
        @equation @valueVariables
    
class Archimedes extends Formula

    constructor: (divPanel, liFormula, constantValue, descriptionVariables) ->
        newtowns = new Variable("E" , "newtowns" , "description" , null)
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
        panel = document.getElementById 'caca'
        graph = new Graph()
        density = new Variable("\u03C1" , "density" , "description" , null)
        gravity = new Variable("g" , "gravity" , "description" , null)
        volume = new Variable("V" , "volume" , "description" , null)
        variables = [newtowns,density,gravity,volume]
        
        super(divPanel , liFormula, constantValue, descriptionVariables, 'images/archimedesFormula.png',variables, @archimedesEquation,graph)
    
    archimedesEquation: (arrayVariables) ->
        arrayVariables[0] * arrayVariables[1] * arrayVariables[2]
    ###
    archimedesEquation: (a,b,c) ->
        a*b*c
    ###
class Variable 
    name: null #string but pass in htlm , if it need for example sub tag
    fullName: null #string to put in constant value
    description: null # small description of variable
    value: null #float
    correct: true #value is float or it is null
    startRange: null #float star range
    endRange: null #float end range

    constructor: (@name,@fullName,@description,@value) ->

class Graph
    canvas: null
    minX: -10
    minY: -10
    maxX: 10
    maxY: 10
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

        xPosIncrement = @unitsPerTick * @unitX
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

        yPosIncrement = @unitsPerTick * @unitY
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

        @rangeX = @maxX - @minX
        @rangeY = @maxY - @minY

        @unitX = @canvas.width / @rangeX 
        @unitY = @canvas.height / @rangeY
        @centerX = Math.round(Math.abs(@minX / @rangeX) * @canvas.width)
        @centerY = Math.round(Math.abs(@minY / @rangeY) * @canvas.height)
        @iteration = (@maxX - @minX) / 1000
        @scaleX = @canvas.width / @rangeX
        @scaleY = @canvas.height / @rangeY
        @drawXAxis()
        @drawYAxis()
        if (@x and @y)
            @drawEquation equation, color, thickness, mode

    drawEquation: (equation, color, thickness, mode) ->
        context = @context
        context.save()
        context.save()
        @transformContext()

        context.beginPath()
        iteration =  @iteration *10
        x = @minX + iteration
        if mode == "line"

            context.moveTo(@minX, equation(@minX))
            y = equation(x)
           
            while x <= @maxX && y <= @maxY
                context.lineTo(x, equation(x))
                x += iteration
                y = equation(x)

            context.restore()
            context.lineJoin = 'round'
            context.lineWidth = thickness
            context.strokeStyle = color
            context.stroke()

        if mode == "dots"

            endAngle = 2*Math.PI
            y = equation(x)

            while x <= @maxX && y <= @maxY
                context.arc x, y, 0.09, 0,endAngle
                x += iteration
                y = equation(x)

            context.restore()
            context.fillStyle = color
            context.fill()
            
        context.restore()
        @drawVariables()

    transformContext: ->
        context = @context

        @context.translate(@centerX, @centerY)

        context.scale(@scaleX, - @scaleY)

window.Archimedes = Archimedes

window.Formula = Formula