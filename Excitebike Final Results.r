################################
#### Figure 4: Results - AI ####
################################

# Load libraries
library(data.table)
library(ggplot2)

# Read data
df.Game_Decision = fread("C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\xgbresults.csv")

# Plot Graphic
ggplot(df.Game_Decision) + # Data
	geom_hline(yintercept = 5408.14, size = 1.1, linetype = 'dashed', color = 'orange')+ # Baseline Results
	geom_ribbon(aes(x = game), ymin = 4831.8, ymax = 6124.0, alpha = 0.05, fill = 'orange')+ # Baseline 90% range
	geom_point(aes(x = game, y = 4*frame), color = '#4B8100') + # Points
	geom_smooth(aes(x = game, y = 4*frame), span = 1/4, alpha = 0, color = '#80d010', size = 1.1) + # Smoothing
	scale_x_continuous(expand = c(0.01, 0.01), name = 'Iteration') + 
	scale_y_continuous(expand = c(0.01, 0.01), name = 'Number of frames') +
	theme_bw()+
	theme(
		panel.border = element_blank(),
		panel.grid = element_line(linetype = 'dashed')
	)
	