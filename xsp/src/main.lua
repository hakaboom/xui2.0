require'base'


setmetatable(_ENV,{__index=require'xui.xui'})
show=true
ui=rootView:createLayout({Area=Rect(100,100,1280,720),Color='rgba(255,255,255,0.1)'})
context=ui:creatContext()

callPrint = function (base)
	local view = base.view
	Print(base)
end

lable=layout:createLayout({id='lable',ui=ui,w=100,h=90}):addToRootView()


page1=lable:createLayout({w=100,h=60,Color='red'}):addToSubview()
--page2=lable:createLayout({w=100,h=70}):addToSubview()
a=page1:createTabPage({
	list={
		{value='1'},{value='2'},
		{value='3'},{value='4'},
		{value='5'},{value='6'},
		{value='7'},{value='8'},
	},
	titleStyle = {
		w=20,h=20
	},
	tabStyle = {
		backgroundColor = 'black'
	},
}):addToSubview():setActionCallback(function(Base) print(Base.layoutView) end)



title=layout:createLayout({ui=ui,w=100,h=10,sort='row',Color='blue'}):addToRootView()
b=title:createStepper({w=20,number=11,maximum=13,step=2}):addToSubview():setActionCallback(function()print(1) end)
title:createInput({w=40,prompt="start"}):addToSubview():setActionCallback( function(Base)
end)







ui:show()

while show do
	sleep(1000)
end

