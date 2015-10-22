express = require 'express'
router = express.Router()

# GET users listing.
router.get '/', (req, res, next) ->
	html = "<h2>你好, " + req.user.username + "</h2><a href='/logout'>退出</a>"
	res.send(html)

module.exports = router
