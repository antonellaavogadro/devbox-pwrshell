param(
     [Parameter()]
     [string]$command
 )

# We are adding this file as an additional layer
# between the devbox.yaml file invoking this task
# and the actual execution of the command.
# The main goal is to ensure we do any additional
# I/O here ahead of running the command on the metal.
# Note we're calling powershell.exe directly, instead
# of running Invoke-Expression, as suggested by
# https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/avoid-using-invoke-expression?view=powershell-7.3
# Also, note that this will run powershell.exe
# even if the system has pwsh.exe.

# Write the contents of the command string to a temporary file and append the extension .ps1 to it
$commandFile = [System.IO.Path]::GetTempFileName() + ".ps1"
Write-Output "Writing command to $commandFile"
$command | Out-File -FilePath $commandFile -Encoding ascii

# run the command file using powershell.exe
Write-Output "Running command $commandFile"
powershell.exe -File $commandFile
$commandExitCode = $LASTEXITCODE
Write-Output "Command exited with code $commandExitCode"

# Clean up the command file
Write-Output "Deleting command file $commandFile"
# Remove-Item -Path $commandFile

# Task powershell scripts should always end with an
# exit code reported up to the runner agent.
exit $commandExitCode

