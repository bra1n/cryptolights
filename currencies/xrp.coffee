class XRP
  constructor: ->
    @ws = null
    @socketUrl = "wss://s1.ripple.com/"
    @donationAddress = ""
    @noBlocks = yes

  start: (txCb) ->
    @stop() if @ws
    @ws = new WebSocket @socketUrl

    @ws.onclose = =>
      setTimeout (=> @start txCb, blockCb), 1000

    @ws.onopen = =>
      @ws.send JSON.stringify command: 'subscribe',streams: ['transactions'], id: 1

    @ws.onmessage = ({data}) =>
      data = JSON.parse data
      if data.engine_result is 'tesSUCCESS' and data.transaction.TransactionType is 'Payment'
        { Amount, Destination, Fee, hash } = data.transaction
        Amount = 0 if Amount.currency?
        txCb? {
          amount: Amount / 1000000
          fee: Fee / 1000000
          link: 'https://xrpcharts.ripple.com/#/transactions/' + hash
          donation: Destination is @donationAddress
        }

  stop: ->
    @ws.close()
    @ws = null
