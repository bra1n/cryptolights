class CanvasRenderer
  constructor: (@c) ->
    @ctx = @c.getContext '2d'
    @resize @c
    @minFps = 45
    @particleMax = 150
    @meteorMax = 100
    @meteors = []
    @blocks = []
    @particles = []
    @running = no
    @lastDraw = Date.now()
    @c.addEventListener 'click', @handleClick.bind(@)
    @render()

  start: -> @running = yes

  stop: -> @running = no

  resize: (@c) ->
    @cw = @c.width = @c.scrollWidth
    @ch = @c.height = @c.scrollHeight
    @ctx.lineCap = 'round'

  rand: (a,b) -> ~~((Math.random()*(b-a+1))+a)

  addBlock: (thickness) ->
    return if @blocks.length >= 5 or not @running
    @blocks.push
      y: -50
      speed: 5
      hue: 190
      alpha: .5
      thickness: Math.round(thickness)
      
  updateBlocks: ->
    i = @blocks.length
    while i--
      block = @blocks[i]
      block.y = Math.round(block.y + block.speed)
      block.alpha = Math.max(0, 1-(4*block.y/@ch-3))/2 if block.y / @ch > 0.75
      @blocks.splice(i, 1) if block.y > @ch

  renderBlocks: ->
    i = @blocks.length
    while i--
      block = @blocks[i]
      @ctx.beginPath()
      @ctx.moveTo(20, block.y)
      @ctx.lineTo(@cw-20, block.y)
      @ctx.lineWidth = block.thickness
      @ctx.strokeStyle = 'hsla('+block.hue+', 80%, 50%, '+block.alpha+')'
      @ctx.stroke()
      @ctx.closePath()
      @ctx.restore()

  createBlockParticles: ->
    i = @blocks.length
    while i--
      block = @blocks[i]
      @particles.push
        x: Math.round(@rand(20, @cw-20))
        y: block.y - 10
        vx: (@rand(0, 100)-50)/100
        vy: (@rand(-50, 50)-50)/100
        radius: Math.round(@rand(2, 6)/2)
        alpha: @rand(50, 75)/100
        hue: block.hue
        light: 50

  handleClick: ({pageX, pageY}) ->
    cx = pageX - @c.getBoundingClientRect().left
    cy = pageY - @c.getBoundingClientRect().top
    for {x, y, thickness, link} in @meteors.reverse()
      t = thickness * 2
      if cx >= x-t and cx <= x+t and cy >= y-t and cy <= y+t
        window.open link
        break

  addMeteor: ({speed, hue, thickness, length, link, donation}) ->
    return if not @running
    return if (@meteors.length >= @meteorMax or @currentFps < @minFps) and !donation
    @meteors.push
      x: Math.round(@rand(thickness, @cw-thickness))
      y: -50
      vy: if donation then speed*0.8 else speed
      hue: Math.round(hue)
      thickness: if donation then Math.max(20, thickness*2) else thickness
      length: Math.max(length, 10)
      alpha: 1
      timestamp: new Date().getTime()
      link: link
      donation: donation
    @meteors.sort (a,b) -> a.thickness - b.thickness

  updateMeteor: (meteor) ->
    meteor.x = Math.round(@rand(meteor.thickness, @cw-meteor.thickness)) if meteor.x < meteor.thickness
    meteor.y = Math.round(meteor.y + meteor.vy)
    meteor.hue = meteor.hue + 3 % 360 if meteor.donation
    if meteor.y / @ch > 0.75
      meteor.alpha = Math.max(0, 1-(4*meteor.y/@ch-3))
      meteor.thickness -= 0.05 if meteor.thickness > 5

  renderMeteor: (meteor) ->
    @ctx.save()
    @ctx.globalAlpha = meteor.alpha
    @ctx.translate(meteor.x, meteor.y)
    @ctx.beginPath()
    @ctx.moveTo(0, 0)
    @ctx.lineTo(0, -meteor.length)
    @ctx.lineWidth = meteor.thickness
    gradient1 = @ctx.createLinearGradient(0, 0, 0, -meteor.length)
    gradient1.addColorStop(0, 'hsla('+meteor.hue+', 60%, 50%, .25)')
    gradient1.addColorStop(1, 'hsla('+meteor.hue+', 60%, 50%, 0)')
    @ctx.strokeStyle = gradient1
    @ctx.stroke()
    @ctx.closePath()
    @ctx.restore()

  renderMeteorBorder: (meteor) ->
    @ctx.save()
    @ctx.globalAlpha = meteor.alpha
    @ctx.translate(meteor.x, meteor.y)
    @ctx.beginPath()
    @ctx.moveTo(0, 0)
    @ctx.lineTo(0, -meteor.length)
    @ctx.lineWidth = Math.round(meteor.thickness / 5)
    gradient2 = @ctx.createLinearGradient(0, meteor.thickness, 0, -meteor.length)
    gradient2.addColorStop(0, 'hsla('+meteor.hue+', 100%, 50%, 0)')
    gradient2.addColorStop(.1, 'hsla('+meteor.hue+', 100%, 100%, .75)')
    gradient2.addColorStop(1, 'hsla('+meteor.hue+', 100%, 50%, 0)')
    @ctx.strokeStyle = gradient2
    @ctx.stroke()
    @ctx.closePath()
    @ctx.restore()

  renderMeteorFlare: (meteor) ->
    @ctx.save()
    @ctx.globalAlpha = meteor.alpha
    @ctx.translate(meteor.x, meteor.y + meteor.thickness*.5)
    @ctx.beginPath()
    @ctx.arc(0, 0, meteor.thickness, 0, Math.PI *2, false)
    gradient3 = @ctx.createRadialGradient(0, 0, 0, 0, 0, meteor.thickness)
    gradient3.addColorStop(0, 'hsla('+(meteor.hue + 30) % 360+', 100%, 50%, .2)')
    gradient3.addColorStop(1, 'hsla('+(meteor.hue + 30) % 360+', 50%, 50%, 0)')
    @ctx.fillStyle = gradient3
    @ctx.fill()
    @ctx.closePath()
    @ctx.restore()

  renderMeteorFlare2: (meteor) ->
    @ctx.save()
    @ctx.globalAlpha = meteor.alpha
    @ctx.translate(meteor.x, meteor.y)
    @ctx.scale(1,1.5)
    @ctx.beginPath()
    @ctx.arc(0, 0, meteor.thickness / 2, 0, Math.PI *2, false)
    gradient4 = @ctx.createRadialGradient(0, 0, 0, 0, 0, meteor.thickness / 2)
    gradient4.addColorStop(0, 'hsla('+(meteor.hue + 60) % 360+', 80%, 70%, .1)')
    gradient4.addColorStop(1, 'hsla('+(meteor.hue + 60) % 360+', 80%, 50%, 0)')
    @ctx.fillStyle = gradient4
    @ctx.fill()
    @ctx.closePath()
    @ctx.restore()

  createParticles: (meteor) ->
    if meteor.donation or (@particles.length < @particleMax - @meteors.length and meteor.thickness > 5)
      @particles.push
        x: meteor.x + (@rand(0, meteor.thickness) - meteor.thickness/2)
        y: meteor.y + (@rand(0, meteor.thickness) - meteor.thickness/2)
        vx: (@rand(0, 100)-50)/100
        vy: (@rand(-25, 75)-50)/100
        radius: if meteor.donation then meteor.thickness*0.2 else Math.round(@rand(1, 6)/2)
        alpha: if meteor.donation then 0.5 else @rand(15, 30)/100
        hue: meteor.hue
        light: if meteor.donation then 0 else 50

  updateParticles: () ->
    i = @particles.length
    while i--
      p = @particles[i]
      p.vx += (@rand(0, 100)-50)/300
      p.vy += (@rand(-25, 75)-50)/300
      p.x += p.vx
      p.y += p.vy
      p.light += 2
      p.alpha -= .01
      @particles.splice(i, 1) if p.alpha < .02

  renderParticles: () ->
    i = @particles.length
    while i--
      p = @particles[i]
      @ctx.beginPath()
      @ctx.fillStyle = 'hsla('+p.hue+', 100%, '+p.light+'%, '+p.alpha+')'
      @ctx.fillRect(Math.round(p.x), Math.round(p.y), p.radius, p.radius)
      @ctx.closePath()

  clear: () ->
    @ctx.globalCompositeOperation = 'destination-out'
    @ctx.fillStyle = 'rgba(0, 0, 0, 0.25)'
    @ctx.fillRect(0, 0, @cw, @ch)
    @ctx.globalCompositeOperation = 'lighter'

  render: () ->
    requestAnimationFrame @render.bind(@)
    return unless @running
    @currentFps = Math.round(1000/(Date.now() - @lastDraw))
    @lastDraw = Date.now()
    @clear()
    # debug
    #@ctx.font = '48px serif';
    #@ctx.fillStyle = 'rgba(255, 255, 255, 1)'
    #@ctx.fillText(@currentFps, 10, 50);
    # blocks
    @updateBlocks()
    @renderBlocks()
    @createBlockParticles()
    # meteors
    i = @meteors.length
    while i--
      meteor = @meteors[i]
      if new Date().getTime() - meteor.timestamp > 15*1000 or meteor.y - meteor.length > @ch
        @meteors.splice i, 1
        continue
      @updateMeteor(meteor)
      @renderMeteor(meteor)
      @renderMeteorBorder(meteor)
      @renderMeteorFlare(meteor)
      @renderMeteorFlare2(meteor)
      @createParticles(meteor)
    # meteor particles
    @updateParticles()
    @renderParticles()

