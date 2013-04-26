@ImageAnalyzer = (image, callback) ->
    bgcolor = primaryColor = secondaryColor = detailColor = null
    init = (image, callback) ->
        img = new Image()
        img.src = image
        img.onload = ->
            cvs = document.createElement 'canvas'
            cvs.width = img.width
            cvs.height = img.height
            ctx = cvs.getContext '2d'
            ctx.drawImage img, 0, 0

            bgcolor = findEdgeColor cvs, ctx

            findTextColors cvs, ctx, ->
                callback bgcolor, primaryColor, secondaryColor, detailColor

    init image, callback

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
                if nextProposedEdgeColor[1] / proposedEdgeColor[1] > 0.3
                    if not isBlackOrWhite nextProposedEdgeColor[0]
                        proposedEdgeColor = nextProposedEdgeColor
                        break

        proposedEdgeColor[0]

    findTextColors = (cvs, ctx, cb) ->
        colors = ctx.getImageData 0, 0, cvs.width, cvs.height

        findDarkTextColor = not isDarkColor bgcolor
        colorCount = {}
        for row in [0...cvs.height]
            for column in [0...cvs.width]
                red = colors.data[((row * (cvs.width * 4)) + (column * 4))]
                green = colors.data[((row * (cvs.width * 4)) + (column * 4)) + 1]
                blue = colors.data[((row * (cvs.width * 4)) + (column * 4)) + 2]

                index = red + ',' + green + ',' + blue
                if not colorCount[index]
                    colorCount[index] = 0
                colorCount[index]++


        possibleColorsSorted = []
        for color, count of colorCount
            curDark = isDarkColor color
            if curDark == findDarkTextColor
                possibleColorsSorted.push [color, count]

        possibleColorsSorted.sort (a, b) ->
            b[1] - a[1]

        for color in possibleColorsSorted
            if not primaryColor
                if isContrastingColor color[0], bgcolor
                    primaryColor = color[0]
            else if not secondaryColor
                if not isDistinct(primaryColor, color[0]) or not isContrastingColor(color[0], bgcolor)
                    continue
                secondaryColor = color[0]
            else if not detailColor
                if not isDistinct(secondaryColor, color[0]) or not isDistinct(primaryColor, color[0]) or not isContrastingColor(color[0], bgcolor)
                    continue
                detailColor = color[0]
                break
                
        defaultColor = if findDarkTextColor then "0,0,0" else "255,255,255"       
        primaryColor = defaultColor if not primaryColor
        secondaryColor = defaultColor if not secondaryColor
        detailColor = defaultColor if not detailColor
                
        cb()

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

    isDarkColor = (color) ->
        if color
            splitted = color.split(',')
            red = splitted[0] / 255
            green = splitted[1] / 255
            blue = splitted[2] / 255

            lum = 0.2126 * red + 0.7152 * green + 0.0722 * blue

            return lum < 0.5
        return false

    isContrastingColor = (color1, color2) ->
        splitted1 = color1.split(',')
        red1 = splitted1[0] / 255
        green1 = splitted1[1] / 255
        blue1 = splitted1[2] / 255

        lum1 = 0.2126 * red1 + 0.7152 * green1 + 0.0722 * blue1

        splitted2 = color2.split(',')
        red2 = splitted2[0] / 255
        green2 = splitted2[1] / 255
        blue2 = splitted2[2] / 255

        lum2 = 0.2126 * red2 + 0.7152 * green2 + 0.0722 * blue2

        if lum1 > lum2
            contrast = (lum1 + 0.05) / (lum2 + 0.05)
        else
            contrast = (lum2 + 0.05) / (lum1 + 0.05)

        return contrast > 1.6

    isDistinct = (color1, color2) ->
        splitted1 = color1.split(',')
        red1 = splitted1[0] / 255
        green1 = splitted1[1] / 255
        blue1 = splitted1[2] / 255

        splitted2 = color2.split(',')
        red2 = splitted2[0] / 255
        green2 = splitted2[1] / 255
        blue2 = splitted2[2] / 255

        treshold = 0.25

        if Math.abs(red1 - red2) > treshold or Math.abs(green1 - green2) > treshold or Math.abs(blue1 - blue2) > treshold
            if Math.abs(red1 - green1) < .03 and Math.abs(red1 - blue1) < .03
                if Math.abs(red2 - green2) < .03 and Math.abs(red2 - blue2) < .03
                    return false
            return true
        return false
