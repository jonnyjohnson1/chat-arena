@echo off

REM Step 1: Download GitHub repo
echo Step 1: Downloading GitHub repository...
git clone https://github.com/jonnyjohnson1/topos-cli
cd topos-cli

REM Step 2: Check if poetry exists and build
where poetry >nul 2>nul
IF %ERRORLEVEL% EQU 0 (
    echo Poetry exists. Building with Poetry...
    poetry build
) ELSE (
    echo Poetry not found. Installing Poetry...
    powershell -Command "Invoke-WebRequest -Uri https://install.python-poetry.org -OutFile install-poetry.py"
    python install-poetry.py
    set PATH=%USERPROFILE%\.poetry\bin;%PATH%
    echo Building with Poetry...
    poetry build
)

REM Step 3: Install the package
echo Step 3: Installing the package...
pip install .

echo Topos package installed!

REM Step 4: Set the spacy trf
which topos
echo "Step 4: Downloading spacy model..."
topos set --spacy trf

echo "Installation complete!"

pause