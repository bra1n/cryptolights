currencies =
  btc: new BTC()
  eth: new ETH()
  ltc: new LTC()
  xrb: new XRB()
prices = {}
stats = {}

currencyFormat =
  style: 'currency'
  currency: 'USD'
  minimumFractionDigits: 0
  maximumFractionDigits:0

# render TX
showTx = (engine, currency, tx) ->
  value = tx.amount * (prices[currency] or 1)
  fee = tx.fee * (prices[currency] or 1)

  engine.addMeteor
    speed: if fee then 2 + 4 * Math.min(2, Math.log10(1+fee))/2 else 6
    hue: if value then 220 - 220 * Math.min(6, Math.log10(1+value))/6 else 220
    thickness: Math.max(5, Math.log10(1+value) * 10)
    length: Math.min(3, Math.log10(1 + fee))/3 * 250
    link: tx.link
    donation: tx.donation

  updateStats currency, value, fee

# render block
showBlock = (engine, currency, block) ->
  engine.addBlock Math.min(250, block.count / 4)
  stats[currency].count = Math.max(0, stats[currency].count - block.count) if stats[currency]?

# get current price
updatePrices = (currencies) ->
  currencyAPI = 'https://min-api.cryptocompare.com/data/price?fsym=USD&tsyms='
  $.get currencyAPI + currencies.join(',').toUpperCase(), (data) ->
    if data
      for currency, price of data
        currency = currency.toLowerCase()
        prices[currency] = Math.round(1/price*100)/100
        $(".#{currency} .price").text prices[currency].toLocaleString(undefined, { style: 'currency', currency: 'USD' })

  marketcapAPI = 'https://api.coinmarketcap.com/v1/global/'
  $.get marketcapAPI, (data) ->
    if data
      $(".marketcap").text data.total_market_cap_usd.toLocaleString(undefined, currencyFormat)


  setTimeout updatePrices.bind(null, currencies), 10*1000

# update stats for a currency, called whenever there is a new TX
# to do that, keep a log of the last 60 seconds of tx
updateStats = (currency, value = 0, fee = 0) ->
  stats[currency] = {last: [], count: 0} unless stats[currency]?
  # increase number of unverified TX
  stats[currency].count++ unless currency is 'xrb'
  # calculate stats for last 60s
  last = stats[currency].last
  timestamp = new Date().getTime()
  last.push {timestamp, value, fee}
  i = last.length
  last.splice(i, 1) while i-- when timestamp - last[i].timestamp > 60*1000
  duration = Math.max(last[last.length - 1].timestamp - last[0].timestamp, 1) / 1000
  txPerSecond = Math.round(last.length / duration * 10)/10
  #valuePerSecond = Math.round(stat.reduce(((a, b) -> a + b.value), 0) / duration)
  valuePerTx = Math.round(last.reduce(((a, b) -> a + b.value), 0) / last.length)
  #feePerSecond = Math.round(stat.reduce(((a, b) -> a + b.fee), 0) / duration * 100)/100
  feePerTx = Math.round(last.reduce(((a, b) -> a + b.fee), 0) / last.length * 100)/100
  $(".#{currency} .stats").text """
    #{txPerSecond.toLocaleString()} tx/s (#{stats[currency].count} unconfirmed)
    #{valuePerTx.toLocaleString(undefined, currencyFormat)} value/tx
    #{feePerTx.toLocaleString(undefined, { style: 'currency', currency: 'USD' })} fee/tx
  """

# set up a lane
initialize = (currency) ->
  if currencies[currency]?
    container = $(".#{currency}")
    container.find("canvas").remove()
    canvas = $ '<canvas></canvas>'
    container.append canvas
    engine = new CanvasRenderer canvas.get(0)
    canvas.data 'engine', engine
    engine.start() if container.is ':visible'
    currencies[currency].start showTx.bind(null, engine, currency), showBlock.bind(null, engine, currency)

    # donation links
    if currencies[currency].donationAddress
      container.find('.donate').on 'click', =>
        $('.overlay .donation').show().siblings().hide()
        $('.overlay').fadeToggle()
          .find('.address').text currencies[currency].donationAddress
          .end().find('.donation img').attr 'src', "img/#{currency}-qr.png"
    else
      container.find('.donate').remove()

# update lane rendering (for resizing and lane toggling
updateLanes = ->
  $(".currencies > div").each ->
    container = $(@)
    engine = container.find('canvas').data 'engine'
    if container.is ':visible'
      engine.resize container.find('canvas').get(0)
      engine.start()
    else
      engine.stop()

showHelp = ->
  $('.overlay .help').show().siblings().hide()
  $('.overlay').fadeIn()

# start everything
$ ->
  # load prices
  updatePrices Object.keys(currencies)
  # set up overlay
  $('.overlay').on 'click', (e) ->
    if $('.overlay .help').is(':visible') # don't show help at the beginning after closing
      document.cookie = "nohelp=true; expires=#{new Date(Date.now()+1000*60*60*24*365).toString()}; path=/"
    $(this).fadeOut() if $(e.target).is('.overlay, .help')
  $('.overlay').hide() if !!document.cookie.match(/nohelp/) or !!location.hash.match(/nohelp/i)
  $('nav').hide() if !!location.hash.match(/nohelp/i)
  # initialize coins
  $('.currencies > div').each -> initialize $(@).attr 'class'
  # listen to resizing
  $(window).resize updateLanes
  # set up nav
  $ 'nav'
  .on 'click', '.help', showHelp
  .on 'click', '.right', ->
    $(".currencies").append($(".currencies > div").first())
    updateLanes()
  .on 'click', '.left', ->
    $(".currencies").prepend($(".currencies > div").last())
    updateLanes()
