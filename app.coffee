express = require 'express'
sio = require 'socket.io'
http = require 'http'
path = require 'path'

mongoose = require 'mongoose'
colors = require 'colors'

models = require './models'

PORT = process.env.PORT || 3000

app = express()
server = http.createServer app
io = sio.listen server

app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'
app.use express.favicon()
app.use express.logger 'dev'
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, 'static'))
app.use express.errorHandler()
app.use(require('less-middleware')({ src: __dirname + '/static' }));
app.use(express.static(path.join(__dirname, 'static')));

mongoose.connect 'mongodb://dbuser:pilotpwva@ds053808.mongolab.com:53808/hackerchat', ->
  console.log "Database connection established".yellow
  server.listen PORT

app.get '/', (req, res) ->
  res.render 'app', {title: 'HackerChat'}

io.sockets.on 'connection', (socket) ->

  socket.on "auth", (req) ->
    console.log "Got auth event"
    user = new models.User()
    user.name = req.name
    user.save (err) ->
      if err
        console.log "Err from create user: #{err}"
      console.log user
      socket.emit "auth", user

  socket.on 'derp', (data) ->
    console.log "Got this from the client: #{data}"
