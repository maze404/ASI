@echo ON
if not exist C:\temp (
    mkdir C:\temp
)
robocopy "%cd%\Data" C:\temp\Data /MIR
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& C:\temp\Data\cb-asi.ps1"