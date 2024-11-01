#!/usr/bin/bash -i
#
#Run dbworkload
#
dbworkload run \
-w movr.py \
-c 4 \
--uri $(envsubst <<< $(type CRDB | grep cockroach-sql | awk '{print $4}' | sed 's/defaultdb/movr_demo/1')| sed "s/\"//g")

