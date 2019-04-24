local _width,_height=screen.getSize().width,screen.getSize().height

if screen.getOrientation() >= screen.PORTRAIT then
	_width,_height = _height,_width
end

local calSacle = function (x) 
	return 750 / _width * x 
end

local utils,floor = require'xui.utils',math.floor

--[[
	创建组件时将会继承父组件的context,layoutView,width,height.

	-- 创建ui
	mainUI = rootView:createLayout()

	-- 底层控件 -- 放置在root中的控件在创建时必须指定ui
	view1 = layout.creatrLayout({ui=mainUi})

	-- 后续的控件可以选择两种写法 -- 后者写法必须传入指定ui
	view1:createButton() 或者 button.createLayout({ui=view1})

	-- 动态构建 -- createView
	view1:createView()
	将表中self.con调用context:createView生成UIView,并赋值与self.layoutView中

	-- 添加至父组件 -- addToParent 
	view1:addToParent()
	首先会检测viewSwitch属性是否已加入进父组件中,再检测是否已调用过createView,再添加进父组件
	!!	注意若父组件未进行过动态构建,其子组件无法使用addToParent

	-- 添加至root组件 -- addToRootView
	view1:addToRootView()
	内容同addToParent,但是是添加进_root中

	-- 添加子组件 -- addSubview
	local view2 = view:createLayout({w=50,h=50})
	view1:addSubview(view2)
	将view2添加进view1中
	!!	注意若添加的组件已添加至ui中,将无法添加进其他组件
	error: component(当前ID) already has parent (父组件ID)

	-- 显示组件 隐藏组件 -- show,hidden
	为组件设置visibiltiy属性

	-- 设置回调 -- setActionCallback
	!!	注意设置回调前必须要进行过createView

	-- 以下与xmod中模块相似
	setStyle()
	setAttr() 
	getID() 
	getStyle()
	getSubview(index)
	getType()
	removeFromParent()

	-- 有关蒙层
	蒙层是创建在root上的组件,由于限制,因次会有一个先后的顺序,排列在蒙层后的组件,会显示在蒙层之上
	因此的话,建议可以在创建ui时优先对root组件构建好布局,保证蒙层可以始终创建在root组件的最顶层。
]]
--[[
	基本所有控件都可以使用这些属性
	w,h:		控件占用父控件的宽高比例 (w,h>0)
	xpos,ypos:  控件x与y轴在父控件中的偏移 
	id:   		控件的id标识,
	color 		控件的背景颜色
	view		控件类型(div或scroller)
	flexDirection 	-- 控件flex成员项的排列方向

	函数内一般都会存在的内容

	__tag   组件的类型表示
	context 		rootView中继承的UIContext属性
	parentView 		父组件

]]
--[[
	API说明
	-------------------------------------------------------------class
	对控件设置style属性
	class:setStyle(...) 
	函数说明:
		同手册上的UIView:setStyle()

	对控件设置Attr属性
	class:setAttr(...)
	函数说明：
		同手册上的UIView:setAttr()

	显示控件       --此显示是通过设置style属性实现
	class:show()
	函数说明:
		设置当前控件的'visibility'属性为'visible'

	隐藏控件       --此显示是通过设置style属性实现
	class:hidden()
	函数说明:
		设置当前控件的'visibility'属性为'hiddlen'

	获取控件id  
	class:getID()
	函数说明:
		获取当前控件的id

	获取控件类型
	class:getType()
	函数说明:
		获取当前控件的__tag标识

	获取当前控件style属性
	class:getStyles(index)
	参数说明:
		index     可选值,填入想要返回的style属性
	函数说明:
		返回当前控件style属性,无指定属性则返回全部属性

	获取当前组件
	class:getView()
	函数说明:
		获取当前组件

	获取字子组件
	class:getSubview(index)
	函数说明:
		返回当前组件的第index个子组件

	动态创建组件
	class:createView()
	函数说明:
		动态构建组件,并讲组件设置在layoutView上

	将当前控件添加进root组件
	class:addToRootView()
	函数说明:
		将当前控件添加进root组件,如未通过createView创建组件,则会自动创建

	将当前控件添加进父组件
	class:addToParent()
	函数说明：
		将当前控件添加进父组件,如未通过createView创建组件,则会自动创建

	在当前组件中添加组件
	class:addSubview(view)
	函数说明:
		将view添加至当前组件

	将当前组件从父组件移除
	class:removeFromParent()
	函数说明:
		将当前组件从父组件移除



	-------------------------------------------------------------rootView
	建立主UI
	rootUI = rootView:createLayout(Base)
	参数说明:
		Base = {
			area = Rect()    			 UI界面的分辨率大小,以及左上角顶点坐标			缺省时默认占满屏幕
			color=rgba(255,255,255,1)	 控件的背景颜色								缺省时为transparent
			view = 'div'				 控件的类型									缺省时为'div'
			config='saveConfig'			 UI保存配置的文件名,配置保存在脚本私有目录下	缺省值为UISave.txt
		}

	构建UI实例
	rootUI:createContext()
	函数说明:
		返回当前创建的UI实例

	显示UI
	rootUI:show()
	函数说明:
		创建并展示UI到屏幕

	关闭UI界面
	rootUI:close()
	函数说明:
		关闭UI界面

	获取UI选项配置
	rootUI:getSaveData
	函数说明:
		返回当前UI配置表

	-------------------------------------------------------------layout
	构建布局组件
	layout1 = layout.createLayout(Base)
	参数说明:
		Base = {
			id='组件1'		控件的id,如设置,则需要唯一 								缺省时自动填充
			w=100			控件占用父控件的宽比例 (w>0)								缺省时为100	
			h=100			控件占用父控件的高比例 (h>0)								缺省时为100
			xpos=0			控件在父控件中左上角顶点x轴的偏移值   						缺省时为0
			ypos=0			控件在父控件中左上角顶点y轴的偏移值   						缺省时为0
			view='div'		控件的组件类型,可选'div'或'scroller' 						缺省时为'div'
			sort='column'	控件flex容器中flex成员项的排列方向可选'row'或'column'  		缺省时为'column'
			color='#ffffff'	控件的背景颜色											缺省时为'transparent'
			--------------------------
			ui 				可选值,指定父组件 
		}
	函数说明:
		在父控件中构建新的组件

	对控件设置回调事件
	layout1:setActionCallback(callback)
	函数说明:
		对控件设置回调属性,并触发callback函数,callback会传入一个表,表内拥有
		{
			id  		触发回调的控件id
			action 		触发回调的事件类型
			view 		触发回调的控件UIView类
		}

	layout同时继承class的所有属性

	-------------------------------------------------------------lable
	构建标签组件
	lable1 = lable.createLayout(Base)
	参数说明:
		Base = {
			id='组件2'		控件的id,如设置,则需要唯一 								缺省时自动填充
			w=100			控件占用父控件的宽比例 (w>0)								缺省时为100	
			h=100			控件占用父控件的高比例 (h>0)								缺省时为100
			xpos=0			控件在父控件中左上角顶点x轴的偏移值   						缺省时为0
			ypos=0			控件在父控件中左上角顶点y轴的偏移值   						缺省时为0
			type='text'		lable组件的类型可选:'text','image' 						缺省时为'text'
			text='ttttt'    如type为'text'则填入 									缺省时为''
			image='src = 'xsp://logo.png''											缺省时为''
			style={
				fontSize=20  text的字体大小											缺省时为10
				textColor    text的字体颜色 											缺省时为'#333333'
			}
			--------------------------
			ui 				可选值,指定父组件 
		}

	lable同时继承class的所有属性

	-------------------------------------------------------------button
	构建按钮组件
	button1 = button.crearteLayout(Base)
	参数说明:
		Base = {
			id='组件3'		控件的id,如设置,则需要唯一 								缺省时自动填充
			w=100			控件占用父控件的宽比例 (w>0)								缺省时为100	
			h=100			控件占用父控件的高比例 (h>0)								缺省时为100
			xpos=0			控件在父控件中左上角顶点x轴的偏移值   						缺省时为0
			ypos=0			控件在父控件中左上角顶点y轴的偏移值   						缺省时为0
			text='ttttt'    如type为'text'则填入 									缺省时为''
			theme='blue'    预置的主题:'blue','red','yellow','white'
			disable=true    填写true时表示该按钮无法点击 								缺省时为false
			style={
				fontSize 					字体大小 								缺省时为18
				textColor 					字体颜色									缺省时为'#333333'
				backgroundColor 			按钮背景颜色 								缺省时为'#ffffff'
				checkedBackgroundColor 		点击按钮时触发的颜色     					缺省时与backgroundColor相同
				borderRadius 				按钮的边框圆角弧度 						缺省时为5
			}
			--------------------------
			ui 				可选值,指定父组件 
		}
	
	设置按钮回调函数
	button1:setActionCallback(callback)
	参数说明:
		callback 			回调时触发的函数

	设置按钮中显示的字
	button1:setValue(str)
	参数说明：
		str 				想要显示的字

	button同时继承class的所有属性

	-------------------------------------------------------------overlay
	构建蒙层组件
	overlay1 = overlay.createLayout(Base)
	参数说明
		Base = {
			id='组件4'		控件的id,如设置,则需要唯一 							缺省时自动填充
			color='#ffffff'	控件的背景颜色										缺省时为'rgba(0,0,0,0.4)'
			unSetActionCallback 是否自己设置回调 
		}
	函数说明:
		此函数将会添加在root组件末,并覆盖UI全部页面,默认触发回调(点击蒙层后就会隐藏该蒙层)
		是popup组件的前置组件。

	设置蒙层回调
	overlay1:setActionCallback(callback)
	参数说明:
		callback  		回调事件中触发的函数
	函数说明:
		在选择unSetActionCallback后需要自己设置回调,不然会导致蒙层无法隐藏,隐藏UI

	overlay同时继承class的所有属性

	-------------------------------------------------------------popup
	构建弹窗组件
	popup1 = popup.createLayout(Base)
	参数说明:
		Base = {
			id='组件5'			控件的id,如设置,则需要唯一 										缺省时自动填充
			w=100				控件占用root控件的宽比例 (w>0)									缺省时为100	
			h=100				控件占用root控件的高比例 (h>0)									缺省时为100
			xpos=0				控件在root控件中左上角顶点x轴的偏移值   							缺省时为0
			ypos=0				控件在root控件中左上角顶点y轴的偏移值   							缺省时为0		
			color='#ffffff'     控件的背景颜色 													缺省值与layout中的相同
			direction='middle'  弹窗在root中弹出的位置:'middle','bottom','right','top','left'		缺省时为'middle'
			--------------------------
			ui 				可选值,指定父组件			
		}	
	函数说明:
		弹窗控件将会创建一个蒙层组件,并添加一个layout组件。
		因此函数的结构也与其他的不同,参数中将添加layout
		layout为生成的layout组件,是通过layout.createLayout生成的
		同时父组件将会设置为蒙层组件。

	设置style属性
	popup:setStyle(...)
	函数说明:
		同UIView:setStyle(),实际上是通过引用至layout组件。

	显示弹窗
	popup1:show()
	函数说明:
		通过设置蒙层的'visibility',达到显示的效果

	隐藏弹窗
	popup1:hidden()
	函数说明:
		通过设置蒙层的'visibility',达到隐藏的效果

	设置回调
	popup1:setActionCallback(callback)
	函数说明:
		这里是设置self.layout的回调。

	获取组件
	popup1:getView()
	函数说明:
		返回layout这个组件

	popup同时继承class的所有属性

	-------------------------------------------------------------input
	构建输入框组件
	input1 = input.createLayout(Base)
	参数说明:
		Base = {
			id='组件6'			控件的id,如设置,则需要唯一 										缺省时自动填充
			w=100				控件占用root控件的宽比例 (w>0)									缺省时为100	
			h=100				控件占用root控件的高比例 (h>0)									缺省时为100
			xpos=0				控件在root控件中左上角顶点x轴的偏移值   							缺省时为0
			ypos=0				控件在root控件中左上角顶点y轴的偏移值   							缺省时为0	
			prompt 				当前输入框中输入的文本 											缺省时为''
			style={
				fontSize=20 	   	 		字体大小												缺省时为18
				textColor='#ffffff'  		字体颜色												缺省时为'#666666'
				backgroundColor='#000000'   输入框的背景颜色 										缺省时为'#e5e5e5'
				checkedBackgroundColor='#ffffff' --------暂时没用
			}	
			---同时可以设置的参数可以查看手册		
		}

	设置回调
	input1:setActionCallback(callback)
	参数说明:
		callback  		回调事件中触发的函数
	
	获取当前输入框中的字符
	input1:getValue()
	函数说明:
		返回当前字符串中的字符

	设置输入框中的字符
	input1:setValue(str)
	参数说明:
		str 	需要改变的字符串	
	函数说明:
		设置当前输入框中的字符

	input组件同时继承class的所有属性

	-------------------------------------------------------------tabPage
	构建标签页布局
	tabPage1 = tabPage1.createLayout(Base)
	参数说明:
		Base = {
			id='组件7'			控件的id,如设置,则需要唯一 										缺省时自动填充
			w=100				控件占用root控件的宽比例 (w>0)									缺省时为100	
			h=100				控件占用root控件的高比例 (h>0)									缺省时为100
			xpos=0				控件在root控件中左上角顶点x轴的偏移值   							缺省时为0
			ypos=0				控件在root控件中左上角顶点y轴的偏移值   							缺省时为0		
			sort='column'		控件flex容器中flex成员项的排列方向可选'row'或'column'  				缺省时为'column'
			color='#000000'     控件的背景颜色 													缺省时为'transparent'
			reverse=true 		设置颠倒布局 左右在于设置标签栏与page的位置
		 	list={} 	        目录     
		 	titleStyle={}		标签的style属性
		 	tabStyle={}			页面的style属性
		}
		list中的每个表的结构为
		{
			value 	 		该标签的标题
			tabStyle = {} 	该标签对应layout组件的style属性,基本都能填写
		}
		list.tabStyle中的属性会覆盖Base.tabStyle的属性
		标签栏与page栏的大小比例:
			当sort为'column'时,高分别占比titleStyle.w 		缺省时为12
			当sort为'row'时,宽分别占比titleStyle.h  			缺省时为15
		标签栏中每个标签的大小可以用,titleWidth以及titleHeight控制。
	函数说明:
		通过设置sort和reverse可以产生多种排列布局。同时标签栏是可以滑动的。
		每个page页面都由layout.createLayout构建。

	设置回调
	tabPage1:setActionCallbac(callback)
	参数说明:
		callback 		事件触发时调用的函数
	函数说明:
		通过点击标签,切换页面。
	
	获取页面
	tabPage1:getPage(index)
	参数说明:
		index可以为数字也可以为字符串。
		当index为数字时,将会返回对应第index个page页面.
		当index为字符串时,将会返回id为index的page页面。
	
	tabPage组件同时继承了class的所有属性

	-------------------------------------------------------------gridSelect
	构建网格选择组件
	gridSelect1  = gridSelect.createLayout(Base)
	参数说明: 
		Base = {
			id='组件8'			控件的id,如设置,则需要唯一 										缺省时自动填充
			w=100				控件占用root控件的宽比例 (w>0)									缺省时为100	
			h=100				控件占用root控件的高比例 (h>0)									缺省时为100
			xpos=0				控件在root控件中左上角顶点x轴的偏移值   							缺省时为0
			ypos=0				控件在root控件中左上角顶点y轴的偏移值   							缺省时为0	
			color='#ffffff'	    控件的背景颜色 													缺省时为'transparent'
			limit=10            选择数量限制 														缺省时为999
			theme='yellow'      内置的选项主题:'red','yellow'
			list={}
			style={}
		}
	list中的结构为
	{	
		value='a'       选项的内容
		checked=true    选项是否选中
		diabled=true    选项是否不可选中  
	}
	style={
		textColor 						字体颜色 												缺省时为'#333'
		disabledTextColor 				不可选时的字体颜色 										缺省时为'#9b9b9b'
		checkedTextColor				选中时的字体颜色 											缺省时为'#333'
		backgroundColor 				选项的背景颜色 											缺省时为'#fff'
		checkedBackgroundColor 			选项选中时的背景颜色 										缺省时为'#fff'
		disabledBackgroundColor 		选项不可选时的背景颜色 									缺省时为'#f6f6f6'
		fontSize 						选项中字符的字体大小 										缺省时为18
		borderWidth 					选项的边框宽度 											缺省时为1
		borderRadius 					选项的边框圆角大小 										缺省时为5
		borderColor 					选项的边框颜色 											缺省时为'#000'
		disabledBorderColor 			选项不可选时的边框颜色  									缺省时为'transparent'
		checkedBorderColor 				选项选中时的边框颜色 										缺省时为'#000'

		linSpacing=2 					每行的间隔大小 											缺省时为1
		selectWidth=15 					每个选项框的宽度 											缺省时为20
		selectHeight=15 				每个选项框的高 											缺省时为20
	}

	函数说明:
		选中的配置可以通过调用self.saveData查看
]]
local object = {}
function object:onCreateError(tag,parent,Base)
	local str
	if not parent.__tag and not parent.ui then
		str = string.format('if called by %s.createLayout format,it must be had parameter ui',tag)
	else
		str = string.format('error in %s.createLayout',tag)
	end
	assert(false,str)
