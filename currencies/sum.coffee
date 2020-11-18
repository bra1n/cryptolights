class SUM
  constructor: ->
    @ws = null
    @socketUrl = "wss://insight.sumcore.org/socket.io/?EIO=3&transport=websocket"
    @txApi = "https://insight.sumcore.org/api/tx/"
    @blockApi = "https://insight.sumcore.org/api/block/"
    @txFees = [0.000224, 0.0005]
    @txFeeTimestamp = 0
    @txFeeInterval = 3000 # how often to query for a fee
    @donationAddress = "SX75kbV2to7LCMj2rc9Bb8agpZxAg6rzoL"

  start: (txCb, blockCb) ->
    @stop() if @ws
    @ws = new WebSocket @socketUrl

    @ws.onclose = =>
      setTimeout (=> @start txCb, blockCb), 1000

    @ws.onopen = =>
      @ws.send '2probe'
      @ws.send '5'
      @ws.send '420["subscribe","sync"]'
      @ws.send '421["subscribe","inv"]'
      @ws.send '422["subscribe","sync"]'
      @ws.send '424["subscribe","sync"]'
      @ws.send '425["subscribe","inv"]'
      @ping = setInterval (=> @ws.send '2'), 25*1000

    @ws.onmessage = ({data}) =>
      data = data.match /^\d+(\[.+?)$/
      if data
        [type, payload] = JSON.parse(data[1])
        if type is 'tx'
          # fetch fees every now and then
          if new Date().getTime() - @txFeeInterval > @txFeeTimestamp
            $.get @txApi + payload.txid, ({fees}) =>
              if fees
                @txFees.shift()
                @txFees.push(fees)
                @txFeeTimestamp = new Date().getTime()

          txCb? {
            amount: payload.valueOut
            fee: Math.random() * Math.abs(@txFees[0] - @txFees[1]) + Math.min.apply(0, @txFees)
            link: 'https://insight.sumcore.org/tx/' + payload.txid
            donation: !!payload.vout.find (vout) => Object.keys(vout)[0] is @donationAddress
          }
        else
          $.get @blockApi + payload, ({tx}) =>
            blockCb? count: if tx then tx.length else 0
          
  stop: ->
    @ws.close()
    clearInterval @ping
    @ws = null
