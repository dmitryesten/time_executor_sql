create or replace package executor_count is

type r_query_info is record (
	text_query V$SQLSTATS.SQL_TEXT%type,
	elapsed_time V$SQLSTATS.ELAPSED_TIME%type,
	last_active_time V$SQLSTATS.LAST_ACTIVE_TIME%type
);

type nt_query is table of r_query_info;


/**
* Get executing time of sql query in millisecond
*
* @param p_text_sql       [not null] - dml query in string format
* @param p_number_execute [null]     - number of executing query
*
* @return [not null] - time executing the query in millisecond
*
* @throws
*/
function get_time_execute_sql(p_text_sql clob, p_date date default sysdate) return nt_query pipelined;

/**
* Get collection elapsed time of specified date
*
* @param p_text_sql [not null] - dml query in string format
* @param p_number_execute [null] - number of executing query
*
* @return [not null] - time executing the query in millisecond
*
* @throws
*/
--function get_time_last_day(p_date date) return nt_elapsed_time pipelined;

end executor_count;
/
create or replace package body executor_count is

function get_time_execute_sql(
	p_text_sql clob, 
	p_date date default sysdate)
return nt_query pipelined is
  	amount_microseconds    pls_integer := 0;
  	l_elapsed_time  pls_integer;
  	l_clob_user_sql clob;
  	l_date		  date;
	l_query_info r_query_info;
begin
	assert_util.assert_is_not_null(p_text_sql, 'p_text_sql');
	assert_util.assert_is_not_null(p_date, 'p_date');
	
	l_clob_user_sql := p_text_sql;
	l_date := p_date;
	l_elapsed_time := 0;
	
	for rec in (	
		select *
		from (
		  select s.SQL_TEXT, s.ELAPSED_TIME, s.LAST_ACTIVE_TIME
		  from V$SQLSTATS s
		  where dbms_lob.compare(s.SQL_FULLTEXT, l_clob_user_sql) = 0 and s.LAST_ACTIVE_TIME <= l_date
		  order by s.LAST_ACTIVE_TIME desc
		) res
	) loop
	l_query_info.text_query := rec.sql_text;
	l_query_info.elapsed_time := rec.elapsed_time;
	l_query_info.last_active_time := rec.last_active_time;
	dbms_output.put_line('sql_text:'||l_query_info.text_query||';  l_elapsed_time: '||l_query_info.elapsed_time||'; l_data: '||l_query_info.last_active_time);
	
	pipe row(rec);
	end loop;
	 
	return;
end;

end executor_count;
/
