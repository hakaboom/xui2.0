setmetatable(_ENV,{__index=require'xui.xui'})
show=true

local mainUI=rootView:createLayout({area=Rect(100,100,1280,720),color='rgba(255,255,255,1)'})
local context=mainUI:createContext()

layout1=layout.createLayout({ui=mainUI,w=100,h=40,color='#00ffffff'}):addToParent()
layout2=layout.createLayout({ui=mainUI,w=100,h=60,color='#00ffffff'}):addToParent()

layout1:createButton({w=20,h=15,theme='blue',text='保存',style={fontSize=12},disabled=false}):addToParent():setActionCallback( function() 弹窗:show() mainUI:getSaveData():save()  end)
layout2:createButton({w=20,h=15,theme='blue',text='不可点击',style={fontSize=12},disabled=true}):addToParent():setActionCallback( function() 弹窗:show()  end)

弹窗=popup.createLayout({ui=mainUI,direction='bottom',w=50,h=50})


tabPage1=layout1:createTabPage({
	list={
		{value='1',tabStyle={backgroundColor='#ffffff'}},{value='2'},
		{value='3'},{value='4'},
		{value='5'},{value='6'},
		{value='7'},{value='8'},
	},
	titleStyle = {
		titleWidth=20,h=20
	},
	tabStyle = {
		backgroundColor = 'black'
	},
}):addToParent():setActionCallback(function(Base) print(Base.layoutView) end)
gridList={
	{value='a',checked=true},{value='b',disabled=true},{value='c'},{value='C'}
}
grid=tabPage1:getPage(1):createGridSelect({list=gridList,theme='yellow',style={selectWidth=19}}):addToParent():setActionCallback()

popup1=弹窗:getView()

diaLog.createLayout({ui=mainUI,text='asdasasadsklhcasjkdhvcjkshvkjcshvkajshvakjschvkjadsa',id='提示框',titleStyle={color='red'}})

mainUI:show()

while show do
	sleep(1000)
end

