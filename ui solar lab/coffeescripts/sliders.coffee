window.sliders = sliders = ->



  


 
  ###
  $('.slider-weigth').noUiSlider({
    start: 0,
    step: 1,
    connect: "lower",
    range: {
      'min': [0],
      'max': [50]
    }
  })
  ###


  

  

  

  $(".slider-weigth").noUiSlider_pips({
    mode: 'count',
    values: 6,
    density: 3,
    stepped: true,
    format: wNumb({
      postfix: 'cm'
    })
  })
  $(".slider-weigth").attr('disabled', 'disabled')
  # Tags after '-inline-' are inserted as HTML.
  # noUiSlider writes to the first element it finds.
  # The tooltip HTML is 'this', so additional
  #// markup can be inserted here.
  $(".slider").Link('lower').to("-inline-<div class=\"tooltipe\"></div>", (value) -> $(this).html "<span>" + Math.floor(value) + "</span>")
