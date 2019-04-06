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
function class:getStyle()
	if self.layoutView then
		return self.layoutView:getStyles()
	else
		return self.con.style
	end
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

	self.layoutView = view
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
	--	printf('read config by %s',o.path)
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
				backgroundColor = Base.color or 'white',
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
	
	xui_layout.Count = not Base.id and xui_layout.Count +1
	local id = Base.id or utils.buildID('layout',xui_layout.Count)
	
	local backgroundColor = Base.color or '#ffffff'
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
function _richText:createLayout(Base) --还没整好
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
				height = height,
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
	local fontSize 				 = (style.fontSize or Base.fontSize) or 18
	local textColor 			 = (style.textColor or Base.textColor) or '#333333'
	local backgroundColor 	     = (style.backgroundColor or style.backgroundColor) or '#ffffff'
	local checkedBackgroundColor = style.checkedBackgroundColor
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
	
	view:setActionCallback(UI.ACTION.CLICK, onClicked)
	view:setActionCallback(UI.ACTION.LONG_PRESS, onClicked)
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

	xui_input.Count = not Base.id and xui_input.Count +1
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
	local fontSize 					 	 = (style.fontSize or (Base.fontSize or style['font-size'])) or 18
	local textColor 					 = (style.textColor or Base.textColor) or '#666666'
	local backgroundColor 				 = ((style.backgroundColor or style['background-color']) or Base.color) or '#e5e5e5'
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

--[[
local _slideNav={}
local xui_slideNav = {
	Count = 0,
}
function _slideNav:createLayout(Base)
	local Base = Base or {}
	local floor,parent,Base = math.floor,object:createInit('slideNav',self,Base)

	local xpos   = floor((Base.xpos or 0)/100*parent.width)
	local ypos   = floor((Base.ypos or 0)/100*parent.height)
	local width  = floor((Base.w or 100)/100*parent.width)
	local height = floor((Base.h or 100)/100*parent.height)
	local context    = parent.context
	local saveData   = parent.saveData
	local parentView = parent.layoutView

	xui_slideNav.Count = not Base.id and xui_slideNav.Count + 1
	local id = Base.id or utils.buildID('slideNav',xui_slideNav.Count)
end
]]

---以下还没整
local _stepper=class:new()
local xui_stepper={
	Count = 0,
	layout = function ()
		return {
			{
				view = 'div',
				style = {
					borderRadius = 999,
					['align-items'] = 'center',
				},
				subviews = {
					{
						view = 'text',
						value = '-',
						style = {},
					},
				},
			},
			{
				view = 'input',
				type = 'number',
				style = {
					['text-align'] = 'center',
				},
				value = '',
				singleline = true,
				disabled = true,
			},
			{
				view = 'div',
				style = {
					borderRadius = 999,
					['align-items'] = 'center',
				},
				subviews = {
					{
						view = 'text',
						value = '+',
						style = {},
					},					
				},
			},
		}
	end
}
function _stepper:createLayout(Base)
	local Base = Base or {}
	local parent,Base = object:createInit('stepper',self,Base)

	local xpos   = floor((Base.xpos or 0)/100*parent.width)
	local ypos   = floor((Base.ypos or 0)/100*parent.height)
	local width  = floor((Base.w or 100)/100*parent.width)
	local height = floor((Base.h or 100)/100*parent.height)
	local context    = parent.context
	local saveData   = parent.saveData
	local parentView = parent.layoutView
	
	xui_stepper.Count = not Base.id and xui_stepper.Count + 1
	local id = Base.id or utils.buildID('stepper',xui_stepper.Count)

	local value = tonumber(Base.value) or 0
	local min   = tonumber(Base.min) or 0
	local max   = tonumber(Base.max) or 999
	local step  = tonumber(Base.step) or 1

	local style = Base.style or {}
	local backgroundColor 		= style.backgroundColor or '#fff'
	local textColor 			= style.textColor or '#000'
	local fontSize 				= style.fontSize or 18
	local buttonWidth			= style.buttonWidth or height--20
	local buttonBackgroundColor = style.buttonBackgroundColor or '3d3d3d'

	local o = {
		__tag = 'stepper',
		context = context,
		parentView = parentView,
		saveData = saveData,
		config = {min = min,max = max,step = step},
		width = width,
		height = height,
		con = {
			view = 'div',
			style = {
				width = width,
				height = height,
				backgroundColor = backgroundColor,
				['flex-start'] = 'center',
				['align-items'] = 'center',
				['flex-direction'] = 'row',
			},
			subviews = {},
		},
	}

	local layout = xui_stepper.layout()
	o.con.subviews = layout
	
	local inputView = layout[2]
	inputView.style.fontSize  = fontSize
	inputView.style.maxlength = maxlength
	inputView.id = id
	inputView.value = o.saveData:get(id,value) 
	
	for k,v in ipairs({1,3}) do
		local view = layout[v]
		view.style.backgroundColor = buttonBackgroundColor 
		
		local textView = view.subviews[1]
		local textStyle = textView.style
		textStyle.fontSize = buttonFontSize
	end

	setmetatable(o,{__index = _stepper})
	return o
