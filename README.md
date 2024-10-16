# Multi-Region DbWorkload Demo

## Description
This is a demo is an adaptation of Multi-Region Demo, that utilizes cockroach workload (movr) and roachprod.  This demo is designed to utilize dbworkload to drive load from the App VM in the AWS-Terraform-CRDB-Multi-Region cluster.  This is for an AWS SH prospect that wants to see Multi-Region capabilities.

## Database
AWS SH Multi-Region Database with 
- 3 regions: us-east1, us-east2, us-west2
- 3 Nodes in each Region

[movr_db_mr.sql](movr_db_mr.sql) will create the database and the shema objects.

## Data
In this initial demo version, data is generated using the cockroach workload movr utility.

## Install DbWorkload on App Servers (crdb-app-0,1,2)
Perform these steps on each of the (AWS Linux2) app VM's in your cluster
### Python3 Setups
sudo yum install gcc -y
sudo amazon-linux-extras install python3.8
sudo pip3.8 install -U pip
pip3 install psycopg[binary]

#### Install dbworkload

pip3 install dbworkload[postgres]

### Generating and loading the data from scratch using dbworkload
- generate the yaml file
```
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


