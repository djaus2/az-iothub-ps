function trimm{
    param (
    [string]$line='' 
    )
    $line = $line.Trim()
    $line = ($line -split '\n')[0]
    If ([string]::IsNullOrEmpty($line  )){
        return ''
    }
    if ($line[0] -eq '"' ){
        $line = $line.Substring(1)
        $line = $line.Trim()
    }
    If ([string]::IsNullOrEmpty($line  )){
        return ''
    }
    if ($line[$line.length-1] -eq '"' ){
        $line = $line.Substring(0,$line.length-1 )
        $line = $line.Trim()
    }
    return $line
}

function clear-export{
    unset IOTHUB_DEVICE_CONN_STRING 
    unset IOTHUB_CONN_STRING_CSHARP 
    unset REMOTE_HOST_NAME 
    unset REMOTE_PORT 
    unset DEVICE_NAME
    unset DEVICE_ID 
    unset SHARED_ACCESS_KEY_NAME 
    unset EVENT_HUBS_COMPATIBILITY_PATH  
    unset EVENT_HUBS_CONNECTION_STRING 
    unset EVENT_HUBS_SAS_KEY 
    unset EVENT_HUBS_COMPATIBILITY_ENDPOINT  
    unset SERVICE_CONNECTION_STRING 
}

function get-headerinfo{
param (
    [string]$Subscription='' ,
    [string]$GroupName='' ,
    [string]$HubName='' ,
    [string]$DeviceName=''
    )
        #SharedAccesKeyName
        $SharedAccesKeyName='iothubowner'
        write-Host 'Getting IOTHUB_DEVICE_CONN_STRING'
       $cs = az iot hub device-identity connection-string show --hub-name $HubName --device-id $DeviceName  --output json  | out-string
       $IOTHUB_DEVICE_CONN_STRING = ($cs   | ConvertFrom-Json).connectionString
       write-Host $IOTHUB_DEVICE_CONN_STRING
       $config= $IOTHUB_DEVICE_CONN_STRING.Split(";",[System.StringSplitOptions]::RemoveEmptyEntries)
       if($config.Length -eq 3)
       {
            write-host ''
            write-host 'Header Info: Device connecton for C header file for Azure SDK for C Arduino' -BackgroundColor Red  -ForegroundColor Yellow -nonewline
            write-host ''
            write-host 'Ref:    https://github.com/djaus2/Azure_IoT_Hub_Arduino_RPI_Pico_Telemetry'
            write-host '...and  https://github.com/Azure/azure-sdk-for-c-arduino'
            write-host ''
            
            $hostcon= $config[0].Split("=",[System.StringSplitOptions]::RemoveEmptyEntries)
            if($hostcon.Length -eq 2)
            {
                $define0 = '#define IOT_CONFIG_IOTHUB_FQDN '
                $husthub =  "{0} ""{1}""" -f $define0, $hostcon[1].Trim()
                write-host $husthub
            }
            $dev= $config[1].Split("=",[System.StringSplitOptions]::RemoveEmptyEntries)
            if($dev.Length -eq 2)
            {
                $define1 = '#define IOT_CONFIG_DEVICE_ID '
                $deviceId =  "{0} ""{1}""" -f $define1, $dev[1].Trim()
                write-host $deviceId
            }
            $key= $config[2].Split("=",[System.StringSplitOptions]::RemoveEmptyEntries)
            if($key.Length -eq 2)
            {
                $define2 = '#define IOT_CONFIG_DEVICE_KEY '
                $sharedkey = "{0} ""{1}=""" -f $define2, $key[1].Trim()
                write-host $sharedkey
            }
            
            write-host ''
       }
}


