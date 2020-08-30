
create or replace package check_object as


type map_objects is table of clob index by varchar2(30);


/**
    To check existing a table
    
    @param p_name_table - name of a table
    
    @return true - table is existing
            false - table isn't existing 
    @throws no_data_found - false
*/
function exist_table(p_name_table varchar2) return boolean deterministic;


/**
    Get all constraints of a table
  
    @param p_name_table - name of a table

    @return map_constraints<constraint_name, clob(ddl)> 
*/
function get_constraints(p_name_table varchar2) return map_objects;


/**
    Get all constraints of a table
    
    @param p_name_table - name of a table

    @return map_objects<index_name, clob(ddl)> 
*/
function get_indexes(p_name_table varchar2) return map_objects;


end check_object;
/
create or replace package body check_object as

function exist_table(p_name_table varchar2) return boolean deterministic as
  l_name_table varchar2(30) := UPPER(p_name_table);
  l_result varchar2(30);
begin

  select table_name
  into l_result
  from user_tables where table_name = l_name_table;

  return case when l_result is not null then true else false end;
exception 
  when no_data_found then
  return false;
end exist_table;


function get_constraints(p_name_table varchar2) return map_objects is
  l_constraint_name varchar2(30);
  l_name_table varchar2(30) := UPPER(p_name_table);
  type nt_constraint is table of user_constraints.constraint_name%type; 
  array_constraint_name nt_constraint;
  map_constraint map_objects;
begin
  select s.constraint_name
  bulk collect into array_constraint_name
  from user_constraints s
  where s.table_name = l_name_table;
  
  if (array_constraint_name.count <> 0) then  
    for i in array_constraint_name.FIRST..array_constraint_name.LAST loop
      l_constraint_name := array_constraint_name(i);
      map_constraint(l_constraint_name) := dbms_metadata.get_ddl('CONSTRAINT', l_constraint_name);
    end loop;
  end if;
  
return map_constraint;
end get_constraints;


function get_indexes(p_name_table varchar2) return map_objects is
  l_index_name varchar2(30);
  l_name_table varchar2(30) := UPPER(p_name_table);
  type nt_index_name is table of user_indexes.index_name%type;
  array_index_name nt_index_name;
  map_index map_objects;
begin
  
  select s.index_name 
  bulk collect into array_index_name
  from user_indexes s 
  where s.table_name = l_name_table;
  
  if (array_index_name.count <> 0) then
    for i in array_index_name.FIRST..array_index_name.LAST loop
      l_index_name := array_index_name(i);
      map_index(l_index_name) := dbms_metadata.get_ddl('INDEX', l_index_name);
    end loop;
  end if;
  
  return map_index;
end get_indexes;

end check_object;
/
create or replace package mg_cleaner as

type nt_array_table is table of varchar2(4000) not null;

/**
    Clean all inactual data after current date
    @param p_table_name - table name
    @param p_date - date
*/
procedure clean (p_table_name varchar2, p_date date);
procedure clean (p_table_name varchar2, p_date varchar2);


/**
    Clean all inactual data after current date
    @param p_array_table - array of table names
    @param p_date - date
*/
procedure clean (p_array_table nt_array_table, p_date date);
procedure clean (p_array_table nt_array_table, p_date varchar2);

end mg_cleaner;
/
create or replace package body mg_cleaner as

function get_table_name_with_prefix(p_prefix varchar2, p_table_name varchar2) 
return varchar2 as
l_concat_table varchar2(4000);
begin
  if (p_table_name is null) then 
    raise_application_error(-20001,'The parameter p_table_name must be not null');
  end if;
  
  l_concat_table := concat(p_prefix, p_table_name);
  
  if (length(l_concat_table) > 30) then
    l_concat_table := substr(l_concat_table, 1, 30);
  end if;
  
  return l_concat_table; 
end;


procedure clean (p_table_name varchar2, p_date date) as
  l_archived_table_name varchar2(30);
  l_old_table           varchar2(30):= UPPER(p_table_name);
  l_date_varchar        varchar2(20):= to_char(p_date, 'DD.MM.YYYY');
  l_template_table      varchar2(30);
  l_ddl_command         clob;
  l_ddl_query           varchar2(4000);
  
  array_constraints check_object.map_objects;
  array_indexes     check_object.map_objects;
