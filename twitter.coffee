twitter  = require 'twitter'
async    = require 'async'
fs       = require 'fs'

config = require './config'

twitter = new twitter(config.twitter)

uploadImage = (file,cb) ->
    fs.readFile('/tmp/photo.png',(err,data) ->
        console.log("Read data")

        twitter.post('media/upload', {media: data}, cb)
    )

module.exports.stream = (cb) ->
    twitter.stream('user', {}, (stream) ->
        stream.on('data', cb)

        stream.on('error', (error) ->
            throw error
        )
    )

module.exports.post = (message,pic,cb) ->
    console.log("Posting \"#{message}\" to twitter")

    uploadImage(pic,(err,media,response) ->
        console.log("Uploaded pic: ")
        console.dir(media)

        twitter.post(
            'statuses/update',
            {
                status: message,
                media_ids: media.media_id_string
            },
            cb)
    )

