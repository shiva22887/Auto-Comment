echo "Enter the managed server alerts received." ;
read v_alerts;
echo $v_alerts | sed -r 's/;/\n/g' > alerts.log
for v_alert in `cat alerts.log`
do
echo "**************************************"
v_server=`echo ${v_alert} | awk -F "/" '{print $NF}'`;
cd  /u01/APPLTOP/instance/wlslogs/FADomain/servers/${v_server}/logs;
v_outfile=`ls -ltr *out* | tail -2 | awk {'print $9'} | head -1` ;
v_reason=`grep -o 'crashed|Server shutdown\|stuck threads has exceed\|Killed\|Aborted\|FUSION_APPS_PROV_PATCH_APPID\|The JVM has crashed\|Blocked\|FAAdmin\|Terminating due to java.lang.OutOfMemoryError\|Blocked lock chains\|Blocked trying to get lock\|Thread deadlock detected' $v_outfile --color`;
if [ -z "$v_reason" ]
then 
    v_outfile=`ls -ltr *out* | tail -3 | awk {'print $9'} | head -1` ;
    v_reason=`grep -o 'crashed|Server shutdown\|stuck threads has exceed\|Killed\|Aborted\|FUSION_APPS_PROV_PATCH_APPID\|The JVM has crashed\|Blocked\|FAAdmin\|Terminating due to java.lang.OutOfMemoryError\|Blocked lock chains\|Blocked trying to get lock\|Thread deadlock detected' $v_outfile`;
fi	
case ${v_reason} in
"stuck threads has exceed") echo "${v_server} is down due to Stuck Threads"; v_issue="Stuck Threads"  ;;
"Thread deadlock detected") echo "${v_server} is down due to Thread Deadlock"; v_issue="Thread Deadlock";;
"Terminating due to java.lang.OutOfMemoryError") echo "${v_server} is down due to OOM"; v_issue="OOM" ;;
"FUSION_APPS_PROV_PATCH_APPID") echo "${v_server} was Manually Shut down" v_issue="Manually Shut down" ;;
"Killed") echo "${v_server} is Killed. Please validate Logs."; exit;;
*) echo "Please refer to logs"; exit;;
esac
echo "Enter the Bug Number.";
read v_bug ;
echo "Enter the Mode of restart Auto/Manual" ;
read v_startmode;
echo "Root Cause: Oracle WebLogic Server:${v_alert} was down due to ${v_issue} Customer impact: $v_server related services were not available for customers Bug:$v_bug Mode of Server Restart:Server was ${v_startmode} restarted."
echo " "
done