end
function _stepper:setActionCallback(callback)
	local view = self.layoutView
	local addView = view:getSubview(3)
	local textView = view:getSubview(2)
	local reduceView = view:getSubview(1)
	
	local saveData = self.saveData
	local maximum = self.config.maximum
	local minimum = self.config.minimum
	local step = self.config.step
	
	local onAdd = function ()
		local num = tonumber(textView:getAttr('value'))
		if num+step <= maximum then
			textView:setAttr('value',num+step)
		end
	end
	local onReduce = function ()
		local num = tonumber(textView:getAttr('value'))
		if num-step >= minimum then
			textView:setAttr('value',num-step)	
		end
	end
	local onINPUT = function (id)
		local value = textView:getAttr('value')
		saveData:put(id,value)
	end

	textView:setActionCallback(UI.ACTION.INPUT, onINPUT)
	addView:setActionCallback(UI.ACTION.CLICK, onAdd)
	reduceView:setActionCallback(UI.ACTION.CLICK, onReduce)
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
function _tabPage:buildTitle(list,style)
	local o={
		view = 'scroller',
		style = {},
		subviews = {},
	}
	
	local list = list or {}
	local style = style or {}
	local layoutSort = self.con.style['flex-direction']
	local width  =	math.floor(layoutSort =='column' and self.width or self.width*(style.w or 12)/100)
	local height =	math.floor(layoutSort =='column' and self.height*(style.h or 15)/100 or self.height)
	
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
		['flex-direction'] = layoutSort=='column' and 'row' or 'column',
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
			},
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

	for i=1, #list do
		local value = list[i].value
		local tabView = _layout:createLayout({ui=self,id=utils.buildID(self.con.id..'_tab',value)})
			tabView:setStyle({
				width=width,
				height=height,
				backgroundColor = backgroundColor,
			})
			
		if type(list[i].tabStyle) =='table' then
			tabView:setStyle(list[i].tabStyle)
		end
			
		self.config.pages[i] = tabView
		o.subviews[1].subviews[i] = tabView:getView()
	end
	
	return o
end
function _tabPage:createLayout(Base)
	local Base = Base or {}
	local xpos = Base.xpos and Base.xpos/100*self.width or 0
	local ypos = Base.ypos and Base.ypos/100*self.height or 0
	local layoutSort = Base.sort=='row' and 'row' or 'column'
	local width = math.floor((Base.w or 100) /100*(self.width or ui.width))
	local height = math.floor((Base.h or 100) /100*(self.height or ui.height))
	if not Base.id then
		xui_tabPage.Count = xui_tabPage.Count + 1
	end
	
	local o={
		__tag = 'tabPage',
		context = self.context,
		parentView = self.layoutView,
		width = width,
		height = height,
		config = {pages={}},
		con = {
			id = utils.buildID('tabPage',(Base.id or xui_tabPage.Count)),
			view = 'div',
			style = {
				width = width,
				height = height,
				left = xpos,
				top = ypos,
				backgroundColor = Base.Color or '#ffffff',
				['flex-direction'] = layoutSort,
			},
			subviews = {
			},
		},
	}

	local list = Base.list or {}
	local titleStyle = Base.titleStyle or {}
	local tabStyle = Base.tabStyle or {}

	local titleView = _tabPage.buildTitle(o,list,titleStyle)
	local titleWidth = titleView.style.width
	local titleHeight = titleView.style['max-height']
	o.con.subviews[1] = titleView
	
	
	tabStyle.width = tabStyle.width or (layoutSort == 'column' and titleWidth or (width-titleWidth) )
	tabStyle.height = tabStyle.height or (layoutSort == 'column' and (height-titleHeight) or titleHeight )
	local tabView = _tabPage.buildTab(o,list,tabStyle)
	o.con.subviews[2] = tabView
	o.tabWidth = tabStyle.width
	o.tabHeight = tabStyle.height

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

	local onClicked = function(id,action)
		if id~=config.checkedIndex then
			local selectView = view:getSubview(1)
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
			
			local tabView = view:getSubview(2):getSubview(1)
			tabView:setStyle('left',(config[id].index-1)*(-1 *self.tabWidth))
		end
		
		if callback then
			local index = config[id].index
			local page = self:getPage(index)
			callback(page)
		end
	end
	
	local selectView = view:getSubview(1)
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


------------------------------------------------------------------
function _layout:createRichText(Base)
	return _richText.createLayout(self,Base)
end
function _layout:createPopup(Base)
	return _popup.createLayout(self,Base)
end
function _layout:createOverlay(Base)
	return _overlay.createLayout(self,Base)
end
function _layout:createButton(Base)
	return _button.createLayout(self,Base)
end
function _layout:createInput(Base)
	return _input.createLayout(self,Base)
end
function _layout:createStepper(Base)
	return _stepper.createLayout(self,Base)
end
function _layout:createTabPage(Base)
	return _tabPage.createLayout(self,Base)
end
local _M={
	rootView = _rootView,
	layout = _layout,
	popup = _popup,
	overlay = _overlay,
}
return _M