create or replace package test_executor_count is
--%suite(testing executor_count package)

  --%test(Checking return number time )
  procedure test_get_time_execute_sql;

end;
/
create or replace package body test_executor_count is

    procedure test_get_time_execute_sql is
        l_test_query nvarchar2(50) := 'select * from dual;';
    begin
      ut.expect(
        est.executor_count.get_time_execute_sql(l_test_query, 2)
      ).to_be_not_null();
    end;

end;
/
