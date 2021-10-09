# Load required packages
library(tidyverse)
library(lubridate)
library(hms)

# Read the steps data and clean it as needed
minute_steps <- read_csv("minuteStepsNarrow_merged.csv")
head(minute_steps)

minute_steps$date_time <- as.POSIXct(minute_steps$ActivityMinute, format="%m/%d/%Y %I:%M:%S %p", tz=Sys.timezone())
minute_steps$time <- as_hms(minute_steps$date_time)
minute_steps$Individual_ID <- factor(minute_steps$Id)

# Summarize average steps per minute for plotting and analysis
average_steps <- minute_steps %>% group_by(Individual_ID, time) %>% summarise(mean_steps = mean(Steps))

# Plot the average steps per minute for 3 random individuals.
set.seed(42)
ggplot(subset(average_steps,Individual_ID %in% sample(unique(average_steps$Individual_ID),size = 3)), aes(x = time, y = mean_steps, group = Individual_ID)) + 
  xlab("Time of the day") + ylab("Average steps per minute") + ggtitle("Activity during the day (Steps)") +
  scale_color_manual(values=c("#E69F00", "#56B4E9", "#009E73")) +
  geom_line(aes(color = Individual_ID), size = 0.4) + stat_smooth(aes(color = Individual_ID), method = "loess") +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(colour = "black", size=1),
        legend.direction = 'vertical', 
        legend.position = c(.2,.8),
        legend.background = element_rect(colour = 'black', size = 0.4),
        legend.title = element_text(size=11),
        legend.text=element_text(size=11),
        plot.title = element_text(size=18, hjust = .5),
        axis.text.x = element_text(size=14),
        axis.text.y = element_text(size=14),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16))


# Read intensity data and clean as needed
minute_intensity <- read_csv("minuteIntensitiesNarrow_merged.csv")
head(minute_intensity)

minute_intensity$date_time <- as.POSIXct(minute_intensity$ActivityMinute, format="%m/%d/%Y %I:%M:%S %p", tz=Sys.timezone())
minute_intensity$time <- as_hms(minute_intensity$date_time)
minute_intensity$Individual_ID <- factor(minute_intensity$Id)

# Summarize average intensity per minute for plotting and analysis

average_intensity <- minute_intensity %>% group_by(Individual_ID, time) %>% summarise(mean_intensity = mean(Intensity))

set.seed(44)
ggplot(subset(average_intensity,Individual_ID %in% sample(unique(average_intensity$Individual_ID),size = 3)), aes(x = time, y = mean_intensity, group = Individual_ID)) + 
  xlab("Time of the day") + ylab("Average intensity per minute") + ggtitle("Activity during the day (Intensity)") +
  scale_color_manual(values=c("#E69F00", "#56B4E9", "#009E73")) +
  geom_line(aes(color = Individual_ID), size = 0.4) + stat_smooth(aes(color = Individual_ID), method = "loess") +
  theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(colour = "black", size=1),
        legend.direction = 'vertical', 
        legend.position = c(.2,.8),
        legend.background = element_rect(colour = 'black', size = 0.4),
        legend.title = element_text(size=11),
        legend.text=element_text(size=11),
        plot.title = element_text(size=18, hjust = .5),
        axis.text.x = element_text(size=14),
        axis.text.y = element_text(size=14),
        axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16))


## Time series clustering using the Dynamic Time Warping algorithm
library(dtwclust)

# Prepare data by converting in wide form to be used in tsclust() function

average_steps_wide <-
  average_steps %>% 
  spread(time, mean_steps)

# Convert the ID column to rownames

average_steps_wide <- 
  average_steps_wide %>% 
  remove_rownames %>% 
  column_to_rownames("Individual_ID")

# Perform k-medoids clustering using Partition around medoids (PAM). Using 6 clusters for this example.
Time_series_clusters <- tsclust(average_steps_wide, type="partitional", k=6L, distance="dtw", clustering="pam")

# Plot the time series results of the clusters.
plot(Time_series_clusters, type = "sc")

# Plot one particular cluster.
plot(Time_series_clusters, type = "sc", clus = 4L)

# Perform hierarchical clustering with 6 clusters.

Time_series_hierearchical_clusters <- tsclust(average_steps_wide, type = "h", k = 6L, distance = "dtw")

# Plot the dendrogram of the individuals clustered
plot(Time_series_hierearchical_clusters)

# Individuals in clusters
cutree(Time_series_hierearchical_clusters, k=6L)

# Combine different data sources for future work
# Read heartrate data
heartrate <- read_csv("heartrate_seconds_merged.csv")

heartrate$date_time <- as.POSIXct(heartrate$Time, format="%m/%d/%Y %I:%M:%S %p", tz=Sys.timezone())

# Join steps and intensity 
new <- minute_steps %>% full_join(minute_intensity, by = c("Id", "date_time"))

# Join heartrate to the previous data frame
new1 <- new %>% left_join(heartrate, by = c("Id", "date_time"))

head(new1)

##########

activity <- read_csv("dailyActivity_merged.csv")
names(activity)
activity_new <- activity %>% select(!c("ActivityDate", "TrackerDistance", "LoggedActivitiesDistance",
                                       "Calories"))
clust_data <- activity_new %>% select(!"Id") %>% filter(complete.cases(.))

# create distance (raw and standardized)
distraw <- dist(clust_data)
diststd <- dist(scale(clust_data))

# look at distances
dim(as.matrix(distraw))
dim(as.matrix(diststd))
as.matrix(distraw)[1:4,1:4]
as.matrix(diststd)[1:4,1:4]

# hierarchical clustering (raw data)
hcrawSL <- hclust(distraw, method="single")
hcrawCL <- hclust(distraw, method="complete")
hcrawAL <- hclust(distraw, method="average")

par(mfrow=c(1,3))
plot(hcrawSL)
plot(hcrawCL)
plot(hcrawAL)


library("dendextend")
dendro <- as.dendrogram(hcrawCL)
dendro.col <- dendro %>%
  set("branches_k_color", k = 4, value =   c("darkslategray", "darkslategray4", "darkslategray3", "gold3")) %>%
  set("branches_lwd", 0.6) %>%
  set("labels_colors", 
      value = c("darkslategray")) %>% 
  set("labels_cex", 0.5)

ggd1 <- as.ggdend(dendro.col)

ggplot(ggd1, theme = theme_minimal()) +
  labs(x = "Num. observations", y = "Height", title = "Dendrogram, k = 7")

