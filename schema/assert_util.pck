create or replace package assert_util is
/**
 * The package contains some functions and procedures for checking argument value
 * @headcom
 */

/**
 * Checking that a integer value is not null
 *
 * @param p_input           [nullable] - checked value
 * @param p_name_argument   [nullable] - argument name of checked value
 *
 * @throws ORA-20001 The value of argument must be not NULL
 */
procedure assert_is_not_null (
  p_input          integer,
  p_name_argument  varchar2 default null
);

/**
 * Checking that a varchar2 value is not null
 *
 * @param p_input           [nullable] - checked value
 * @param p_name_argument   [nullable] - argument name of checked value
 *
 * @throws ORA-20002 The value of argument must be not NULL
 */
procedure assert_is_not_null (
  p_input          varchar2,
  p_name_argument  varchar2 default null
);

/**
 * Checking that a date value is not null
 *
 * @param p_input           [nullable] - checked value
 * @param p_name_argument   [nullable] - argument name of checked value
 *
 * @throws ORA-20002 The value of argument must be not NULL
 */
procedure assert_is_not_null (
  p_input          date,
  p_name_argument  varchar2 default null
);

/**
 * Checking that a date value is not null
 *
 * @param p_input           [nullable] - checked value
 * @param p_name_argument   [nullable] - argument name of checked value
 *
 * @throws ORA-20002 The value of argument must be not NULL
 */
procedure assert_is_not_null (
  p_input          boolean,
  p_name_argument  varchar2 default null
);

/**
 * Checking that a integer value is null
 *
 * @param p_input          [nullable] - checked value
 * @param p_name_argument  [nullable] - argument name of checked value
 *
 * @throws ORA-20003 The value of argument must be NULL
 */
procedure assert_is_null(
  p_input          integer,
  p_name_argument  varchar2 default null
);

/**
 * Checking that a varchar2 value is null
 *
 * @param p_input          [nullable] - checked value
 * @param p_name_argument  [nullable] - argument name of checked value
 *
 * @throws ORA-20003 The value of argument must be NULL
 */
procedure assert_is_null(
  p_input          varchar2,
  p_name_argument  varchar2 default null
);

/**
 * Checking that a date value is null
 *
 * @param p_input          [nullable] - checked value
 * @param p_name_argument  [nullable] - argument name of checked value
 *
 * @throws ORA-20003 The value of argument must be NULL
 */
procedure assert_is_null(
  p_input          date,
  p_name_argument  varchar2 default null
);

/**
 * Convert bool "true" or "false" values to integer "1" or "0" value 
 *
 * @param p_input [nullable] - a bool value for converting
 * @return [nullable] the value after converting:
 *                      1, if the value before converting is "true" 
 *                      0, if the value before converting is "false"
 *                      null, if the value before converting is null
 */
function bool_to_number(p_input boolean) return integer deterministic;

/**
 * Convert bool "true" or "false" values to varchar2 string "true" or "false" value 
 *
 * @param p_input [nullable] - a bool value for converting
 * @return [nullable] the value after converting:
 *                      'true', if the value before converting is "true" 
 *                      'false', if the value before converting is "false"
 *                       null, if the value before converting is null
 */
function bool_to_varchar2(p_input boolean) return varchar2 deterministic;


/**
 * Convert varchar2 string "true" or "false" values to bool "true" or "false" value 
 *
 * @param p_input [nullable] - a bool value for converting
 * @return        [nullable] the value after converting:
 *                      'true', if the value before converting is "true" 
 *                      'false', if the value before converting is "false"
 *                       null, if the value before converting is null
 */
function varchar2_to_bool(p_input varchar2) return boolean deterministic;

/**
 * Convert integer value "1" or "0" value to bool "true" or "false" value 
 *
 * @param p_input [nullable] - a bool value for converting
 * @return        [nullable] the value after converting:
 *                      '1', if the value before converting is "true" 
 *                      '0', if the value before converting is "false"
 *                      null, if the value before converting is null
 */
function number_to_bool(p_input number) return boolean deterministic;

end assert_util;
/
create or replace package body assert_util is

