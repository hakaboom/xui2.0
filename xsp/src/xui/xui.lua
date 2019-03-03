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

------------------------------------------------------------------
local _button={}
local xui_button={
	Count = 0,
	layout = function ()
		return {
			view = 'div',
			style = {
                ['align-items'] = 'center',
                ['justify-content'] = 'center',
                ['border-radius'] = 12,
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
	end
}
function _button:createLayout(Base)
	Base = Base or {}
	local xpos = Base.xpos and Base.xpos/100*self.width or 0
	local ypos = Base.ypos and Base.ypos/100*self.height or 0
	local width = (Base.w or 100)/100*self.width
	local height = (Base.h or 100)/100*self.height
	if not Base.id then
		xui_button.Count = xui_button.Count + 1
	end

	local o = {
		type = 'button',
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
	layout.id = Base.id or 'xui.button'..tostring(xui_button.Count)
	
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
	local view = self.layoutView

	Subview:addSubview(view)
	self.Subview = view 
	self.viewSwitch = true
	return self
end


------------------------------------------------------------------
local _lable={}
local xui_lable={
	Count=0,
} 
function _lable:createLayout(Base)
	Base = Base or {}
end


------------------------------------------------------------------
local _layout={}
local xui_layout={
	Count = 0,	
}
function _layout:createLayout(Base)
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
				backgroundColor = Base.Color or 'white',
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
------------------------------------------------------------------
local _M={
	rootView = _rootView,
	layout = _layout,
}
return _M