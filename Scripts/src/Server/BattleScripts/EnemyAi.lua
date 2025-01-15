
local enemyAi = {}

local moveTable = {"Slash", "FireBall"}

local function dealDamage(player,number)
	player.Health = player.Health - number
end

function enemyAi.ez (player)
	wait(2)
	local randomMove = moveTable[math.random(1,#moveTable)]
	print(randomMove)
	if randomMove == "Slash" then 
		dealDamage(player,10)
	elseif randomMove == "FireBall" then
		dealDamage(player,20)
	end
	
	
	
end

function enemyAi.mid(player)
	wait(2)
end

function enemyAi.hard(player)
	wait(2)
end

function enemyAi.boss(player)
	wait(2)
	
end

return enemyAi
