# The MIT License (MIT)
#
# Copyright (c) 2015 Manuel
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

HEXCOLORTABLE = [
  '#000000'
  '#8b4900'
  '#ff0000'
  '#ffb726'
  '#ffff00'
  '#00d200'
  '#0000d2'
  '#d900db'
]

SIZE = 40
MARGIN = SIZE/2
GAME = null

class Tile
  type: '.'
  size: SIZE
  margin: MARGIN

  constructor: (@position) ->
  isMoveable: ->
    [false, false, false, false]

class Way extends Tile
  type: '+'
  constuctor: ->
    super

class Wall extends Tile
  type: '#'
  costructor: ->
    super

class Marble extends Tile

  constructor: (@name, position) ->
    super position
    @type = @name
    @color = HEXCOLORTABLE[parseInt(@name)]

  move: (pos) ->
    switch GAME.tiles[pos].constructor.name
      when 'Way'
        found = $.grep GAME.marbles, (value) ->
          value.position == pos
        if found.length < 1 then true
        else false
      else false
  
  moveTop: -> this.move(@position-10)
  moveRight: -> this.move(@position+1)
  moveBottom: -> this.move(@position+10)
  moveLeft: -> this.move(@position-1)

class Game
  tiles: []
  marbles: []
  select: null
  points: 0

  constructor: (@field, @solution, @moves) ->
    this.createField @field, this.tiles
    this.createMarbles @field, this.marbles

  createMarbles: (field, layers) ->
    $.each field, (index, value) ->
      switch value
        when '1', '2', '3', '4', '5', '6', '7', '8', '9'
          layers.push new Marble value, index

  createField: (field, layers) ->
    $.each field, (index, value) ->
      switch value
        when '#'
          layers.push new Wall index
        when '+', '1', '2', '3', '4', '5', '6', '7', '8', '9'
          layers.push new Way index
        when '.'
          layers.push new Tile index

  analyseField: ->
    arr1 = []
    arr2 = []

    $.each @marbles, (index, value) ->
      arr1.push "#{value.position}_#{value.name}"

    $.each @solution, (index, value) ->
      arr2.push "#{value.position}_#{value.marble}"

    $(arr1).not(arr2).length == 0 and $(arr2).not(arr1).length == 0

$(document).ready ->
  game = null
  next = null
  back = null

  hash = '' + window.location
  prefix = '//' + window.location.host +
    window.location.pathname.replace("index.html", "")
  level = hash.split('#')[1]

  if level == undefined
    level = 'l001'

  $.getJSON prefix + '/game/levels/' + level + '.json', (data) ->
    GAME = new Game data['field'], data['solution'], parseInt(data['moves'])
    next = data['next']
    back = data['back']
    $('#moves').text GAME.moves
    $('#points').text 0
    drawField()
    drawMarbles()

  $('#back').click ->
    window.location = '#' + back
    location.reload()

  $('#restart').click ->
    window.location = '#' + level
    location.reload()

  $('#reset').click ->
    window.location = '#l001'
    location.reload()

  $('#next').click ->
    window.location = '#' + next
    location.reload()

  $('#leftarrow').click -> process 37
  $('#toparrow').click -> process 38
  $('#rightarrow').click -> process 39
  $('#bottomarrow').click -> process 40
  $(this).keydown (e) ->
    e.preventDefault()
    process e.which

process = (key) ->
    return if GAME.select == null
 
    ary = $.grep GAME.marbles, (value) ->
      parseInt(GAME.select.name) == parseInt(value.type)
    active = ary[0]
    switch key
      when 37, 65, 72 then active.position -= 1 while active.moveLeft()
      when 38, 87, 75 then active.position -= 10 while active.moveTop()
      when 39, 68, 76 then active.position += 1 while active.moveRight()
      when 40, 83, 74 then active.position += 10 while active.moveBottom()

    $('#marbles').animateLayer GAME.select,
      x: active.margin + (active.position % 10) * SIZE
      y: active.margin + parseInt(active.position / 10) * SIZE
      strokeStyle: '#222'
      strokeWidth: 2

    $('#moves').text GAME.moves -= 1 if GAME.moves >= 1
    if GAME.analyseField() then alert "You win!"
    else if GAME.moves <= 0 then alert 'GAME over!'

    GAME.select = null

drawField = ->
  $.each GAME.solution, (index, value) ->
    $("#marbles").drawArc
      layer: true
      fillStyle: HEXCOLORTABLE[value.marble]
      strokeWidth: 0
      opacity: .4
      x: MARGIN + (value.position % 10) * SIZE
      y: MARGIN + parseInt(value.position / 10) * SIZE
      radius: SIZE/2 - 2

  $.each GAME.tiles, (index, value) ->
    switch value.type
      when '#'
        $('#marbles').drawRect
          layer: true
          strokeStyle: '#222'
          strokeWidth: 4
          fillStyle: '#444'
          x: value.margin + (value.position % 10) * value.size
          y: value.margin + parseInt(value.position / 10) * value.size
          width: value.size - 5
          height: value.size - 5

drawMarbles = ->
  $.each GAME.marbles, (index, value) ->
    switch value.type
      when '1', '2', '3', '4', '5', '6', '7', '8', '9'
        $("#marbles").drawArc
          name: "#{value.name}"
          layer: true
          fillStyle: value.color
          strokeStyle: '#222'
          strokeWidth: 2
          x: value.margin + (value.position % 10) * value.size
          y: value.margin + parseInt(value.position / 10) * value.size
          radius: value.size/2 - 2
          click: (layer) ->
            if GAME.select != null
              $('#marbles').setLayer GAME.select,
                strokeStyle: '#222'
                strokeWidth: 2

            $("#marbles").setLayer layer,
              strokeStyle: '#fff'
              strokeWidth: 3
          
            $("#marbles").drawLayers()
            GAME.select = layer
