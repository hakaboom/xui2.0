require'base'
ui=require'xui.xui'
setmetatable(_ENV,{__index=ui})
ui=rootView:createLayout({Area=Rect(0,0,1920,1080/2)})
ui:creatContext()

title=layout:createLayoutView({ui=ui,Color='red'}):addToRootView()
t=title:createLayoutView({Color="blue"}):addToSubview()

ui:show()

while true do
	sleep(1000)
end