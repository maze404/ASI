@echo ON
echo "Creating local temporary storage..."
if not exist C:\temp ( mkdir C:\temp )
echo "Done."
echo "Copying the script files to local storage..."
robocopy "%cd%\Data" C:\temp\Data /MIR
echo "Done."
echo "Starting the script..."
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& C:\temp\Data\cb-asi.ps1"
pause
