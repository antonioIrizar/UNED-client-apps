class Item
    typeElement: null
    nameAttr: []
    dataAttr: []
    text: null
    parent: false
    child: null

    constructor: (@typeElement, @nameAttr, @dataAttr, @text, @parent, @child) ->

window.Item = Item