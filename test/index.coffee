net = require('net')
socketHeartbeat = require('../')





describe.only 'socket-heartbeat', ->
  @timeout(10000)

  beforeEach (done)->
    @server = net.createServer (socket)=>
      @socket = socket
      socketHeartbeat(socket, {
        idle_ms: 500
        interval_ms: 100,
        probe_count: 3,
        send_probe: -> socket.write('PROBE')
      })
      done()

    @server.listen '5893', =>
      @client = net.createConnection port:'5893'

  afterEach (done)->
    @client.destroy()
    @server.close -> done()



  it 'client receives PROBE if idle too long', ->
    Promise.all([
      once @client, 'data'
      once @socket, 'heartbeatCheck'
    ]).spread (data)->
      a data.toString(), 'PROBE'


  it 'client does NOT receive PROBE if sends any data', ->
    Promise.all([
      once @socket, 'readable'
      once @socket, 'heartbeatOk'
    ])
    @client.write 'FOO'


  it 'client is forcibly disconnected if it does not respond to PROBE', ->
    Promise.all([
      once @client, 'close'
      times 4, @client, 'data'
    ])
    .get(1)
    .then(lo.flatten)
    .then (datas)->
      eq datas.map((x)-> x.toString()), lo.range(4).map -> 'PROBE'


  it 'when client exits pinpong mode event handlers unbinded'
  it 'if socket is in flowing mode data-event type used is "data"'
  it 'if socket isnt in flowing mode data-event type used is "readable"'
