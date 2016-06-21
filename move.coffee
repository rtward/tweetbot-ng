async = require 'async'
io    = require 'rpi-gpio'

config = require './config'

lightPin         = config.pins.light
leftForwardPin   = config.pins.leftForward
leftBackwardPin  = config.pins.leftBackward
rightForwardPin  = config.pins.rightForward 
rightBackwardPin = config.pins.rightBackward

io.setup(lightPin, io.DIR_OUT,
    (err) ->
        if err
            console.log("Error enabling light pin ("+lightPin+"): "+err)
        else
            console.log("Light pin set for output")
)

io.setup(leftForwardPin, io.DIR_OUT,
    (err) ->
        if err
            console.log("Error enabling left forward pin ("+leftForwardPin+"): "+err)
        else
            console.log("Left forward pin ("+leftForwardPin+") set for output")
)

io.setup(leftBackwardPin, io.DIR_OUT,
    (err) ->
        if err
            console.log("Error enabling left backward pin ("+leftBackwardPin+"): "+err)
        else
            console.log("Left backward pin ("+leftBackwardPin+") set for output")
)

io.setup(rightForwardPin, io.DIR_OUT,
    (err) ->
        if err
            console.log("Error enabling right forward pin ("+rightForwardPin+"): "+err)
        else
            console.log("Right forward pin ("+rightForwardPin+") set for output")
)

io.setup(rightBackwardPin, io.DIR_OUT,
    (err) ->
        if err
            console.log("Error enabling right backward pin ("+rightBackwardPin+"): "+err)
        else
            console.log("Right backward pin ("+rightBackwardPin+") set for output")
)

lightOn = (cb) ->
    io.write(lightPin, true, (err) ->
        if err
            console.log("Error turning on light: "+err)
        else
            console.log("Light On")

        cb()
    )

lightOff = (cb) ->
    io.write(lightPin, false, (err) ->
        if err
            console.log("Error turning off light: "+err)
        else
            console.log("Light Off")
        cb()
    )

leftFwd = (cb) ->
    io.write(leftForwardPin, true, (err) ->
        if err
            console.log("Error turning on left forward: "+err)
        else
            console.log("Left Motor Forward")
        cb()
    )

leftBack = (cb) ->
    io.write(leftBackwardPin, true, (err) ->
        if err
            console.log("Error turning on left backward: "+err)
        else
            console.log("Left Motor Backward")
        cb()
    )

leftOff = (cb) ->
    async.parallel([
            (cb) -> io.write(leftForwardPin,false,cb),
            (cb) -> io.write(leftBackwardPin,false,cb)
        ],
        (err) -> 
            if err
                console.log("Error turning off left motor: "+err)
            else
                console.log("Left Motor Off")
            cb()
    )

rightFwd = (cb) ->
    io.write(rightForwardPin, true, (err) ->
        if err
            console.log("Error turning on right forward: "+err)
        else
            console.log("Right Motor Forward")
        cb()
    )

rightBack = (cb) ->
    io.write(rightBackwardPin, true, (err) ->
        if err
            console.log("Error turning on right backward: "+err)
        else
            console.log("Right Motor Backward")
        cb()
    )

rightOff = (cb) ->
    async.parallel([
            (cb) -> io.write(rightForwardPin,false,cb),
            (cb) -> io.write(rightBackwardPin,false,cb)
        ],
        (err) -> 
            if err
                console.log("Error turning off right motor: "+err)
            else
                console.log("Right Motor Off")
            cb()
    )

runCmds = (cmds,duration,cb) ->
    async.series([
            (cb) -> async.parallel(cmds,cb),
            (cb) -> setTimeout(cb,duration),
            (cb) -> async.parallel([leftOff,rightOff],cb)
        ],cb)

module.exports.goForward = (duration,cb) ->
    runCmds([leftFwd,rightFwd],duration,cb)

module.exports.goBackwards = (duration,cb) ->
    runCmds([leftBack,rightBack],duration,cb)

module.exports.leftTurn = (duration,cb) ->
    runCmds([leftBack,rightFwd],duration,cb)
        
module.exports.rightTurn = (duration,cb) ->
    runCmds([rightBack,leftFwd],duration,cb)

