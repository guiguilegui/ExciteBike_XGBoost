#############################################
#### Figure 3: Results - Baseline Random ####
#############################################

# Load libraries
library(data.table)
library(ggplot2)

# Read data
df.Game_Decision = fread("C:\\Users\\Guillaume\\Documents\\Nes\\Excitebike\\Baseline Results.tsv")

# Statistics
# mean(df.Game_Decision$result) * 4 / 60
# quantile(df.Game_Decision$result, c(0.05, 0.95)) * 4

# Plot graph
ggplot(df.Game_Decision) + # Data
	geom_jitter(aes(x = 1, y = result * 4), height = 0, width = 0.36, alpha = 0.5)+ # Points
	geom_boxplot(aes(x = 1, y = result * 4), outlier.alpha = 0, alpha = 0.7, fill = 'orange', size = 1) + # Boxplot
	theme_bw() + 
	scale_x_continuous(expand = c(0.01,0.01))+
	scale_y_continuous(expand = c(0.01,0.01), name = 'Number of frames', minor_breaks = seq(4000, 7000, 100))+
	theme(
		axis.text.x = element_blank(),
		axis.title.x = element_blank(),
		axis.ticks.x = element_blank(),
		panel.border = element_blank(),
		panel.grid.major.x = element_blank(),
		panel.grid.minor.x = element_blank(),
		panel.grid.major.y = element_line(linetype = 'dashed'),
		panel.grid.minor.y = element_line(linetype = 'dashed')
	)
	