require'base'
uiLib=require'xui.xui'
setmetatable(_ENV,{__index=uiLib})
ui=rootView:createLayout({Area=Rect(100,100,1607,828)})
ui:creatContext()

title=layout:createLayout({ui=ui,w=100,h=50,Color='red'}):addToRootView()
title:createButton({w=20,h=20,text="111111"}):addToSubview()
title:createButton({w=20,h=20,text="222222"}):addToSubview()

ui:show()


while true do
	sleep(1000)
end

