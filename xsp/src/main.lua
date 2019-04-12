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

弹窗=popup.createLayout({ui=mainUI,direction='middle',w=50,h=50})
popup1=弹窗:getView()

components={
	{type='text',value='黄色主题',theme='yellow'},
	{type='link',value='百度link',href='www.baidu.com',theme='red'},
	{type='link',value='谷歌link',href='www.goole.com',theme='black'},
	{type='text',value='自定义颜色',style={textColor='#546E7A'}},
	{type='tag' ,value='满100减20',theme='red'},
	{type='tag',value='自由行',style={textColor='#3d3d3d',boredrColor='#FFC900',backgroundColor='#FFC900',borderRadius=14}},
}
richText1=lable1:createRichText({list=components,w=60,h=20,style={fontSize=12}}):addToParent()

gridList={
	{value='1',checked=true},{value='2'},{value='3'},{value='4'}
}
grid=lable1:createGridSelect({list=gridList,theme='yellow',style={selectWidth=19}}):addToParent():setActionCallback()
mainUI:show()

while show do
	sleep(1000)
end

