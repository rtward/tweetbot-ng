readline = require 'readline'
async    = require 'async'

move    = require  './move'
config  = require  './config'
twitter = require './twitter'
cam     = require './camera'

commandRegex = ///
    (
        (F|FORWARD|FWD)   |
        (B|BACKWARD|BKWD) |
        (L|LEFT|LFT|LT)   |
        (R|RIGHT|RGHT|RT)
    )
    \s*
    (\d+)
///img

helpRegex = ///help///img

takePicture = (message) ->
    console.log("Taking a picture and posting it")
    cam.get((filename) ->
        console.log("Got photo at #{filename}")
        twitter.post(message,filename,() -> "Picture posted")
    )

sendHelp = (toWhom) ->
    if toWhom
        takePicture("@#{toWhom} Like this FORWARD 1. A direction and a distance. Other directions are BACKWARD, LEFT, and RIGHT")
    else
        takePicture("Commands look like this FORWARD 1. It's a direction and a distance. Other directions are BACKWARD, LEFT, and RIGHT")

parseCommands = (text,cb) ->
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
    () -> cb(matches.length))


# Read input from the command line
terminal = readline.createInterface({
    input:  process.stdin,
    output: process.stdout
})
terminal.on 'line', (line) ->
    console.log("Parsing input from STDIN: "+line)
    parseCommands(line)

# Read input from twitter
twitter.stream (tweet) ->
    fromUser = tweet?.user?.screen_name

    if fromUser and fromUser != 'tweetmybot'
        console.log("Parsing input from Twitter: "+tweet?.text)

        if helpRegex.exec(tweet?.text)
            sendHelp(fromUser)

        parseCommands(tweet.text,(cmds) ->
            if cmds > 0
                takePicture("Okay @#{fromUser}, where to next?")
            else
                if fromUser
                    takePicture("Sorry @#{fromUser} I didn't understand that, try a command like FORWARD 1")
        )

takePicture("Tweet bot is online and accepting commands! Send me a tweet and I'll drive around!")
sendHelp()
