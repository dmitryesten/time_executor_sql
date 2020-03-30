create table user_chat (
    id_user integer,
    nickname nvarchar2(20),
    age integer,
    gender nchar,
    constraint pk_id_user primary key (id_user)
);
/
create procedure create_rand_user_chat(p_number_rows integer default 500) is
    C_MIN_VALUE constant integer := 1;
    C_MAX_VALUE constant integer := 99999999999;
    C_MIN_NUMBER_CHARS constant integer := 6;
    C_MAX_NUMBER_CHARS constant integer := 20;
    C_MIN_USER_AGE constant integer := 16;
    C_MAX_USER_AGE constant integer := 100; 
    
    l_nubmer_rows integer := p_number_rows; 
begin
    insert into user_chat (id_user, nickname, age, gender)
    select 
        round(dbms_random.value(C_MIN_VALUE, C_MAX_VALUE)) id_user,
        dbms_random.string('x', dbms_random.value(C_MIN_NUMBER_CHARS, C_MAX_NUMBER_CHARS)) nickname,
        round(dbms_random.value(C_MIN_USER_AGE, C_MAX_USER_AGE)) age,
        case round(dbms_random.value)
            when 1 then 'M' else 'F'
        end case   
    from dual 
    connect by 1=1 and rownum <=l_nubmer_rows;
end create_rand_user_chat;