procedure assert_is_not_null (
  p_input integer,
  p_name_argument varchar2 default null
) is
begin
  if (p_input is null) then
    error.raise_error(
      p_errcode => error.CODE_VALUE_ARGUMENT_IS_NULL,
      p_errmessage => 'Значение аргумента '||p_name_argument||' должно быть отлично от null');
  end if;
end assert_is_not_null;

procedure assert_is_not_null (
  p_input varchar2,
  p_name_argument varchar2 default null
) is
begin
  if (p_input is null) then
  error.raise_error(
      p_errcode => error.CODE_VALUE_ARGUMENT_IS_NULL,
      p_errmessage => 'Значение аргумента '||p_name_argument||' должно быть отлично от null');
  end if;
end assert_is_not_null;


procedure assert_is_not_null (
  p_input date,
  p_name_argument varchar2 default null
) is
begin
  if(p_input is null) then
    error.raise_error(
      p_errcode => error.CODE_VALUE_ARGUMENT_IS_NULL,
      p_errmessage => 'Значение аргумента '||p_name_argument||' должно быть отлично от null');
  end if;
end assert_is_not_null;


procedure assert_is_not_null (
  p_input boolean,
  p_name_argument varchar2 default null
) is
begin
  if (p_input is null) then
   error.raise_error(
      p_errcode => error.CODE_VALUE_ARGUMENT_IS_NULL,
      p_errmessage => 'Значение аргуменнта '||p_name_argument||' должно быть отлично от null');
  end if;
end assert_is_not_null;


procedure assert_is_null (
  p_input integer,
  p_name_argument varchar2 default null
) is
begin
  if (p_input is not null) then
    error.raise_error(
      p_errcode => error.CODE_VALUE_IS_NOT_NULL,
      p_errmessage => 'Значение аргумента '||p_name_argument||' должно быть null');
  end if;
end assert_is_null;


procedure assert_is_null (
  p_input varchar2,
  p_name_argument varchar2 default null
) is
begin
  if (p_input is not null) then
    error.raise_error(
      p_errcode => error.CODE_VALUE_IS_NOT_NULL,
      p_errmessage => 'Значение аргумента '||p_name_argument||' должно быть null');
  end if;
end assert_is_null;


procedure assert_is_null (
  p_input date,
  p_name_argument varchar2 default null
) is
begin
  if (p_input is not null) then
    error.raise_error(
      p_errcode => error.CODE_VALUE_IS_NOT_NULL,
      p_errmessage => 'Значение аргумента '||p_name_argument||' должно быть null');
  end if;
end assert_is_null;


function bool_to_number(
  p_input boolean
) return integer deterministic is
l_result integer;
begin
  if (p_input) then
    l_result := 1;
  elsif (p_input = false) then
    l_result := 0;
  else
     l_result := null;
  end if;
  return l_result;
end bool_to_number;


function bool_to_varchar2 (
  p_input boolean
) return varchar2 deterministic is
l_result varchar2 (4000 char);
begin
  if (p_input) then
    l_result := 'true';
  elsif (p_input = false) then
    l_result := 'false';
  else
    l_result := null;
  end if;
  return l_result;
end bool_to_varchar2;


function varchar2_to_bool (
  p_input varchar2
) return boolean deterministic is
l_result boolean;
begin
  case
    when p_input = 'true' then  l_result := true;
    when p_input = 'false' then  l_result := false;
    when p_input is null  then  l_result := null;
    else
      error.raise_error (
        p_errcode => error.CODE_INCORRECT_ARGUMENT_VALUE,
        p_errmessage => 'Некорректное значение аргумента'
      );
    end case;
  return l_result;
end varchar2_to_bool;


function number_to_bool(
  p_input number
) return boolean deterministic is
l_result boolean;
begin
  case
    when p_input = 1 then l_result := true;
    when p_input = 0 then l_result := false;
    when p_input is null then l_result := null;
    else
      error.raise_error (
        p_errcode => error.CODE_INCORRECT_ARGUMENT_VALUE,
        p_errmessage => 'Значение аргумента не является 1 или 0'
      );
    end case;
  return l_result;
end number_to_bool;

end assert_util;
/
