Function GetLaptopName
{
$UserResponse= [System.Windows.Forms.MessageBox]::Show("Does this Laptop have an Ethernet Port?" , "Status" , 4)

if ($UserResponse -eq "Yes" ) 
{
#variable to grab mac address and gets rid of the dashes in the mac address
$MAC= Get-NetAdapter -name "Ethernet" | Select-Object MacAddress | ForEach-Object {$_.MacAddress -replace "-",""}
#cuts the mac address down to the last 4 characters used in the naming process
$grabMAC = $MAC.Substring($MAC.get_Length()-4)
} 

else 

{ 
#variable to grab mac address and gets rid of the dashes in the mac address
$MAC= Get-NetAdapter -name "Wi-Fi" | Select-Object MacAddress | ForEach-Object {$_.MacAddress -replace "-",""}
#cuts the mac address down to the last 4 characters used in the naming process
$grabMAC = $MAC.Substring($MAC.get_Length()-4)
} 
#shows the model type and gets rid of all spaces within the name
$grabserialnumber = wmic bios get serialnumber
$grabserialnumber
$grabModel = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Model | ForEach-Object {$_.Model -replace " ", ""}
#Switch used to detect the model of the computer and set the number associated with the model to it 
#Add additional units in by changing the computer name within "....." make sure there are no spaces! **MAKE SURE COMPUTER NAME MATCHES WHAT SHOWS UP IN "grabModel"**
#Change the $grabModel variable in order to change what the assigned number is to the laptop
$fixModel = "nothing"
Switch ($grabModel)
{  
#can change out {$_ -contains "HPZBook"} for the exact name "HPZBook15uG4" no brackets necessary like this: "HPZBook15uG4" {$grabModel = "HP22" }
{$grabModel -contains "HPZBook15u"} {$fixModel = "HP22" }
{$_ -contains "HPZBookStudioG3"} {$fixModel = "HP23" }
{$_ -contains "HPEliteBook850"} {$fixModel = "HP12" }
{$_ -contains "Precision5520"} {$fixModel = "DE32" }
{$_ -contains "Precision5530"} {$fixModel = "DE35" }
{$_ -contains "XPS13"} {$fixModel = "DE11" }
{$_ -contains "XPS15"} {$fixModel = "DE21" }
{$_ -contains "SurfaceBook2"} {$fixModel = "MS32" }
{$_ -contains "SurfacePro3"} {$fixModel = "MS38" }
{$_ -contains "HPZbookstudioG5"} {$fixModel = "HP25" }
{$_ -contains "HPZbookstudio14uG5"} {$fixModel = "HP85" }
{$_ -contains "HPZbookstudio14uG6"} {$fixModel = "HP86" }
}

#Detects whether the machine is a laptop or not, if so it sets itself to "L" for laptop otherwise it automatically defaults to "D" for desktop
Function Laptop
{
Param( [string]$computer = “localhost” )
$isLaptop = $false
#Checks if the machine’s chasis type is 9.Laptop 10.Notebook 14.Sub-Notebook if it is any of these it is a laptop
if(Get-WmiObject -Class win32_systemenclosure -ComputerName $computer | Where-Object { $_.chassistypes -eq 9 -or $_.chassistypes -eq 10 -or $_.chassistypes -eq 14})
{ $isLaptop = $true }
#Checks if there is a battery status , if true then the machine is considered a laptop (Desktops dont run on battery /giphy silly)
if(Get-WmiObject -Class win32_battery -ComputerName $computer)
{ $isLaptop = $true }
$isLaptop
}
If(Laptop) { $Detect = “L” } 
else { $Detect = “D”} 

#Function InputDate will take user input for the date (MMYY ex. 1219 for December 2019)
function InputDate([string]$Message, [string]$WindowTitle, [string]$DefaultText)
{ Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Windows.Forms
    <#
    originally based on the code shown at http://technet.microsoft.com/en-us/library/ff730941.aspx
    .DESCRIPTION
    Prompts the user with a multi-line input box and returns the text they enter, or null if they cancelled the prompt.
    .PARAMETER Message
    The message to display to the user explaining what text we are asking them to enter.
    .PARAMETER WindowTitle
    The text to display on the prompt window's title.
    .PARAMETER DefaultText
    The default text to show in the input box.
    #>
    #input parameters
     $Message = "Please enter laptop warranty date"
     $WindowTitle = "Warranty Date"

    # Create the Label.
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Size(10,10)
    $label.Size = New-Object System.Drawing.Size(320,20)
    $label.AutoSize = $true
    $label.Text = $Message

    # Create the TextBox used to capture the user's text.
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Size(40,40)
    $textBox.Size = New-Object System.Drawing.Size(225,200)
    $textBox.AcceptsReturn = $false
    $textBox.AcceptsTab = $false
    $textBox.Multiline = $false
    $textBox.ScrollBars = 'Both'
    $textBox.Text = $DefaultText

    # Create the OK button.
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Size(115,250)
    $okButton.Size = New-Object System.Drawing.Size(75,25)
    $okButton.Text = "OK"
    $okButton.Add_Click({ $form.Tag = $textBox.Text; $form.Close() })

    <# Create the Cancel button.
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Size(510,250)
    $cancelButton.Size = New-Object System.Drawing.Size(75,25)
    $cancelButton.Text = "Cancel"
    $cancelButton.Add_Click({ $form.Tag = $null; $form.Close() })
    #>

    # Create the form.
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $WindowTitle
    $form.Size = New-Object System.Drawing.Size(350,120)
    $form.FormBorderStyle = 'FixedSingle'
    $form.StartPosition = "CenterScreen"
    $form.AutoSizeMode = 'GrowAndShrink'
    $form.Topmost = $True
    $form.AcceptButton = $okButton
    $form.CancelButton = $cancelButton
    $form.ShowInTaskbar = $true

    # Add all of the controls to the form.
    $form.Controls.Add($label)
    $form.Controls.Add($textBox)
    $form.Controls.Add($okButton)
    $form.Controls.Add($cancelButton)

    # Initialize and show the form.
    $form.Add_Shown({$form.Activate()})
    $form.ShowDialog() > $null  # Trash the text of the button that was clicked.

    # Return the text that the user entered.
    return $form.Tag
}
$getdate = InputDate
#output string for laptop naming
$CN = $Detect + $fixModel + "-" + $getdate + "-" + $grabMAC +$Manufact

$CN
}
$laptopname = GetLaptopName
$laptopname

