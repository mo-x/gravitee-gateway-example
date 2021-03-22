#!/bin/sh

management_path=/var/opt/gateway/graviteeio-full-1.30.0/graviteeio-management-api-1.30.0/plugins/

#
#if [ ! -d $gateway_path"/opt_update"]; then
#  mkdir $gateway_path"/opt_update"
#fi

#下载更新配置文件
wget https://xxxx/gateway_update.json -O gateway_update.json
if [ ! -f 'gateway_update.json' ]; then
  exit
fi

#下载链接地址cat
repository=$(cat gateway_update.json | jq '.repository' | sed 's/\"//g')
len=$(cat gateway_update.json | jq '.plugins|length')
#console print all plugins update

#management进程
api_process=$(ps -ef | grep gravitee.management | grep -v grep | awk '{print $2}')
echo $api_process
#
time=$(date "+%Y-%m-%d")
echo "========本次更新插件列表如下:========" >>update_managementlog-$time.txt
for ((i = 0; i < len; i++)); do
  commond_pre="cat gateway_update.json | jq '.plugins[$i]"
  opt=".opt'"
  # shellcheck disable=SC2089
  #插件名称
  get_name=".name'"
  #获取操作是update/add
  opt_type=$(eval $commond_pre $opt | sed 's/\"//g')
  plugins_name=$(eval $commond_pre $get_name | sed 's/\"//g')
  if [ $opt_type == "add" ]; then
    version=$(eval $commond_pre".version'" | sed 's/\"//g')
    echo "添加插件--->$plugins_name-$version.zip" >>update_managementlog-$time.txt
  elif [ $opt_type == "update" ]; then
    #待更新版本号
    from_version=$(eval $commond_pre".from_version'" | sed 's/\"//g')
    to_version=$(eval $commond_pre".to_version'" | sed 's/\"//g')
    echo "更新插件--->$plugins_name-$from_version.zip 更新为$plugins_name-$to_version.zip" >>update_managementlog-$time.txt
  fi
done

echo "========开始下载插件========" >>update_managementlog-$time.txt
for ((i = 0; i < len; i++)); do
  commond_pre="cat gateway_update.json | jq '.plugins[$i]"
  opt=".opt'"
  # shellcheck disable=SC2089
  #插件名称
  get_name=".name'"
  #获取操作是update/add
  opt_type=$(eval $commond_pre $opt | sed 's/\"//g')
  plugins_name=$(eval $commond_pre $get_name | sed 's/\"//g')
  if [ $opt_type == "add" ]; then
    version=$(eval $commond_pre".version'" | sed 's/\"//g')
    wget $repository$plugins_name"-"$version.zip -O $plugins_name"-"$version.zip
    str=$(curl --connect-timeout 1 -s -w "%{http_code}" -o temp $repository$plugins_name"-"$version.zip)
    if [ ! $str == "200" ]; then
      echo "下载失败====>$repository$plugins_name-$version.zip 地址错误" >>update_managementlog-$time.txt
      exit
    fi
    if [ -f $plugins_name"-"$version.zip ]; then
      echo "下载 ====> $plugins_name-$version.zip 成功" >>update_managementlog-$time.txt
      echo "下载 ====> $plugins_name-$version.zip 成功"
    else
      echo "下载 ====> $plugins_name-$version.zip 失败" >>update_managementlog-$time.txt
      echo "下载 ====> $plugins_name-$version.zip 失败"
      echo "退出本次更新操作" >>update_managementlog.-$time.txt
      exit
    fi
  elif [ $opt_type == "update" ]; then
    #待更新版本号
    from_version=$(eval $commond_pre".from_version'" | sed 's/\"//g')
    to_version=$(eval $commond_pre".to_version'" | sed 's/\"//g')
    str=$(curl --connect-timeout 1 -s -w "%{http_code}" -o temp $repository$plugins_name"-"$to_version.zip)
    if [ ! $str == "200" ]; then
      echo "下载失败====>$repository$plugins_name-$to_version.zip 地址错误" >>update_managementlog-$time.txt
      exit
    fi
    wget $repository$plugins_name"-"$to_version.zip -O $plugins_name"-"$to_version.zip
    if [ -f "$plugins_name-$to_version.zip" ]; then
      echo "下载 ====> $plugins_name-$to_version.zip成功" >>update_managementlog-$time.txt
      echo "下载 ====> $plugins_name-$to_version.zip成功"
    else
      echo "下载 ====>$plugins_name-$to_version.zip失败" >>update_managementlog-$time.txt
      echo "退出本次更新操作" >>update_managementlog.-$time.txt
      exit
    fi
  fi
done
echo "========插件下载完成========" >>update_managementlog-$time.txt

echo "========开始更新插件========" >>update_managementlog-$time.txt

for ((i = 0; i < len; i++)); do
  #操作类型
  commond_pre="cat gateway_update.json | jq '.plugins[$i]"
  opt=".opt'"
  #插件名称
  get_name=".name'"
  #获取操作是update/add
  opt_type=$(eval $commond_pre $opt | sed 's/\"//g')
  plugins_name=$(eval $commond_pre $get_name | sed 's/\"//g')
  if [ $opt_type = "add" ]; then
    echo "添加插件--$plugins_name-$version.zip"
    cp -rf $plugins_name"-"$version.zip $management_path
    if [ -f "$management_path$plugins_name-$version.zip" ]; then
      echo "添加插件到management--$management_path$plugins_name-$version.zip 成功" >>update_managementlog-$time.txt
    fi
  elif [ $opt_type = "update" ]; then
    #待更新版本号
    echo "更新插件--$plugins_name-$to_version.zip"
    from_version=$(eval $commond_pre".from_version'" | sed 's/\"//g')
    to_version=$(eval $commond_pre".to_version'" | sed 's/\"//g')
    cp -rf $plugins_name-$to_version.zip $management_path
    if [ -f "$management_path$plugins_name-$to_version.zip" ]; then
      echo "更新management插件====> $management_path$plugins_name-$to_version.zip 成功" >>update_managementlog-$time.txt
    else
      echo "更新management插件====> $management_path$plugins_name-$to_version.zip 失败" >>update_managementlog-$time.txt
    fi
    rm -f "$management_path$plugins_name-$from_version.zip"
    if [ ! -f "$management_path$plugins_name-$from_version.zip" ]; then
      echo "删除management插件成功====>$management_path$plugins_name-$from_version.zip" >>update_managementlog-$time.txt
    else
      echo "删除management插件失败====>$management_path$plugins_name-$from_version.zip" >>update_managementlog-$time.txt
    fi
  fi
done
echo "========更新插件结束========" >>update_managementlog-$time.txt
echo "========更新插件结束========" >>update_managementlog-$time.txt

management_bin=/var/opt/gateway/graviteeio-full-1.30.0/graviteeio-management-api-1.30.0/bin/gravitee
management_process=$(ps -ef | grep gravitee-management-api-standalone-bootstrap-1.30.0 | grep -v grep | awk '{print $2}')
if [ -n "$management_process" ]; then
  echo "管理进程:$management_process" >>update_managementlog-$time.txt
  kill -9 $management_process
  nohup $management_bin >/dev/null 2>&1 &
else
  nohup $management_bin >/dev/null 2>&1 &
fi
echo "script execute finish"
