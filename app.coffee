# My app

rand = (max) -> Math.ceil(Math.random()*max)

generateDiceArray = (faces, num=1) ->
  console.log "#{num}d#{faces}"
  rand(faces) for i in [1..num]
  
make = (req, res) ->
  dices = generateDiceArray(
    parseInt(req.params.faces),
    parseInt(req.params.num)
  )
  data =
    num: req.params.num
    faces: req.params.faces
    dices: dices
    sum: dices.reduce (x,y) -> x + y
  res.format
    html: -> res.render 'dices', data
    text: -> res.send "#{data.dices.join(' + ')} = #{data.sum}"
    json: -> res.send data

# Express

express = require('express')
stylus = require('stylus')
nib = require('nib')

app = express()

app.set 'title', 'R&aacute;ndomer'
app.set 'view engine', 'blade'

app.use express.logger()
app.use stylus.middleware
  src: __dirname + '/views',
  dest: __dirname + '/static',
  compile: (str, path) ->
    stylus(str)
      .set('filename', path)
      .set('compress', true)
      .use(nib())
      .import('nib')
app.use express.static(__dirname + '/static')

params = require('express-params')
params.extend(app);

app.get '/', (req, res) -> res.redirect "/#{rand(10)}d#{rand(10)}"

numRegEx = /^[123456789]\d*$/
app.param 'faces', numRegEx
app.param 'num', numRegEx
app.get '/:faces', make
app.get '/(:num)d(:faces)', make
app.get '/(:num)/(:faces)', make

app.listen(process.env.PORT)
