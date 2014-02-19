#!/bin/sh
# func:自动监控tomcat脚本并且执行重启            操作
# author:刘良祥
# date:16/11/2013

# 定义环境变量
export JAVA_HOME=/usr/jdk1.6.0_45
export CLASSPATH=$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin
# DEFINE

# 获取tomcat进程ID
TomcatID=$(ps -ef |grep tomcat|grep -w 'tomcat_web'|grep -v 'grep'|awk '{print $2}')

# tomcat启动程序(这里注意tomcat实际安装的路径)
StartTomcat=/usr/tomcat_web/bin/startup.sh
TomcatCache=/usr/tomcat_web/work


# 定义要监控的页面地址 
WebUrl=http://www.xygezi.com

# 日志输出
GetPageInfo=/usr/tomcat_web/liulxiang/tmp/TomcatMonitor.Info
TomcatMonitorLog=/usr/tomcat_web/liulxiang/tmp/TomcatMonitor.log

Monitor()
{
  echo "[info]开始监控tomcat...[$(date +'%F %H:%M:%S')]"
  
  if($TomcatID>0);then  # 这里判断TOMCAT进程是否存在
    echo "[info]当前tomcat进程ID为:$TomcatID,继续检测页面..."
    
    # 检测是否启动成功(成功的话页面会返回状态"200")
    
    TomcatServiceCode=$(curl -s -o $GetPageInfo -m 10--connect-timeout 10 $WebUrl -w %{http_code})
    
    if($TomcatServiceCode -eq 200);then
        echo "[info]页面返回码为$TomcatServiceCode,tomcat启动成功,测试页面正常......"
    else
        echo "[error]tomcat页面出错,请注意......状态码为$TomcatServiceCode,错误日志已输出到$GetPageInfo"
        echo "[error]页面访问出错,开始重启tomcat"
        kill -9 $TomcatID  # 杀掉原tomcat进程
        sleep 3
        rm -rf $TomcatCache # 清理tomcat缓存
        $StartTomcat
    fi
  else
    echo "[error]tomcat进程不存在!tomcat开始自动重启..."
    echo "[info]$StartTomcat,请稍候......"
    rm -rf $TomcatCache
    $StartTomcat 
  fi
  echo "------------------------------"
}
Monitor>>$TomcatMonitorLog
