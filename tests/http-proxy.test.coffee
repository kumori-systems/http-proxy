q = require 'q'
EventEmitter = require('events').EventEmitter
should = require 'should'
supertest = require 'supertest'
nativeHttp = require 'http'
http = require '@kumori/http-message'
httpProxy = require '../src/index'

#### START: ENABLE LOG LINES FOR DEBUGGING ####
# This will show all log lines in the code if the test are executed with
# DEBUG="kumori:*" set in the environment. For example, running:
#
# $ DEBUG="kumori:*" npm test
#
debug = require 'debug'
# debug.enable 'http-proxy:*'
# debug.enable 'http-proxy:info, kumori:debug'
debug.log = () ->
  console.log arguments...
#### END: ENABLE LOG LINES FOR DEBUGGING ####

#-------------------------------------------------------------------------------
class Reply extends EventEmitter

  @dynCount = 0

  constructor: (@name, iid) ->
    @config = {}
    @runtimeAgent = {
      config: {
        iid: iid
      },
      createChannel: () ->
        return new Reply("dyn_rep_#{Reply.dynCount++}", iid)
    }

  setConfig: () ->

  handleRequest: () -> throw new Error 'NOT IMPLEMENTED'

#-------------------------------------------------------------------------------
class Request extends EventEmitter

  constructor: (@name, iid) ->
    @sentMessages = []
    @config = {}
    @runtimeAgent = {
      config: {
        iid: iid
      }
    }

  sendRequest: (message) ->
    @sentMessages.push message
    return q.promise (resolve, reject) ->
      resolve [{status: 'OK'}]
      reject 'NOT IMPLEMENTED'

  setConfig: () ->

  resetSentMesages: () -> @sentMessages = []

  getLastSentMessage: () -> return @sentMessages.pop()

#-------------------------------------------------------------------------------

proxy = null
httpMessageServer = null
replyChannel = null
dynReplyChannel = null
dynRequestChannel = null
IID = 'A1'
SEP_IID = 'SEP1'
reqIdCount = 1
CONNKEY = '123456'
MESSAGE = 'TEST_MESSAGE'

nativeServer = null
nativeHost = 'localhost'
nativePort = 8082
nativeResponse = 'Hola Radiola'


describe 'http-proxy test', ->

  before (done) ->
    nativeServer = nativeHttp.createServer (request, response) ->
      data = ''
      request.on 'data', (chunk) ->
        data += chunk
      request.on 'end', () ->
        response.statusCode = 200
        response.setHeader('content-type', 'text/plain')
        response.write "RESPONSE:#{data}"
        response.end()


    nativeServer.listen nativePort, nativeHost, (err) ->
      if err? then throw err
      replyChannel = new Reply('main_rep_channel', IID)
      dynRequestChannel = new Request('dyn_req', IID)
      httpMessageServer = http.createServer()
      httpMessageServer.on 'error', (err) -> throw err
      httpMessageServer.listen replyChannel
      httpMessageServer.on 'listening', (err) ->
        if err? then throw err
        request = JSON.stringify {
          type: 'getDynChannel'
          fromInstance: SEP_IID
        }
        replyChannel.handleRequest([request], [dynRequestChannel])
        .then (message) ->
          reply = message[0][0] # when test, we dont receive a "status" segment
          reply.should.be.eql IID
          dynReplyChannel = message[1][0]
          dynReplyChannel.constructor.name.should.be.eql 'Reply'
          dynReplyChannel.name.should.be.eql 'dyn_rep_0'
          proxy = httpProxy httpMessageServer, nativeHost, nativePort
          done()
        .fail (err) -> done err


  after (done) ->
    httpMessageServer.close()
    done()


  it 'Process a request', () ->
    dynRequestChannel.resetSentMesages()
    reqId = "#{reqIdCount++}"
    m1 = _createMessage 'request', reqId, 'get', true
    dynReplyChannel.handleRequest [m1]
    .then () ->
      m2 = _createMessage 'end', reqId
      dynReplyChannel.handleRequest [m2]
    .then () ->
      q.delay(1000)
    .then () ->
      r3 = dynRequestChannel.getLastSentMessage()
      r3 = JSON.parse r3
      [r2, r2data] = dynRequestChannel.getLastSentMessage()
      r2 = JSON.parse r2
      r2data = r2data.toString()
      r1 = dynRequestChannel.getLastSentMessage()
      r1 = JSON.parse r1
      r1.type.should.be.eql 'response'
      r1.reqId.should.be.eql reqId
      r1.data.headers.instancespath.should.be.eql ",iid=#{IID}"
      r2.type.should.be.eql 'data'
      r2.reqId.should.be.eql reqId
      r2data.should.be.eql 'RESPONSE:'
      r3.type.should.be.eql 'end'
      r3.reqId.should.be.eql reqId


  it 'Process a request with payload', () ->

    reqId = "#{reqIdCount++}"
    m1 = _createMessage 'request', reqId, 'post'
    dynReplyChannel.handleRequest [m1]
    .then () ->
      m2 = _createMessage 'data', reqId
      dynReplyChannel.handleRequest [m2, MESSAGE]
    .then () ->
      m3 = _createMessage 'end', reqId
      dynReplyChannel.handleRequest [m3]
    .then () ->
      q.delay(100)
    .then () ->
      r3 = dynRequestChannel.getLastSentMessage()
      r3 = JSON.parse r3
      [r2, r2data] = dynRequestChannel.getLastSentMessage()
      r2 = JSON.parse r2
      r2data = r2data.toString()
      r1 = dynRequestChannel.getLastSentMessage()
      r1 = JSON.parse r1
      r1.type.should.be.eql 'response'
      r1.reqId.should.be.eql reqId
      r2.type.should.be.eql 'data'
      r2.reqId.should.be.eql reqId
      r2data.should.be.eql "RESPONSE:#{MESSAGE}"
      r3.type.should.be.eql 'end'
      r3.reqId.should.be.eql reqId


  it 'Process error events', (done) ->
    forcedError = 'This is forced error'
    endThis = (error) ->
      proxy.removeAllListeners 'error'
      done error
    proxy.on 'error', (error) ->
      try
        error.message.should.eql forcedError
        endThis()
      catch err
        endThis err
    proxy.nodeProxy.emit 'error', new Error forcedError


  _createMessage = (type, reqId, method, use_instancespath) ->
    if type is 'request'
      requestData =
        protocol: 'http'
        url: '/'
        method: method
        headers:
          host: 'localhost:8080',
          connection: 'keep-alive'
      if use_instancespath? then requestData.headers.instancespath = ''
    return JSON.stringify {
      type: type
      domain: 'uno.empresa.es'
      fromInstance: SEP_IID
      connKey: CONNKEY
      reqId: reqId
      data: requestData
    }
