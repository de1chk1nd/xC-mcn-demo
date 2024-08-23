$file = Get-ChildItem -Path $PSScriptRoot -Filter "*-ssh.pem" -Name
$filename = $file.Split(".")[0]
$path = "$PSScriptRoot\$file"

icacls.exe $path /reset

icacls.exe $path /grant "$($env:USERNAME):(f)"

icacls.exe $path /inheritance:r

& 'C:\Program Files (x86)\WinSCP\winscp.com' /keygen $path /output="$($PSScriptRoot)\$filename.ppk"

putty.exe -i "$($PSScriptRoot)\$filename.ppk" ubuntu@ubuntu-eu-central-1.de1chk1nd-lab.aws
putty.exe -i "$($PSScriptRoot)\$filename.ppk" ubuntu@ubuntu-eu-west-1.de1chk1nd-lab.aws 