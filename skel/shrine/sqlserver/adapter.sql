--#https://open.med.harvard.edu/svn/shrine/releases/1.18.2/code/adapter/src/main/resources/adapter.sql
--removed engine=innodb default charset=latin1; from each create table
--changed auto_increment to identity(1,1)
--changed timestamp types to datetime
--broke out index creatation into seperate commands
--changed enum types to contraints

create table SHRINE_QUERY(
  [id] [int] not null IDENTITY(1,1),
  local_id [varchar](255) not null,
  network_id bigint not null,
  username [varchar](255) not null,
  domain [varchar](255) not null,
  query_name [varchar](255) not null,
  query_expression text,
  date_created datetime default current_timestamp,
  has_been_run bit not null default 0,
  flagged bit not null default 0,
  flag_message [varchar](255) null,
  constraint query_id_pk primary key clustered (id asc),
  query_xml text
)
CREATE NONCLUSTERED INDEX [ix_SHRINE_QUERY_network_id] ON [dbo].[SHRINE_QUERY] ([network_id] ASC)
CREATE NONCLUSTERED INDEX [ix_SHRINE_QUERY_local_id] ON [dbo].[SHRINE_QUERY] ([local_id] ASC)
CREATE NONCLUSTERED INDEX [ix_SHRINE_QUERY_username_domain] ON [dbo].[SHRINE_QUERY] (username, domain ASC)


create table QUERY_RESULT(
  id int not null identity(1,1),
  local_id varchar(255) not null,
  query_id int not null,
  [type] varchar(255) not null check ([type] in ('PATIENTSET','PATIENT_COUNT_XML','PATIENT_AGE_COUNT_XML','PATIENT_RACE_COUNT_XML','PATIENT_VITALSTATUS_COUNT_XML','PATIENT_GENDER_COUNT_XML','ERROR')),
  [status] varchar(50) not null check ([status] in ('FINISHED', 'ERROR', 'PROCESSING', 'QUEUED')),
  time_elapsed int null,
  last_updated datetime default current_timestamp,
  constraint QUERY_RESULT_id_pk primary key(id),
  constraint fk_QUERY_RESULT_query_id foreign key (query_id) references SHRINE_QUERY (id) on delete cascade
)

create table ERROR_RESULT(
  id int not null identity(1,1),
  result_id int not null,
  message varchar(255) not null,
  constraint ERROR_RESULT_id_pk primary key(id),
  constraint fk_ERROR_RESULT_QUERY_RESULT_id foreign key (result_id) references QUERY_RESULT (id) on delete cascade
)

create table COUNT_RESULT(
  id int not null identity(1,1),
  result_id int not null,
  original_count int not null,
  obfuscated_count int not null,
  date_created datetime default current_timestamp,
  constraint COUNT_RESULT_id_pk primary key(id),
  constraint fk_COUNT_RESULT_QUERY_RESULT_id foreign key (result_id) references QUERY_RESULT (id) on delete cascade
)

create table BREAKDOWN_RESULT(
  id int not null identity(1,1),
  result_id int not null,
  data_key varchar(255) not null,
  original_value int not null,
  obfuscated_value int not null,
  constraint BREAKDOWN_RESULT_id_pk primary key(id),
  constraint fk_BREAKDOWN_RESULT_QUERY_RESULT_id foreign key (result_id) references QUERY_RESULT (id) on delete cascade
)

create table PRIVILEGED_USER(
  id int not null identity(1,1),
  username varchar(255) not null,
  domain varchar(255) not null,
  threshold int not null,
  override_date timestamp null,
  constraint priviliged_user_pk primary key(id),
  constraint ix_PRIVILEGED_USER_username_domain unique (username, domain)
)
