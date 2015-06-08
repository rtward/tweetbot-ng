twitter  = require 'twitter'
readline = require 'readline'
async    = require 'async'

move   = require './move'
config = require './config'

commandRegex = ///
    (
        (F|FORWARD|FWD)   |
        (B|BACKWARD|BKWD) |
        (L|LEFT|LFT)      |
        (R|RIGHT|RGHT)
    )
    \s*
    (\d+)
///img

parseCommands = (text) ->
    # Find all the commands in the given text, and store them in the matches array
    matches = []
    while cmdMatch = commandRegex.exec(text)
        matches.push(cmdMatch)
        
    # One at a time, handle the command matches
    async.mapSeries(matches, (match,cb) ->

        # Get the duration from the command match
        duration = parseInt(match[6])

        # If the duration is larger then the max, trim it back
        if duration > config.maxDuration
            duration = config.maxDuration

        # Multiply the duration to get the duration milliseconds
        duration = duration*config.durationMultiplier

        # Run the command found with the parsed duration
        if match[2]
            move.goForward(duration,cb)
        else if match[3]
            move.goBackwards(duration,cb)
        else if match[4]
            move.leftTurn(duration,cb)
        else if match[5]
            move.rightTurn(duration,cb)
    )

takePicture = () ->
    console.log("Taking a picture and posting it")

    # TODO Actually take a picture

    # After some interval, take another picture
    setTimeout(takePicture,config.pictureInterval)

# Read input from the command line
terminal = readline.createInterface({
    input:  process.stdin,
    output: process.stdout
})
terminal.on('line', (line) ->
    console.log("Parsing input from STDIN: "+line)
    parseCommands(line)
)

# Read input from twitter
twitter = new twitter(config.twitter)
twitter.stream('user', {}, (stream) ->
    stream.on('data', (tweet) ->
        console.log("Parsing input from Twitter: "+tweet.text)
        parseCommands(tweet.text)
    )

    stream.on('error', (error) ->
        throw error
    )
)

# Start taking pictures
takePicture()
