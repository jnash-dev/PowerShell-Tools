$key = '{018D5C66-4533-4307-9B53-224DE2ED1FE6}'
$reg32 = 'HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}'
$reg64 = 'HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}'

$test32 = Test-Path -Path $reg32 #-PathType Leaf
If ($test32 -eq $True) {
Write-Host "Removing $reg32"
Stop-Process -Name "Explorer"
Remove-Item $reg32 -Recurse -Force
#Start-Process Explorer.exe
}

$test64 = Test-Path -Path $reg64 #-PathType Leaf
If ($test64 -eq $True) {
Write-Host "Removing $reg64"
Stop-Process -Name "Explorer"
Remove-Item $reg64 -Recurse -Force
Start-Process explorer.exe
}
