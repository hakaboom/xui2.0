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
                ['border-radius'] = 12,
				['margin'] = 1,
            },
			subviews = {
                {
                    view = 'text',
                    style = {
                        ['text-overflow'] = 'ellipsis',
                        ['font-size'] = 25,
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
		Subview = self.Subview,
		width = width,
		height = height,
		con = {
		},
	}
	
	local layout = xui_button.layout()
	local style  = layout.style
	o.con = layout
	layout.id = utils.buildID('button',(Base.id or xui_button.Count))
		
	style.width = width
	style.height = height
	style.left = xpos
	style.top = ypos
	style.backgroundColor = Base.Color or 'white'
		
	layout.subviews[1].value = Base.text
	
	utils.mergeTable(o.con.style,Base.style)
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
	local Subview = self.Subview
	
	if not self.layoutView then
		self:createView()
	end

	Subview:addSubview(self.layoutView)
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
				['justify-content'] = 'flex-end',
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
						['backgroundColor'] = '#ffffff',
					},
					subviews = {},
				},
			},
		}
	end,
	config={},
} 
function _lable:createLayout(Base)
	local	Base = Base or {}
	local	xpos = Base.xpos and Base.xpos/100*self.width or 0
	local	ypos = Base.ypos and Base.ypos/100*self.height or 0
	local	layoutSort = Base.sort=='column' and 'column' or 'row'
	local	width = (Base.w or 100) /100*(self.width or ui.width)
	local	height = (Base.h or 20) /100*(self.height or ui.height)
	if not Base.id then
		xui_lable.Count = xui_lable.Count + 1
	end
	local o={
		__tag = 'lable',
		context = self.context,
		Subview = self.Subview,
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
				backgroundColor = Base.Color or '#4c4a48',
				['flex-direction'] = layoutSort,
			},
			subviews = {
			},
		},
	}
	
	local	list = Base.list or {}
	local 	style = Base.style or {}
	local	textColor = style.textColor or 'black'
	local	backgroundColor = (style.backgroundColor or style['background-color']) or '#4c4a48'
	local	fontSize = (style.fontSize or style['font-size']) or 18
	local	checkedTextColor = style.checkedTextColor or textColor 
	local	checkedBackgroundColor = style.checkedBackgroundColor or '#ffffff'
	local	disabledTextColor = style.disableTextColor or textColor
	local	disabledBackgroundColor = style.disableBackgroundColor or '#4c4a48'

	local	layout = o.con.subviews
	for i=1,#list do
		local value = list[i].value
		local select_layout = xui_lable.select_layout()
		select_layout.id = o.con.id .. '@' ..value
		
		local selectStyle = select_layout.style
		selectStyle['width'] = layoutSort=='column' and width or width*0.2
		selectStyle['height'] = layoutSort=='column' and height*0.2 or height
		
		local textView = select_layout.subviews[1]
		local textViewStyle = textView.style
		textViewStyle['width'] = selectStyle['width']
		textViewStyle['height'] = selectStyle['height']*0.95
		textViewStyle['backgroundColor'] = i==1 and checkedBackgroundColor or disabledBackgroundColor
		local textValueStyle = textView.subviews[1].style
		textValueStyle['fontSize'] = fontSize
		textValueStyle['textColor'] = i==1 and checkedTextColor or disabledTextColor
		textView.subviews[1].value = value or ''
		
		local bottomView = select_layout.subviews[2]
		local bottomViewStyle = bottomView.style
		bottomViewStyle['width'] = selectStyle['width']
		bottomViewStyle['height'] = selectStyle['height']*0.05
		bottomViewStyle['backgroundColor'] = checkedBackgroundColor
		
		layout[i] = select_layout
		
		local checked = i==1 and true or false
		local disable = not checked
		if i==1 then o.config.checkedIndex = select_layout.id end
		o.config[select_layout.id] = {index = i,value = value,checked = checked,disabled = disabled}
		o.config[select_layout.id].color = {
			checkedTextColor = checkedTextColor,checkedBackgroundColor = checkedBackgroundColor,
			disabledTextColor = disabledTextColor,disabledBackgroundColor = disabledBackgroundColor}
	end

	setmetatable(o,{__index = _lable})
	return o
end

function _lable:setActionCallback(callback)
	local view = self.layoutView
	local config = self.config

	local onClicked = function(id,action)
		if id~=config.checkedIndex then
			local color = config[id].color
			local subview = view:getSubview(config[id].index)
			subview:getSubview(1):setStyle({
				backgroundColor = color.checkedBackgroundColor
			})
			subview:getSubview(1):getSubview(1):setStyle({
				textColor = color.checkedTextColor
			})
			
			local checkedView = view:getSubview(config[config.checkedIndex].index)
			checkedView:getSubview(1):setStyle({
				backgroundColor = color.disabledBackgroundColor
			})
			checkedView:getSubview(1):getSubview(1):setStyle({
				textColor = color.disableCheckedTextColor
			})
			config.checkedIndex = id
		end
	end
	
	local subviewsCount = view:subviewsCount()
	for i = 1, subviewsCount do
		local subview = view:getSubview(i)
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
	local Subview = self.Subview
	
	if not self.layoutView then
		self:createView()
	end
	
	Subview:addSubview(self.layoutView)
	self.viewSwitch = treu
	return self
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
	local width = (Base.w or 100) /100*(self.width or ui.width)
	local height = (Base.h or 20) /100*(self.height or ui.height)
	if not Base.id then
		xui_layout.Count = xui_layout.Count + 1
	end
	
	local o = {
		__tag = 'layout',
		context = self.context or Base.ui.context,
		Subview = self.layoutView,
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
	
	--	print(o.con.id)
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

	if not self.viewSwitch then
		self:createView()
	end
	local view = self.layoutView
	
	rootView:addSubview(view)
	self.Subview = view 
	self.viewSwitch = true
	return self
end

function _layout:addToSubview() 
	if self.viewSwitch then return end --防止重复添加
	local context = self.context
	local Subview = self.Subview
	
	if not self.viewSwitch then
		self:createView()
	end
	local view = self.layoutView
	
	Subview:addSubview(view)
	self.Subview = view 
	self.viewSwitch = true
	return self
end

function _layout:createButton(Base)
	return _button.createLayout(self,Base)
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