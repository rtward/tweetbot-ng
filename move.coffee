async = require 'async'

leftForwardPin   = 1
leftBackwardPin  = 2
rightForwardPin  = 3
rightBackwardPin = 4

leftFwd = (cb) ->
    console.log("Left Forward")
    cb()

leftBack = (cb) ->
    console.log("Left Back")
    cb()

leftOff = (cb) ->
    console.log("Left Off")
    cb()

rightFwd = (cb) ->
    console.log("Right Forward")
    cb()

rightBack = (cb) ->
    console.log("Right Back")
    cb()

rightOff = (cb) ->
    console.log("Right Off")
    cb()

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
    runCmds([leftFwd,rightBack],duration,cb)