begin
  
  if (l_date_varchar is null) then
    raise_application_error(-20001,'The parameter p_date must be not null');
  end if;
  
  if (l_old_table is null) then
    raise_application_error(-20001,'The parameter p_table_name must be not null');
  end if;

  l_archived_table_name := get_table_name_with_prefix('BKP_', l_old_table);
  l_template_table := get_table_name_with_prefix('TMP_', l_old_table);
    
  array_constraints := check_object.get_constraints(l_old_table);
  array_indexes     := check_object.get_indexes(l_old_table);
  
  dbms_output.put_line('Caching actual data to '||l_template_table||' table ...');
  l_ddl_query := 
    'create table '||l_template_table||' nologging as 
     select * from '||l_old_table||'
     where SCN_TO_TIMESTAMP(ora_rowscn) > to_date('''||l_date_varchar||''', ''DD.MM.YYYY'')';
  execute immediate l_ddl_query;
  dbms_output.put_line('The actual data was cached to '||l_template_table||' table.');
  
    
  dbms_output.put_line('Droping '||l_old_table||' table');
  execute immediate 'drop table '||l_old_table ||' cascade constraints';
  dbms_output.put_line('The '||l_old_table||' table was dropped.');
  
  
  dbms_output.put_line('Create '||l_old_table ||' table and moving actual data it.');
  l_ddl_query := 
  'create table '||l_old_table||' nologging as select * from '||l_template_table;
  execute immediate l_ddl_query;
  dbms_output.put_line('The actual data was moved to now created '||l_old_table||' table.');
  
  
  dbms_output.put_line('Droping temp table table');
  execute immediate 'drop table '||l_template_table;
  dbms_output.put_line(l_template_table||' was dropped');
  
  if (array_constraints.count <> 0) then
    dbms_output.put_line('Re-add constraints in '||l_old_table||' table ...');
    dbms_output.put_line(array_constraints.FIRST||' '||array_constraints.LAST);
    for i in array_constraints.FIRST..array_constraints.LAST loop
      dbms_output.put_line('constraint: '|| array_constraints(i));
      l_ddl_command := array_constraints(i);
      dbms_output.put_line('execute: '||array_constraints(i));
      execute immediate l_ddl_command;
    end loop;
    dbms_output.put_line('Constraints were recreated for '||l_old_table||' table.');
  end if;
  
  if (array_indexes.count <> 0) then
    dbms_output.put_line('Re-create indexes in '||l_old_table||' table ...');
    for i in array_indexes.FIRST..array_indexes.LAST loop
      l_ddl_command := array_indexes(i);
      dbms_output.put_line('execute: '||array_indexes(i));
      execute immediate l_ddl_command;
    end loop;
    dbms_output.put_line('Indexes were recreated for '||l_old_table||' table.');
  end if;
  
end clean;


procedure clean (p_table_name varchar2, p_date varchar2) is
    l_table_name varchar2(30) := UPPER(p_table_name);
    l_date date := to_date(p_date, 'DD.MM.YYYY');
begin 
  mg_cleaner.clean(p_table_name => l_table_name, p_date => l_date);
end clean;

procedure clean (p_array_table nt_array_table, p_date date) as
  C_EMPTY_COLLECTION constant integer := 0;
  l_array_table      nt_array_table;
  l_date             date; 
begin
  if (p_array_table is null) then
    raise_application_error(-20001,'The parameter p_array_table must be not null');
  end if;
  
  if (p_date is null) then
    raise_application_error(-20001,'The parameter p_date must be not null');
  end if;
  
  if (p_array_table.count = C_EMPTY_COLLECTION) then
    raise_application_error(-20002,'The collection p_array_table is empty');
  end if;
  
  l_array_table := p_array_table;
  l_date        := p_date;
  
  for i IN l_array_table.FIRST..l_array_table.LAST loop
    if (l_array_table(i) is not null) then
        mg_cleaner.clean(p_table_name => l_array_table(i), p_date => l_date);
    end if;
  end loop;
  
end clean;
procedure clean (p_array_table nt_array_table, p_date varchar2) as
  C_EMPTY_COLLECTION constant integer := 0;
  l_array_table      nt_array_table;
  l_date date := to_date(p_date, 'DD.MM.YYYY');
