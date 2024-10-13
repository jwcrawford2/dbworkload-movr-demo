select id, email, name, formatted, postmark from file_data where region = 'westus2' and id = 324234234234 and formatted is FALSE for update;
update file_data set formatted = TRUE, postmark = now() where region = 'westus2' and id = 324234234234;


