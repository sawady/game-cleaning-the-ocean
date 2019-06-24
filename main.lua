gameOver = false
gamePaused = false
debug = false

gameObjects = {}
level = 1
points = 100
levelSpeed = 1
shouldCreate = 5
pointsAndObjects = 0
destroyingTimer = 0
levelTimer = 0
levelCountdown = 0

FISH_POINTS = -50
TRASH_POINTS = 10

function collide(x, y, object)
  return object.x <= x and x <= object.x + object.width and object.y <= y and y <= object.y + object.height
end

function makeSprite(path, x, y, scale, speed)
  local object = {}
  object.image = love.graphics.newImage("graphics/" .. path .. ".png")
  object.x = x
  object.y = y
  object.speed = speed
  if scale == nil then
    scale = 1
  end
  object.scale = scale
  object.width = object.image:getWidth() * scale
  object.height = object.image:getHeight() * scale
  object.tags = {}
  object.opacity = 1
  return object
end

function setTag(obj, tag)
  table.insert(obj.tags, tag)
end

function hasTag(obj, tag)
  for index, value in ipairs(obj.tags) do
    if value == tag then
      return true
    end
  end
  return false
end

function drawObjects()
  for key, value in ipairs(gameObjects) do
    if value.removing then
      drawRemoving(value)
    else
      drawSprite(value)
    end
  end
end

function drawObjectPoints(object)
  local text = object.points
  if object.points > 0 then
    text = "+" .. text
  else
    text = text
  end
  love.graphics.print(text, object.x + object.width - 25, object.y - 30 - 10 * object.opacity * 3 * -1)
end

function drawRemoving(object)
  love.graphics.setColor({1, 1, 1, object.opacity})
  drawSprite(object)
  love.graphics.setColor({1, 1, 1, 1})
  drawObjectPoints(object)
end

function drawSprite(sprite)
  love.graphics.draw(sprite.image, sprite.x, sprite.y, math.rad(0), sprite.scale, sprite.scale)
  if debug then
    love.graphics.rectangle("line", sprite.x, sprite.y, sprite.width, sprite.height)
  end
end

function objectAt(x, y)
  for key, value in ipairs(gameObjects) do
    if collide(x, y, value) and not value.removing then
      return key
    end
  end
end

function updateObjects(dt)
  for key, value in ipairs(gameObjects) do
    if not value.removing then
      value.x = value.x + value.speed * dt * level
    end
  end
end

function outside(x)
  return x > love.graphics.getWidth() - 100
end

function checkObjects(x, y)
  for key, value in ipairs(gameObjects) do
    if outside(value.x) then
      removePoints(key)
      table.remove(gameObjects, key)
    end
  end
end

function makeFish(x, y)
  local name = "fish" .. love.math.random(1, 3)
  local sprite = makeSprite(name, x, y, 0.4, math.min(50 * levelSpeed * love.math.random(1, 3), 80))
  sprite.points = FISH_POINTS
  table.insert(sprite.tags, "fish")
  return sprite
end

function makeTrash(x, y, speed)
  local name = "trash" .. love.math.random(1, 3)
  local s = math.min(50 * levelSpeed * love.math.random(1, 3), 80)
  local sprite = makeSprite(name, x, y, 0.7, s)
  sprite.points = TRASH_POINTS
  table.insert(sprite.tags, "trash")
  return sprite
end

function addPoints(key)
  points = points + gameObjects[key].points
end

function removePoints(key)
  if hasTag(gameObjects[key], "trash") then
    points = points - 10
  end
end

function timerPointsAndObject(dt)
  pointsAndObjects = pointsAndObjects + dt
  local timerSpeed = math.max(0.5 - (level * 0.01), 0.1)
  if pointsAndObjects > timerSpeed then
    pointsAndObjects = pointsAndObjects - timerSpeed
    points = points - 1
    addObject()
  end
end

function decrementOpacity()
  for key, value in ipairs(gameObjects) do
    if value.removing then
      value.opacity = value.opacity - 0.05
      if value.opacity <= 0 then
        table.remove(gameObjects, key)
      end
    end
  end
end

function timerdestroyingTimer(dt)
  destroyingTimer = destroyingTimer + dt
  if destroyingTimer > 0.01 then
    destroyingTimer = destroyingTimer - 0.01
    decrementOpacity()
  end
end

function passLevelTimer(dt)
  levelTimer = levelTimer + dt
  if levelTimer > 1 then
    levelTimer = levelTimer - 1
    levelCountdown = levelCountdown + 1
    if levelCountdown % 10 == 0 then
      level = level + 1
    end
  end
end

function addObject()
  local r = love.math.random(1, 100)
  local h = love.math.random(30, love.graphics.getHeight() - 100)
  if r <= 30 then
    table.insert(gameObjects, makeTrash(10, h))
  end
  if r >= 60 then
    table.insert(gameObjects, makeFish(10, h))
  end
end

function love.load()
  love.mouse.setVisible(false)
  background = makeSprite("background", 0, 0)
  font = love.graphics.newFont("graphics/animeace2_reg.ttf", 50)
  love.graphics.setFont(font)
  hand = makeSprite("hand", 0, 0, 1.2)
end

function drawGameOver()
  local text = "Game over"
  love.graphics.print(
    text,
    love.graphics.getWidth() / 2 - font:getWidth(text) / 2,
    love.graphics.getHeight() / 2 - font:getHeight(text) / 2
  )
end

function checkGameOver()
  if points <= 0 and not gameOver then
    gameOver = true
    points = 0
  end
end

function drawPoints()
  love.graphics.print("points " .. points, 10, 10)
end

function drawLevel()
  local text = "level " .. level
  local x = love.graphics.getWidth() - font:getWidth(text) - 10
  local y = 10
  love.graphics.print(text, x, y)
end

function love.draw()
  drawSprite(background)
  drawObjects()
  if gameOver then
    drawGameOver()
  end
  drawPoints()
  drawLevel()
  drawSprite(hand)
end

function updateBackground()
  local s = 0
  if level >= 10 then
    local d = love.math.random(0, 1)
    if d == 0 then
      d = -1
    end
    s = s + love.math.random(1, level - 10) * d
  end
  background.x = 0 + s
  background.y = 0 + s
end

function love.update(dt)
  checkGameOver()
  hand.x = love.mouse.getX() - (hand.width / 2)
  hand.y = love.mouse.getY() - (hand.height / 2)
  if gamePaused or gameOver then
    return
  end
  updateBackground()
  timerPointsAndObject(dt)
  timerdestroyingTimer(dt)
  passLevelTimer(dt)
  checkObjects()
  updateObjects(dt)
end

function love.mousepressed(x, y, button, istouch, presses)
  if gamePaused or gameOver then
    return
  end
  local k = objectAt(x, y)
  if k ~= nil then
    addPoints(k)
    gameObjects[k].removing = true
  end
end

function love.keypressed(k)
  if k == "escape" then
    love.event.quit()
  end
end

function love.focus(f)
  if not f then
    gamePaused = true
  else
    gamePaused = false
  end
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end
