-- intuit-mr.sql

CREATE DATABASE intuit_mr PRIMARY REGION "westus2" REGIONS "westus2", "eastus2", "centralus" SURVIVE REGION FAILURE SECONDARY REGION "centralus";

USE intuit_mr;

CREATE TYPE application_enum AS ENUM ('C0', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9');

CREATE TABLE file_data (
    id              INT DEFAULT unique_rowid(),
    application     application_enum    NOT NULL,
    email           STRING(10)          NOT NULL,
    name            STRING(10)          NOT NULL,
    formatted       BOOLEAN             NOT NULL,
    postmark        TIMESTAMP           NOT NULL DEFAULT now(),
    dataval00       JSONB               NOT NULL,
    dataval01       INT                 NOT NULL,
    dataval02       FLOAT               NOT NULL,
    dataval03       STRING(15)          NOT NULL,
    dataval04       STRING(10)          NOT NULL,
    dataval05       STRING(5)           NOT NULL,
    dataval06       INT                 NOT NULL,
    dataval07       STRING(20)          NOT NULL,
    dataval08       JSONB               NOT NULL,
    dataval09       TIMESTAMP           NOT NULL,
    dataval10       STRING(10)          NOT NULL,
    dataval11       STRING(15)          NOT NULL,
    dataval12       STRING(5)           NOT NULL,
    dataval13       FLOAT               NOT NULL,
    dataval14       STRING(5)           NOT NULL,
    dataval15       STRING(10)          NOT NULL,
    dataval16       STRING(15)          NOT NULL,
    dataval17       STRING(5)           NOT NULL,
    dataval18       STRING(10)          NOT NULL,
    dataval19       STRING(20)          NOT NULL,
    dataval20       STRING(15)          NOT NULL,
    dataval21       JSONB               NOT NULL,
    dataval22       INT                 NOT NULL,
    dataval23       FLOAT               NOT NULL,
    dataval24       bit(10)             NOT NULL,
    dataval25       INT ARRAY           NOT NULL,
    dataval26       STRING(10)          NOT NULL,
    dataval27       STRING(5)           NOT NULL,
    dataval28       STRING(5)           NOT NULL,
    dataval29       BYTEA               NOT NULL,
    dataval30       STRING(5)           NOT NULL,
    dataval31       STRING(15)          NOT NULL,
    dataval32       STRING(5)           NOT NULL,
    dataval33       STRING(10)          NOT NULL,
    dataval34       STRING(5)           NOT NULL,
    dataval35       STRING(5)           NOT NULL,
    dataval36       STRING(5)           NOT NULL,
    dataval37       STRING(5)           NOT NULL,
    dataval38       STRING(5)           NOT NULL,
    dataval39       DATE                NOT NULL,
    dataval40       TIME                NOT NULL,
    CONSTRAINT file_data_pkey PRIMARY KEY (id));

ALTER TABLE file_data ADD COLUMN region crdb_internal_region AS (
    CASE 
        WHEN application = 'C0' then 'westus2'
        WHEN application = 'C1' then 'westus2'
        WHEN application = 'C2' then 'westus2'
        WHEN application = 'C3' then 'westus2'
        WHEN application = 'C4' then 'westus2'
        WHEN application = 'C5' then 'eastus2'
        WHEN application = 'C6' then 'eastus2'
        WHEN application = 'C7' then 'eastus2'
        WHEN application = 'C8' then 'eastus2'
        WHEN application = 'C9' then 'eastus2'
    END
) STORED NOT NULL;

ALTER TABLE file_data SET LOCALITY REGIONAL BY ROW AS "region";

CREATE INDEX email_idx ON file_data (email);
CREATE INDEX name_idx ON file_data (name);

SET override_multi_region_zone_config = true;
-- Primary Key (Table)
ALTER PARTITION westus2 OF INDEX file_data@file_data_pkey CONFIGURE ZONE USING voter_constraints = '{+region=eastus2: 1, +region=centralus: 2, +region=westus2: 2}',  lease_preferences = '[[+region=westus2]]';
ALTER PARTITION eastus2 OF INDEX file_data@file_data_pkey CONFIGURE ZONE USING voter_constraints = '{+region=westus2: 1, +region=centralus: 2, +region=eastus2: 2}',  lease_preferences = '[[+region=eastus2]]';

-- Secondary Index (email_idx)
ALTER PARTITION westus2 OF INDEX file_data@email_idx CONFIGURE ZONE USING voter_constraints = '{+region=eastus2: 1, +region=centralus: 2, +region=westus2: 2}',  lease_preferences = '[[+region=westus2]]';
ALTER PARTITION eastus2 OF INDEX file_data@email_idx CONFIGURE ZONE USING voter_constraints = '{+region=westus2: 1, +region=centralus: 2, +region=eastus2: 2}',  lease_preferences = '[[+region=eastus2]]';

-- Secondary Index (name_idx)
ALTER PARTITION westus2 OF INDEX file_data@name_idx CONFIGURE ZONE USING voter_constraints = '{+region=eastus2: 1, +region=centralus: 2, +region=westus2: 2}',  lease_preferences = '[[+region=westus2]]';
ALTER PARTITION eastus2 OF INDEX file_data@name_idx CONFIGURE ZONE USING voter_constraints = '{+region=westus2: 1, +region=centralus: 2, +region=eastus2: 2}',  lease_preferences = '[[+region=eastus2]]';

select partition_name, parent_partition, column_names, index_name, partition_value, full_zone_config from [show partitions from table file_data];


-- MOVE westus2 LEASEHOLDERS to centralus
ALTER PARTITION westus2 OF INDEX file_data@file_data_pkey CONFIGURE ZONE USING lease_preferences = '[[+region=centralus]]';
ALTER PARTITION westus2 OF INDEX file_data@email_idx CONFIGURE ZONE USING lease_preferences = '[[+region=centralus]]';
ALTER PARTITION westus2 OF INDEX file_data@name_idx CONFIGURE ZONE USING lease_preferences = '[[+region=centralus]]';

-- MOVE westus2 LEASEHOLDERS back up to westus2
ALTER PARTITION westus2 OF INDEX file_data@file_data_pkey CONFIGURE ZONE USING lease_preferences = '[[+region=westus2]]';
ALTER PARTITION westus2 OF INDEX file_data@email_idx CONFIGURE ZONE USING lease_preferences = '[[+region=westus2]]';
ALTER PARTITION westus2 OF INDEX file_data@name_idx CONFIGURE ZONE USING lease_preferences = '[[+region=westus2]]';
