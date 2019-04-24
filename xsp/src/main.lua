require'base'
local json = require'cjson'
setmetatable(_ENV,{__index=require'xui.xui'})
show=true

local mainUI=rootView:createLayout({area=Rect(100,100,1280,720),color='rgba(255,255,255,1)'})
local context=mainUI:createContext()

lable1=layout.createLayout({ui=mainUI,w=100,h=40,color='#00ffffff'}):addToParent()
lable2=layout.createLayout({ui=mainUI,w=100,h=60,color='#00ffffff'}):addToParent()

lable1:createButton({w=20,h=15,theme='blue',text='保存',fontSize=12,disabled=false}):addToParent():setActionCallback( function() 弹窗:show() mainUI:getSaveData():save()  end)
lable1:createButton({w=20,h=15,theme='blue',text='不可点击' ,fontSize=12,disabled=true}):addToParent():setActionCallback( function() 弹窗:show()  end)
lable1:setAttr('href','www.baidu.com')
label1=lable1:createLabel({id='aaa',w=100,h=20,text='测试'}):addToParent()
gridList={
	{value='a',checked=true},{value='b',disabled=true},{value='c'},{value='d'}
}
grid=lable1:createGridSelect({list=gridList,theme='red',style={selectWidth=19}}):addToParent():setActionCallback()

popup1=弹窗:getView()



mainUI:show()

while show do
	sleep(1000)
end

