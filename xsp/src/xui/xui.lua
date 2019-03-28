local _width,_height=screen.getSize().width,screen.getSize()._height
local calSacle = function (x) return 750 / _width * x end

local utils = require'xui.utils'

local class={}
function class:new()
	local o={
	}
	setmetatable(o,{__index = self})
	return o
end
function class:setStyle(...)
	local tbl = {...}
	local ViewStyle = self.con.style
	if (#tbl == 1) then
		local styles = tbl[1]
		if (type(tbl[1]) == 'table') then
			if not rawget(self,'layoutView') then
				utils.mergeTable(ViewStyle,styles)
			else
				self.layoutView:setStyle(styles)
			end
		end
	elseif (#tbl == 2) then
		local key,value = tbl[1],tbl[2]
		if not rawget(self,'layoutView') then
			ViewStyle[key] = value
		else
			self.layoutView:setStyle(key,value)
		end
	end
	return self
end
function class:setAttr(...)
	local tbl = {...}
	if (#tbl == 1) then
		local Attrs = tbl[1]
		if (type(tbl[1]) == 'table') then
			if not rawget(self,'layoutView') then
				utils.mergeTable(self.con,Attrs)
			else
				self.layoutView:setAttr(Attrs)
			end
		end
	elseif (#tbl == 2) then
		local key,value = tbl[1],tbl[2]
		if not rawget(self,'layoutView') then
			self.con[key] = value
		else
			self.layoutView:setAttr(key,value)
		end
	end
	return self
end
function class:setOverlay()

end
function class:getID()
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
	if self.viewSwitch then return end
	local context = self.context
	local rootView = context:getRootView()

	if not rawget(self,'layoutView') then
		self:createView()
	end
	
	rootView:addSubview(self.layoutView)
	self.viewSwitch = true
	return self
end
function class:addToSubview() 
	if self.viewSwitch then return end --防止重复添加
	local context = self.context
	local parentView = self.parentView

	if not rawget(self,'layoutView') then
		self:createView()
	end

	parentView:addSubview(self.layoutView)
	self.viewSwitch = true
	return self
end
function class:removeFromParent()
	self.layoutView:removeFromParent()
end
function class:getType()
	return self.__tag
end

local _storage={}
function _storage:new(fileName)
	local o ={
		data={},
		path = xmod.resolvePath('[private]'..(fileName or 'UISave.txt'))
	}
	
	local cjson = require'cjson'
	local file = io.open(o.path,'a+')
	
	local str = file:read('a')
	file:close()
	if #str~=0 then
		o.data = cjson.encode(str)
	end
	
	setmetatable(o,{__index = _storage})
	return o
end
function _storage:put(key,value)
	self.data[key] = value
end
function _storage:get(key,defValue)
	return (self.data[key] or defsValue)
end
function _storage:save()
	local cjson = require'cjson'
	local t = self.data
	local str = cjson.decode(t)
	io.open(o.path,'r+'):write(ste):flush():close()
end
------------------------------------------------------------------

local _rootView={}
function _rootView:createLayout(Base)
	local rect = Base.Area or Rect(0,0,_width,_height)
	local width,height = calSacle(rect.width),calSacle(rect.height)

	local o={
		__tag = 'root_UI',
		width = width,
		height = height,
		rootLayout = {
			view = Base.view or 'scroller',
			style ={	
				width = width,
				height = height,
				left = calSacle(rect.x),
				top	= calSacle(rect.y),
				backgroundColor = Base.Color or 'white',
			},
			subviews = {},
		},
		globalStyle = Base.globalStyle or {},
	}
	setmetatable(o,{__index = self})
	return o
end
function _rootView:creatContext()
	local context = UI.createContext(self.rootLayout,self.globalStyle)
	self.context = context
	return context
end
function _rootView:show()
	self.context:show()
end
function _rootView:close()
	self.context:close()
end

------------------------------------------------------------------
local _layout=class:new()
local xui_layout={
	Count = 0,
}
function _layout:createLayout(Base)
	local Base = Base or {}
	local xpos = Base.xpos and Base.xpos/100*self.width or 0
	local ypos = Base.ypos and Base.ypos/100*self.height or 0
	local width = math.floor((Base.w or 100) /100*(self.width or ui.width))
	local height = math.floor((Base.h or 100) /100*(self.height or ui.height))
	if not Base.id then
		xui_layout.Count = xui_layout.Count + 1
	end

	local o = {
		__tag = 'layout',
		context = self.context or Base.ui.context,
		parentView = self.layoutView,
		viewSwitch = false,
		width = width,
		height = height,
		con = {	
			id = Base.id or 'xui.layout'..tostring(xui_layout.Count),
			view = Base.view or 'div',
			class = Base.class,
			style ={
				width = width,
				height = height,
				left = xpos,
				top = ypos,
				backgroundColor = Base.Color or 'rgb(255,255,255)',
				['flex-direction'] = Base.sort or 'column',
			},
			subviews = {},
			['scroll-direction'] = (Base.sort == 'row') and 'horizontal' or 'vertical',
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
	view:setActionCallback(UI.ACTION.SWIPE, onClicked)
	return self
end

------------------------------------------------------------------
local _button=class:new()
local xui_button={
	Count = 0,
	layout = function ()
		return {
			view = 'div',
			style = {
                ['align-items'] = 'center',
                ['justify-content'] = 'center',
            },
			subviews = {
                {
                    view = 'text',
                    style = {
                        ['text-overflow'] = 'ellipsis',
                        ['font-size'] = 15,
                        lines = 1,
                    },
                    value = '',
                }
            }
		}
	end,
}
function _button:createLayout(Base)
	local Base = Base or {}
	local xpos = Base.xpos and Base.xpos/100*self.width or 0
	local ypos = Base.ypos and Base.ypos/100*self.height or 0
	local width = math.floor((Base.w or 100) /100*(self.width or ui.width))
	local height = math.floor((Base.h or 100) /100*(self.height or ui.height))
	if not Base.id then
		xui_button.Count = xui_button.Count + 1
	end

	local o = {
		__tag = 'button',
		context = self.context,
		parentView = self.layoutView,
		width = width,
		height = height,
		con = {
		},
	}
	local style = Base.style or {}
	local fontSize = (style.fontSize or style['font-size']) or 18
	local textColor = style.textColor or '#333333'	
	local backgroundColor = (style.backgroundColor or style['background-color']) or '#ffffff'
	local checkedBackgroundColor = style.checkedBackgroundColor or '#efeff0'
	local borderRadius = (style.borderRadius or  style['border-radius']) or 15
	
	local layout = xui_button.layout()
	layout.id = utils.buildID('button',(Base.id or xui_button.Count))
	utils.mergeTable(layout.style,{
		width = width,
		height = height,
		left = xpos,
		top = ypos,
		borderRadius = borderRadius,
		backgroundColor  = backgroundColor,
		['backgroundColor:active'] = checkedBackgroundColor,
	})
	
	utils.mergeTable(layout.subviews[1].style,{
		fontSize = fontSize,
		color = textColor,
	})
	
	layout.subviews[1].value = Base.text

	o.con = layout
	
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
	if not self.layoutView then
		self.con.subviews[1].value = str
	else
		self.layoutView:getSubview(1):setAttr('value',str)
	end
end
function _layout:createButton(Base)
	return _button.createLayout(self,Base)
end

------------------------------------------------------------------
local _input=class:new()
local xui_input={
	Count = 1,
	layout = function ()
		return {
			view = 'input',
			style = {},
			value = '',
		}
	end
}
function _input:createLayout(Base)
	local Base = Base or {}
	local xpos = Base.xpos and Base.xpos/100*self.width or 0
	local ypos = Base.ypos and Base.ypos/100*self.height or 0
	local width = (Base.w or 100)/100*self.width
	local height = (Base.h or 100)/100*self.height
	if not Base.id then
		xui_input.Count = xui_input.Count + 1
	end
	
	local o ={
		__tag = 'input',
		context = self.context,
		parentView = self.layoutView,
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
	
	local id = utils.buildID('input',(Base.id or xui_button.Count))
	local kbtype = Base.kbtype or 'text'
	local prompt = Base.prompt or ''
	local placeholder = Base.placeholder or ''
	local disabled = Base.disabled or false
	local autofocus = Base.autofocus or false
	local maxlength = Base.maxlength or 999
	local singleline = Base.singleline or true

	local style = Base.style or {}
	local fontSize = (style.fontSize or style['font-size']) or 20
	local textColor = style.textColor or '#666666'
	local backgroundColor = (style.backgroundColor or style['background-color']) or '#e5e5e5'
	local checkedBackgroundColor = style.checkedBackgroundColor or '#000000'
	local layout = xui_input.layout()
	
	local cancelStyle = style.cancelStyle or {}
	local cancelFontSize = cancelStyle.fontSize or 15
	local cancelBackgroundColor = cancelStyle.backgroundColor or '#eeeeee'
	local cancelCheckedBackgroundColor = cancelStyle.cancelCheckedBackgroundColor or cancelBackgroundColor
	
	o.con.style.backgroundColor = backgroundColor
	local inputLayout = {
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
			['padding-left'] = 6,	
		},
	}
	o.con.subviews[1] = inputLayout
	
	local cancel = self.createButton(o,{w=20,text='取消',style={
		backgroundColor = cancelBackgroundColor,
		fontSize = cancelFontSize,
		borderRadius = 0,
		checkedBackgroundColor = cancelCheckedBackgroundColor,
	}})
	cancel:setStyle({
		left = width*0.8,
		visibility = 'hidden',
		position = 'absolute',
	})
	o.con.subviews[2] = cancel:getView()
	
	setmetatable(o,{__index = _input})
	return o
end
function _input:setActionCallback(callback)
	local view = self.layoutView
	local inputView = view:getSubview(1)
	local cancel = view:getSubview(2)
	
	local onClicked = function (id,action)
		cancel:setStyle('visibility','visible')
		inputView:setAttr('disabled',false)
	end
	local onCancel = function (id,action)
		cancel:setStyle('visibility','hidden')
		inputView:setAttr('disabled',true)
	end
	local onINPUT = function (id,action)
		local value = view:getAttr('value')
		local Base = {id=id,action=action,view=view,value=value}
		
		if callback then
			callback(Base)
		end
	end
	
	cancel:setActionCallback(UI.ACTION.CLICK,onCancel)
	inputView:setActionCallback(UI.ACTION.CLICK,onClicked)
	inputView:setActionCallback(UI.ACTION.INPUT,onINPUT)
end
function _input:getValue()
	return self.saveData.value
end
function _layout:createInput(Base)
	return _input.createLayout(self,Base)
end
------------------------------------------------------------------
local _gridSelect=class:new() 
local xui_gridSelect={
	Count = 0,
	select_layout = function ()
		return {
			view = 'div',
            style = {
                ['flex-direction'] = 'row',
                ['justify-content'] = 'space-between',
                ['flex-wrap'] = 'wrap'
            },
            subviews = {

            }		
		}
	end,
	option_layout = function ()
		return {
			view = 'div',
			style = {},
			subviews = {
				{
					view = 'text',
					style = {},
					value = ''
				},
			},
		}
	end,
}
function _gridSelect:createLayout(Base)
	local	list = Base.list or {}
	local	style = Base.style or {}
	local	limit = Base.limit or 999 -- 可选数量
	local	textColor = style.textColor or '#333333'
	local	backgroundColor = (style.backgroundColor or style['background-color']) or '#f6f6f6'
	local	fontSize = (style.fontSize or style['font-size']) or 20
	local 	borderColor = style.borderColor or 'rgba(0,0,0,0)'
	local	checkedTextColor = style.checkedTextColor or textColor
	local	checkedBackgroundColor = style.checkedBackgroundColor or '#c0c0c0'
	local 	checkedBorderColor	= style.checkedBorderColor or 'rgba(0,0,0,0)'
	local	disableBorderColor = style.disableBorderColor or 'rgba(0,0,0,0)'
	local	disableBackgroundColor = style.disableBackgroundColor or '#f6f6f6'
	local 	disabledTextColor = style.disabledTextColor or '#9b9b9b'
	
	Base.w = not Base.w and 100/#list or Base.w
	Base.lineSpacing = Base.lineSpacing and Base.lineSpacing/100*self.width or 5
	local	lines = math.floor(100/Base.w)
	local 	layoutWidth  = Base.w/100*self.width
	local	layoutHeight = Base.h/100*self.height
	local	lineSpacing  = (100-(Base.w*lines))/(lines-1)/100*self.width
	local	columnSpacing = Base.lineSpacing or 12
	local	column = math.ceil(#list/lines)
	
	local layout = xui_gridSelect.select_layout()
	layout.id = utils.buildID('gridSelect',(Base.id or xui_button.Count))

end
------------------------------------------------------------------
local _stepper=class:new()
local xui_stepper={
	Count = 0,
	layout = function ()
		return {
			{
				view = 'div',
				style = {
					flex = 1,
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
					flex = 2,
					['text-align'] = 'center',
				},
				value = '',
				singleline = true,
				disabled = true,
			},
			{
				view = 'div',
				style = {
					flex = 1,
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
	local xpos = Base.xpos and Base.xpos/100*self.width or 0
	local ypos = Base.ypos and Base.ypos/100*self.height or 0
	local width = math.floor((Base.w or 100) /100*(self.width or ui.width))
	local height = math.floor((Base.h or 100) /100*(self.height or ui.height))
	
	local value = tonumber(Base.number) or 0
	local step = tonumber(Base.step) or 1
	local maximum = Base.maximum or 999
	local minimum = Base.minimum or 0
	local maxlength = Base.maxlength or #tostring(maximum)
	local style = Base.style or {}
	local fontSize = (style.fontSize or style['font-size']) or 18
	local backgroundColor = (style['background-color'] or style.backgroundColor) or '#ffffff'
	
	local buttonStyle = style.buttonStyle or {}
	local buttonBackgroundColor = buttonStyle.backgroundColor or '#e5e5e5'
	local buttonFontSize = (buttonStyle.fontSize or buttonStyle['font-size']) or 20
		
	local o = {
		__tag = 'stepper',
		context = self.context,
		parentView = self.layoutView,
		config = {maximum= maximum,minimum = minimum,step = step},
		width = width,
		height = height,
		con = {
			view = 'div',
			style = {
				['flex-start'] = 'space-between',
				['align-items'] = 'center',
				['flex-direction'] = 'row',
				width = width,
				height = height,
				backgroundColor = backgroundColor,
			},
			subviews = {},
		},
	}
	
	local layout = xui_stepper.layout()
	o.con.subviews = layout
	
	local inputView = layout[2]
	local inputStyle = inputView.style
	inputStyle.fontSize = fontSize
	inputStyle.maxlength = maxlength
	inputView.value = value
	
	for k,v in ipairs({1,3}) do
		local view = layout[v]
		local viewStyle = view.style
		viewStyle.backgroundColor = buttonBackgroundColor 
		
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
	
	addView:setActionCallback(UI.ACTION.CLICK, onAdd)
	reduceView:setActionCallback(UI.ACTION.CLICK, onReduce)
	return self
end
function _layout:createStepper(Base)
	return _stepper.createLayout(self,Base)
end
------------------------------------------------------------------
local _tabPage=class:new()
local xui_tabPage={
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
	local  tabStyle = Base.tabStyle or {}

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
function _layout:createTabPage(Base)
	return _tabPage.createLayout(self,Base)
end

------------------------------------------------------------------

local _M={
	rootView = _rootView,
	layout = _layout,
}
return _M