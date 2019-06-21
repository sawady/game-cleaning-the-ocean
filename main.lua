gamePaused = false

fishes = {}
trashes = {}

function makeSprite(path, x, y, scale, speed)
  local object = {}
  object.image = love.graphics.newImage("graphics/" .. path .. ".png")
  object.x = x
  object.y = y
  object.speed = speed
  object.width = object.image:getWidth()
  object.height = object.image:getHeight()
  object.scale = scale
  return object
end

function drawFishes()
  for key, value in ipairs(fishes) do
    drawSprite(value)
  end
end

function drawTrashes()
  for key, value in ipairs(trashes) do
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
end

function updateObjects(objects, dt)
  for key, value in ipairs(objects) do
    value.x = value.x + value.speed * dt
  end
end

function checkObjects(objects)
  for key, value in ipairs(objects) do
    if (value.x > love.graphics.getWidth() - 100) then
      table.remove(objects, key)
    end
  end
end

function love.load()
  background = makeSprite("background", 0, 0)
  hand = makeSprite("hand", 0, 0, 1.2)
  table.insert(fishes, makeSprite("fish", 300, 300, 0.5, 150))
  table.insert(trashes, makeSprite("trash", 200, 200, 0.7, 150))
end

function love.draw()
  drawSprite(background)
  drawLines()
  drawFishes()
  drawTrashes()
  drawSprite(hand)
end

function love.update(dt)
  if gameIsPaused then
    return
  end
  hand.x = love.mouse.getX() - (hand.width / 2)
  hand.y = love.mouse.getY() - (hand.height / 2)
  checkObjects(fishes, dt)
  checkObjects(trashes, dt)
  updateObjects(fishes, dt)
  updateObjects(trashes, dt)
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
