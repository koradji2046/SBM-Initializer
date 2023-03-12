:: Usage - careat-project <proj> [corp]

set corp=%2
set proj=%1
if not defined corp set corp=xflib
if not defined proj set proj=test

set root=%corp%-%proj%
mkdir %root%
call :copyPom xflib-prod01.pom %root%\pom.xml

::call :createJar dependencies pom
call :createJar parent pom pom
call :createJar common
call :createJar utils
call :createJar business
call :createService

call :compile

goto :end

:createJar
set subProj=%1
set projType=%2
set subRoot=%root%\%root%-%subProj%
if not "%projType%" == "pom" (
  mkdir %subRoot%\src\main\java\com\%corp%\%proj%
  mkdir %subRoot%\src\main\resources\META-INF
) else (
  mkdir %subRoot%
)
call :copyPom xflib-prod01-%subProj%.pom %subRoot%\pom.xml
::copy xflib-prod01-%subProj%.pom %subRoot%\pom.xml
::call :replace %subRoot%\pom.xml prod01 %proj%
goto :eof

:createService
set subRoot=%root%\%root%-service
mkdir %subRoot%
mkdir %subRoot%\src\main\java\com\%corp%\%proj%
mkdir %subRoot%\src\main\resources\config
mkdir %subRoot%\src\main\resources\META-INF
call :copyPom xflib-prod01-service.pom %subRoot%\pom.xml
::copy xflib-prod01-service.pom %subRoot%\pom.xml
::call :replace %subRoot%\pom.xml prod01 %proj%
copy application.yml %subRoot%\src\main\resources\config\application.yml
>%subRoot%\src\main\java\com\%corp%\%proj%\Bootstrap.java echo package com.%corp%.%proj%;
>>%subRoot%\src\main\java\com\%corp%\%proj%\Bootstrap.java type Bootstrap.java
goto :eof

:replace
set fileName=%1
set sourceString=%2
set newString=%3
start replace.vbs
goto :eof

:: copyPom <sourcePomFile> <targetPomFile>
:copyPom
set src=%~1
set pom=%~2
copy %src% %pom%
call :replace %pom% prod01 %proj%
call :replace %pom% xflib %corp%
goto :eof

:compile
pushd %cd%
cd %root%
call mvn clean package
call mvn clean dependency:tree
popd
goto :eof

:end