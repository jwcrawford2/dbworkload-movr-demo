# dbworkload-movr-demo

## Description
This demo is an adaptation of demo assets around the Cockroach MOVR app demo, including J4's Multi-Region Demo [crdb-movr-mr-demo](https://github.com/sheaffej/crdb-movr-mr-demo) which utilizes cockroach workload movr on a roachprod cluster.  This demo replaces cockroach workload with  **dbworkload** to drive the load.  This demo adaptation/example is for a self-hosted cluster deployment on AWS using Ron Nollen's Terraform scripts.  It is designed to run on the App VM, which can be optioinally deployed, in both the single-region or multi-region terraform scripts (which now include the MOVR app).

## CRDB Cluster Environments
### Single Region (AWS)
- 1 regions: us-east2
- 3 Nodes
- [movr_db.sql](movr_db.sql) to create single-region database
  - *NOTE: This file also loads seed data for demo.  Will look to add dbworkload data generation in later release.*

### Multi-Region (AWS)
or Multi-Region Database with 
- 3 regions: us-east1, us-east2, us-west2
- 3 Nodes in each Region
- [movr_db_mr.sql](movr_db_mr.sql) 
  - *NOTE: This file also loads seed data for demo.  Will look to add dbworkload data generation in later release.*

## Pre-Demo Setups

### Install DbWorkload on App Server (crdb-app-0,1,2, etc)
Perform these steps on each App Node VM in your cluster.   

#### Required Python3 Setups for AWS EC2 Linux2  
```
sudo yum install gcc -y
sudo amazon-linux-extras install python3.8
sudo pip3.8 install -U pip
pip3 install psycopg[binary]
```
#### Install dbworkload
```
pip3 install dbworkload[postgres]
```
## Prepare Data 
In this initial demo version, data is generated using the cockroach workload movr utility.

# Demo 
## Start dbworkload on App Node (Primary App Node if MR)
SSH Terminal to App Node VM and run command (will need to replace CRDB Connectino URI - whcih uses CRDB alias in the .bashrc file) 
(Example USEast:
```
cd workloads
dbworkload run \
-w movr.py \
-c 4 \
--uri $(envsubst <<< $(type CRDB | grep cockroach-sql | awk '{print $4}' | sed 's/defaultdb/movr_demo/1')| sed "s/\"//g")

```
##

Central:
```
cd workloads
dbworkload run \
-w movr.py \
-c 4 \
--uri $(envsubst <<< $(type CRDB | grep cockroach-sql | awk '{print $4}' | sed 's/defaultdb/movr_demo/1')| sed "s/\"//g")
```
West:
```
cd workloads
dbworkload run \
-w movr.py \
-c 4 \
--uri $(envsubst <<< $(type CRDB | grep cockroach-sql | awk '{print $4}' | sed 's/defaultdb/movr_demo/1')| sed "s/\"//g")
```

# Show Terminals for Each Region
```
(instructions)
```

# Discuss Latencies
```
(instructions)
```

# Prepare for Region Failure
```
(add steps for script to stop West CRDB Nodes)


```

# 
```


