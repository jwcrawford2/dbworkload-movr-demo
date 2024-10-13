select id, from file_data where region = %s and id = %s for update;
update file_data set postmark = now() where region = 'westus2' and id = 324234234234;


