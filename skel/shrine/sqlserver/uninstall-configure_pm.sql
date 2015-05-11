use DB_NAME;


delete from PM_USER_DATA
where full_name='shrine';

delete from PM_PROJECT_DATA
where project_wiki='http://open.med.harvard.edu/display/SHRINE';

delete from PM_PROJECT_USER_ROLES
where PROJECT_ID='SHRINE';

delete from PM_PROJECT_USER_ROLES
where PROJECT_ID='SHRINE';

delete from PM_CELL_DATA
where name='SHRINE Federated Query';

