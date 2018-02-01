#bitcoinSocket = new WebSocket "wss://ws.blockchain.info/inv"
#bitcoinSocket.onopen = ->
#  bitcoinSocket.send JSON.stringify op: 'unconfirmed_sub'
#  bitcoinSocket.send JSON.stringify op: 'blocks_sub'
#bitcoinSocket.onmessage = ({data}) ->
#  data = JSON.parse data
#  if data.op is 'utx'
#    fee = 0
#    valOut = 0
#    valIn = 0
#    valIn += input.prev_out.value/100000000 for input in data.x.inputs
#    valOut += output.value/100000000 for output in data.x.out
#    fee = Math.max valIn - valOut, 0
#    showTx 'btc', { amount: valOut, fee, hash: data.x.hash }
#  else
#    showBlock 'btc', data.x
#
#
#
#
#nanoSocket = new WebSocket "wss://www.nanode.co/socket.io/?EIO=3&transport=websocket"
#nanoSocket.onopen = ->
#  nanoSocket.send '2'
#nanoSocket.onmessage = ({data}) ->
#  data = data.match /^\d+(\[.+?)$/
#  if data
#    [type, payload] = JSON.parse(data[1])
#    if type is 'block'
#      showTx 'nano', {amount: payload.amount / Math.pow(10, 30), fee: 0, hash: payload.hash}
#
etherSocket = new WebSocket "ws://ethersocket.herokuapp.com"
etherSocket.onmessage = ({data}) ->
  data = JSON.parse data
  if data.type is 'tx'
    showTx 'ethereum', {amount: data.ethers, fee: data.fee, hash: data.hash}
  else
    showBlock 'ethereum', data


showTx = (network, tx) ->
  console.log 'tx', network, tx

showBlock = (network, block) ->
  console.log 'block', network, block