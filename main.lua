local gridSize = 8
local windowWidth, windowHeight = 640, 480
local cellWidth, cellHeight = windowWidth / gridSize, windowHeight / gridSize
local grid = {}
local revealed = {}
local firstSelection = nil
local secondSelection = nil
local wait = false
local waitTime = 0.5
local waitTimer = 0

function love.load()
    love.window.setTitle("shift")
    love.window.setMode(windowWidth, windowHeight)
    math.randomseed(os.time())

    local numbers = {}
    for i = 1, (gridSize * gridSize) / 2 do
        numbers[#numbers + 1] = i
        numbers[#numbers + 1] = i
    end

    for i = #numbers, 2, -1 do
        local j = math.random(i)
        numbers[i], numbers[j] = numbers[j], numbers[i]
    end

    local index = 1
    for y = 1, gridSize do
        grid[y] = {}
        revealed[y] = {}
        for x = 1, gridSize do
            grid[y][x] = numbers[index]
            revealed[y][x] = false
            index = index + 1
        end
    end
end

function love.update(dt)
    if wait then
        waitTimer = waitTimer + dt
        if waitTimer >= waitTime then
            wait = false
            waitTimer = 0
            if grid[firstSelection.y][firstSelection.x] ~= grid[secondSelection.y][secondSelection.x] then
                revealed[firstSelection.y][firstSelection.x] = false
                revealed[secondSelection.y][secondSelection.x] = false
            end
            firstSelection = nil
            secondSelection = nil
        end
    end
end

function love.draw()
    for y = 1, gridSize do
        for x = 1, gridSize do
            local xPos, yPos = (x - 1) * cellWidth, (y - 1) * cellHeight

            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", xPos, yPos, cellWidth, cellHeight)

            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", xPos, yPos, cellWidth, cellHeight)

            if revealed[y][x] or (firstSelection and firstSelection.x == x and firstSelection.y == y) or (secondSelection and secondSelection.x == x and secondSelection.y == y) then
                love.graphics.setColor(0, 0, 0)
                love.graphics.printf(grid[y][x], xPos, yPos + cellHeight / 2 - 10, cellWidth, "center")
            end
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 and not wait then
        local gridX, gridY = math.floor(x / cellWidth) + 1, math.floor(y / cellHeight) + 1

        if not revealed[gridY][gridX] then
            if not firstSelection then
                firstSelection = { x = gridX, y = gridY }
                revealed[gridY][gridX] = true
            elseif not secondSelection and (gridX ~= firstSelection.x or gridY ~= firstSelection.y) then
                secondSelection = { x = gridX, y = gridY }
                revealed[gridY][gridX] = true
                wait = true
            end
        end
    end
end

