a = require('chai').assert
Promise = require('bluebird')

GLOBAL.Promise = Promise
GLOBAL.a = a
GLOBAL.eq = a.deepEqual
GLOBAL.lo = require('lodash')


GLOBAL.times = (goal, o, evt)->
  results = []
  new Promise (r, rj)->
    o.on evt, ->
      results.push lo.toArray(arguments)
      if results.length is goal
        o.removeListener 'error', rj
        r results
    o.once 'error', rj

GLOBAL.once = (o, evt)->
  times(1, o, evt).get(0)
