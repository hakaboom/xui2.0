local _width,_height=screen.getSize().width,screen.getSize()._height
local calSacle=function (x)return 750 / _width * x end

local utils = require'xui.utils'

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
	local context = self.context
	context:show()
end


------------------------------------------------------------------
local _layout={}
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
				['flex-direction'] = Base.sort or 'column'
			},
		},
	}
	
	utils.mergeTable(o.con.style,Base.style)
	setmetatable(o,{__index = self})
	return o
end
function _layout:createView()
	local context = self.context
	local view = context:createView(self.con)

	self.layoutView = view
	return self
end
function _layout:addToRootView()
	if self.viewSwitch then return end	--防止重复添加
	local context = self.context
	local rootView = context:getRootView()

	if not self.layoutView then
		self:createView()
	end
	
	rootView:addSubview(self.layoutView)
	self.viewSwitch = true
	return self
end
function _layout:addToSubview() 
	if self.viewSwitch then return end --防止重复添加
	local context = self.context
	local parentView = self.parentView

	if not self.layoutView then
		self:createView()
	end
	
	parentView:addSubview(self.layoutView)
	self.viewSwitch = true
	return self
end
function _layout:setStyle(styles)	--styles need table
	if not layoutView then
		local layoutStyle = self.con.style
		utils.mergeTable(layoutStyle,styles)
	else
		local view = self.layoutView
		view:setStyle(styles)
	end
end
function _layout:getView()
	return self.con
end
function _layout:getID()
	local id = self.con.id
	return id
end

------------------------------------------------------------------
local _button={}
local xui_button={
	Count = 0,
	layout = function ()
		return {
			view = 'div',
			style = {
				['backgroundColor:active'] ='#efeff0',
                ['align-items'] = 'center',
                ['justify-content'] = 'center',
                ['border-radius'] = 15,
            },
			subviews = {
                {
                    view = 'text',
                    style = {
                        ['text-overflow'] = 'ellipsis',
                        ['font-size'] = 15,
                        lines = 1,
                    }
                }
            }
		}
	end,
}
function _button:createLayout(Base)
	local Base = Base or {}
	local xpos = Base.xpos and Base.xpos/100*self.width or 0
	local ypos = Base.ypos and Base.ypos/100*self.height or 0
	local width = (Base.w or 100)/100*self.width
	local height = (Base.h or 100)/100*self.height
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
	
	local layout = xui_button.layout()
	layout.id = utils.buildID('button',(Base.id or xui_button.Count))
	utils.mergeTable(layout.style,{
		width = width,height = height,left = xpos,top = ypos,
		backgroundColor  = (Base.Color or 'white'),
	})
		
	layout.subviews[1].value = Base.text

	o.con = layout
	setmetatable(o,{__index = _button})
	return o
end
function _button:createView()
	local context = self.context
	local view = context:createView(self.con)

	self.layoutView = view
	return self
end
function _button:addToSubview()
	local context = self.context
	local parentView = self.parentView
	
	if not self.layoutView then
		self:createView()
	end

	parentView:addSubview(self.layoutView)
	self.viewSwitch = true
	return self
end
function _button:setActionCallback(callback)
	local view = self.layoutView
	local onClicked=function (id,action)
		local Base={id=id,action=action,view=view}
		if callback then
			callback(Base)
		end
	end
	view:setActionCallback(UI.ACTION.CLICK, onClicked)
    view:setActionCallback(UI.ACTION.LONG_PRESS, onClicked)
end
function _layout:createButton(Base)
	return _button.createLayout(self,Base)
end

