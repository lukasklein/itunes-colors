$ ->
    color = ImageAnalyzer 'sample.jpg', (bgcolor, primaryColor, secondaryColor, detailColor) ->
        $('#frame').css('background-color', 'rgb(' + bgcolor + ')')
        $('.primary').css('color', 'rgb(' + primaryColor + ')')
        $('.secondary').css('color', 'rgb(' + secondaryColor + ')')
        $('.detail').css('color', 'rgb(' + detailColor + ')')
