######################
#### R part of AI ####
######################

###################
# 0 R Preparation #
###################

# 0.1 Load libraries
suppressMessages(library(dplyr))
suppressMessages(library(xgboost))
suppressMessages(library(magrittr))

# 0.2 Custom functions
# 0.2.1 function to predict for each action
mat_create = function(h, v){ 
	data.train  = df.Game_Decision %>% mutate(actionh = h, actionv = v) %>% {.[,varlist]} %>% as.matrix()
	mode(data.train) = 'numeric'
	return(xgb.DMatrix(data = data.train))
}

# 0.3 Assign fixed variables
revert = FALSE
varlist = c('ypos', 'xspeed', 'angle', 'status', 'to_run', 'lane', 'slant_timer', 'futurepos0', 'futurepos1', 'futurepos2', 'futurepos3', 'actionh', 'actionv')













###############
# 1 Read data #
###############

# 1.1 Read values from lua
game = 			as.numeric(commandArgs(trailingOnly=TRUE)[1])
frame = 		as.numeric(commandArgs(trailingOnly=TRUE)[2])
totalresult = 	as.numeric(commandArgs(trailingOnly=TRUE)[3])

# 1.2 Read current run results
df.Game_Decision = read.csv("C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\Game Decision.tsv", sep = "\t", fill = TRUE)



	
	
	
	
	
	
	
#################################
# 2 Transform data for training #
#################################
	
# 2.1 If it is the first simulation
if(game == 1) {

	# 2.1.1 Set reward function
	df.Game_Decision2 = 
		df.Game_Decision %>% 
		group_by(game) %>% 
		mutate(
			reward = lead(xpos) - xpos, # Target variable is the distance travelled in the four next frames
			response = reward
		) %>%
		filter(!is.na(reward))
		
	# 2.1.2 Initialize empty data frame for global results
	pastxgb = data.frame()
	
# 2.2 If it is NOT the first simulation
}else{

	# 2.2.1 Read results from previous simulations
	pastxgb = read.csv("C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\xgbresults.csv")
	
	# 2.2.2 Read target model
	target_xgb <- xgb.load('C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\target_xgb.model')
	
	# 2.2.3 If results are worse, revert to target model, else load current model
	if(game %% 5 == 0 & game > 40 & frame > (pastxgb %>% filter(game %% 5 == 0 & revert == FALSE) %>% pull(frame) %>% median()) ){ # If deterministic results are worst than median after 40 simulations, revert to target model
		xgb <- xgb.load('C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\target_xgb.model')
		revert = TRUE
	} else {
		xgb <- xgb.load('C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\xgb.model')
	}
	
	# 2.2.4 Corrected Data
	df.Game_Decision2 = df.Game_Decision
	
	
	# 2.2.5 Evaluate function for each button pressed
	Q1 = predict(xgb, newdata = mat_create(-1,-1)) 	
	Q2 = predict(xgb, newdata = mat_create(-1,0)) 	
	Q3 = predict(xgb, newdata = mat_create(-1,1)) 	
	Q4 = predict(xgb, newdata = mat_create(0,-1)) 	
	Q5 = predict(xgb, newdata = mat_create(0,0)) 	
	Q6 = predict(xgb, newdata = mat_create(0,1)) 	
	Q7 = predict(xgb, newdata = mat_create(1,-1)) 	
	Q8 = predict(xgb, newdata = mat_create(1,0)) 	
	Q9 = predict(xgb, newdata = mat_create(1,1)) 	

	# 2.2.6 Choose randomly one of the action that had the best results
	rand_action = 
		cbind(Q1,Q2,Q3,Q4,Q5,Q6,Q7,Q8,Q9) %>%
		apply(1, function(x) {which(x == max(x)) %>% sample(1)})

	# 2.2.7 Put the chosen action in a data frame to compute the reward
	data.train  = 
		as.matrix(
			df.Game_Decision2 %>% 
			mutate(
				actionh = ifelse(rand_action %in% 1:3, -1, ifelse(rand_action %in% 4:6, 0, 1)),
				actionv = ifelse(rand_action %in% c(1, 4, 7), -1, ifelse(rand_action %in% c(2, 5, 8), 0, 1))
			) %>% 
			{.[,varlist]})
	mode(data.train) = 'numeric'
	xgb_mat.train = xgb.DMatrix(data = data.train)
	df.Game_Decision2$Q = predict(target_xgb, newdata =  xgb_mat.train) 
	
	# 2.2.7 Update response variable in the original data frame
	df.Game_Decision2 = 
		df.Game_Decision2 %>% 
		group_by(game) %>% 
		mutate(
			reward = lead(xpos) - xpos,
			response = reward + 0.95 * lead(Q)
		) %>%
		filter(!is.na(response))
}

# 2.3 Put training data into XGBoost's data format
data.train  = as.matrix(df.Game_Decision2 [,varlist])
mode(data.train) = 'numeric'
xgb_mat.train = xgb.DMatrix(data = data.train, label = as.numeric(df.Game_Decision2$response))














