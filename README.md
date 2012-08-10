AppOSS介绍
==========

# 系统说明 #
AppOSS是一个自动化的通用运维平台，它的目的是协助devops减少重复劳动，积累运维工作实践。  

AppOSS设计的初衷是对大型的、混合多种类型的互联网应用系统进行运维，它虽然诞生于淘宝的内部需求，但实际场景并不比别人更特别，因此我希望能够对其它类似的场景也有帮助。  

从功能角度看，AppOSS仅仅是一个基于Web的ssh并发执行工具，这意味着它不会对你的运维工作做过多的干预，你可以使用任何你觉得合适的技术和框架来操作自己的系统。

# 安装说明 #
AppOSS作为一个运维自动化平台，主要包括两个部分：Center 和 Agent。前者是一个基于Ruby on Rails的 web 应用，后者是一个基于 erlang 的并发 ssh 处理进程，这个项目是center部分，其它部分请参看后面的`相关项目`。

运维平台本身需要与实际的工作环境整合，所以我们让AppOSS Center通过不同的 adapter 来适配到不同的场景中，adapter是一个mountable engine，主要解决应用、机器信息和用户身份如何导入系统的问题。  
为了让开发者的方便，我们提供了一个简单的 adapter ：apposs\_simple\_adapter，它使用google oauth2来认证用户身份，因此安装时你需要设置好用于认证的google oauth参数。  

支持多个不同的oauth provider通常不是大型互联网企业的需求，因此不是我们的初衷，但是如果你需要这样做，可以看看apposs\_simple\_adapter这个项目，修改它即可。

# 安装步骤 #
获取项目代码，进入项目目录  

	git clone git@github.com:taobao/apposs-center.git   
	cd apposs-center

安装相关gem

	bundle install  

执行安装任务

	rake install:data

	# rake任务内容：
	# 	1.根据样例，修改数据库配置  
	# 		config/database.yml.example -> config/database.yml
	# 	2.根据用户输入，设定 google oauth 的 client id 和 client secret
	# 	（应用地址缺省是 http://localhost:3000, callback 地址缺省是 http://localhost:3000/auth/google_oauth2/callback）   
	#  		config/initializers/omniauth.rb.example -> config/initializers/omniauth.rb
	#	3.准备初始化数据
	#		db/fixtures/*.rb.example -> db/fixtures/*.rb

其它准备

	mkdir log  
	rake db:create db:migrate   

启动  
	
	rails s  

此时用户访问 http://localhost:3000 时将被要求使用google帐号授权，登录后就可以看到首页了。  

# 相关项目 #
##apposs\_file  

    说明：支持文件同步的插件
    地址：https://github.com/taobao/apposs_file

##apposs\_simple\_adapter  

    说明：简单的适配插件，用于示例
    地址：https://github.com/taobao/apposs_simple_adapter

##apposs\_agent  

    说明：负责下发和执行指令脚本的并发客户端
    地址：https://github.com/taobao/apposs_agent

