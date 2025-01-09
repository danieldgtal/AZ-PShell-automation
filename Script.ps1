Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force

Connect-AzAccount

#Variable declaration
$rg_name = "rg"
$storage_name = "dchiatuiro"
$cont_name = "cont1"
$cont_name2 = "cont2"

#Creating new resource group 
New-AzResourceGroup -Name $rg_name -Location 'East US'    

#Creating new storage account
New-AzStorageAccount -ResourceGroupName $rg_name -Name $storage_name -SkuName Standard_LRS -Location 'East US'-Kind StorageV2 -AccessTier Hot

#Store resource Group and storage account in a variable
$r_group = Get-AzResourceGroup -ResourceGroupName $rg_name
$s_account = Get-AzStorageAccount -ResourceGroupName $rg_name -Name $storage_name

##Creating a container - Task 1.1 
New-AzStorageContaine -Name $cont_name -Context $s_account.Context


##Creating txt files and uploading files to container - Task 1.2

#Create txt files script path
$scriptPath = "C:\Users\danie\Downloads\CAA-01\DSM760\assignment\1\createfiles.ps1"

#Execute creation of new files 
& $scriptPath

#Get all .txt files
$files = Get-ChildItem -Path . -Filter *.txt

#Loop through all .txt files and upload it to Azure Storage Container
foreach($file in $files) {
    try {
        #Upload the file to the Azure Storage Container
        Set-AzStorageBlobContent -File $file.FullName -Container $cont_name -Context $s_account.Context

        
        #output a message to confirm file upload
        Write-Host "Uploaded $($file.Name) to container $cont_name"
    }
    catch {
        # Output a message if the file upload failed
        Write-Host "Failed to upload $($file.Name) to container $cont_name. Error: $_"
    }
   

}


#Creating container 2 and copy blobs from cont1 to cont2 - Task 1.3 
New-AzStorageContaine -Name $cont_name2 -Context $s_account.Context

#Get all blobs in container 1 
$cont1_blobs = Get-AzStorageBlob -Container $cont_name -Context $s_account.Context

#Copy each blob from cont1 to cont2
foreach ($blob in $cont1_blobs) {
    $cont1_blob_uri = $blob.ICloudBlob.Uri.AbsoluteUri
    $cont2_blob_name = $blob.Name

    # Start the copy operation
    Start-AzStorageBlobCopy -SrcUri $cont1_blob_uri -DestContainer $cont_name2 -DestBlob $cont2_blob_name -Context $s_account.Context
    Write-Host "Copied $($blob.Name) to container $cont_name2"
}

#list the blobs from the cont2 - Task 1.4
#store all blobs in a variable
$cont2_blobs = Get-AzStorageBlob -Container $cont_name2 -Context $s_account.Context

#list all blobs 
echo $cont2_blobs 

#change any single blob from hot to cool - Task 2.1
$cont2_file1 = $cont2_blobs[0]
$cont2_file1.BlobClient.SetAccessTier('cool') #set blobfile to cool


#Download a blob from azure storage to local pc -Task 2.2 
$cont2_file2 = $cont2_blobs[1]
$localpath = "C:\Users\danie\Downloads\CAA-01\DSM760\assignment\1\"

# Download the blob to the local file path
Get-AzStorageBlobContent -Container $cont_name2 -Blob $cont2_file2.Name -Destination $localpath\$mod_cont2_file2 -Context $s_account.Context


#Remove/delete a blob file
$last_file = $cont2_blobs[-1] # Gets last file in the container

Remove-AzStorageBlob -Container $cont_name2 -Blob $last_file.Name -Context $s_account.Context #Removes the last file 



