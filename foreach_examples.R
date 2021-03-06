library(tidyverse)
library(foreach)
library(doParallel)


# Simple for loop
for(i in 1:100){
    print(sqrt(i))
}

# Do it sequentially using foreach
foreach(i=1:100) %do% {
    sqrt(i)
} # notice the result is in the list

# Do it parallel using foreach
## first register parallel backend
registerDoParallel(cores = 4) 

# WINDOWS
# clusters <-  makeCluster(4) (create 4 worker cluster)
# registerDoParallel(cl = clusters)

# Check if you have registered the parallel backend and
# also how many workers you have assigned.
foreach::getDoParRegistered()
foreach::getDoParWorkers()

foreach(i=1:100) %dopar% {
    sqrt(i)
}

# Generate 1000 by 1000 matrix
foreach(i=1:1000) %dopar% {
    rnorm(1000,mean = i, sd = sqrt(i))
} 
# but this is not in matrix, we have list of columns,
# so how do we combine these at once without looping through the result

# use .combine
mat <- foreach(i=1:1000, .combine = cbind) %dopar% {
    rnorm(1000,mean=i,sd=sqrt(i))
}
dim(mat)
class(mat)

# median of each column vector
medians <- foreach(col=iter(mat, by = "column"), .combine = "c") %dopar% {
    median(col)
}
medians

# calculate squre of sum of elements for every vector of which the index is multiple of 10, 
# but median for everything else?
res1 <- foreach(col=iter(mat, by = "column"), i=icount(), .combine = "c") %dopar% {
    if ( (i %% 10) == 0){
        sum(col)^2
    }
    else {
        median(col)
    }
}

# skip columns of which its median is less than 800, and calculate variance on those that meet the condition
res2 <- foreach(col=iter(mat, by = "column"), m=iter(medians), .combine = rbind) %:% when(m >= 800) %dopar% {
    c(var(col),m)
}
all(res2[,2] >= 800)

# nested foreach
system.time(foreach(a=(1:1000),.combine=cbind) %:%
    foreach(b=(1:100), .combine = c) %do% {
        rnorm(1,mean = a, sd = sqrt(b))
    })

registerDoParallel(cores = 7)
system.time(foreach(a=(1:1000),.combine=cbind) %:%
                foreach(b=(1:100), .combine = c) %dopar% {
                    rnorm(1,mean = a, sd = sqrt(b))
                })
                    













