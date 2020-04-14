# 主要功能
eye会对服务器的磁盘、内存、DDOS超出自定范围后自动报警

# 安装eye
## 下载eye
```
wget -O eye.sh https://pan.shuaiguoer.com/code/shell/eye/eye_1.sh
```
## 给予eye执行权限
```
chmod a+x eye.sh
```
## 添加计划任务
```
crontab -e
* * * * * /eye绝对路径/eye.sh
```

# 安装mailx
<a href="https://blog.shuaiguoer.com/mailx.html" target="_blank">mailx的安装与使用</a>

# eye更新记录
- 对服务器的磁盘、内存、DDOS超出自定范围后，以邮件的形式报警
- 增加eye配置文件，以修改配置文件的方式，自定义报警触发条件
- 可以交互的方式，修改配置文件：--config
- 增加默认的配置文件，避免不必要的操作
- 添加eye帮助信息：--help
- 添加彩色字体，优化用户体验
- 添加eye状态控制及查看的功能：start | stop | restart | status
- 添加eye版本更新功能：update。可从网盘自动下载最新版本的eye
- eye会记录服务器磁盘、内存、DDOS触发报警的日志
- 将eye加入系统服务：service eye {start | stop | restart | status | update | --config | --help"}
- 将eye加入环境变量：eye {start | stop | restart | status | update | --config | --help"}
- eye增加系统显示信息功能：show
- eye存储网盘添加SSL证书,URL由http修改为:https
- eye版本更新,添加判断是否安装wget(如果没有安装wget,更新时将首先安装wget,再进行下载更新eye)
