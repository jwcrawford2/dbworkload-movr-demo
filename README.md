# dbworkload-movr-demo

## Description
This is a demo is an adaptation of Cockroach MOVR applicatino demo, including J4's Multi-Region Demo [crdb-movr-mr-demo](https://github.com/sheaffej/crdb-movr-mr-demo) which utilizes cockroach workload movr on a roachprod cluster.  This demo replaces cockroach workload with  **dbworkload** to drive the load.  This demo adaptation/example is for a self-hosted cluster deployment on AWS using Ron Nollen's Terraform scripts.   It is designed to run on the Applications VM, which can be optioinally deployed, in both the single-region or multi-region terraform scripts (which now include the MOVR app).

## Database
AWS SH Single or Multi-Region Database with 
- 3 regions: us-east1, us-east2, us-west2
- 3 Nodes in each Region

[movr_db_mr.sql](movr_db_mr.sql) will create the database and the shema objects.

## Data
In this initial demo version, data is generated using the cockroach workload movr utility.

## Install DbWorkload on App Server (crdb-app-0,1,2, etc)
Perform these steps on each of the (AWS Linux2) Appserver VM's in your cluster
### Required Python3 Setups for AWS EC2 Linux2  
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
### Generating and loading the data from scratch using dbworkload
--generate the yaml file
```
--generate the yaml file
dbworkload util yaml -i movr_db_sr.sql
```
- edit the yaml file
change application choice and apply 10 choices

- generate the csv
```
dbworkload util csv -i movr_db_sr.yaml
```

- for the local import run the python server in one session and run the import from another
```
python3 -m http.server -b 192.168.5.101 3000
```
```

```
# Demo
# Run dbworkload on an appserver in each region 
East:
```
dbworkload run -w movr.py -c 4 --uri "postgresql://chipdbuser@192.168.3.124:26257/movr_demo?sslmode=verify-full&sslrootcert=$HOME/certs/ca.crt&sslcert=$HOME/certs/client.chipdbuser.crt&sslkey=$HOME/certs/client.chipdbuser.key" 
```
Central:
```
dbworkload run -w movr.py -c 4 --uri "postgresql://chipdbuser@192.168.3.124:26257/movr_demo?sslmode=verify-full&sslrootcert=$HOME/certs/ca.crt&sslcert=$HOME/certs/client.chipdbuser.crt&sslkey=$HOME/certs/client.chipdbuser.key" 
```
West:
```
dbworkload run -w file_data.py --driver postgres --uri "postgresql://ron@192.168.7.100:26257/intuit_mr?sslmode=verify-full&sslrootcert=$HOME/certs/ca.crt&sslcert=$HOME/certs/client.ron.crt&sslkey=$HOME/certs/client.ron.key" -d 300
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