##################
# 3 Update model #
##################

# 3.1 If first game, generate model
if(game == 1) {
	xgb = xgb.train(data = xgb_mat.train, nrounds = 1, watchlist = list(train=xgb_mat.train), params = list(max_depth = 3, eta = 0.1, nthread = 2, base_score = 0, colsample_bytree = 1/2))
}else{
	if(revert == TRUE){
# 3.2 If not first game and results are bad, revert to target model
		xgb = xgb.train(data = xgb_mat.train, nrounds = 1, watchlist = list(train=xgb_mat.train), params = list(max_depth = 3, eta = 0.1, nthread = 2, base_score = 0, colsample_bytree = 1/2), xgb_model = "C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\target_xgb.model")
	}else{
# 3.3 Else, update model
		xgb = xgb.train(data = xgb_mat.train, nrounds = 1, watchlist = list(train=xgb_mat.train), params = list(max_depth = 3, eta = 0.1, nthread = 2, base_score = 0, colsample_bytree = 1/2), xgb_model = "C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\xgb.model")
	}
}

####################
# 4 Output Results #
####################

# 4.1 Convert the simulation's results and model's results to a data frame
xgb.imp = xgb.importance(feature_names = varlist, model = xgb)
pastxgb = 
	t(xgb.imp$Gain) %>%
	as.data.frame() %>%
 	set_colnames(xgb.imp$Feature) %>%
	mutate(game = game, frame = frame, totalresult = totalresult, niter = xgb$niter, err = rev(xgb$evaluation_log$train_rmse)[1], revert = revert) %>%
	bind_rows(pastxgb)
write.csv(pastxgb, "C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\xgbresults.csv",row.names = FALSE)
if(game %% 5 == 0 & revert == FALSE){ xgb.save(xgb, 'C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\target_xgb.model')}


# 4.2 Save XGBoost model into file
xgb.save(xgb, 'C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\xgb.model')

# 4.3 Transform XGBoost's model so that Lua can Understand
boost_index = which(substring(xgb.dd, 1, 7) == 'booster')
var_action = which(varlist %in% c('actionh', 'actionv')) - 1


if(game == 1){
	boost_index = c(1, length(xgb.dd)+1)
	b2 = 1
}else{
	boost_index = c(which(substring(xgb.dd, 1, 7) == 'booster'), length(xgb.dd)+1)	
	b2 = boost_index %>% {length(.)-1} %>% seq()
}

xx = 
	b2 %>%
	sapply(function(x) {
		subset = xgb.dd[boost_index[x]:(boost_index[x+1]-1)]
		
		if(paste0('^[0-9]+:\\[f(', paste0(var_action, collapse = ')|('), ')[<>=]') %>% grepl(subset) %>% sum > 0){
			df = 
				data.frame(
					jj = sub('([0-9]+):.*', '\\1', subset[-1]) %>% as.numeric(),
					feat =  gsub('.*\\[f([0-9]+).*', '\\1', subset[-1]),
					comp = gsub('.*\\[.*?([<>=]).*\\].*', '\\1', subset[-1]),
					spl = gsub('.*?([0-9\\.]+)\\].*', '\\1', subset[-1]),
					yes = gsub('.*?yes=([0-9]+),.*', '\\1', subset[-1]) %>% as.numeric(),
					no = gsub('.*?no=([0-9]+),.*', '\\1', subset[-1]) %>% as.numeric(),
					leaf = gsub('.*?leaf=([-0-9.]+)', '\\1', subset[-1])
				)
			parents = df %>% filter(feat %in% var_action) %>% pull(jj)

			while(!(0 %in% parents)){
				parents = c(parents, df %>% filter(yes %in% parents | no %in% parents) %>% pull(jj)) %>% unique()
			}
			
			children = c(df %>% filter(feat %in% var_action) %>% pull(yes), df %>% filter(feat %in% var_action) %>% pull(no))
			children_new = NULL
			while(length(children_new) != length(children)){
				children = 
					c(
						children, 
						df %>% filter(jj %in% children) %>% pull(yes),
						df %>% filter(jj %in% children) %>% pull(no)
					) %>% 
					unique()
				children_new = children
			}
			
			df2 = df %>% filter(jj %in% parents | jj %in% children)
			
			df2 %>% 
			summarise(
				array = 
					paste0(
						ifelse(
							!is.na(yes),
							paste0('[', jj, ']={f=', feat, ',c="', comp, '",s=', spl, ',y=', yes, ',n=', no, '}'),
							paste0('[', jj, ']={l=', leaf, '}')
						),
						collapse = ','
					)
			) %>%
			pull(array)
		}else{
			''
		}
	}) %>%
	.[.!='']

zz = 
	xx %>%
	{paste0('[', seq(length(.)), ']={', ., '}')} %>%
	paste0(collapse = ',') %>%
	paste0('xgb={', ., '}')
	
if(zz == 'xgb={[1]={},[0]={}}'){
	zz = 'xgb={}'
}

write(zz, file = "C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\xgbdumpwow")

