create or replace package executor_count is

/**
* Get amount of executing sql query N-times in millisecond
*
* @param p_text_sql [not null] - dml query in string format
* @param p_number_execute [null] - number of executing query
*
* @return [not null] - time executing the query in millisecond
*
* @throws
*/
function get_time_execute_sql(p_text_sql varchar2, p_number_execute integer default 5) return number;

end executor_count;
/
create or replace package body executor_count is

function get_time_execute_sql(p_text_sql varchar2, p_number_execute integer default 5)
return number is
  amount_microseconds    pls_integer := 0;
  l_elapsed_time pls_integer;
  l_clob_user_sql     clob := to_clob(p_text_sql);
begin
  if p_text_sql is null then 
     raise_application_error(-20001, 'The parametr value of p_text_sql mustn''t NULL');
  end if;

   for i in 1..p_number_execute loop
     l_elapsed_time := 0;
     dbms_output.put_line('Start execute sql ...');
     execute immediate p_text_sql;
     dbms_output.put_line('Finish execute sql ...');
     dbms_output.put_line('');

     select res.elapsed_time
     into l_elapsed_time
     from (
       select s.ELAPSED_TIME, s.LAST_ACTIVE_TIME
       from V$SQLSTATS s
       where dbms_lob.compare(s.SQL_FULLTEXT, l_clob_user_sql) = 0
       order by s.LAST_ACTIVE_TIME desc
     ) res where rownum = 1;
     dbms_output.put_line('l_elapsed_time: '||l_elapsed_time);
     amount_microseconds := amount_microseconds + l_elapsed_time;
   end loop;
return amount_microseconds;
   
end;

end executor_count;
/
