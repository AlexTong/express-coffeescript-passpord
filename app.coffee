express = require 'express'
path = require 'path'
favicon = require 'serve-favicon'
logger = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
passport = require('passport');
Strategy = require('passport-local').Strategy;

db = require('./db')
passport.use(new Strategy(
	(username, password, cb)->
		db.users.findByUsername(username, (err, user)->
			if err then return cb(err)
			if !user then return cb(null, false)
			if user.password != password then return cb(null, false)
			return cb(null, user);
		)
))

passport.serializeUser((user, cb)->
	cb(null, user.id)
)

passport.deserializeUser((id, cb)->
	db.users.findById(id, (err, user)->
		if err then return cb(err)
		cb(null, user)
	)
)
app = express()

# view engine setup
app.set 'views', path.join __dirname, 'views'
app.set 'view engine', 'jade'

# uncomment after placing your favicon in /public
# app.use favicon "#{__dirname}/public/favicon.ico"
app.use logger 'dev'
app.use bodyParser.json()
app.use bodyParser.urlencoded
	extended: true
app.use cookieParser()
app.use express.static path.join __dirname, 'public'
app.use(require('express-session')({secret: 'keyboard cat', resave: false, saveUninitialized: false}));
app.use(passport.initialize());
app.use(passport.session());

app.get('/', (req, res)->
	res.render('index', {user: req.user})
)

app.get('/login', (req, res)-> res.render('login'))

app.post('/login', passport.authenticate('local', {failureRedirect: '/login'}), (req, res)-> res.redirect('/'));

app.get('/logout', (req, res)->
	req.logout()
	res.redirect('/')
)

app.get('/profile',
	require('connect-ensure-login').ensureLoggedIn(),
	(req, res)-> res.render('profile', {user: req.user})
);

# catch 404 and forward to error handler
app.use (req, res, next) ->
	err = new Error 'Not Found'
	err.status = 404
	next err

# error handlers

# development error handler
# will print stacktrace
if app.get('env') is 'development'
	app.use (err, req, res, next) ->
		res.status err.status or 500
		res.render 'error',
			message: err.message,
			error: err

# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
	res.status err.status or 500
	res.render 'error',
		message: err.message,
		error: {}

module.exports = app
