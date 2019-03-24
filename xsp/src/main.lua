require'base'

setmetatable(_ENV,{__index=require'xui.xui'})
show=true
ui=rootView:createLayout({Area=Rect(100,100,1280,720),Color='rgba(255,255,255,0.1)'})
ui:creatContext()

title=layout:createLayout({ui=ui,w=100,h=10,sort='row'}):addToRootView()
title:createButton({w=20,text="111111"}):addToSubview():setActionCallback(function() show=false end)

lable=layout:createLayout({ui=ui,w=100,h=80,id='aa'}):addToRootView()
lable:createLable({
	list={{value='1'},{value='2'},{value='3'},{value='4'},{value='5'}},
	titleStyle={
	
	},
	tabStyle={
	
	},
}):addToSubview():setActionCallback(function(...)Print(...) end)























ui:show()
while show do
	sleep(1000)
end

