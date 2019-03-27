require'base'


setmetatable(_ENV,{__index=require'xui.xui'})
show=true
ui=rootView:createLayout({Area=Rect(100,100,1280,720),Color='rgba(255,255,255,0.1)'})
ui:creatContext()


lable=layout:createLayout({ui=ui,w=100,h=90}):addToRootView()


page1=lable:createLayout({w=100,h=70}):addToSubview()
page2=lable:createLayout({w=100,h=70}):addToSubview()
a=page1:createLable({
	list={
		{value='1'},{value='2'},
		{value='3'},{value='4'},
		{value='5'},{value='6'},
	},
	titleStyle = {
		w=20,h=20
	},
	tabStyle = {
		backgroundColor = 'black'
	},
}):addToSubview():setActionCallback(function(Base) end)



title=layout:createLayout({ui=ui,w=100,h=10,sort='row',Color='blue'}):addToRootView()
b=title:createButton({w=20,text="close"}):addToSubview():setActionCallback(function() end)
title:createInput({w=20,value="start"}):addToSubview():setActionCallback( function(Base)
	
end)






















ui:show()
while show do
	sleep(1000)
end

