gamePaused = false

gameObjects = {}
debug = false

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
  return object
end

function setTag(obj, tag)
  table.insert(obj.tags, tag)
end

function drawObjects()
  for key, value in ipairs(gameObjects) do
    drawSprite(value)
  end
end

function drawLines()
  local first = love.graphics.getWidth() * (1 / 3)
  local second = love.graphics.getWidth() * (2 / 3)
  local h = love.graphics.getHeight()
  love.graphics.setLineWidth(2)
  love.graphics.line(first, 0, first, h)
  love.graphics.line(second, 0, second, h)
end

function drawSprite(sprite)
  love.graphics.draw(sprite.image, sprite.x, sprite.y, math.rad(0), sprite.scale, sprite.scale)
  if debug then
    love.graphics.rectangle("line", sprite.x, sprite.y, sprite.width, sprite.height)
  end
end

function objectAt(x, y)
  for key, value in ipairs(gameObjects) do
    if collide(x, y, value) then
      return key
    end
  end
end

function updateObjects(dt)
  for key, value in ipairs(gameObjects) do
    value.x = value.x + value.speed * dt
  end
end

function outside(x)
  return x > love.graphics.getWidth() - 100
end

function checkObjects(x, y)
  for key, value in ipairs(gameObjects) do
    if outside(value.x) then
      table.remove(gameObjects, key)
    end
  end
end

function makeFish(x, y, speed)
  return makeSprite("fish", x, y, 0.4, speed)
end

function makeTrash(x, y, speed)
  return makeSprite("trash", x, y, 0.7, speed)
end

function love.load()
  background = makeSprite("background", 0, 0)
  hand = makeSprite("hand", 0, 0, 1.2)
  table.insert(gameObjects, makeFish(300, 300, 50))
  table.insert(gameObjects, makeTrash(200, 200, 50))
end

function love.draw()
  drawSprite(background)
  drawLines()
  drawObjects()
  drawSprite(hand)
end

function love.update(dt)
  if gameIsPaused then
    return
  end
  hand.x = love.mouse.getX() - (hand.width / 2)
  hand.y = love.mouse.getY() - (hand.height / 2)
  checkObjects()
  updateObjects(dt)
end

function love.mousepressed(x, y, button, istouch, presses)
  local k = objectAt(x, y)
  if k ~= nil then
    table.remove(gameObjects, k)
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
