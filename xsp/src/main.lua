require'base'

setmetatable(_ENV,{__index=require'xui.xui'})
show=true
ui=rootView:createLayout({Area=Rect(100,100,1280,720),Color='rgba(255,255,255,0.1)'})
ui:creatContext()


lable=layout:createLayout({ui=ui,w=100,h=90}):addToRootView()

page1=lable:createLayout({w=100,h=100}):addToSubview()
a=page1:createLable({
	list={
		{value='1'},{value='2'},
		{value='3'},{value='4'},
		{value='5'},{value='6'},
		{value='7'},{value='8'},
	},
	titleStyle = {
	},
	sort = 'row',
}):addToSubview():setActionCallback(function(page) end)

title=layout:createLayout({ui=ui,w=100,h=10,sort='row'}):addToRootView()
title:createButton({w=50,text="111111",Color='blue'}):addToSubview():setActionCallback(function() show=false end)
title:createButton({w=50,text="222222"}):addToSubview()
:setActionCallback(function(Base) show=true end)






















ui:show()
while show do
	sleep(1000)
end

