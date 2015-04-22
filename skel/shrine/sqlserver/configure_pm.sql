use DB_NAME;


insert into PM_USER_DATA
(user_id, full_name, password, status_cd)
values
('SHRINE_USER', 'shrine', 'SHRINE_PASSWORD_CRYPTED', 'A');



insert into PM_PROJECT_DATA
(project_id, project_name, project_wiki, project_path, status_cd)
values
('SHRINE', 'SHRINE', 'http://open.med.harvard.edu/display/SHRINE', '/SHRINE', 'A');

insert into PM_PROJECT_USER_ROLES
(PROJECT_ID, USER_ID, USER_ROLE_CD, STATUS_CD)
values
('SHRINE', 'SHRINE_USER', 'USER', 'A');

insert into PM_PROJECT_USER_ROLES
(PROJECT_ID, USER_ID, USER_ROLE_CD, STATUS_CD)
values
('SHRINE', 'SHRINE_USER', 'DATA_OBFSC', 'A');


insert into PM_CELL_DATA
(cell_id, project_path, name, method_cd, url, can_override, status_cd)
values
('CRC', '/SHRINE', 'SHRINE Federated Query', 'REST', 'https://SHRINE_IP:SHRINE_SSL_PORT/shrine/rest/i2b2/', 1, 'A');