------------------------------------------------------------------
local _gridSelect={} 
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
local _lable={}
local xui_lable={
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
	config={},
} 
function _lable:buildSelect(list,style)
	local o={
		view = 'scroller',
		style = {},
		subviews = {},
	}
	
	local list = list or {}
	local style = style or {}
	local layoutSort = self.con.style['flex-direction']
	local width  =	layoutSort =='column' and self.width or self.width*0.15
	local height =	layoutSort =='column' and self.height*0.15 or self.height
	local selectWidth  = layoutSort =='column' and width*0.15 or width
	local selectHeight = layoutSort =='column' and height or height*0.15
	local fontSize = (style.fontSize or style['font-size']) or 15
	local checkedTextColor = style.checkedTextColor or '#000000'
	local checkedBackgroundColor = style.checkedBackgroundColor or '#ffffff'
	local disabledTextColor = style.disabledTextColor or '#b0b0b0'
	local disabledBackgroundColor = style.disableBackgroundColor or '#000000'
	local checkedBottomColor = style.checkedBottomColor or '#000000'
	local disableBottomColor = style.disableBottomColor or '#ffffff'
	
	o.style={
		['flex-direction'] = layoutSort=='column' and 'row' or 'column',
	}
	o['scroll-direction'] = o.style['flex-direction']=='column' and 'vertical' or 'horizontal'
	
	local subviews = o.subviews
	for i=1, #list do
		local value = list[i].value or ''
		local layout = xui_lable.select_layout()
		layout.id = self.con.id ..'@'.. value
		subviews[i] = layout
		
		local layoutStyle = layout.style
		layoutStyle.width  = selectWidth
		layoutStyle.height = selectHeight
		
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
function _lable:buildTab(list,style)
	local o={
		view = 'div',
		style = {},
		subviews = {},
	}
	
	local list = list or {}
	local style = style or {}
	local width = style.width
	local height = style.height
	local backgroundColor = style.backgroundColor or '#ffffff'
	
	o.style.width = width
	o.style.height = height
	local t={
		'red','blue','black','yellow','purple'
	}
	for i=1, #list do
		local	tabView = _layout:createLayout({ui=self,id=list[i].value})
			tabView:setStyle({
				width=width,
				height=height,
				backgroundColor = t[i],
				left = ( i - 1 )*( -1 * width),
			})

			o.subviews[i] = tabView:getView()
	end
	
	return o
end
function _lable:createLayout(Base)
	local	Base = Base or {}
	local	xpos = Base.xpos and Base.xpos/100*self.width or 0
	local	ypos = Base.ypos and Base.ypos/100*self.height or 0
	local	layoutSort = Base.sort=='row' and 'row' or 'column'
	local	width = math.floor((Base.w or 100) /100*(self.width or ui.width))
	local	height = math.floor((Base.h or 100) /100*(self.height or ui.height))
	if not Base.id then
		xui_lable.Count = xui_lable.Count + 1
	end
	
	local o={
		__tag = 'lable',
		context = self.context,
		parentView = self.layoutView,
		width = width,
		height = height,
		config = {},
		con = {
			id = utils.buildID('lable',(Base.id or xui_lable.Count)),
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
	
	local	list = Base.list or {}
	local	titleStyle = Base.titleStyle or {}
	local 	tabStyle = Base.tabStyle or {}

	local selectView = _lable.buildSelect(o,list,titleStyle)
	local selectWidth  = layoutSort =='column' and width or width*0.15
	local selectHeight = layoutSort =='column' and height*0.15 or height
	selectView.style.width = selectWidth
	selectView.style['max-height'] = selectHeight
	o.con.subviews[1] = selectView
	
	
	tabStyle.width = tabStyle.width or (layoutSort == 'column' and selectWidth or (width-selectWidth) )
	tabStyle.height = tabStyle.height or (layoutSort == 'column' and (height-selectHeight) or selectHeight )
	local tabView = _lable.buildTab(o,list,tabStyle)
	o.con.subviews[2] = tabView
	o.tabWidth = tabStyle.width
	o.tabHeight = tabStyle.height

	setmetatable(o,{__index = _lable})
	return o
end
function _lable:setActionCallback(callback)
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
			

		end
		
		if callback then
			callback()
		end
	end
	
	local selectView = view:getSubview(1)
	local subviewsCount = selectView:subviewsCount()
	for i = 1, subviewsCount do
		local subview = selectView:getSubview(i)
		subview:setActionCallback(UI.ACTION.CLICK, onClicked)
		subview:setActionCallback(UI.ACTION.LONG_PRESS, onClicked)
	end
	
	return self
end
function _lable:createView()
	local context = self.context
	local view = context:createView(self.con)

	self.layoutView = view
	return self
end
function _lable:addToSubview()
	local context = self.context
	local parentView = self.parentView
	
	if not self.layoutView then
		self:createView()
	end

	parentView:addSubview(self.layoutView)
	self.viewSwitch = true
	return self
end
function _layout:createLable(Base)
	return _lable.createLayout(self,Base)
end


------------------------------------------------------------------

local _M={
	rootView = _rootView,
	layout = _layout,
}
return _M