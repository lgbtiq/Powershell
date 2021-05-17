<#
Name:       exportDrawIo.ps1
Created:    17.05.2021
Author:     lgbtiq

Description:
    If no input params are given, the script asks for an drawio input file to convert to PDF,
    each tab of the drawio drawing printed on a separate page and nicely cropped. The PDF is
    stored with a similar name in the same path as the drawio file is stored.
    If input parameter is a path, the script searches recursively for drawio files to convert.
    If input parameter is a file, this file is converted.

Input Args:
    arg[0] - (optional) input path of drawio file or one of its parent folders as string



#>

Add-Type -AssemblyName System.Windows.Forms

# init array
$drawfileArray = @()
$drawfile = $args[0]


###############################################################################
# FUNCTIONS PART

# Funciton to export the single *.drawio input file to a single *.pdf, nicely cropped
function Export-DrawIoToPDF {

    Param ([string]$in)

    if (-Not [string]::IsNullOrEmpty($in))
    {
        $pdf = $in.Replace(".drawio", ".pdf")
        $cmd = "C:\Program Files\draw.io\draw.io.exe"
        $prm =  '-x', '-f', '-p', '--crop', '-o', $pdf, $in

        & $cmd $prm
        echo "Suceessfully exported " $pdf
    }

}

###############################################################################
# SCRIPT PART


# if no input parameter is given, ask for file
if ([string]::IsNullOrEmpty($drawfile))
{
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
    $FileBrowser.InitialDirectory = [Environment]::GetFolderPath('Desktop')
    $FileBrowser.Title = "Choose DrawIO File or whole folder to convert to PDF"
    $null = $FileBrowser.ShowDialog()

    $drawfile = $FileBrowser.FileName
}

# if input parameter is a directory, recursively get all drawio files
if ((Get-Item $drawfile) -is [System.IO.DirectoryInfo])
{
    $drawfileArray = (Get-ChildItem -Path $drawfile -Filter *.drawio -Recurse -ErrorAction SilentlyContinue -Force)

    foreach ($file in $drawfileArray)
    {
        Export-DrawIoToPDF -in $file.FullName
    }
}
else
{
    # single file input
    Export-DrawIoToPDF -in $drawfile
}


