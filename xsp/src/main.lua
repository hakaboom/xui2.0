require'base'


setmetatable(_ENV,{__index=require'xui.xui'})
show=true

local mainUI=rootView:createLayout({area=Rect(100,100,1280,720),Color='rgba(255,255,255,0.1)'})
context=mainUI:creatContext()

lable=layout.createLayout({ui=mainUI,w=100,h=50,color='#00ffffff'}):addToParent()--:addToRootView()

printLayout = function(base)
	print(base:getID())
end

显示弹窗=lable:createButton({w=20,h=10,type='blue',text='显示弹窗',fontSize=12}):addToParent():setActionCallback(function() 弹窗:show() end)
显示蒙层=lable:createButton({w=20,h=10,type='blue',text='显示蒙层',fontSize=12}):addToParent():setActionCallback(function() 蒙层1:show() end)
蒙层1=lable:createOverlay({color='blue'})
弹窗按钮=lable:createButton({w=30,h=20,type='yellow',text='弹窗'}):createView():setActionCallback(function() end)
弹窗=lable:createPopup({view=弹窗按钮,direction='top'}):addToParent():show()
--
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

