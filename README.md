# Intuit Multi-Region Demo

## Database
Multi-Region Database with 3 regions: westus2, centralus, eastus2
3 Nodes in each Region
4 vCPU per node
64GiB per node

intuit-mr.sql will create the database and the shema objects

## Data
`dbworklaod` will generate the data, however it is also available in Azure Storage.  You can choose to load some or all of the files.

- generate the yaml file
```
dbworkload util yaml -i file_data.sql
```

- edit the yaml file
change application choice and apply 10 choices

- generate the csv
```
dbworkload util csv -i file_data.yaml
```

- for the local import run the python server in one session and run the import from another
```
python3 -m http.server -b 192.168.5.101 3000
```
```
IMPORT INTO file_data(application,email,name,formatted,postmark,dataval00,dataval01,dataval02,dataval03,dataval04,dataval05,dataval06,dataval07,dataval08,dataval09,dataval10,dataval11,dataval12,dataval13,dataval14,dataval15,dataval16,dataval17,dataval18,dataval19,dataval20,dataval21,dataval22,dataval23,dataval24,dataval25,dataval26,dataval27,dataval28,dataval29,dataval30,dataval31,dataval32,dataval33,dataval34,dataval35,dataval36,dataval37,dataval38,dataval39,dataval40) 
    CSV DATA ('http://192.168.5.101:3000/file_data.0_0_0.tsv') WITH delimiter = e'\t', nullif = '';
```
- For the import from Azure Blob Storage
```
IMPORT INTO
	file_data(application,email,name,formatted,postmark,dataval00,dataval01,dataval02,dataval03,dataval04,dataval05,dataval06,dataval07,dataval08,dataval09,dataval10,dataval11,dataval12,dataval13,dataval14,dataval15,dataval16,dataval17,dataval18,dataval19,dataval20,dataval21,dataval22,dataval23,dataval24,dataval25,dataval26,dataval27,dataval28,dataval29,dataval30,dataval31,dataval32,dataval33,dataval34,dataval35,dataval36,dataval37,dataval38,dataval39,dataval40)
	CSV DATA ('azure-blob://nollen-intuit-container/csv/*.tsv?AUTH=specified&AZURE_ACCOUNT_NAME=nollenstorageaccount&AZURE_ACCOUNT_KEY={url-encoded-key}') 
WITH delimiter = e'\t', nullif = '';
```
- If you need to copy files from Linux to Azure Blob Storage
```
 azcopy cp "*" "https://nollenstorageaccount.blob.core.windows.net/nollen-intuit-container/csv"
```

Copy CSV Files from Linux to Azure Storage Blob
Create a Shared Access Signature (SAS) [be sure you're at the storage account level] in the portal and copy the SAS Token. I did not specify the IP address.  The token should look like this:

Now you can create the AZCopy Command by combining the HTTPS string available in the properties tab of the container and the SAS Token.
```
azcopy cp "*" "https://nollenstorageaccount.blob.core.windows.net/nollen-intuit-container/csv/?sv=2022-11-02&ss=bfqt&srt=sco&sp=rwdlacupyx&se=2024-11-01T03:14:45Z&st=2024-10-11T19:14:45Z&spr=https&sig=wRQecYEuH%2FZeyMIpi55BL6%2BgDe0CTtTi94DASC1qEyk%3D"
```

- To backup the database to Azure Storage
```
BACKUP DATABASE intuit_mr INTO
'azure-blob://nollenbackupintuitmr?AUTH=specified&AZURE_ACCOUNT_NAME=nollennohrstorage&AZURE_ACCOUNT_KEY=BMhChHaP5tcofRbA2BrkYKPoeJn5eWFqW
1hmJJ15ejJnQXxQXPh1CIpCyanN6QKiKS4cee3J9OR3%2BAStzkdngA%3D%3D';
-- URL Encode That Account Key!
```
# Demo
# Run dbworkload on an appserver in each region 
West:
```
dbworkload run -w file_data.py --driver postgres --uri "postgresql://ron@192.168.5.100:26257/intuit_mr?sslmode=verify-full&sslrootcert=$HOME/certs/ca.crt&sslcert=$HOME/certs/client.ron.crt&sslkey=$HOME/certs/client.ron.key" -d 300
```
Central:
```
dbworkload run -w file_data.py --driver postgres --uri "postgresql://ron@192.168.6.101:26257/intuit_mr?sslmode=verify-full&sslrootcert=$HOME/certs/ca.crt&sslcert=$HOME/certs/client.ron.crt&sslkey=$HOME/certs/client.ron.key" -d 300
```
East:
```
dbworkload run -w file_data.py --driver postgres --uri "postgresql://ron@192.168.7.100:26257/intuit_mr?sslmode=verify-full&sslrootcert=$HOME/certs/ca.crt&sslcert=$HOME/certs/client.ron.crt&sslkey=$HOME/certs/client.ron.key" -d 300
```

# Set the Override
```
SET override_multi_region_zone_config = true
```

# Show the Partitions
```
select partition_name, parent_partition, column_names, index_name, full_zone_config from [show partitions from table file_data] where partition_name = 'westus2';
```

# Let's verify where the lease holder currently resides
```
select concat('select range_id, replicas, voting_replicas from [show range from table file_data for row(''',region::string,''',',id::string,')];') from file_data where application = 'C0' limit 1;

select range_id, lease_holder, replicas, voting_replicas from [show ranges from table file_data with details] where range_id = 154;
```

# Move the lease holders to the central region
```
ALTER PARTITION westus2 OF INDEX file_data@file_data_pkey CONFIGURE ZONE USING lease_preferences = '[[+region=centralus]]';
ALTER PARTITION westus2 OF INDEX file_data@email_idx CONFIGURE ZONE USING lease_preferences = '[[+region=centralus]]';
ALTER PARTITION westus2 OF INDEX file_data@name_idx  CONFIGURE ZONE USING lease_preferences = '[[+region=centralus]]';
```

# Verify the lease holder moved
```
select concat('select range_id, replicas, voting_replicas from [show range from table file_data for row(''',region::string,''',',id::string,')];') from file_data where application = 'C0' limit 1;

select range_id, lease_holder, replicas, voting_replicas from [show ranges from table file_data with details] where range_id = 154;
```

# Move the lease holders back to the west
```
ALTER PARTITION westus2 OF INDEX file_data@file_data_pkey CONFIGURE ZONE USING lease_preferences = '[[+region=westus2]]';
ALTER PARTITION westus2 OF INDEX file_data@email_idx CONFIGURE ZONE USING lease_preferences = '[[+region=westus2]]';
ALTER PARTITION westus2 OF INDEX file_data@name_idx  CONFIGURE ZONE USING lease_preferences = '[[+region=westus2]]';
```

# Finally, verify that the lease holder is back in the west
```
select concat('select range_id, replicas, voting_replicas from [show range from table file_data for row(''',region::string,''',',id::string,')];') from file_data where application = 'C0' limit 1;

select range_id, lease_holder, replicas, voting_replicas from [show ranges from table file_data with details] where range_id = 154;
```


