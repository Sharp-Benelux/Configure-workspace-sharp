set-executionpolicy Unrestricted -force
import-module burnttoast

#Is alleen nodig bij de eerste afdraai van de scripting dus tovoegen met de install-modules hierboven; Checking if ToastReboot:// protocol handler is present
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -erroraction silentlycontinue | out-null
$ProtocolHandler = get-item 'HKCR:\ToastReboot' -erroraction 'silentlycontinue'
if (!$ProtocolHandler) {
    #create handler for reboot
    New-item 'HKCR:\ToastReboot' -force
    set-itemproperty 'HKCR:\ToastReboot' -name '(DEFAULT)' -value 'url:ToastReboot' -force
    set-itemproperty 'HKCR:\ToastReboot' -name 'URL Protocol' -value '' -force
    new-itemproperty -path 'HKCR:\ToastReboot' -propertytype dword -name 'EditFlags' -value 2162688
    New-item 'HKCR:\ToastReboot\Shell\Open\command' -force
    set-itemproperty 'HKCR:\ToastReboot\Shell\Open\command' -name '(DEFAULT)' -value 'C:\Windows\System32\shutdown.exe -r -t 00' -force
}

#onderstaande stuurt de scripting weg naar de ingelogde gebruikers met de juiste foto's, voor meer informatie over de documentatie en parameters van dit script zie https://github.com/Windos/BurntToast
$scriptblock = {
    $heroimage = New-BTImage -Source 'https://www.sharp.nl/sites/default/files/styles/328w/public/2021-10/Sharp_IT%20Services_CMYK_1000%20750.png' -HeroImage
    $Text1 = New-BTText -Content  "Uw computer wordt na 10 minuten opnieuw opgestart"
    $Text2 = New-BTText -Content "Sharp IT services heeft updates geïnstalleerd. U kunt hieronder kiezen voor nu herstarten of het uitstellen hiervan"
    $Button = New-BTButton -Content "Uitstellen" -snooze -id 'SnoozeTime'
    $Button2 = New-BTButton -Content "Nu herstarten" -Arguments "ToastReboot:" -ActivationType Protocol
    $5Min = New-BTSelectionBoxItem -Id 5 -Content '5 minuten'
    $10Min = New-BTSelectionBoxItem -Id 10 -Content '10 minuten'
    $1Hour = New-BTSelectionBoxItem -Id 60 -Content '1 uur'
    $Items = $5Min, $10Min, $1Hour
    $SelectionBox = New-BTInput -Id 'SnoozeTime' -DefaultSelectionBoxItemId 10 -Items $Items
    $action = New-BTAction -Buttons $Button, $Button2 -inputs $SelectionBox
    $Binding = New-BTBinding -Children $text1, $text2 -HeroImage $heroimage
    $Visual = New-BTVisual -BindingGeneric $Binding
    $Content = New-BTContent -Visual $Visual -Actions $action
    Submit-BTNotification -Content $Content
}

invoke-ascurrentuser -scriptblock $scriptblock