--#https://open.med.harvard.edu/svn/shrine/releases/1.18.2/code/broadcaster-aggregator/src/main/resources/hub.sql
--removed engine=innodb default charset=latin1; from each create table
--changed auto_increment to identity(1,1)
--changed timestamp types to datetime
--broke out index creatation into seperate commands

create table HUB_QUERY (
	NETWORK_QUERY_ID bigint not null,
    DOMAIN varchar(256) not null,
    USERNAME varchar(256) not null,
    CREATE_DATE datetime not null default current_timestamp,
    QUERY_DEFINITION text not null,
	constraint hub_query_id_pk primary key(NETWORK_QUERY_ID)
)
CREATE NONCLUSTERED INDEX ix_HUB_QUERY_username_domain ON [dbo].[HUB_QUERY] (username, domain ASC)


create table HUB_QUERY_RESULT (
	ID int not null identity(1,1),
    NETWORK_QUERY_ID bigint not null,
    NODE_NAME varchar(255) not null,
    CREATE_DATE datetime not null default current_timestamp,
    STATUS varchar(255) not null,
	constraint hub_query_result_id_pk primary key(ID)
)
CREATE NONCLUSTERED INDEX ix_HUB_QUERY_RESULT_network_query_id ON HUB_QUERY_RESULT (NETWORK_QUERY_ID)
CREATE NONCLUSTERED INDEX ix_HUB_QUERY_RESULT_network_query_id_node_name ON HUB_QUERY_RESULT (NETWORK_QUERY_ID, NODE_NAME)
