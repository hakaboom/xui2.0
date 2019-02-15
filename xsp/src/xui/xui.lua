local _width,_height=screen.getSize().width,screen.getSize()._height
local calSacle=function (x)return 750 / _width * x end

local utils = require'xui.utils'

local _rootView={}
function _rootView:createLayout(Base)
	local rect = Base.Area or Rect(0,0,_width,_height)
	local width,height = calSacle(rect.width),calSacle(rect.height)

	local o={
		type = 'root_UI',
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

--/////////////////////////////////////////////////////////////
local _layout={}
local xui_layout={
	Count = 0,	
}
function _layout:createLayoutView(Base)
	Base = Base or {}
	local xpos = Base.xpos and Base.xpos/100*self.width or 0
	local ypos = Base.ypos and Base.ypos/100*self.height or 0
	local width = (Base.w or 100) /100*(self.width or ui.width)
	local height = (Base.h or 20) /100*(self.height or ui.height)
	if not Base.id then
		xui_layout.Count = xui_layout.Count + 1
	end
	local o = {
		type = 'layout',
		context = self.context or Base.ui.context,
		Subview = self.layoutView,
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
				backgroundColor = Base.Color or 'white',
			},
		},
	}
	print(o.con.id)
	utils.mergeTable(o.con.style,Base.style)
	setmetatable(o,{__index = self})
	return o
end

function _layout:createView()
	local context = self.context
	local view = context:createView(self.con)

	self.layoutView = view
	self.viewSwitch = false
	return view
end

function _layout:addToRootView(layoutView)
	local context = self.context
	local view = layoutView or self:createView()
	local rootView = context:getRootView()

	rootView:addSubview(view)
	self.Subview = rootView
	self.viewSwitch = true
	return self
end

function _layout:addToSubview(layoutView) 
	local context = self.context
	local view = layoutView or self:createView()
	local Subview = self.Subview
	Subview:addSubview(view)
	self.viewSwitch = true
	return self
end

--/////////////////////////////////////////////////////////////
local _button={}
local xui_button={
	Count = 0,
}
function _button:createLayoutView(Base)
	local xpos = Base.xpos and Base.xpos/100*self.width or 0
	local ypos = Base.ypos and Base.ypos/100*self.height or 0
	local width = Base.w/100*self.width
	local height = Base.h/100*self.height

	local o = {
		type = 'button',
		context = self.context,
		Subview = self.Subview,
		width = width,
		height = height,
		con = {
			id = Base.id or 'xui.button'..tostring(xui_button.Count),
			view = 'div',
			style = {
				width = width,
				height = height,
				left = xpos,
				top = ypos,
			},
		},
	}

	local text = Base.text
	setmetatable(o,{__index = self})
end


--/////////////////////////////////////////////////////////////
local _lable={}
local xui_lable={
	Count=0,
} 
function _lable:createLayoutView(Base)

end


--/////////////////////////////////////////////////////////////
local _M={
	rootView = _rootView,
	layout = _layout,
	button = _button,
	lable  = _lable,
}
return _M