end
function object:createInit(tag,parent,Base) --return parent,Base
	if (not parent.__tag and parent.ui) then
		return parent.ui,parent
	elseif (not parent.__tag and Base.ui) then
		return Base.ui,Base
	elseif (parent.__tag and not Base.ui) then
		return parent,Base
	elseif (parent.__tag and Base.ui) then
		return Base.ui,Base
	else
		self:onCreateError(tag,parent,Base)
	end
end
function object:ifViewAdded(id,viewID)
	printf('component(ID:%s) have been added to (ID:%s)',id,viewID)
end
function object:copyInherit(t)
	local context    = t.context
	local saveData   = t.saveData
	local layoutView = t.parentView
	local width 	 = t.width
	local height     = t.height
	return {
		context = context,saveData = saveData,layoutView = layoutView,
		width = width,height = height,
	}
end


local class = {}
function class:new()
	local o={}
	setmetatable(o,{__index = self})
	return o
end
function class:setStyle(...)
	local tbl = {...}
	local ViewStyle = self.con.style
	if (#tbl == 1) then
		local styles = tbl[1]
		if (type(tbl[1]) == 'table') then
			if rawget(self,'layoutView') then
				self.layoutView:setStyle(styles)
			end
			utils.mergeTable(ViewStyle,styles)
		end
	elseif (#tbl == 2) then
		local key,value = tbl[1],tbl[2]
			if rawget(self,'layoutView') then
				self.layoutView:setStyle(key,value)
			end
			ViewStyle[key] = value
	end
	return self
end
function class:setAttr(...)
	local tbl = {...}
	if (#tbl == 1) then
		local Attrs = tbl[1]
		if (type(tbl[1]) == 'table') then
			if rawget(self,'layoutView') then
				self.layoutView:setAttr(Attrs)
			end
				utils.mergeTable(self.con,Attrs)
		end
	elseif (#tbl == 2) then
		local key,value = tbl[1],tbl[2]
			if rawget(self,'layoutView') then
				self.layoutView:setAttr(key,value)
			end
			self.con[key] = value
	end
	return self
end
function class:show()
	self:setStyle('visibility','visible')
	return self
end
function class:hidden()
	self:setStyle('visibility','hidden')
	return self
end
function class:getID()
	if self.layoutView then
		return self.layoutView:getID()
	end
	return self.con.id
end
function class:getStyles(index)
	local styles
	if self.layoutView then
		styles = self.layoutView:getStyles()
	else
		styles = self.con.style
	end

	if index then
		return styles[index]
	end
	return styles
end
function class:getView()
	if self.layoutView then
		return self.layoutView
	else
		return self.con
	end
end
function class:getSubview(index)
	if self.layoutView then
		return self.layoutView:getSubview(index)
	else
		return self.con.subviews(index)
	end
end
function class:createView()
	local context = self.context
	local view = context:createView(self.con)

	rawset(self,'layoutView',view)
	return self
end
function class:addToRootView()
	if self.viewSwitch then 
		object:ifViewAdded(self:getID(),'root')
		return self
	end

	local context = self.context
	local rootView = context:getRootView()

	if not rawget(self,'layoutView') then
		self:createView()
	end
	
	rootView:addSubview(self.layoutView)
	self.viewSwitch = true
	return self
end
function class:addToParent()
	if self.viewSwitch then 
		object:ifViewAdded(self:getID(),self.parentView:getID())
		return self
	end 

	local context = self.context
	local parentView = self.parentView

	if not rawget(self,'layoutView') then
		self:createView()
	end

	parentView:addSubview(self.layoutView)
	self.viewSwitch = true
	return self
end
function class:addSubview(view)
	local parent = self:getView()
	if type(parent)=='table' then
		table.insert(parent.subviews,view.con)
	elseif type(parent)=='userdata' then
		parent:addSubview(view.layoutView or view:createView():getView())
	end
end
function class:removeFromParent()
	self.layoutView:removeFromParent()
end
function class:getType()
	return self.__tag
end


local _storage = {}
function _storage:new(fileName)
	local o ={
		data={},
		path = xmod.resolvePath('[private]'..(fileName or 'UISave.txt'))
	}
	
	local cjson = require'cjson'
	io.open(o.path,'a')	
	local file = io.open(o.path,'r')

	local str = file:read('*a')
	file:close()
	if #str~=0 then
		o.data = cjson.decode(str)
	end
	
	setmetatable(o,{__index = _storage})
	return o
end
function _storage:put(id,value)
	self.data[id] = value
end
function _storage:get(id,defValue)
	return (self.data[id] or defValue)
end
function _storage:encodePut(id,value)
	local t = {}
	for k,v in pairs(value) do
		if v then
			t[#t+1] = k
		end
	end
	local str = table.concat(t,'@')
	self.data[id] = str
end
function _storage:decodeGet(id,defValue)
	local value = self.data[id]
	Print(value)
	if value then
		local t = {}
		for k,v in pairs(utils.split(value,'@')) do
			t[v] = true
		end
		return t
	end
	return defValue
end
function _storage:save()
	local cjson = require'cjson'
	local t = self.data
	local str = cjson.encode(t)

	local file = io.open(self.path,'w+')
	file:write(str)
	file:flush()
	file:close()
end


local _rootView = {}
function _rootView:createLayout(Base)
	local rect = Base.area or Rect(0,0,_width,_height)
	local width,height = calSacle(rect.width),calSacle(rect.height)
	local left,top = calSacle(rect.x),calSacle(rect.y)
	
	local o={
		__tag = 'root',
		width = width,
		height = height,
		saveData = _storage:new(Base.config),
		rootLayout = {
			view = Base.view or 'div',
			style ={	
				width  = width,
				height = height,
				left = left,
				top	 = top,
				backgroundColor = Base.color or 'transparent',
			},
			subviews = {},
		},
		globalStyle = Base.globalStyle or {},
	}
	setmetatable(o,{__index = self})
	return o
end
function _rootView:createContext()
	local context = UI.createContext(self.rootLayout,self.globalStyle)
	self.context = context
	self.layoutView = context:getRootView()
	return context
end
function _rootView:show()
	self.context:show()
end
function _rootView:close()
	self.context:close()
end
function _rootView:getSaveData()
	return self.saveData
end


local _layout = class:new()
local xui_layout = {
	Count = 0,
}
function _layout:createLayout(Base)
	local Base = Base or {}
	local parent,Base = object:createInit('layout',self,Base)
	
	local xpos   = floor((Base.xpos or 0)/100*parent.width)
	local ypos   = floor((Base.ypos or 0)/100*parent.height)
	local width  = floor((Base.w or 100)/100*parent.width)
	local height = floor((Base.h or 100)/100*parent.height)
	local context    = parent.context
	local saveData   = parent.saveData
	local parentView = parent.layoutView

	xui_layout.Count = not Base.id and xui_layout.Count + 1 or xui_layout.Count
	local id = Base.id or utils.buildID('layout',xui_layout.Count)
	
	local backgroundColor = Base.color or 'transparent'
	local view 			  = Base.view=='scroller' and 'scroller' or 'div'
	local flexDirection   = Base.sort=='row' and 'row' or 'column'
	local scrollDirection = flexDirection=='row' and 'horizontal' or 'vertical'

	local o = {
		__tag = 'layout',
		context = context,
		saveData = saveData,
		parentView = parentView,
		width = width,
		height = height,
		con = {	
			id = id,
			view = view,
			style ={
				width = width,
				height = height,
				left = xpos,
				top = ypos,
				backgroundColor = backgroundColor,
				['flex-direction'] = flexDirection,
			},
			subviews = {},
			['scroll-direction'] = scrollDirection,
		},
	}
	utils.mergeTable(o.con.style,Base.style)
	
	setmetatable(o,{__index = _layout})

	return o
end
function _layout:setActionCallback(callback)
	local view = self.layoutView
	local onClicked = function (id,action)
		local Base={id=id,action=action,view=view}
		if callback then
			callback(Base)
		end
	end
	view:setActionCallback(UI.ACTION.CLICK, onClicked)
	return self
end

--[[
local _richText = class:new()
local xui_richText = {
	Count = 1,
	viewType = {
		text = function ()
			return {
				view = 'text',
				value = '',
				style = {
					lines = 1,
					margin = 1,
					['text-align'] = 'center',
				},
			}
		end,
		icon = function ()
			return {
				view = 'image',
				src = '',
				style = {},
			}
		end,
		tag = function ()
			return {
				view = 'div',
				style = {
					['justify-content'] = 'center',
					['align-items'] = 'center',
				},
				subviews = {
					{
						view = 'text',
						value = '',
						style = {
							lines = 1,
							margin = 1,
							['text-align'] = 'center',
						},
					},
				},
			}
		end,
	},
	THEME = {
		black = {
			color = '#000',
			borderColor = '#000'
		},
		red = {
			color = '#ed3d03',
			borderColor = '#ed3d03',
		},
		blue = {
			color = '#0F8DE8',
			borderColor = '#0F8DE8'
		},
		yellow = {
			color = '#ffc900',
			borderColor = '#ffc900',
		},
	},
}
function _richText:createLayout(Base) --还没整好,不知道应该怎么控制换行
	local Base = Base or {}
	local parent,Base = object:createInit('richText',self,Base)

	local xpos   = floor((Base.xpos or 0)/100*parent.width)
	local ypos   = floor((Base.ypos or 0)/100*parent.height)
	local width  = floor((Base.w or 100)/100*parent.width)
	local height = floor((Base.h or 100)/100*parent.height)
	local context    = parent.context
	local saveData   = parent.saveData
	local parentView = parent.layoutView

	xui_richText.Count = not Base.id and xui_richText.Count + 1
	local id = Base.id or utils.buildID('richText',xui_richText.Count)

	local list  = Base.list
	local style = Base.style or {}
	local fontSize 				= style.fontSize or 16
	local lines					= style.lines or 1
	local textColor 			= style.textColor or '#333'
	local borderColor 			= style.boredrColor or '#000'
	local borderWidth 			= style.borderWidth or 1
	local borderRadius 			= style.borderRadius or 5
	local backgroundColor 		= style.backgroundColor or '#fff'

	local o = {
		__tag = 'lable',
		context = context,
		parentView = parentView,
		width = width,
		height = height,
		con = {
			id = id,
			view = 'div',
			style = {
				width = width,
			--	height = height,
				left = xpos,
				top = ypos,
				backgroundColor = backgroundColor,
				['flex-direction'] = 'row',
				['align-items'] = 'center',
			},
			subviews = {},
		},
	}

	local linkConfig = {}
	local type = list.type
	if type == 'special' then


	else
		for k,v in pairs(list) do
			local type  = v.type
			local theme = xui_richText.THEME[v.theme] or {}
			local style = v.style or {}
				
			if 	(type=='text')     then
				view = xui_richText.viewType.text()
				view.value = v.value or ''
				view.style.fontSize 	= style.fontSize or fontSize
				view.style.color 		= (style.textColor or theme.color) or textColor
				view.style.lines 		= style.lines or lines
			elseif (type=='link')  then
					view = xui_richText.viewType.text()
				view.value = v.value or ''
				view.style.fontSize 	= style.fontSize or fontSize
				view.style.color 		= (style.textColor or theme.color) or textColor
				view.style.lines 		= style.lines or lines
				table.insert(linkConfig,{index = k,href = v.href})
			elseif (type=='icon')  then
				view = xui_richText.viewType.icon()
				view.src = v.icon or '' 
			elseif (type=='tag')   then
				view = xui_richText.viewType.tag() 
				view.style.height 				= style.tagHeight and (style.tagHeight/100*height)
				view.style.backgroundColor  	= style.backgroundColor or backgroundColor
				view.style['border-radius'] 	= style.borderRadius or borderRadius
				view.style['border-color'] 		= (style.boredrColor or theme.borderColor) or borderColor
				view.style['border-width']		= style.borderWidth or borderWidth 

				local textView = view.subviews[1]
				textView.value = v.value or ''
				textView.style.fontSize = style.fontSize or fontSize
				textView.style.color 	= (style.textColor or theme.color) or textColor
				textView.style.lines 	= style.lines or lines
			end 
			table.insert(o.con.subviews,view)
		end
	end

	setmetatable(o, { __index = _richText })
	o:createView()
	
	local layoutView = o.layoutView
	for k,v in ipairs(linkConfig) do
		local onClicked = function ()
			runtime.openURL(v.href)
		end	
		layoutView:getSubview(v.index):setActionCallback(UI.ACTION.CLICK,onClicked)
	end
	
	return o
end
]]--

local _label = class:new()
local xui_label = {
	Count = 0,
	theme = {

	}
}
function _label:createLayout(Base) 
	local Base = Base or {}
	local parent,Base = object:createInit('label',self,Base)

	local xpos   = floor((Base.xpos or 0)/100*parent.width)
	local ypos   = floor((Base.ypos or 0)/100*parent.height)
	local width  = floor((Base.w or 100)/100*parent.width)
	local height = floor((Base.h or 100)/100*parent.height)
	local context    = parent.context
	local saveData   = parent.saveData
	local parentView = parent.layoutView

	xui_label.Count = not Base.id and xui_label.Count + 1
	local id = Base.id or utils.buildID('label',xui_label.Count)

	local o = {
		__tag = 'label',
		context = context,
		saveData = saveData,
		parentView = parentView,
		width = width,
		height = height,
		con = {
			id = id,
			view = 'div',
			style = {
				left = xpos,
				top = ypos,
			},
			subviews = {
				{
					width = width,
					height = height,
					view = '',
					style = {},
				},
			},
		},
	}

	local type = Base.type or 'text'
	local value = Base.text or ''
	local image  = Base.image or ''
	local style = Base.style or {}
	local fontSize = style.fontSize or 18
	local textColor = style.textColor or '#333333'

	local view = o.con.subviews[1]
	if type =='text' then
		view.view = 'text'
		view.value = value
		view.style.fontSize = fontSize
		view.style.textColor = textColor
	elseif type == 'image' then
		view.view = 'image'
		view.src = image
	end

	utils.mergeTable(view.style,style)

	setmetatable(o,{__index = _label})
	return o
end


local _button = class:new()
local xui_button = {
	Count = 0,
	style = {
		btn = {
			blue = {
				backgroundColor = '#0F8DE8'
			},
			red = {
				backgroundColor = '#ffc500',
			},
			yellow = {
				backgroundColor = '#ffc900'
			},
			white = {
				backgroundColor = '#fff',
				['border-width'] = 1,
				['border-color'] = '#A5A5A5',
			},
			disabled = {
				opacity = 0.2,
			},
		},
		text = {
			blue = {
				color = '#fff',
			},
			red = {
				color = '#fff',
			},
			yellow = {
				color = '#fff',
			},
			white = {
				color = '#3d3d3d',
			},
			disabled = {
				color = '#ffffff'
			},
		},
	}
}
function _button:createLayout(Base)
	local Base = Base or {}
	local parent,Base = object:createInit('button',self,Base)

	local xpos   = floor((Base.xpos or 0)/100*parent.width)
	local ypos   = floor((Base.ypos or 0)/100*parent.height)
	local width  = floor((Base.w or 100)/100*parent.width)
	local height = floor((Base.h or 100)/100*parent.height)
	local context    = parent.context
	local saveData   = parent.saveData
	local parentView = parent.layoutView
	
	xui_button.Count = not Base.id and xui_button.Count +1
	local id = Base.id or utils.buildID('button',xui_button.Count)

	local value = Base.text or ''
	local style = Base.style or {}
	local theme					 = Base.theme
	local disabled				 = Base.disabled or false
	local fontSize 				 = style.fontSize or 18
	local textColor 			 = style.textColoror or '#333333'
	local backgroundColor 	     = style.backgroundColor or '#ffffff'
	local checkedBackgroundColor = style.checkedBackgroundColor or backgroundColor
	local borderRadius 			 = style.borderRadius or 5

	local o = {
		__tag = 'button',
		context = context,
		parentView = parentView,
		width = width,
		height = height,
		disabled = disabled,
		con = {
			id = id,
			view = 'div',
			style = {
				left = xpos,
				top  = ypos,
				width  = width,
				height = height,
				backgroundColor  = backgroundColor,
				['backgroundColor:active'] = checkedBackgroundColor,
                ['align-items'] = 'center',
                ['justify-content'] = 'center',	
				borderRadius = borderRadius,
			},
			subviews = {
				{
					view = 'text',
					value = value,
					style = {
						fontSize = fontSize,
						color = textColor,				
						['text-align'] = 'center',
						lines = 1,
					},
				},
			},
		},
	}

	--div
	utils.mergeTable(o.con.style,xui_button.style.btn[theme])
	utils.mergeTable(o.con.subviews[1].style,xui_button.style.text[theme])
	--text
	utils.mergeTable(o.con.style,Base.btnStyle)
	utils.mergeTable(o.con.subviews[1].style,Base.textStyle)
	if disabled then
		utils.mergeTable(o.con.style,xui_button.style.btn.disabled)
		utils.mergeTable(o.con.subviews[1].style,xui_button.style.text.disabled)
		o.con.style['backgroundColor:active'] = nil
	end
	setmetatable(o,{__index = _button})
	
	return o
end
function _button:setActionCallback(callback)
	local view = self.layoutView
	local onClicked = function (id,action)
		if callback then
			callback(self)
		end
	end

	if not self.disabled then
		view:setActionCallback(UI.ACTION.CLICK, onClicked)
		view:setActionCallback(UI.ACTION.LONG_PRESS, onClicked)
	end
	return self
end
function _button:setValue(str)
	local str = tostring(str) or ''
	if self.layoutView then
		self.layoutView:getSubview(1):setAttr('value',str)
	end
		self.con.subviews[1].value = str
end


local  _overlay = class:new()
local xui_overlay = {
	Count = 0,
}
function _overlay:createLayout(Base) --overlay会在创建时将view设置回调并添加进root组件中,如果不设置回调可能会导致无法点击,需调用hidden
	local Base = Base or {}
	local parent,Base = object:createInit('overlay',self,Base)
	
	local context  = parent.context
	local saveData = parent.saveData
	
	xui_overlay.Count = not Base.id and xui_overlay.Count +1
	local id = Base.id or utils.buildID('overlay',xui_overlay.Count)
	local backgroundColor = Base.color or 'rgba(0,0,0,0.4)'
	local rootView = context:getRootView()
	local rootStyle = rootView:getStyles()
	local width,height = rootStyle.width,rootStyle.height

	local o = {
		__tag = 'overlay',
		context = context,
		saveData = saveData,
		parentView = rootView,
		width = width,
		height = height,
		con = {
			id = id,
			view = 'div',
			style = {
				width = width,
				height = height,
				backgroundColor = backgroundColor,
				position = 'absolute',
				visibility = 'hidden',
			},
			subviews = {},
		},
	}
	setmetatable(o,{__index = _overlay})

	o:createView()
	if not Base.unSetActionCallback then 
		o:setActionCallback()
	end
	o:addToRootView()

	return o 
end
function _overlay:setActionCallback(callback)
	local view = self.layoutView
	local onClicked = function (id,action)
		print('close overlay')
		view:setStyle('visibility','hidden')
	end
	view:setActionCallback(UI.ACTION.CLICK,onClicked)
	return self
end


local _popup = class:new()
local xui_popup = {
	Count = 0,
	layoutStyle = {
		left = {
			['transition'] = 'left 1s ease-in-out',
		},
		top = {
			['transition'] = 'top 1s ease-in-out',
		},
		right = {
			['transition'] = 'left 1s ease-in-out',		
		},
		bottom = {
			['transition'] = 'top 1s ease-in-out',	

		},
		middle = {
			
		},
	},
	overlayStyle = {
		left = {
			['justify-content'] = 'center',	
			['align-items'] = 'flex-start'
		},
		top = {
			['justify-content'] = 'flex-start',	
			['align-items'] = 'center',			
		},
		right = {
			['justify-content'] = 'center',	
			['align-items'] = 'flex-end'		
		},
		bottom = {	
			['justify-content'] = 'flex-end',	
			['align-items'] = 'center',		
		},
		middle = {
			['justify-content'] = 'center',	
			['align-items'] = 'center',			
		},
	},
}
function _popup:createLayout(Base)
	local Base = Base or {}
	local parent,Base = object:createInit('popup',self,Base)

	local xpos   = Base.xpos or 0
	local ypos   = Base.ypos or 0
	local w  = Base.w or 100
	local h  = Base.h or 100

	local context = parent.context
	local saveData = parent.saveData

	xui_popup.Count = not Base.id and xui_popup.Count + 1
	local id = Base.id or utils.buildID('popup',xui_popup.Count)
	local direction = Base.direction or 'middle'

	local o = {
		__tag = 'popup',
		context = context,
		saveData = saveData,
		viewSwitch = true,
		direction = direction,
		--layoutView = 
		--parentView = 
		--layout = 
	}
	
	--创建蒙层
	local overlay = _overlay.createLayout(parent):addToRootView()
	o.overlay = overlay
	overlay:setStyle(xui_popup.overlayStyle[direction])

	--创建布局
	local layout = Base.view or _layout.createLayout(overlay,{color=Base.color,w=w,h=h,xpos=xpos,ypos=ypos})
	layout:setStyle(xui_popup.layoutStyle[direction])

	overlay:addSubview(layout) --将布局添加至蒙层

	o.layout = layout
	o.layoutView = layout:getView()
	o.parentView = overlay:getView()

	setmetatable(o,{__index = _popup})
	return o
end
function _popup:setStyle(...)
	self.layout:setStyle(...)
	return self
end
function _popup:show()
	self.overlay:show()
	return self
end
function _popup:hidden()
	self.overlay:hide()
	return self
end
function _popup:setActionCallback(callback)
	self.layoutView:setActionCallback(callback)
	return self
end
function _popup:getView()	--将会返回添加进蒙层的控件
	return self.layout
end


local _input = class:new()
local xui_input = {
	Count = 0,
	layout = function ()
		return {
			view = 'input',
			style = {},
			value = '',
		}
	end,
	THEME = {
		
	
	}
}
function _input:createLayout(Base)
	local Base = Base or {}
	local parent,Base = object:createInit('input',self,Base)

	local xpos   = floor((Base.xpos or 0)/100*parent.width)
	local ypos   = floor((Base.ypos or 0)/100*parent.height)
	local width  = floor((Base.w or 100)/100*parent.width)
	local height = floor((Base.h or 100)/100*parent.height)
	local context    = parent.context
	local saveData   = parent.saveData
	local parentView = parent.layoutView

	xui_input.Count = not Base.id and xui_input.Count + 1
	local id = Base.id or utils.buildID('input',xui_input.Count)

	local o = {
		__tag = 'input',
		context = context,
		parentView = parentView,
		saveData = saveData,
		width = width,
		height = height,
		con = {
			view = 'div',
			style = {
				width = width,
				height = height,
				['flex-direction'] = 'row',
				['border-radius'] = 5,
				['align-items'] = 'center',
			},
			subviews = {},
		},
	}

	local kbtype = Base.kbtype or 'text'
	local prompt = o.saveData:get(id,Base.prompt)
	local placeholder = Base.placeholder or ''
	local disabled    = Base.disabled or false
	local autofocus   = Base.autofocus or false
	local maxlength   = Base.maxlength or 999
	local singleline  = Base.singleline or true

	local style = Base.style or {}
	local fontSize 					 	 = style.fontSize or 18
	local textColor 					 = style.textColor or '#666666'
	local backgroundColor 				 = style.backgroundColor or '#e5e5e5'
	local checkedBackgroundColor 		 = style.checkedBackgroundColor or backgroundColor
	

	o.con.style.backgroundColor = backgroundColor

	local inputLayout = {
		id = id,
		view = 'input',
		type = kbtype,
		value = prompt,
		placeholder = placeholder,
		disabled = disabled,
		autofocus = autofocus,
		maxlength = maxlength,
		singleline = singleline,
		style = {
			width = width,
			height = height,
			fontSize = fontSize,
			color = textColor,
			backgroundColor = backgroundColor,
			['backgroundColor:focus'] = checkedBackgroundColor,
			['padding-left'] = 5,	
		},
	}
	o.con.subviews[1] = inputLayout
	
	setmetatable(o,{__index = _input})
	
	return o
end
function _input:setActionCallback(callback)
	local view = self.layoutView
	local inputView = view:getSubview(1)
	local saveData = self.saveData

	local onINPUT = function (id,action)
		local value = inputView:getAttr('value')
		local Base = {id=id,action=action,view=view,value=value}
		saveData:put(id,value)
		if callback then
			callback(Base)
		end
	end
	
	inputView:setActionCallback(UI.ACTION.INPUT,onINPUT)
	return self
end
function _input:getValue()
	return self.saveData.value
end
function _input:setValue(str)
	local str=str or ''
	self:setAttr('value',str)
	return self
end


local _tabPage = class:new()
local xui_tabPage = {
	Count=0,
	select_layout=function ()
		return {
			view = 'div',
			style = {
				['align-items'] = 'center',
			},
			subviews = {
				{
					view = 'div',
					style = {
						['justify-content'] = 'center',
						['align-items'] = 'center',
					},
					subviews = {
						{
							view = 'text',
							style = {},
							value = '',
						},
					},
				},
				{
					view = 'div',
					style = {
					},
					subviews = {},
				},
			},
		}
	end,
	tab_layout=function ()
		return {
			view = 'div',
			style = {
				backgroundColor ='red',
			},
			subviews = {},
		}
	end,
	toString = function (Base)
		local str = string.format('tabPage<id=%s,tabCount=%s,width=%s,height=%s>',
			Base.con.id,#Base.config.pages,Base.width,Base.height
		)
		return str
	end,
} 
function _tabPage:buildTitle(list,style,layoutSort)
	local o={
		view = 'scroller',
		style = {},
		subviews = {},
	}
	
	local list = list or {}
	local style = style or {}
	local layoutSort = layoutSort 

	local width  =	floor(layoutSort =='column' and self.width or self.width*(style.w or 12)/100)
	local height =	floor(layoutSort =='column' and self.height*(style.h or 15)/100 or self.height)

	local titleWidth  = layoutSort =='column' and width*(style.titleWidth or 15)/100 or width
	local titleHeight = layoutSort =='column' and height or height*(style.titleHeight or 15)/100 
	local fontSize = (style.fontSize or style['font-size']) or 15
	local checkedTextColor = style.checkedTextColor or '#000000'
	local checkedBackgroundColor = style.checkedBackgroundColor or '#ffffff'
	local disabledTextColor = style.disabledTextColor or '#b0b0b0'
	local disabledBackgroundColor = style.disableBackgroundColor or '#000000'
	local checkedBottomColor = style.checkedBottomColor or '#000000'
	local disableBottomColor = style.disableBottomColor or '#ffffff'
	
	o.style={
		width = width,
		['max-height'] = height,
		['flex-direction']   = layoutSort=='column' and 'row' or 'column',
	}
	o['scroll-direction'] = o.style['flex-direction']=='column' and 'vertical' or 'horizontal'

	local subviews = o.subviews
	for i=1, #list do
		local value = list[i].value or ''
		local layout = xui_tabPage.select_layout()
		layout.id = utils.buildID(self.con.id..'_title',value)
		subviews[i] = layout
		
		local layoutStyle = layout.style
		layoutStyle.width  = titleWidth
		layoutStyle.height = titleHeight
		layoutStyle.backgroundColor = checkedBackgroundColor
		
		local textView = layout.subviews[1]
		local textViewStyle = textView.style
		textViewStyle.width  = layoutStyle.width
		textViewStyle.height = layoutStyle.height*0.9		
		
		local textValueStyle = textView.subviews[1].style
		textValueStyle['font-size'] = fontSize
		textValueStyle.color = i==1 and checkedTextColor or disabledTextColor
		textView.subviews[1].value = value
		
		local bottomView = layout.subviews[2]
		local bottomViewStyle = bottomView.style
		bottomViewStyle.width  = layoutStyle.width*0.75
		bottomViewStyle.height = layoutStyle.height-textViewStyle.height
		bottomViewStyle.backgroundColor = i==1 and checkedBottomColor or disableBottomColor
		
		local checked =  i==1 and true or false
		local disable = not checked
		if i==1 then self.config.checkedIndex = layout.id end
		self.config[layout.id] = {index = i,value = value,checked = checked,disabled = disabled}
		self.config[layout.id].color = {
			checkedTextColor = checkedTextColor,checkedBackgroundColor = checkedBackgroundColor,
			disabledTextColor = disabledTextColor,disabledBackgroundColor = disabledBackgroundColor,
			checkedBottomColor = checkedBottomColor,disableBottomColor = disableBottomColor}
	end
	return o
end
function _tabPage:buildTab(list,style)
	local o={
		view = 'div',
		style = {},
		subviews = {
			{
				view = 'div',
				style = {
					['flex-direction'] = 'row',
				},
				subviews = {},
			}
		},
	}
	
	local list = list or {}
	local style = style or {}
	local width = style.width
	local height = style.height
	local backgroundColor = style.backgroundColor or '#ffffff'

	o.style.width = width
	o.style.height = height
	o.subviews[1].style.width = width*#list
	o.subviews[1].style.height = height

	local parentUI = object:copyInherit(self)
	parentUI.width = width
	parentUI.height = height

	for i=1, #list do
		local value = list[i].value
		local id = utils.buildID(self.con.id..'_tab',value)
		local tabView = _layout:createLayout({ui=parentUI,id=id})
			tabView:setStyle({
				backgroundColor = backgroundColor,
			})
		tabView:setStyle(list[i].tabStyle)

		self.config.pages[i] = tabView
		o.subviews[1].subviews[i] = tabView:getView()
	end
	
	return o
end
function _tabPage:createLayout(Base)
	local Base = Base or {}
	local parent,Base = object:createInit('tabPage',self,Base)

	local xpos   = floor((Base.xpos or 0)/100*parent.width)
	local ypos   = floor((Base.ypos or 0)/100*parent.height)
	local width  = floor((Base.w or 100)/100*parent.width)
	local height = floor((Base.h or 100)/100*parent.height)
	local context    = parent.context
	local saveData   = parent.saveData
	local parentView = parent.layoutView

	xui_tabPage.Count = not Base.id and xui_tabPage.Count + 1
	local id = Base.id or utils.buildID('tabPage',xui_tabPage.Count)	
	local flexDirection = Base.sort=='row' and 'row' or 'column'

	local o={
		__tag = 'tabPage',
		context = context,
		parentView = parentView,
		saveData = saveData,
		width = width,
		height = height,
		config = {pages={}},
		con = {
			id = id,
			view = 'div',
			style = {
				width  = width,
				height = height,
				left = xpos,
				top  = ypos,
				backgroundColor = Base.color or 'transparent',
				['flex-direction'] = Base.reverse and flexDirection..'-reverse' or flexDirection,
			},
			subviews = {},
		},
	}

	local list       = Base.list or {}
	local titleStyle = Base.titleStyle or {}
	local tabStyle   = Base.tabStyle or {}

	local titleView = _tabPage.buildTitle(o,list,titleStyle,flexDirection)
	local titleWidth = titleView.style.width
	local titleHeight = titleView.style['max-height']
	
	tabStyle.width  = tabStyle.width  or (flexDirection == 'column' and titleWidth or (width-titleWidth) )
	tabStyle.height = tabStyle.height or (flexDirection == 'column' and (height-titleHeight) or titleHeight )
	local tabView = _tabPage.buildTab(o,list,tabStyle)
	o.tabWidth = tabStyle.width
	o.tabHeight = tabStyle.height

	o.con.subviews[1] = titleView
	o.con.subviews[2] = tabView

	setmetatable(o,{__index = _tabPage,__tostring = xui_tabPage.toString})
	return o
end
function _tabPage:createView()
	local context = self.context
	local view = context:createView(self.con)
	
	self.layoutView = view
	
	local tabView = view:getSubview(2):getSubview(1)
	local tabCount = tabView:subviewsCount()
	for i = 1, tabCount do
		self.config.pages[i].layoutView = tabView:getSubview(i)
		self.config.pages[i].viewSwitch = true
	end

	return self
end
function _tabPage:setActionCallback(callback)
	local view = self.layoutView
	local config = self.config
	local selectView = view:getSubview(1)
	local tabView = view:getSubview(2):getSubview(1)		

	local onClicked = function(id,action)
		if id~=config.checkedIndex then
			local color = config[id].color
			--checked 
			local subview = selectView:getSubview(config[id].index)
			subview:getSubview(1):getSubview(1):setStyle({
				color = color.checkedTextColor
			})
			subview:getSubview(2):setStyle({
				backgroundColor = color.checkedBottomColor
			})
			--disable
			local checkedView = selectView:getSubview(config[config.checkedIndex].index)
			checkedView:getSubview(1):getSubview(1):setStyle({
				color = color.disabledTextColor
			})
			checkedView:getSubview(2):setStyle({
				backgroundColor = color.disableBottomColor
			})

			config.checkedIndex = id
			
			tabView:setStyle('left',(config[id].index-1)*(-1 *self.tabWidth))
		end
		
		if callback then
			local index = config[id].index
			local page = self:getPage(index)
			callback(page)
		end
	end
	
	local subviewsCount = selectView:subviewsCount()
	for i = 1, subviewsCount do
		local subview = selectView:getSubview(i)
		subview:setActionCallback(UI.ACTION.CLICK, onClicked)
	end
	return self
end
function _tabPage:getPage(index)
	local _type = type(index)
	if (_type == 'number') then
		return self.config.pages[index]
	elseif (_type == 'string') then
		local str = utils.buildID(self.con.id..'_title',index)
		local index = self.config[str].index
		return self.config.pages[index]
	else
		return self.config.pages
	end
end


local _gridSelect = class:new()
local xui_gridSelect = {
	Count = 0,
	layout = function ()
		return {
		--  id = nil,
			view = 'div',
			style = {
				['justify-content'] = 'center',
			},
			subviews = {
				{
					view = 'text',
					style = {},
					value = '',
				}
			},
		}
	end,
	style = {
		theme = {
			['yellow'] = {
				textColor = '#333333',
				checkedTextColor = '#ffffff',
				disableTextColor = '#eeeeee',
				borderColor = '#000000',
				checkedBorderColor = '#ffb200',
				backgroundColor = '#ffffff',
				checkedBackgroundColor = '#ffb200',
			},
			['red'] = {
				textColor = '#333333',
				checkedTextColor = '#ec5d29',
				disableTextColor = '#eeeeee',
				borderColor = '#f5f5f5',
				checkedBorderColor = '#ec5d29',
				backgroundColor = '#f5f5f5',
				checkedBackgroundColor = '#fef9f9',
			}
		},
		text = {
			['text-overflow'] = 'ellipsis',
			['text-align'] = 'center',
		},
	},
}
function _gridSelect:createLayout(Base)
	local Base = Base or {}
	local parent,Base = object:createInit('gridSelect',self,Base)

	local xpos   = floor((Base.xpos or 0)/100*parent.width)
	local ypos   = floor((Base.ypos or 0)/100*parent.height)
	local width  = floor((Base.w or 100)/100*parent.width)
	local height = floor((Base.h or 100)/100*parent.height)
	local context    = parent.context
	local saveData   = parent.saveData
	local parentView = parent.layoutView

	xui_tabPage.Count = not Base.id and xui_tabPage.Count + 1
	local id = Base.id or utils.buildID('gridSelect',xui_gridSelect.Count)	

	local o = {
		__tag = 'gridSelect',
		context = context,
		parentView = parentView,
		saveData = saveData,
		width = width,
		height = height,
		con = {
			id = id,
			view = 'div',
			style = {
				width = width,
				height = height,
				left = xpos,
				top = ypos,
				backgroundColor = Base.color or 'transparent' ,
				['flex-direction'] = 'row',
				['justify-content'] = 'space-between',
				['flex-wrap'] = 'wrap',
			},
			subviews = {},
		}
	}

	local list  = Base.list or {}
	local style = Base.style or {}
	local limit = Base.limit or 999

	---style
	local theme = Base.theme and xui_gridSelect.style.theme[Base.theme] or {}
	local textColor 			 = (style.textColor or theme.textColor) or '#333'
	local disableTextColor 		 = (style.disableTextColor or theme.disableTextColor) or '#9b9b9b'
	local checkedTextColor 		 = (style.checkedTextColor or theme.checkedTextColor) or '#333'
	local backgroundColor 		 = (style.backgroundColor or theme.backgroundColor) or '#fff'
	local checkedBackgroundColor = (style.checkedBackgroundColor or theme.checkedBackgroundColor) or '#fff'
	local disabledBackgroundColor = style.disableBackgroundColor or '#f6f6f6'
	local fontSize 				 = style.fontSize or 18
	local borderWidth 			 = style.borderWidth or 1
	local borderRadius 			 = style.borderRadius or 5 
	local borderColor 			 = (style.borderColor or theme.borderColor)  or '#000'
	local disabledBorderColor    = style.disabledBorderColor or 'transparent'
	local checkedBorderColor     = (style.checkedBorderColor or theme.checkedBorderColor) or '#000'
	--list 
	local listCount = #list --选项数量
	local lineSpacing = (style.lineSpacing or 1)/100*width --行间隔
	local selectWidth  = (style.selectWidth or 20)/100*width
	local selectHeight = (style.selectHeight or 20)/100*height
	local linesCount =  floor(width/selectWidth) --每行数量
	xui_gridSelect[id] = {
		textColor = textColor , disabledTextColor = disableTextColor, checkedTextColor = checkedTextColor,
		backgroundColor = backgroundColor , checkedBackgroundColor =checkedBackgroundColor , disabledBackgroundColor = disabledBackgroundColor,
		borderColor = borderColor , disabledBorderColor = disabledBorderColor , checkedBorderColor = checkedBorderColor,
		limit = limit , config = {}
	}
	local saveConfig = saveData:decodeGet(id) or {}
	local checkedCount = 0
	for k,v in pairs(list) do
		local config = {}
		local view = xui_gridSelect.layout()
		local value = v.value
		local checked  = saveConfig[value] or  v.checked
		local disabled = v.disabled
		if checked then
			checkedCount = checkedCount + 1
		end

		local selectID = utils.buildID(id..'_select',value)
		view.id = selectID
		view.style.width = selectWidth
		view.style.height = selectHeight
		view.style.backgroundColor = disabled and disabledBackgroundColor or (checked and checkedBackgroundColor or backgroundColor)
		view.style.borderWidth  = borderWidth
		view.style.borderColor  = disabled and disabledBorderColor or (checked and checkedBorderColor or borderColor) 
		view.style.borderRadius = borderRadius
		view.style['margin-top'] = k > linesCount and lineSpacing or 0

		local textView = view.subviews[1]
		textView.value = value
		utils.mergeTable(textView.style,xui_gridSelect.style.text)
		textView.style.color = disabled and disabledTextColor or (checked and checkedTextColor or textColor)
		textView.style.fontSize = fontSize

		table.insert(o.con.subviews,view)
		xui_gridSelect[id].config[selectID] = { index = k ,checked = checked, disabled = disabled, value = value	}
	end

	-- 填充空白
	local addeds = listCount % linesCount
	local len = (addeds~=0 and linesCount<=listCount) and (linesCount-addeds) or 0
	for i =1,len do
		local view = xui_gridSelect.layout()
		view.style.width = selectWidth
		view.style['margin-top'] = lineSpacing
		view.style.opacity = 0
		table.insert(o.con.subviews,view)
	end

	setmetatable(o,{__index = _gridSelect})
	return o
end
function _gridSelect:setActionCallback(callback)
	local view = self.layoutView
	local saveData = self.saveData
	local data = xui_gridSelect[self.con.id]
	local config = data.config

	local onClicked = function (id,action)
		local checkedConfig = config[id]
		local checkedView = view:getSubview(checkedConfig.index)
		local saveConfig = {}

		--upCheckCount
		local upCheckCount = 0
		for k,v in pairs(config) do
			if v.checked then
				saveConfig[v.value] = true
				upCheckCount = upCheckCount + 1
			end
		end

		if not checkedConfig.disabled then
			if checkedConfig.checked then
				textColor = data.textColor
				borderColor = data.borderColor
				backgroundColor = data.backgroundColor
				upCheckCount = upCheckCount - 1
			else
				if upCheckCount >= data.limit then
					checkedConfig.checked = not checkedConfig.checked
				else
					borderColor = data.checkedBorderColor
					textColor = data.checkedTextColor
					backgroundColor = data.checkedBackgroundColor
					upCheckCount = upCheckCount + 1
				end
			end
			checkedView:setStyle({
				borderColor = borderColor,
				backgroundColor = backgroundColor,
			})
			checkedView:getSubview(1):setStyle({color = textColor})
		end

		checkedConfig.checked = not checkedConfig.checked
		saveConfig[checkedConfig.value] = checkedConfig.checked and true
		saveData:encodePut(self.con.id,saveConfig)
		if callback then
			callback()
		end
	end

	local subviewsCount = view:subviewsCount()
	for i =1,subviewsCount do
		view:getSubview(i):setActionCallback(UI.ACTION.CLICK,onClicked)
	end
end


---------------------------------------------------------
local _dialog = class:new()
local xui_dialog = {
	Count = 0,
}
function  _dialog.createLayout(Base)
	local ui = Base.ui

	local width  = Base.w or 50
	local height = Base.h or 50
	local backgroundColor = Base.color or 'transparent'
	xui_dialog.Count = not Base.id and xui_dialog.Count + 1
	local id = Base.id or utils.buildID('dialog',xui_dialog.Count)

	local style = Base.style or {}
	local o = {

	}

	local popup = popup.createLayout({ui=ui,id=id,direction='middle',w=width,h=height,color=backgroundColor})
	local popupView = popup:getView()

	-- 标题
	local titleW = style.titleWidth or 100
	local titleH = style.titleHeight or 20
	local titleValue = Base.titleValue or '标题'
	local title = popupView:createLabel({w=titleW,h=titleH,text=titleValue}):addToParent()

	--内容
	local textW = style.textWidth or 100
	local textH = style.textHeight or 60
	local textValue = Base.text or ''
	local text = popupView:createLabel({w=textW,h=textH,text=textValue}):addToParent()

	--按钮
	local buttonW = style.buttonWidth or 100
	local buttonH = style.buttonHeight or 20
	local button = popupView:createLayout({w=buttonW,h=buttonH,sort='row'}):addToParent()
	local cancel = button:createButton({w=50,h=100,text='cancel'}):addToParent()
	local ok = button.createButton({w=50,h=100,text='ok'}):addToParent()

	setmetatable(o,{__index = _dialog})
	return o
end

---------------------------------------------------------
local API = {
	Label 		= _label,
	GridSelect 	= _gridSelect,
	Popup 		= _popup,
	Overlay 	= _overlay,
	Button 		= _button,
	Input 		= _input,
	TabPage 	= _tabPage,
	RichText    = _richText
}
for k,v in pairs(API) do
	_layout['create'..k] = function (self,Base)
		return v.createLayout(self,Base)
	end
end

return {
	rootView 	= _rootView,
	layout 		= _layout,
	lable 		= _lable,
	gridSelect 	= _gridSelect,
	popup 		= _popup,
	overlay 	= _overlay,
	button 		= _button,
	input 		= _input,
	tabPage 	= _tabPage,
	richText    = _richText,
	dialog 		= _dialog
}