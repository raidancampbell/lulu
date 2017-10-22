# Description:
#   Generates help commands for Hubot.
#
# Commands:
#   hubot help - Send a link to all of hubot's commands.
#   hubot help <query> - Displays all help commands that match <query>.
#
# URLS:
#   /hubot/help
#
# Notes:
#   These commands are grabbed from comment blocks at the top of each file.

helpContents = (name, commands) ->

  """
<html>
  <head>
  <title>#{name} Help</title>
  <style type="text/css">
    body {
      background: #d3d6d9;
      color: #636c75;
      text-shadow: 0 1px 1px rgba(255, 255, 255, .5);
      font-family: Helvetica, Arial, sans-serif;
    }
    h1 {
      margin: 8px 0;
      padding: 0;
    }
    .commands {
      font-size: 13px;
    }
    p {
      border-bottom: 1px solid #eee;
      margin: 6px 0 0 0;
      padding-bottom: 5px;
    }
    p:last-child {
      border: 0;
    }
  </style>
  </head>
  <body>
    <h1>#{name} Help</h1>
    <div class="commands">
      #{commands}
    </div>
  </body>
</html>
  """

module.exports = (robot) ->
  robot.respond /help\s*(.*)?$/i, (msg) ->

    if msg.match[1]
      # When given a command to ask about, perform the old behavior and list
      # help for all matching commands in a query.
      cmds = robot.helpCommands()
      cmds = cmds.filter (cmd) ->
        cmd.match new RegExp(msg.match[1], 'i')
      emit = cmds.join "\n"
      unless robot.name.toLowerCase() is 'hubot'
        emit = emit.replace /hubot/ig, robot.name
      # this hack makes lulu respond directly, instead of in the room
      delete msg.message.user.room
      msg.send emit

    else
      # When there is no command asked about, just tell the room where to find
      # lulu's command listing, instead of exceeding the server's flood limit
      # attempting to send a command listing.
      msg.send "View my command list at http://hacsoc.org/lulu and my environment variables at http://hacsoc.org/lulu/env.html"

  robot.router.get '/hubot/help', (req, res) ->
    cmds = robot.helpCommands()
    emit = "<p>#{cmds.join '</p><p>'}</p>"

    emit = emit.replace /hubot/ig, "<b>#{robot.name}</b>"

    res.setHeader 'content-type', 'text/html'
    res.end helpContents robot.name, emit
