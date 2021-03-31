/**

  Add permissions for user cell_readonly for insecure clients.

  Run with postgres from postgres database.

*/

-- Set the name of the database
\set dbname datos_finales_proyecto_nacional
\set dbowneruser nacional
\set dbreadonlyuser cell_readonly

\c postgres

begin;

create user :dbowneruser with
password '38fn3k39erj34n8'
NOSUPERUSER LOGIN NOCREATEDB NOCREATEROLE NOREPLICATION;

create user :dbreadonlyuser with
password 'manCastle002'
NOSUPERUSER LOGIN NOCREATEDB NOCREATEROLE NOREPLICATION;

commit;

-- Create database cannot be run in a transaction
create database :dbname
owner :dbowneruser;

\c :dbname

-- Drop default privileges
revoke all privileges on database :dbname
from public;

revoke all privileges on schema public
from public;

revoke all privileges on database :dbname
from :dbreadonlyuser;

revoke all privileges on schema public
from :dbreadonlyuser;

grant connect on database :dbname
to :dbreadonlyuser;

-- Grant select to all tables
grant usage on schema public
to :dbreadonlyuser;

grant select on all tables
in schema public
to :dbreadonlyuser;

grant usage on schema context
to :dbreadonlyuser;

grant select on all tables
in schema context
to :dbreadonlyuser;

grant usage on schema data
to :dbreadonlyuser;

grant select on all tables
in schema data
to :dbreadonlyuser;

grant usage on schema test
to :dbreadonlyuser;

grant select on all tables
in schema test
to :dbreadonlyuser;
