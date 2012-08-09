AppOSS介绍
==========

# 系统说明 #
AppOSS是一个自动化的通用运维平台，它的目的是协助devops减少重复劳动，积累运维工作实践。
从功能角度看，AppOSS仅仅是一个基于Web的ssh并发执行工具，这意味着它不会对你的运维工作做过多的干预，你可以使用任何你觉得合适的技术和框架来运维自己的系统

# 安装说明 #
AppOSS作为一个运维自动化平台，主要包括两个部分：Center 和 Agent。前者是一个基于Ruby on Rails的 web 应用，后者是一个基于 erlang 的并发 ssh 处理进程，这里仅介绍Center的安装。

运维平台本身需要与实际的工作环境整合，所以我们让AppOSS Center通过不同的 adapter 来适配到不同的场景中，adapter是一个mountable engine，主要解决应用、机器信息和用户身份如何导入系统的问题。为了让开发者的方便，我们提供了一个简单的 adapter ：apposs\_simple\_adapter，它使用google oauth2来认证用户身份

# 安装步骤 #
* 获取项目代码，进入项目目录
```
git clone git@github.com:taobao/apposs-center.git
cd apposs-center
```
* 根据样例，修改数据库配置
```
cp config/database.yml.sample config/database.yml # add db user and modify this file laster
```
* 根据样例，修改 google oauth 的 client id 和 client secret（应用地址缺省是 http://localhost:3000, callback 地址缺省是 http://localhost:3000/auth/google_oauth2/callback
```
cp config/initializers/omniauth.rb.example config/initializers/omniauth.rb # modify it later
```
* 其它准备
```
mkdir log
bundle install
rake db:create db:migrate
```
* 启动
```
rackup
```
此时用户访问 http://localhost:3000 时将被要求使用google帐号授权，登录后就可以看到首页了

