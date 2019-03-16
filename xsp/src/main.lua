require'base'
uiLib=require'xui.xui'
setmetatable(_ENV,{__index=uiLib})
show=true
ui=rootView:createLayout({Area=Rect(100,100,1607,828),Color='rgba(255,255,255,0.1)'})
ui:creatContext()

title=layout:createLayout({ui=ui,w=100,h=10,sort='row'}):addToRootView()
title:createButton({w=20,text="111111"}):addToSubview():setActionCallback(function() show=false end)

lable=layout:createLayout({ui=ui,w=100,h=50,Color='red'}):addToRootView()
list1={
	{value='主菜单1'},{value='战斗菜单1'},{value='帮助1'}
}
lable:createLable({list=list1}):addToSubview():setActionCallback(function(...)Print(...) end)

list2={
	{value='主菜单2'},{value='战斗菜单2'},{value='帮助3'}
}
lable:createLable({list=list2}):addToSubview():setActionCallback(function(...)Print(...) end)
ui:show()


while show do
	sleep(100)
end

