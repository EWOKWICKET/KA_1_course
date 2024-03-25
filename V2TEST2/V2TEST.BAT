@ECHO OFF
TASM cmp.asm
TLINK cmp
echo Testing...
echo.>test.res
echo === test1 ===>>test.res
%1 < V2TEST1.IN >>test.res
@REM echo === test2 ===>>test.res
@REM %1 < V2TEST2.IN >>test.res
echo === test3 ===>>test.res
%1 < V2TEST3.IN >>test.res
echo === test4 ===>>test.res
%1 < V2TEST4.IN >>test.res

fc /b test.res v2test.ok
