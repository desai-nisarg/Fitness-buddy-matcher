# Fitness-buddy-matcher 

Motivation:
I aim to create a web application where people can find fitness buddies to work out with. As someone interested in improving my fitness who had issues with motivation, I would've appreciated having a buddy to work out with. However, every time I tried to work out with a friend, it never worked because either we were at very different fitness levels, or we worked out on different schedules. I found apps online to find fitness buddies but none of them matched people based on the factors I cared about. 

Data source:
I tried to find if any of the popular fitness tracker providers had an API where I could obtain anonymized data to train my matching model. However, given that these data are sensitive, it is difficult to get access to data other than your own personal data. Fortunately, I found a kaggle dataset from volunteers that shared their Fitbit tracker data. I use these data to train two different models. First, I use time series clustering using the Dynamic Time Warping algorithm on the time series data on steps, intensity, and heart rate. This should match people who are active at similar times of the day. As a night owl, I struggle to find people who want to work out at night. Second, I use hierarchical clustering on aggregated activity data. This should match people of similar activity levels over the day with the goal of matching people with similar fitness levels and similar preferences for the kinds of activities. If two people are at different fitness levels or if they prefer different activities, it may be difficult to stay buddies who work out together. 

Expected output:
The project should result in a webpage where one could login with their Fitbit account and share their Fitbit data via Fitbit's API (or upload downloaded data from their fitness tracker). The clustering algorithms should cluster similar people together and recommend them.
 
