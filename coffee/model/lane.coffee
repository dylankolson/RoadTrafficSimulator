'use strict'

define (require) ->
  $ = require 'jquery'
  Segment = require 'geom/segment'

  class Lane
    constructor: (@sourceSegment, @targetSegment, @road) ->
      @leftAdjacent = null
      @rightAdjacent = null
      @leftmostAdjacent = null
      @rightmostAdjacent = null
      @carsPositions = {}

    toJSON: ->
      obj = $.extend {}, @
      delete obj.carsPositions
      obj

    length: -> # TODO: property
      @middleLine.length()

    @property 'middleLine',
      get: -> new Segment @sourceSegment.center(), @targetSegment.center()

    @property 'sourceSideId',
      get: -> @road.sourceSideId

    @property 'targetSideId',
      get: -> @road.targetSideId

    @property 'isRightmost',
      get: -> @ is @.rightmostAdjacent

    @property 'isLeftmost',
      get: -> @ is @.leftmostAdjacent

    getTurnDirection: (other) ->
      throw Error 'invalid lanes' if @road.target isnt other.road.source
      side1 = @targetSideId
      side2 = other.sourceSideId
      # 0 - left, 1 - forward, 2 - right
      turnNumber = (side2 - side1 - 1 + 8) % 4

    getLeftBorder: -> # TODO: property
      new Segment @sourceSegment.source, @targetSegment.target

    getRightBorder: -> # TODO: property
      new Segment @sourceSegment.target, @targetSegment.source

    getDirection: -> # TODO: property
      @middleLine.direction()

    getPoint: (a) ->
      @middleLine.getPoint a

    addCarPosition: (carPosition) ->
      throw Error 'car is already here' if carPosition.id of @carsPositions
      @carsPositions[carPosition.id] = carPosition

    removeCar: (carPosition) ->
      throw Error 'removing unknown car' unless carPosition.id of @carsPositions
      delete @carsPositions[carPosition.id]

    getNext: (carPosition) ->
      throw Error 'car is on other lane' if carPosition.lane isnt @
      next = null
      bestDistance = Infinity
      for id, o of @carsPositions
        distance = o.position - carPosition.position
        if 0 < distance < bestDistance
          bestDistance = distance
          next = o
      next
