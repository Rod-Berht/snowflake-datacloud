use database YOUR_DATABASE;
use schema YOUR_SCHEMA;

set sf_parameter_logging='parm:dbms_output';
select $sf_parameter_logging as parm_log from dual;
-- parm:dbms_output

call setvariable('sf_session_logging','sess:dbms_output');
select getvariable('sf_session_logging') as sess_log from dual;
-- sess:dbms_output

create or replace procedure JS_DEMO_LOGGING()
  returns variant
  language javascript
  execute as caller  
as $$
  var vParmLog = '', vSessLog = '';
  dbms_output_init = function() {
    var oSqlCall = snowflake.createStatement({sqlText:
      "select $sf_parameter_logging as c1, getvariable('sf_session_logging') as c2 from dual"
      }).execute(); 
    if (oSqlCall.next()) {
      vParmLog = oSqlCall.getColumnValue(1);
      vSessLog = oSqlCall.getColumnValue(2);
    }
  }
  dbms_output_line = function(pMessage) {
    vParmLog += ":P:"+pMessage;
    vSessLog += ":S:"+pMessage;
  }
  dbms_output_flush = function() {
    var oSqlCall = snowflake.createStatement({sqlText:"set sf_parameter_logging = ?",binds:[vParmLog]}).execute(); 
        oSqlCall = snowflake.createStatement({sqlText:"call setvariable('sf_session_logging',?)",binds:[vSessLog]}).execute(); 
  }
  dbms_output_init();
  dbms_output_line("log1");
  dbms_output_line("log2");
  dbms_output_flush();
  var vReturn = "return:"+vParmLog+":"+vSessLog;
  return vReturn;
$$;
call JS_DEMO_LOGGING();
-- return:parm:dbms_output:P:log1:P:log2:sess:dbms_output:S:log1:S:log2

select $sf_parameter_logging as parm_log from dual;
-- parm:dbms_output:P:log1:P:log2

select getvariable('sf_session_logging') as sess_log from dual;
-- sess:dbms_output:S:log1:S:log2
