create or replace package error is
/**
 * The package contains client exceptions and procedure for throwing one
 * @headcom
 */

CODE_DUP_VAL_ON_INDEX     constant  pls_integer := -1;

EXC_PARENT_KEY_NOT_FOUND  exception;
CODE_PARENT_KEY_NOT_FOUND constant  pls_integer := -2291;

VALUE_ARGUMENT_IS_NULL      exception;
CODE_VALUE_ARGUMENT_IS_NULL constant pls_integer := -20001;

VALUE_ARGUMENT_IS_NOT_NULL      exception;
CODE_VALUE_IS_NOT_NULL constant pls_integer := -20002;

MORE_ONE_ARGUMENTS_IN_OBJECT  exception;
CODE_MORE_ONE_IN_OBJECT constant pls_integer := -20003;

EXC_NO_DATA_TYPE_CONFIG_VALUE  exception;
CODE_NO_DATA_TYPE_CONFIG_VALUE constant pls_integer := -20004;

EXC_ALL_VALUES_IS_NULL exception;
CODE_ALL_VALUES_IS_NULL constant pls_integer := -20005;

EXC_INCORRECT_ARGUMENT_VALUE exception;
CODE_INCORRECT_ARGUMENT_VALUE  constant pls_integer := -20006;

EXC_UPDATE_ID_ISNT_EXISTS exception;
CODE_UPDATE_ID_ISNT_EXISTS  constant pls_integer := -20007;

EXC_INTERSECTION_DATE exception;
CODE_INTERSECTION_DATE constant pls_integer := -20008;

CODE_NO_DATA_FOUND constant pls_integer := -20009;

CODE_TOO_MANY_ROWS constant pls_integer := -20010;

pragma exception_init(EXC_PARENT_KEY_NOT_FOUND, -2291);
pragma exception_init(VALUE_ARGUMENT_IS_NULL, -20001);
pragma exception_init(VALUE_ARGUMENT_IS_NOT_NULL, -20002);
pragma exception_init(MORE_ONE_ARGUMENTS_IN_OBJECT, -20003);
pragma exception_init(EXC_NO_DATA_TYPE_CONFIG_VALUE, -20004);
pragma exception_init(EXC_ALL_VALUES_IS_NULL, -20005);
pragma exception_init(EXC_INCORRECT_ARGUMENT_VALUE, -20006);
pragma exception_init(EXC_UPDATE_ID_ISNT_EXISTS, -20007);
pragma exception_init(EXC_INTERSECTION_DATE, -20008);

/**
 * Throwing exception
 *
 * @param errcode_             [not null] - code error (-20999...-20000)
 * @param errmessage_          [nullable] - describe exception, null - default descrive exception
 * @param push_in_error_stack_ [not null] - put exception to stack error (true) or rewrite stack (false)
 */
procedure raise_error(p_errcode integer, p_errmessage varchar2 default null, p_push_in_error_stack boolean default true);
end error;
/
create or replace package body error is

procedure raise_error(p_errcode integer, p_errmessage varchar2 default null, p_push_in_error_stack boolean default true) is
begin
  dbms_standard.raise_application_error(
    num            => p_errcode,
    msg            => coalesce(p_errmessage, 'Ops exception'),
    keeperrorstack => p_push_in_error_stack
  );
end raise_error;
end error;
/
