@echo off
REM Simple Windows batch script to run symbolic execution

echo ================================================================================
echo GALETTE SYMBOLIC EXECUTION - VITRUVIUS MODEL TRANSFORMATION
echo ================================================================================
echo.

REM Check JAVA_HOME
if not defined JAVA_HOME (
    echo ERROR: JAVA_HOME is not set
    echo Please set JAVA_HOME to your JDK installation
    exit /b 1
)

echo JAVA_HOME: %JAVA_HOME%
echo.

REM Set directories
set GALETTE_DIR=C:\Users\10239\galette-vitruv
set AMATHEA_DIR=C:\Users\10239\Amathea-acset

echo Galette directory: %GALETTE_DIR%
echo Amathea directory: %AMATHEA_DIR%
echo.

REM Build if needed
echo Step 1: Checking Galette build...
if not exist %GALETTE_DIR%\knarr-runtime\target\classes\edu\neu\ccs\prl\galette\vitruvius\VitruvSymbolicExecutionExample.class (
    echo Building knarr-runtime...
    cd /d %GALETTE_DIR%\knarr-runtime
    call mvn compile -DskipTests -Dcheckstyle.skip=true
    if errorlevel 1 (
        echo ERROR: Build failed
        exit /b 1
    )
)
echo OK Galette classes found
echo.

echo Step 2: Checking Amathea-acset build...
if not exist %AMATHEA_DIR%\vsum\target\classes (
    echo Building Amathea-acset...
    cd /d %AMATHEA_DIR%
    call mvn compile -DskipTests -Dcheckstyle.skip=true
    if errorlevel 1 (
        echo ERROR: Amathea build failed
        exit /b 1
    )
)
echo OK Amathea classes found
echo.

echo Step 3: Building classpath...

REM Get Amathea classpath
cd /d %AMATHEA_DIR%\vsum
if not exist target\classpath.txt (
    call mvn dependency:build-classpath -Dmdep.outputFile=target\classpath.txt -q
)

set /p VSUM_CLASSPATH=<target\classpath.txt
set VSUM_CLASSPATH=%AMATHEA_DIR%\vsum\target\classes;%AMATHEA_DIR%\consistency\target\classes;%AMATHEA_DIR%\model\target\classes;%VSUM_CLASSPATH%

REM Get Galette classpath
cd /d %GALETTE_DIR%\knarr-runtime
if not exist target\classpath.txt (
    call mvn dependency:build-classpath -Dmdep.outputFile=target\classpath.txt -q
)

set /p KNARR_CLASSPATH=<target\classpath.txt
set KNARR_CLASSPATH=%GALETTE_DIR%\knarr-runtime\target\classes;%KNARR_CLASSPATH%

REM Combine
set FULL_CLASSPATH=%KNARR_CLASSPATH%;%VSUM_CLASSPATH%

echo OK Classpath built
echo.

echo ================================================================================
echo Running symbolic execution...
echo ================================================================================
echo.

REM Change to galette-vitruv for output
cd /d %GALETTE_DIR%

REM Run
java -cp "%FULL_CLASSPATH%" edu.neu.ccs.prl.galette.vitruvius.VitruvSymbolicExecutionExample

if errorlevel 1 (
    echo.
    echo ================================================================================
    echo ERROR: Symbolic execution failed
    echo ================================================================================
    exit /b 1
)

echo.
echo ================================================================================
echo SUCCESS: Symbolic execution completed!
echo ================================================================================
echo.

REM Check for output
if exist galette-output-* (
    echo Output directories created in galette-vitruv
    echo.
)

echo Done!
