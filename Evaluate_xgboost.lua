-----------------------------------------------------
---- Function to evaluate the trees from Xgboost ----
-----------------------------------------------------

xgb_predict = function()

	-- Initialize resulting amount --
	Sum_predict = 0
	
	-- Iterate through all trees --
	for round = 1, #xgb do
	
		-- Initialize current branch --
		j = 0
		leaf2 = true
		
		while leaf2 do
			
			-- test to select the correct branch of the tree --
			loadstring("test = " .. feats[xgb[round][j]["f"]+1] .. xgb[round][j]["c"].. xgb[round][j]["s"])()
			
			-- update branch --
			if test then
				j = xgb[round][j]["y"]
			else 
				j = xgb[round][j]["n"]
			end
			
			
			if xgb[round][j] == nil then -- if branch doesn't exist, stop looping --
				leaf2 = false
			elseif xgb[round][j].l ~= nil then  -- if branch only has prediction, stop looping --
				leaf2 = false
			end
		end
		
		-- if branch has prediction, add to results --
		if xgb[round][j] ~= nil then 
			Sum_predict = xgb[round][j].l + Sum_predict
		end
	end

	return Sum_predict
end
-- print(xgb_predict(ypos, angle, status, lane, futurepos0, futurepos1, futurepos2, futurepos3, action, xgb))
