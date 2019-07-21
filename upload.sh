#!/bin/bash

#配置文件变量初始化
repoUrl=`sed '/^repoUrl=/!d;s/.*=//' ./conf/upload.conf` 

#可以上传的格式,添加只需满足 |txt|*|....这个格式
format=`sed '/^format=/!d;s/.*=//' ./conf/upload.conf`

#github图床的基本路径
baseURL=`sed '/^baseURL=/!d;s/.*=//' ./conf/upload.conf`

#Define新建仓库function CreateRepo
CreateRepo(){
	echo "====================Initing repo....:===================="
	
	if [ ${repoUrl} == " "]
	then
	   echo "仓库地址为空，请到conf/upload.conf里配置仓库地址后再执行Shell"
	   fileflag=false
	else
	   echo "================检测到配置仓库地址:======================"
	   git init #| tee log.s
		mkdir -p images
		mkdir -p log
		mkdir -p conf
	   echo "==============you remote repo URL is :==================="
	   echo "====>>>>${repoUrl}" 
	   fileflag=true
	fi
	#起个别名picture
	git remote add picture ${repoUrl} 
	git remote -v
	echo "====>>>>your repo Url is ${repoUrl}"
}

#Define上传图片function
#目前只能增加上传图片，删除什么的有问题
upload(){
echo "=================Prepare for the upload==================="

#1.解决很长时间没有使用的仓库push出现Updates were rejected because the tip of your current branch is behind的问题
#2.解决在本地用git add remore origin添加远程库push出现的问题，问题同上

git status images/ >picList.list

grep -E "${format}" picList.list >log/name.list 
grep -E "${format}" picList.list >>log/_history.log

rm -f picList.list
#echo "===============auto merge conflicts start=================" 
#git pull picture master --allow-unrelated-histories  
#git add . 
#git commit -m"auto merge conflicts"  
#echo "===============auto merge conflicts end===================" 

#cat ./name.s |awk  -F ' '  '{print $1}' 

git add .
echo "<<<<<<==========Enter your commit Message:=========>>>>>>>>"
read commit

echo "your commit is：${commit}"
echo -e "\n"
echo "===================git commiting...======================="
git commit -m"${commit}"
echo -e "\n"
echo "===================git pushing...========================="

echo "===============auto merge conflicts start=================" 
git pull picture master --allow-unrelated-histories  
git add . 
git commit -m"auto merge conflicts"  
echo "===============auto merge conflicts end===================" 

git push picture master

#echo "===================git push successful===================="

#echo repoUrl=${repoUrl}

#拼接返回的图片URL
arr=(${repoUrl///// })  #按/划分URL，存在数组中
tmpURL=${baseURL}${arr[3]}${arr[4]}
picURL=${tmpURL%.*}
#echo ${picURL}

#输出图片URL
LINE=" "
cat ./log/name.list  | while read LINE; do
    if [ "$LINE" = " " ]; 
	then
      echo "没有新增的图片!"
    else 
      echo "picUrl: ${picURL}/master/${LINE}"
    fi
	echo "upload successful...."
    
done;


}
#############################################################
file=".git"
#是否存在仓库
fileflag=false
if [ -d $file ] && [ -e $file ]
then
   echo "======================检测到Git仓库...===================="
   #本身存在的github仓库
   git config -l |grep remote.*.url | awk  -F '='  '{print $2}' > config.conf
   echo "======================Git仓库地址为...===================="
   cat config.conf
   fileflag=true
else
   echo ".git文件目录不存在,是否创建一个新的Git repo？(y/n)"
   read isCreate
   #echo ${isCreate}
   if [ ${isCreate} == y ]
   then
      echo "=====================Create new repo...=================="
	  CreateRepo
   else
      echo "============You choose Do NOT create new repo...========="
	  echo "====================Shell Exiting.....==================="
   fi	  
fi

#存在Git仓库，上传图片
#echo fileflag=${fileflag}
if [ ${fileflag} == true ]
then
   upload
   #echo "upload"  
else
   echo "=============找不到Git仓库，Shell退出执行================"
fi
