@echo off & setlocal enableextensions enabledelayedexpansion
::
:: t.bat - compile & run tests (MSVC).
::

set std=%1
if not "%std%"=="" set std=-std:%std%

set CppCoreCheckInclude=%VCINSTALLDIR%\Auxiliary\VS\include

call :CompilerVersion version
echo VC%version%: %args%

::set    stdspn=-Dspan_CONFIG_SELECT_STD_SPAN=1 -Dspan_CONFIG_SELECT_NONSTD_SPAN=1

set span_contract=^
    -Dspan_CONFIG_CONTRACT_VIOLATION_TERMINATES=0 ^
    -Dspan_CONFIG_CONTRACT_VIOLATION_THROWS=1
    
set span_provide=^
    -Dspan_CONFIG_PROVIDE_CONSTRUCTION_FROM_STDARRAY_ELEMENT_TYPE=1 ^
    -Dspan_CONFIG_PROVIDE_WITH_CONTAINER_TO_STD=99 ^
    -Dspan_CONFIG_PROVIDE_BACK_FRONT=1 ^
    -Dspan_CONFIG_PROVIDE_SWAP=1 ^
    -Dspan_CONFIG_PROVIDE_SAME=1 ^
    -Dspan_CONFIG_PROVIDE_MAKE_SPAN_TO_STD=99 ^
    -Dspan_CONFIG_PROVIDE_BYTE_SPAN=1

cl -W3 -EHsc %std% %stdspn% %span_contract% %span_provide% -DNOMINMAX -I../include/nonstd span-main.t.cpp span.t.cpp && span-main.t.exe
endlocal & goto :EOF

:: subroutines:

:CompilerVersion  version
@echo off & setlocal enableextensions
set tmpprogram=_getcompilerversion.tmp
set tmpsource=%tmpprogram%.c

echo #include ^<stdio.h^>                   >%tmpsource%
echo int main(){printf("%%d\n",_MSC_VER);} >>%tmpsource%

cl /nologo %tmpsource% >nul
for /f %%x in ('%tmpprogram%') do set version=%%x
del %tmpprogram%.* >nul
set offset=0
if %version% LSS 1900 set /a offset=1
set /a version="version / 10 - 10 * ( 5 + offset )"
endlocal & set %1=%version%& goto :EOF
