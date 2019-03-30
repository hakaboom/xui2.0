require'base'


setmetatable(_ENV,{__index=require'xui.xui'})
show=true

local ui=rootView:createLayout({Area=Rect(100,100,1280,720),Color='rgba(255,255,255,0.1)'})
context=ui:creatContext()

lable=layout:createLayout({id='lable',ui=ui,w=100,h=90}):addToRootView()


page1=lable:createLayout({w=100,h=50,Color='red'}):addSubview()

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
--}):addSubview():setActionCallback(function(Base) print(Base.layoutView) end)



--title=layout:createLayout({ui=ui,w=100,h=10,sort='row',Color='blue'}):addToRootView()
----b=title:createStepper({w=20,number=11,maximum=13,step=2}):addSubview():setActionCallback(function()print(1) end)
----c=title:createInput({w=40,prompt="start"}):addSubview():setActionCallback()
d=page1:createButton({w=10,h=10,style={backgroundColor='red',fontSize=10}}):addSubview():setActionCallback(function()  end)
d:setValue('asdsada')
--f=page1:createPopup({w=20,h=100,direction='left'}):show()
e=overlay:createLayout({ui=ui,w=50,h=50}):addToRootView():setActionCallback():show()

ui:show()

while show do
	sleep(1000)
end

