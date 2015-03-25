class Slider

    constructor: (name, start, step, min, max, values, density, postfix) ->
        $('.' + name).noUiSlider(
            'start': start
            'step': step
            'connect': 'lower'
            'range': 
                'min': min
                'max': max
        )

        $('.' + name).noUiSlider_pips(
            'mode': 'count'
            'values': values
            'density': density
            'stepped': true,
            'format': wNumb(
                'postfix': postfix
            )
        )
    
        $("."+ name).Link('lower').to("-inline-<div class=\"tooltipe\"></div>", (value) -> $(this).html "<span>" + Math.floor(value) + "</span>")


window.Slider = Slider