function Printlaptopname([string]$Message, [string]$WindowTitle, [string]$DefaultText)
{ Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Windows.Forms
    <#
    originally based on the code shown at http://technet.microsoft.com/en-us/library/ff730941.aspx
    .DESCRIPTION
    Prompts the user with a multi-line input box and returns the text they enter, or null if they cancelled the prompt.
    .PARAMETER Message
    The message to display to the user explaining what text we are asking them to enter.
    .PARAMETER WindowTitle
    The text to display on the prompt window's title.
    .PARAMETER DefaultText
    The default text to show in the input box.
    #>
    #input parameters
     $Message = "Copy/Paste this Laptop Name"
     $WindowTitle = "Laptop Name"
     $DefaultText = $laptopname

    # Create the Label.
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Size(10,10)
    $label.Size = New-Object System.Drawing.Size(320,20)
    $label.AutoSize = $true
    $label.Text = $Message

    # Create the TextBox used to capture the user's text.
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Size(40,40)
    $textBox.Size = New-Object System.Drawing.Size(225,200)
    $textBox.AcceptsReturn = $false
    $textBox.AcceptsTab = $false
    $textBox.Multiline = $false
    $textBox.ScrollBars = 'Both'
    $textBox.Text = $DefaultText

    # Create the OK button.
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Size(115,250)
    $okButton.Size = New-Object System.Drawing.Size(75,25)
    $okButton.Text = "OK"
    $okButton.Add_Click({ $form.Tag = $textBox.Text; $form.Close() })

    <# Create the Cancel button.
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Size(510,250)
    $cancelButton.Size = New-Object System.Drawing.Size(75,25)
    $cancelButton.Text = "Cancel"
    $cancelButton.Add_Click({ $form.Tag = $null; $form.Close() })
    #>

    # Create the form.
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $WindowTitle
    $form.Size = New-Object System.Drawing.Size(350,120)
    $form.FormBorderStyle = 'FixedSingle'
    $form.StartPosition = "CenterScreen"
    $form.AutoSizeMode = 'GrowAndShrink'
    $form.Topmost = $True
    $form.AcceptButton = $okButton
    $form.CancelButton = $cancelButton
    $form.ShowInTaskbar = $true

    # Add all of the controls to the form.
    $form.Controls.Add($label)
    $form.Controls.Add($textBox)
    $form.Controls.Add($okButton)
    $form.Controls.Add($cancelButton)

    # Initialize and show the form.
    $form.Add_Shown({$form.Activate()})
    $form.ShowDialog() > $null  # Trash the text of the button that was clicked.

    # Return the text that the user entered.
    return $form.Tag
}
Printlaptopname
