ImageAnalyzer = (image, frame) ->
    init = (image, frame) ->
        frm = document.getElementById(frame)
        img = new Image()
        img.src = image
        img.onload = ->
            cvs = document.createElement 'canvas'
            cvs.width = img.width
            cvs.height = img.height
            ctx = cvs.getContext '2d'
            ctx.drawImage img, 0, 0

            color = findEdgeColor cvs, ctx
            frm.style.background = 'rgb(' + color + ')'
            
    init image, frame

    findEdgeColor = (cvs, ctx) ->
        leftEdgeColors = ctx.getImageData 0, 0, 1, cvs.height

        # Get most common color from the first column
        colorCount = {}
        for pixel in [0...cvs.height]
            red = leftEdgeColors.data[pixel*4]
            green = leftEdgeColors.data[pixel*4 + 1]
            blue = leftEdgeColors.data[pixel*4 + 2]

            index = red + ',' + green + ',' + blue
            if not colorCount[index]
                colorCount[index] = 0
            colorCount[index]++

        
        sortedColorCount = []
        for color, count of colorCount
            if count > 2
                sortedColorCount.push [color, count]
        
        sortedColorCount.sort (a, b) ->
            b[1] - a[1]

        proposedEdgeColor = sortedColorCount[0]
        if isBlackOrWhite proposedEdgeColor[0]
            for nextProposedEdgeColor in sortedColorCount
                if nextProposedEdgeColor[1] / proposedEdgeColor[1] > 0.4
                    if not isBlackOrWhite nextProposedEdgeColor[0]
                        proposedEdgeColor = nextProposedEdgeColor
                        break

        proposedEdgeColor[0]


    isBlackOrWhite = (color) ->
        splitted = color.split(',')
        red = splitted[0]
        green = splitted[1]
        blue = splitted[2]

        tresholdWhite = 255*0.91
        tresholdBlack = 255*0.09

        if red > tresholdWhite and green > tresholdWhite and blue > tresholdWhite
            return true
        if red < tresholdBlack and green < tresholdBlack and blue < tresholdBlack
            return true

        return false

$ ->
    color = ImageAnalyzer 'sample.jpg', 'frame'