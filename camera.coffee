RaspiCam = require('raspicam')

rc = new RaspiCam({
    mode: 'photo',
    output: '/tmp/photo.png'
})

rc.on("start", () ->
    console.log("Capturing photo")
)

rc.on("stop", () ->
    console.log("Done capturing photo")
)

module.exports.get = (cb) ->
    waiting = true

    rc.on("read", (err,timestamp,filename) ->
        if waiting and filename == 'photo.png'
            waiting = false
            rc.stop()
            console.log("Caputred photo to #{filename}")
            cb(filename)
    )
    
    rc.start()
