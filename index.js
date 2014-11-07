var merge = require('lodash.merge')
var pingpong = require('ping-pong')



var defaults = {
  idle_ms: 5000,
  interval_ms: 10000,
  is_flowing: false,
  probe_count: 3,
  send_probe: function(){
    console.warn('socket-heartbeat requires a "send_probe" implementation')
  }
}



module.exports = function socketHeartbeat(socket, config){

  config = merge({}, defaults, config)

  if (config.idle_ms) {
    socket.setTimeout(config.idle_ms)
    socket.once('timeout', pingPongMode)
  } else pingPongMode()

  function pingPongMode() {
    socket.emit('heartbeatCheck')
    var timer = pingpong(config.interval_ms, config.probe_count, ping, onFlatline)

    socket.once('close', exit)
    socket.on((config.is_flowing ? 'data' : 'readable'), onPulse)

    function ping(probesLeft) {
      config.send_probe(socket, probesLeft)
    }

    function exit() {
      socket.removeListener('readable', onPulse)
      socket.removeListener('close', exit)
      pingpong.clear(timer)
    }

    function onFlatline() {
      exit()
      socket.emit('heartbeatFlatline')
      socket.destroy()
    }

    function onPulse() {
      socket.emit('heartbeatOk')
      /* Exit back to idleTimeout mode
      unless idle_ms is set to 0 in which
      case reset the pingpong session. */
      if (config.idle_ms) {
        exit()
        socket.once('timeout', pingPongMode)
      } else pingpong.pong(timer)
    }
  }
}
