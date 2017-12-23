express = require 'express'
bodyparser = require 'body-parser'

metrics = require './metrics'
users = require './users'
session = require 'express-session'

app = express()

app.use(session({secret: 'shashasha'}));

isConnected = (req, res, next) ->
    if req.session.connected
      next()
    else
      res.redirect '/connexion'

app.set 'port', '8888'
app.set 'views', "#{__dirname}/../views"
app.set 'view engine', 'pug'

app.use bodyparser.json()
app.use bodyparser.urlencoded()

app.use '/', express.static "#{__dirname}/../public"

app.get '/', isConnected, (req, res) ->
  res.render 'index',
    name: req.session.username
    id: req.session.userid

app.get '/connexion', (req, res) ->
  res.render 'connexion'

app.post '/signin', (req, res) ->
  users.checkuser req.body, (err, id, login) ->
    throw next err if err
    if id != null
     req.session.connected = true
     req.session.userid = id
     req.session.username = login
    res.redirect('/')

app.post '/signup', (req, res) ->
  users.save req.body, (err) ->
    throw next err if err
    res.redirect('/')

app.get '/signout', (req, res) ->
  req.session.connected = false
  req.session.id = null
  res.redirect('/')

app.get '/metrics.json', (req, res) ->
  metrics.get req.session.userid, (err, data) ->
    throw next err if err
    res.status(200).json data

app.post '/metrics.json/:id', (req, res) ->
  metrics.save req.params.id, req.body, (err) ->
    throw next err if err
    res.status(200).send 'metrics saved'

app.get '/newmetrics', isConnected,  (req, res) ->
  res.render 'add',
    name: req.session.username
    id: req.session.userid

app.post '/newmetrics/add', isConnected, (req, res) ->
  metrics.add req.session.userid, req.body, (err) ->
    throw next err if err
    res.redirect('/')

app.get '/delete/:timestamp', (req, res) ->
  metrics.delete req.session.userid, req.params.timestamp, (err) ->
    throw next err if err
    res.status(200).send "Metrics deleted"


app.listen app.get('port'), () ->
  console.log "Server listening on #{app.get 'port'} !"
