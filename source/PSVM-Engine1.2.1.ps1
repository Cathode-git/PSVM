cd $PSScriptRoot
#initialize nircmdc
.\nircmdc.exe beep 0 0

#import key list
$csv = Import-Csv ".\list.csv" -Delimiter ";"

#import dll with C#
$Signature = @'
    [DllImport("user32.dll", CharSet=CharSet.Auto, ExactSpelling=true)] 
    public static extern short GetAsyncKeyState(int virtualKeyCode); 
'@
Add-Type -MemberDefinition $Signature -Name Keyboard -Namespace PsOneApi

$stop = 0

#start the loop
do {

    #loop the app list
    foreach ($row in $csv) {
        $bind = $row.bind
        $app = $row.app
    
        $press = [bool]([PsOneApi.Keyboard]::GetAsyncKeyState($bind) -eq -32767)

        if ($press -eq $true) {
    
            #Write-Host $bind

            #if quit button is pressed quit the engine
            if ($app -eq "Quit PSVM") {
                $stop ++
            } 
            #else check key pressed and adjust app volume
            $increment = $row.increment / 100
            .\nircmdc.exe changeappvolume $app $increment 
        }
		
	}
	#reduce CPU Usage by adding latency to loop
	Start-Sleep -Milliseconds 10
} while ($stop -eq 0)

