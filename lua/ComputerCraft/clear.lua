--Clears and paves an area, leaving caves exposed
--Set parameters--------------------------------------------------------------
rightFirst = true
lineDepth = 50
nLines = 50

--Define functions------------------------------------------------------------
function overburden()
    i = 1
    while turtle.detectUp() do
        turtle.digUp()
        if turtle.up() then
            i = i + 1
        end
    end
    j = 1
    while j < i do
        if turtle.down() then
            j = j + 1
        end
    end
end

function forwards(x)
    while not turtle.forward() do
        turtle.dig()
    end
    turtle.digDown()
    turtle.down()
    cave = turtle.detectDown()
    while not turtle.up() do
        turtle.digUp()
    end
    if not cave then
        turtle.select(1)
        if turtle.getItemCount() > 2 then
            turtle.placeDown()
        else
            for j = 2, 16 do
                if turtle.compareTo(j) then
                    turtle.select(j)
                    turtle.placeDown()
                    break
                end
            end
        end
    end
end

function turnV()
    if rightFirst then
        turtle.turnRight()
    else
        turtle.turnLeft()
    end
end

--carry out code--------------------------------------------------------------
for rowI = 1, nLines do
    for lineI = 1, lineDepth do
        overburden()
        forwards()
        overburden()
    end
    turnV()
    forwards()
    turnV()
    rightFirst = not rightFirst
end
