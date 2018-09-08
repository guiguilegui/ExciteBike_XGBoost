
library(data.table)
library(dplyr)
library(tidyr)
library(xgboost)
library(ggplot2)
library(gridExtra)
library(cowplot)

# xgb <- xgb.load('C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\xgb.model')
# xgb.importance(feature_names = c('ypos', 'angle', 'status', 'lane', 'futurepos0', 'futurepos1', 'futurepos2', 'futurepos3', 'action'), model = xgb)

for(i in 1:500){
df.Game_Decision = fread("C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\xgbresults.csv")



g1 = ggplot(df.Game_Decision) + 
	geom_hline(yintercept = 5408.14, size = 1.5, linetype = 'dashed', color = 'red')+
	geom_ribbon(aes(x = game), ymin = 4831.8, ymax = 6124.0, alpha = 0.05, fill = 'red')+
	geom_point(aes(x = game, y = 4*frame)) + 
	geom_smooth(aes(x = game, y = 4*frame), span = 1/4, alpha = 0) + 
	scale_x_continuous(expand = c(0, 0))+
	scale_y_continuous(expand = c(0, 0))+
	theme_bw() + 
	theme(
		axis.text.x = element_blank(),
		axis.title.x = element_blank(),
		axis.ticks.x = element_blank()
		
	)
	
g2 = ggplot(df.Game_Decision) + 
	geom_point(aes(x = game, y = err)) + 
	geom_smooth(aes(x = game, y = err)) + 
	theme_bw() + 
	theme(
		axis.text.x = element_blank(),
		axis.title.x = element_blank(),
		axis.ticks.x = element_blank()
		
	)
	
g3 = ggplot(df.Game_Decision %>% mutate(actionh = ifelse(is.na(actionh), 0, actionh))) + 
	geom_point(aes(x = game, y = actionh)) + 
	geom_smooth(aes(x = game, y = actionh)) + 
	theme_bw() + 
	theme(
		axis.text.x = element_blank(),
		axis.title.x = element_blank(),
		axis.ticks.x = element_blank()
		
	)

g4 = ggplot(df.Game_Decision %>% mutate(actionv = ifelse(is.na(actionv), 0, actionv))) + 
	geom_point(aes(x = game, y = actionv)) + 
	geom_smooth(aes(x = game, y = actionv)) + 
	theme_bw() + 
	theme(
		axis.text.x = element_blank(),
		axis.title.x = element_blank(),
		axis.ticks.x = element_blank()
		
	)
	
g5 = 
	ggplot(gather(df.Game_Decision, key = 'Feature', Gain, 1:13) %>% mutate(Gain = ifelse(is.na(Gain), 0, Gain))) + 
	geom_area(aes(x = game, y = Gain, fill = Feature)) + 
	theme_bw() + 
	theme(
		axis.text.x = element_blank(),
		axis.title.x = element_blank(),
		axis.ticks.x = element_blank(),
		legend.position=c(.8,.75)
	)
		
g6 = ggplot(df.Game_Decision) + 
	geom_point(aes(x = game, y = niter)) + 
	geom_smooth(aes(x = game, y = niter)) + 
	theme_bw()
	
	
print(plot_grid(g1, g2, g3, g4, g5, g6, align = 'v', nrow = 6, rel_heights  = c(1/6, 1/6, 1/6, 1/6, 1/6, 1/6)))
# print(plot_grid(g1, g2, g3, g4, align = 'v', nrow = 4, rel_heights  = c(2/6, 1/6, 1/6, 1/5)))
Sys.sleep(30)
}