function set-export{
    param (
    [string]$Subscription='' ,
    [string]$GroupName='' ,
    [string]$HubName='' ,
    [string]$DeviceName=''
    )

    show-heading '  S E T   E X P O R T  V A R S   '  3

    write-Host ''
    write-Host Note: Environment Variables only exist for the life of the current Shell -BackGroundColor DarkRed -ForeGroundColor White
        write-Host ''
    #SharedAccesKeyName
    $SharedAccesKeyName='iothubowner'
     write-Host 'Getting IOTHUB_DEVICE_CONN_STRING'
    $cs = az iot hub device-identity connection-string show --hub-name $HubName --device-id $DeviceName  --output json  | out-string
    $IOTHUB_DEVICE_CONN_STRING = ($cs   | ConvertFrom-Json).connectionString
    write-Host $IOTHUB_DEVICE_CONN_STRING
    export IOTHUB_DEVICE_CONN_STRING = $IOTHUB_DEVICE_CONN_STRING 


    # Hub Coonection String
    #                             az iot hub connection-string show --name $HubName --policy-name iothubowner --key primary  --resource-group $GroupName --output table
    write-host 'Getting IOTHUB_CONN_STRING_CSHARP'
    $cs = az iot hub connection-string show --name $HubName --policy-name iothubowner --key primary  --resource-group $GroupName --output json  
    $IOTHUB_CONN_STRING_CSHARP = ($cs   | ConvertFrom-Json).connectionString
    write-host $IOTHUB_CONN_STRING_CSHARP
    export IOTHUB_CONN_STRING_CSHARP =$IOTHUB_CONN_STRING_CSHARP 

    
    
    # Service Connection string
     write-host 'Getting Service Connection string'
      $cs = az iot hub connection-string show --policy-name service --name $HubName --output json | out-string
      $SERVICE_CONNECTION_STRING = ($cs   | ConvertFrom-Json).connectionString
      write-host $SERVICE_CONNECTION_STRING
     export SERVICE_CONNECTION_STRING = $SERVICE_CONNECTION_STRING

    #DeviceID
    write-host 'DEVICE_ID'
    $DEVICE_ID = $DeviceName
    write-Host $DEVICE_ID
    export DEVICE_ID = $DEVICE_ID 



    # EventHubsCompatibleEndpoint
    write-host 'Getting EventHubsCompatibleEndpoint'
    $cs =  az iot hub show --query properties.eventHubEndpoints.events.endpoint --name $HubName --output json |out-string
    $cs = trimm($cs)
    $EventHubsCompatibleEndpoint = $cs.Replace('"','')
    write-host $EventHubsCompatibleEndpoint
    export EVENT_HUBS_COMPATIBILITY_ENDPOINT = $EventHubsCompatibleEndpoint
    
    # EventHubsCompatiblePath
    write-host 'Getting EventHubsCompatiblePath'
    $cs = az iot hub show --query properties.eventHubEndpoints.events.path --name $HubName --output json  |out-string
    $cs = trimm $cs
    $EventHubsCompatiblePath = $cs
    write-host $EventHubsCompatiblePath 
    export EVENT_HUBS_COMPATIBILITY_PATH =$EventHubsCompatiblePath


    
    # EventHubsSasKey
    write-host 'Getting EventHubsSasKey'
    $cs = az iot hub policy show --name iothubowner --query primaryKey --hub-name $HubName   |out-string
    $cs = trimm $cs
    $EventHubsSasKey = $cs
    write-host  $EventHubsSasKey
    export EVENT_HUBS_SAS_KEY=$EventHubsSasKey

    # EventHubsConnectionString
    write-host 'Calculating the Builtin Event Hub-Compatible Endpoint Connection String'
    # Endpoint=sb://<FQDN>/;SharedAccessKeyName=<KeyName>;SharedAccessKey=<KeyValue>
    $cs="Enpoint=$EventHubsCompatibleEndpoint;SharedAccessKeyName=$SharedAccesKeyName;SharedAccessKey=$EventHubsSasKey;EntityPath=$EventHubsCompatiblePath"
    $cs = trimm $cs
    $EventHubsConnectionString = $cs
    write-host $EventHubsConnectionString
    export EVENT_HUBS_CONNECTION_STRING = $EventHubsConnectionString

    # The next two are only required by Device Streaming Proxy Hub

    # Remote Host Name
    write-host ''
    write-host 'Next two are only required by Device Streaming SSH/RDP Proxy Quickstart.'
    write-host " See https://docs.microsoft.com/en-us/azure/iot-hub/quickstart-device-streams-proxy-csharp"
    write-host 'REMOTE_HOST_NAME'
    $REMOTE_HOST_NAME = "localhost"
    write-host $REMOTE_HOST_NAME
    export REMOTE_HOST_NAME = $REMOTE_HOST_NAME

    # Remote Port
    write-host 'REMOTE_PORT'
    $REMOTE_PORT  =  2222
    write-host $REMOTE_PORT 
    export REMOTE_PORT = $REMOTE_PORT
    get-anykey
}