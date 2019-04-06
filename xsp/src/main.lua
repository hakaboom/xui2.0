require'base'

setmetatable(_ENV,{__index=require'xui.xui'})
show=true

local mainUI=rootView:createLayout({area=Rect(100,100,1280,720),color='rgba(255,255,255,1)'})
local context=mainUI:createContext()

lable1=layout.createLayout({ui=mainUI,w=100,h=50,color='#00ffffff'}):addToParent()
lable2=layout.createLayout({ui=mainUI,w=100,h=50,color='#00ffffff'}):addToParent()

lable1:createButton({w=20,h=10,theme='blue',text='lable1',fontSize=12}):addToParent():setActionCallback( function() 弹窗:show() mainUI:getSaveData():save()  end)
lable2:createButton({w=20,h=10,theme='yellow',text='lable2',fontSize=12}):addToParent():setActionCallback( function() 弹窗:show() end)
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
--	{type='text',value='春秋旅游广州-泰国曼谷6天往返单机票自由行自由春秋旅游广州-泰国曼谷6天往返单机票自由行自由行…',style={lines=3}}
}
richText1=lable1:createRichText({list=components,w=60,h=30,style={fontSize=12}}):addToParent()
stepper=lable1:createStepper({w=40,h=30}):addToParent()

-- lable2=layout.createLayout({id='lable2',ui=mainUI,w=20,h=20,color='blue'})
-- lable3=lable2:createLayout({id='lable3',w=50,h=100,color='red'}) 
-- lable2:addSubview(lable3)
-- lable:addSubview(lable2)

--d=lable:createPopup()
--a=page1:createTabPage({
--	list={
--		{value='1'},{value='2'},
--		{value='3'},{value='4'},
--		{value='5'},{value='6'},
--		{value='7'},{value='8'},
--	},
--	titleStyle = {
--		w=20,h=20
--	},
--	tabStyle = {
--		backgroundColor = 'black'
--	},
--}):addToParent():setActionCallback(function(Base) print(Base.layoutView) end)



--title=layout:createLayout({ui=ui,w=100,h=10,sort='row',Color='blue'}):addToRootView()
----b=title:createStepper({w=20,number=11,maximum=13,step=2}):addToParent():setActionCallback(function()print(1) end)
----c=title:createInput({w=40,prompt="start"}):addToParent():setActionCallback()
--d:setValue('asdsada')
--f=page1:createPopup({w=20,h=100,direction='left'}):show()
--e=overlay:createLayout({ui=ui,w=50,h=50}):addToRootView():setActionCallback():show()

mainUI:show()
while show do
	sleep(1000)
end

