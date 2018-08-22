--Clears out an underground area in lines
--Set parameters--------------------------------------------------------------
rightFirst = true
lineDepth = 50
nLines = 50
spacing = 0

--Define functions------------------------------------------------------------
function check()
    while turtle.detect() or turtle.detectUp() or turtle.detectDown() do
        if turtle.detectUp() then
            turtle.digUp()
            sleep(0.3)
        end
        if turtle.detect() then
            turtle.dig()
            sleep(0.3)
        end
        if turtle.detectDown() then
            turtle.digDown()
        end
    end
end

function line(x)
    for i = 1, x do
        check()
        while not turtle.forward() do
            turtle.dig()
            torchCount = torchCount + 1
            if torchCount % 13 == 0 then
                if turtle.getItemCount() > 2 then
                    turtle.placeDown()
                end
                torchCount = 1
            end
        end
        check()
    end
end

function turnV()
    if rightFirst then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
end

--Carry out the functions-----------------------------------------------------
torchCount = 1
for j = 1, nLines do
    line(lineDepth)
    turnV()
    line(spacing + 1)
    turnV()
end
