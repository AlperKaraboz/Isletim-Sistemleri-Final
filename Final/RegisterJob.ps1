$action =
    {
        $cpu = 2;
        $saniye = 3
        $logPath = "LOGLAR/"
        for (;;)
        {
            $tmp = Get-WmiObject Win32_PerfFormattedData_PerfProc_Process |
            select-object -property Name, @{Name = "CPU"; Expression = {($_.PercentProcessorTime/ (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors)}} |
            Where-Object {($_.Name -notmatch "^(idle|_total|system)$") -and ($_.CPU -GE $cpu)} |
            Sort-Object -Property CPU -Descending;
            cls;
            New-Item -ItemType Directory -Force -Path $logPath
            $name = (get-date).tostring("yyyy-MM-dd")
            If ($tmp.count -gt 0) {
                 "Kullanimi gecen%" + $cpu + [Environment]::NewLine + (get-date).tostring("HH:mm:ss")  >> ($logPath + $name + ".log")
                $tmp | Format-Table -Autosize -Property Name, CPU >> ($logPath + $name + ".log")
            }else{
                "Cpu Kullanimi gecen yok  %" + $cpu + [Environment]::NewLine + (get-date).tostring("HH:mm:ss") >> ($logPath + $name + ".log")
            }
            Start-Sleep -Seconds $saniye
        }
    }
$trigger = New-JobTrigger -Once -at (Get-Date).AddSeconds(5)
$opt = New-ScheduledJobOption -RunElevated -RequireNetwork
Register-ScheduledJob "MyJob" -Trigger $trigger -ScheduledJobOption $opt -ScriptBlock $action