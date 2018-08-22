--Creates a floating island with a randomly generated base.
--Set parameters--------------------------------------------------------------
matSize = 15
heightLim = 15

matSize = matSize - (1 - matSize % 2)

--Create matrix of random numbers---------------------------------------------
matR = {}
for first=1,matSize+2 do
	matR[first] = {}
	for second=1,matSize+2 do
		matR[first][second] = math.random(0,heightLim)
	end
end

--Smooth the previous one out
mat = {}
for first=1,matSize do
	mat[first]={}
	for second=1,matSize do
		mat[first][second] = 
			math.floor(
			(matR[first][second] * 0.5) +
			(matR[first][second+1] * 0.5) +
			(matR[first][second+2] * 0.5) +
			(matR[first+1][second] * 0.5) +
			matR[first+1][second+1] +
			(matR[first+1][second+2] * 0.5) +
			(matR[first+2][second] * 0.5) +
			(matR[first+2][second+1] * 0.5) +
			(matR[first+2][second+2] * 0.5)
			) / 5
	end
end

matR = nil --Delete the obsolete random matrix

--Function to place a block
slotNo = 1
turtle.select(1)
function place()
	if slotNo > 15 then
		slotNo = 1
	end
	while not turtle.compareTo(16) and slotNo < 15 do
		slotNo = slotNo + 1
		turtle.select(slotNo)
	end
	while turtle.getItemCount(slotNo) == 0 do --If there's nothing to use, wait.
		sleep(1)
		slotNo = 1
		turtle.select(slotNo)
	end
	turtle.placeUp()
end

--Function to complete a full layer of blocks
function blocks(height)
	turn = true
	--Do each line
	for i=1,matSize - 1 do
		for j=1,matSize - 1 do
			if turn then
				for k=1,mat[i][j] do
					place()
					turtle.down()
				end
				turtle.forward()
				for k=1,mat[i][j] do
					turtle.up()
				end
			else
				for k=1,mat[i][j] do
					place()
					turtle.down()
				end
				turtle.forward()
				for k=1,mat[i][j] do
					turtle.up()
				end
			end
		end
		--Turn for the next line
		if turn then
			for k = 1,mat[i][matSize] do
				place()
				turtle.down()
			end
			turtle.turnLeft()
			turtle.forward()
			turtle.turnLeft()
			for k = 1,mat[i][matSize] do
				turtle.up()
			end
		else
			for k = 1,mat[i][1] do
				place()
				turtle.down()
			end
			turtle.turnRight()
			turtle.forward()
			turtle.turnRight()
			for k = 1,mat[i][1] do
				turtle.up()
			end
		end
		turn = not turn
	end
	--Do the final line
	for i=1,matSize - 1 do
		for j=1,mat[matSize][matSize - i] do
			place()
			turtle.down()
		end
		turtle.forward()
		for j=1,mat[matSize][matSize - i] do
			turtle.up()
		end
	end
	place()
	--Return to start position.
	turtle.turnLeft()
	turtle.turnLeft()
	for i=1,matSize-1 do
		turtle.forward()
	end
	turtle.turnLeft()
	for i=1,matSize-1 do
		turtle.forward()
	end
	turtle.turnLeft()
	turtle.down()
end

--Run the functions in the correct manner
blocks()
