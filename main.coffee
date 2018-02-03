currencies = ['btc', 'eth', 'ltc', 'xrb']
prices = {}

# get current price
updatePrices = ->
  currencyAPI = 'https://min-api.cryptocompare.com/data/price?fsym=USD&tsyms='
  $.get currencyAPI + currencies.join(',').toUpperCase(), (data) ->
    if data
      for currency, price of data
        currency = currency.toLowerCase()
        prices[currency] = Math.round(1/price*100)/100
        $('.'+currency+' .price').text prices[currency]

  setTimeout updatePrices, 10*1000

# litecoin live feed
litecoinSocket = new WebSocket "wss://insight.litecore.io/socket.io/?EIO=3&transport=websocket"

litecoinSocket.onopen = ->
  litecoinSocket.send '2probe'
  litecoinSocket.send '5'
  litecoinSocket.send '420["subscribe","sync"]'
  litecoinSocket.send '421["subscribe","inv"]'
  litecoinSocket.send '422["subscribe","sync"]'
  litecoinSocket.send '424["subscribe","sync"]'
  litecoinSocket.send '425["subscribe","inv"]'
  setInterval (-> litecoinSocket.send '2'), 25*1000

litecoinSocket.onmessage = ({data}) ->
  data = data.match /^\d+(\[.+?)$/
  if data
    [type, payload] = JSON.parse(data[1])
    if type is 'tx'
      showTx 'ltc',
        amount: payload.valueOut
        fee: 0
        hash: payload.txid
        recipients: payload.vout.map (value) -> Object.keys(value)[0]
    else
      showBlock 'ltc', payload

# bitcoin live feed
bitcoinSocket = new WebSocket "wss://ws.blockchain.info/inv"
bitcoinSocket.onopen = ->
  bitcoinSocket.send JSON.stringify op: 'unconfirmed_sub'
  bitcoinSocket.send JSON.stringify op: 'blocks_sub'
bitcoinSocket.onmessage = ({data}) ->
  data = JSON.parse data
  if data.op is 'utx'
    fee = 0
    valOut = 0
    valIn = 0
    valIn += input.prev_out.value/100000000 for input in data.x.inputs
    valOut += output.value/100000000 for output in data.x.out
    fee = Math.max valIn - valOut, 0
    showTx 'btc',
      amount: valOut
      fee: fee
      recipients: data.x.out.map (out) -> [out.addr, out.value/100000000]
  else
    showBlock 'btc', data.x

# nano live feed
nanoSocket = new WebSocket "wss://www.nanode.co/socket.io/?EIO=3&transport=websocket"
nanoSocket.onopen = ->
  setInterval (-> nanoSocket.send '2'), 25*1000
nanoSocket.onmessage = ({data}) ->
  data = data.match /^\d+(\[.+?)$/
  if data
    [type, payload] = JSON.parse(data[1])
    if type is 'block'
      showTx 'xrb', {amount: payload.amount / Math.pow(10, 30), fee: 0, hash: payload.hash}

# ether live feed
etherSocket = new WebSocket "ws://ethersocket.herokuapp.com"
etherSocket.onmessage = ({data}) ->
  data = JSON.parse data
  if data.type is 'tx'
    showTx 'eth', {amount: data.ethers, fee: data.fee, hash: data.hash}
  else
    showBlock 'eth', data

#################
### rendering ###
#################
lanes = {}

showTx = (currency, tx) ->
  price = tx.amount*prices[currency]
  fee = tx.fee*prices[currency]

  lanes[currency].addMeteor
    speed: if fee then 2 + 4 * Math.min(2, Math.log10(1+fee))/2 else 6
    hue: if price then 220 - 220 * Math.min(6, Math.log10(1+price))/6 else 220
    thickness: Math.max(5, Math.log10(1+price) * 10)
    length: Math.min(3, Math.log10(1 + fee))/3 * 250

showBlock = (currency) ->
  lanes[currency].addBlock()

$ ->
  updatePrices()
  $('.currencies > div').each ->
    currency = $(@).attr 'class'
    canvas = $ '<canvas></canvas>'
    $('.'+currency).append canvas
    lanes[currency] = new CanvasRenderer canvas.get(0)