begin
  if (p_array_table.count = C_EMPTY_COLLECTION) then
    raise_application_error(-20002,'The collection p_array_table is empty');
  end if;
  
  l_array_table := p_array_table;
  l_date        := p_date;
  
  for i IN l_array_table.FIRST..l_array_table.LAST loop
    if (l_array_table(i) is not null) then
        mg_cleaner.clean(p_table_name => l_array_table(i), p_date => l_date);
    end if;
  end loop; 
end clean;

end mg_cleaner;
/
create or replace package test_generator as

procedure create_test_table;

procedure drop_test_table;

end test_generator;
/
create or replace package body test_generator as

procedure create_test_table as 
begin
   execute immediate 
   'create table test1 (
        id integer,
        name varchar2(50),
        age integer,
        constraint pk_id_test1 PRIMARY KEY (id),
        constraint constr_name_test1 CHECK (length(name) < 50) )';
   execute immediate 'create index idx_test1_age on test1(age)';
   
   execute immediate
   'create table test2 (
        id integer,
        fk_id_test1 integer,
        password varchar2(20),
        constraint pk_id_test2 PRIMARY KEY (id),
        constraint fk_test1 foreign key (fk_id_test1) references test1 (id),
        constraint chk_password CHECK (length(password) < 20) )';
   
   execute immediate 
   'create sequence test_seq
    increment by 1
    start with 1
    nocache';
    
    execute immediate 
    'insert into test1 (id, name, age)  
      select 
      test_seq.nextval,
      dbms_random.string(''a'', ROUND(dbms_random.value(1, 49))),
      ROUND(dbms_random.value(18, 100))
      from dual
      connect by 1=1 and rownum <= 10000';
    commit;
    execute immediate
    'insert into test2  (id, fk_id_test1, password)
      with test1_random_order as (
      select id from test1 order by dbms_random.value 
      ),
      test1_one_id as (
      select id from test1_random_order where rownum = 1
      )
      select 
          test_seq.nextval, 
          (select * from test1_one_id),
          dbms_random.string(''a'', ROUND(dbms_random.value(1, 19)))   
      from dual
      connect by 1=1 and rownum < 10000';
     commit;

end create_test_table;

procedure drop_test_table as 
begin
  execute immediate 'drop table test2 CASCADE CONSTRAINTS';
  execute immediate 'drop table test1 CASCADE CONSTRAINTS';
  execute immediate 'drop sequence test_seq';
end drop_test_table;

end test_generator;
/create or replace package test_check_object as

procedure test_exist_table;

procedure test_get_constraints;

procedure test_get_indexes;

end test_check_object;
/
create or replace package body test_check_object as

procedure test_exist_table as
begin
   test_generator.create_test_table;
    if (check_object.exist_table('test1')) then
        dbms_output.put_line('test_check_object: successfully');
        test_generator.drop_test_table;
    else
        dbms_output.put_line('test_check_object: fall');
        test_generator.drop_test_table;
    end if;

end test_exist_table;

procedure test_get_constraints as 
  test_map check_object.map_objects;
  l_test_actual_key varchar2(30) := UPPER('pk_id_test1');
begin
  test_generator.create_test_table;
  
  test_map := check_object.get_constraints('test1');
  dbms_output.put_line('checking '||l_test_actual_key);
  if (test_map(l_test_actual_key) is not null )then
    dbms_output.put_line('test_get_constraints: successfully');
    test_generator.drop_test_table;
  else
    dbms_output.put_line('test_get_constraints: fall');
    test_generator.drop_test_table;
  end if;
end test_get_constraints;

procedure test_get_indexes as
  test_map check_object.map_objects;
  l_test_actual_index varchar2(30) := UPPER('idx_test1_age');
begin
  test_generator.create_test_table;
  test_map := check_object.get_indexes('TEST1');
  
  dbms_output.put_line('checking '||l_test_actual_index);
  if (test_map(l_test_actual_index) is not null) then
    dbms_output.put_line('test_get_indexes: successfully');
    test_generator.drop_test_table;
  else
    dbms_output.put_line('test_get_indexes: fall');
    test_generator.drop_test_table;
  end if;

end test_get_indexes;

end test_check_object;
/


