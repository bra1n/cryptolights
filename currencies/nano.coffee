class NANO
  constructor: ->
    @ws = null
    @socketUrl = "wss://ws.nanocrawler.cc/"
    @donationAddress = "nano_1em33f7ewc9mpbargkp14m3uuojz5wt96hzu4tcfb585ds8575gp1fnoxaj3"

  start: (txCb) ->
    @stop() if @ws
    @ws = new WebSocket @socketUrl

    @ws.onclose = =>
      setTimeout (=> @start txCb, blockCb), 1000

    @ws.onopen = =>
      @ws.send JSON.stringify event: 'subscribe', data: ['all']
      @ping = setInterval (=> @ws.send JSON.stringify event: 'keepalive'), 30*1000

    @ws.onmessage = ({data}) =>
      data = JSON.parse data
      if data.data and data.data.is_send is 'true'
        { amount, link_as_account } = data.data.block
        txCb? {
          amount: amount
          fee: 0
          link: 'https://nanocrawler.cc/explorer/block/' + data.data.hash
          donation: link_as_account is @donationAddress
        }

  stop: ->
    @ws.close()
    clearInterval @ping
    @ws = null
