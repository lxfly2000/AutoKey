--Encoding: GBK, 运行环境：Lua for Windows（Lua 5.1.5）
--wx库参考: http://docs.wxwidgets.org/2.8/wx_classref.html

--[[
按键脚本可用函数：
sendKey(vkCode,isPressDown):
无返回值，
vkCode:虚拟键码（参考MSDN：https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx），
isPressDown:true为按下，false为放开
sleep(milliseconds):
无返回值，
milliseconds:等待的毫秒数

亦支持标准Lua语法。
]]

--引用
require("wx")
require("alien")

--控件ID
ID_BUTTON_RECORD=101
ID_BUTTON_PLAY=102
ID_STATIC_EVENTCOUNTER=103
ID_EDIT_SCRIPT=104
ID_BUTTON_OPEN=105
ID_BUTTON_SAVE=106
ID_EDIT_FILEPATH=107
ID_MENU_SYSICON=101
ID_MENUITEM_SHOW=1001
ID_MENUITEM_ABOUT=1002
ID_MENUITEM_HELP=1003
ID_MENUITEM_EXIT=1004
ID_MENU_PLAY=102
ID_MENUITEM_CHANGEHOTKEY=1005
ID_MENUITEM_TIMEBASED=1006
ID_MENUITEM_CLEARONRECORD=1007
ID_MENU_RECORD=103

g_dialog=nil
g_textCounter=nil
g_buttonRecord=nil
g_buttonPlay=nil
g_editScript=nil
g_editFilePath=nil
g_buttonOpen=nil
g_buttonSave=nil
g_buttonAbout=nil
g_sysicon=nil
g_menuSysicon=nil
g_menuRecord=nil
g_menuPlay=nil
g_menuItemUseSleep=nil
g_menuItemClearOnRecord=nil

--虚拟键码（可读字符键的虚拟键码为ASCII，对于字母则是大写字符的ASCII）
VK_LBUTTON=0x01
VK_RBUTTON=0x02
VK_CANCEL=0x03
VK_MBUTTON=0x04
VK_XBUTTON1=0x05
VK_XBUTTON2=0x06
VK_BACK=0x08
VK_TAB=0x09
VK_CLEAR=0x0C
VK_RETURN=0x0D
VK_SHIFT=0x10
VK_CONTROL=0x11
VK_MENU=0x12
VK_PAUSE=0x13
VK_CAPITAL=0x14
VK_KANA=0x15
VK_HANGUEL=0x15
VK_HANGUL=0x15
VK_JUNJA=0x17
VK_FINAL=0x18
VK_HANJA=0x19
VK_KANJI=0x19
VK_ESCAPE=0x1B
VK_CONVERT=0x1C
VK_NONCONVERT=0x1D
VK_ACCEPT=0x1E
VK_MODECHANGE=0x1F
VK_SPACE=0x20
VK_PRIOR=0x21
VK_NEXT=0x22
VK_END=0x23
VK_HOME=0x24
VK_LEFT=0x25
VK_UP=0x26
VK_RIGHT=0x27
VK_DOWN=0x28
VK_SELECT=0x29
VK_PRINT=0x2A
VK_EXECUTE=0x2B
VK_SNAPSHOT=0x2C
VK_INSERT=0x2D
VK_DELETE=0x2E
VK_HELP=0x2F
VK_LWIN=0x5B
VK_RWIN=0x5C
VK_APPS=0x5D
VK_SLEEP=0x5F
VK_NUMPAD0=0x60
VK_NUMPAD1=0x61
VK_NUMPAD2=0x62
VK_NUMPAD3=0x63
VK_NUMPAD4=0x64
VK_NUMPAD5=0x65
VK_NUMPAD6=0x66
VK_NUMPAD7=0x67
VK_NUMPAD8=0x68
VK_NUMPAD9=0x69
VK_MULTIPLY=0x6A
VK_ADD=0x6B
VK_SEPARATOR=0x6C
VK_SUBTRACT=0x6D
VK_DECIMAL=0x6E
VK_DIVIDE=0x6F
VK_F1=0x70
VK_F2=0x71
VK_F3=0x72
VK_F4=0x73
VK_F5=0x74
VK_F6=0x75
VK_F7=0x76
VK_F8=0x77
VK_F9=0x78
VK_F10=0x79
VK_F11=0x7A
VK_F12=0x7B
VK_F13=0x7C
VK_F14=0x7D
VK_F15=0x7E
VK_F16=0x7F
VK_F17=0x80
VK_F18=0x81
VK_F19=0x82
VK_F20=0x83
VK_F21=0x84
VK_F22=0x85
VK_F23=0x86
VK_F24=0x87
VK_NUMLOCK=0x90
VK_SCROLL=0x91
VK_LSHIFT=0xA0
VK_RSHIFT=0xA1
VK_LCONTROL=0xA2
VK_RCONTROL=0xA3
VK_LMENU=0xA4
VK_RMENU=0xA5
VK_BROWSER_BACK=0xA6
VK_BROWSER_FORWARD=0xA7
VK_BROWSER_REFRESH=0xA8
VK_BROWSER_STOP=0xA9
VK_BROWSER_SEARCH=0xAA
VK_BROWSER_FAVORITES=0xAB
VK_BROWSER_HOME=0xAC
VK_VOLUME_MUTE=0xAD
VK_VOLUME_DOWN=0xAE
VK_VOLUME_UP=0xAF
VK_MEDIA_NEXT_TRACK=0xB0
VK_MEDIA_PREV_TRACK=0xB1
VK_MEDIA_STOP=0xB2
VK_MEDIA_PLAY_PAUSE=0xB3
VK_LAUNCH_MAIL=0xB4
VK_LAUNCH_MEDIA_SELECT=0xB5
VK_LAUNCH_APP1=0xB6
VK_LAUNCH_APP2=0xB7
VK_OEM_1=0xBA
VK_OEM_PLUS=0xBB
VK_OEM_COMMA=0xBC
VK_OEM_MINUS=0xBD
VK_OEM_PERIOD=0xBE
VK_OEM_2=0xBF
VK_OEM_3=0xC0
VK_OEM_4=0xDB
VK_OEM_5=0xDC
VK_OEM_6=0xDD
VK_OEM_7=0xDE
VK_OEM_8=0xDF
VK_OEM_102=0xE2
VK_PROCESSKEY=0xE5
VK_PACKET=0xE7
VK_ATTN=0xF6
VK_CRSEL=0xF7
VK_EXSEL=0xF8
VK_EREOF=0xF9
VK_PLAY=0xFA
VK_ZOOM=0xFB
VK_NONAME=0xFC
VK_PA1=0xFD
VK_OEM_CLEAR=0xFE

function getVkText(vk)
	if (vk>=0x30 and vk<=0x39) or (vk>=0x41 and vk<=0x5A) then
		return string.char(vk)
	else
		return string.format("0x%02X",vk)
	end
end

function getDateTimeString()
	return "录制于："..os.date("%Y-%m-%d %X")
end

--全局变量
g_appname="AutoKey"
g_author="lxfly2000"
g_appurl="https://github.com/lxfly2000/AutoKey"
g_version="1"
g_startMessage="AutoKey by lxfly2000"
g_appdesc="此程序可以模仿按键精灵的方式来帮助你完成重复性的键盘操作。"
g_hotkeyPlay=VK_F12--VK_*或string.byte('<大写ASCII字符或数字>',1)
g_hotkeyRecord=VK_F11
g_useSleep=true
g_clearOnRecord=false
g_hookproc=nil
g_hookKeyboard=nil
g_onSettingHotkeyCtrlId=0
g_functionCount={
	keyCount=0,
	displayCount=function(self)
		textMsg(string.format("事件数：%d",self.keyCount))
	end,
	resetCount=function(self)
		self.keyCount=0
		self.displayCount(self)
	end,
	addKeyCount=function(self)
		self.keyCount=self.keyCount+1
		self.displayCount(self)
	end
}
g_onRunningScript=false
g_onRecordingScript=false
g_lastRecordEventTime=0

--DLL变量
g_kernel32=nil
g_user32=nil

--WinAPI常量
KEYEVENTF_KEYUP=0x0002
WM_KEYDOWN=0x100
WM_KEYUP=0x101
WM_SYSKEYDOWN=0x104
WM_SYSKEYUP=0x105
WH_KEYBOARD_LL=13
HC_ACTION=0

--获取WindowsAPI
function getWindowsApi()
	g_kernel32=alien.load("kernel32.dll")
	g_user32=alien.load("user32.dll")
	--Kernel32.dll:VOID WINAPI Sleep(DWORD dwMilliseconds);
	g_kernel32.Sleep:types{ret="void","ulong",abi="stdcall"}
	--User32.dll:VOID WINAPI keybd_event(BYTE bVk,BYTE bScan,DWORD dwFlags,ULONG_PTR dwExtraInfo);
	g_user32.keybd_event:types{ret="void","byte","byte","ulong","ulong",abi="stdcall"}
	--User32.dll:HHOOK WINAPI SetWindowsHookEx(int idHook,HOOKPROC lpfn,HINSTANCE hMod,DWORD dwThreadId);
	g_user32.SetWindowsHookExA:types{ret="pointer","int","callback","pointer","ulong",abi="stdcall"}
	--User32.dll:BOOL WINAPI UnhookWindowsHookEx(HHOOK hhk);
	g_user32.UnhookWindowsHookEx:types{ret="int","pointer",abi="stdcall"}
	--User32.dll:LRESULT WINAPI CallNextHookEx(HHOOK hhk,int nCode,WPARAM wParam,LPARAM lParam);
	g_user32.CallNextHookEx:types{ret="long","pointer","int","uint","long",abi="stdcall"}
	--typedef LRESULT (CALLBACK* HOOKPROC)(int code, WPARAM wParam, LPARAM lParam);
	g_hookproc=alien.callback(keyboardHook,{ret="long","int","uint","pointer"--[["long"]],abi="stdcall"})--党中央已经钦定啦！参数3的类型就是pointer，这样吼不吼啊？
end

function keyboardHook(code,wParam,lParam)
	if code==HC_ACTION then
		keyProcess(alien.touint(lParam),wParam)
	end
	return g_user32.CallNextHookEx(g_hookKeyboard,code,wParam,lParam)
end

function changeHotkeyTip(ctrl,key)
	ctrl:SetToolTip("快捷键："..getVkText(key))
end

function keyProcess(vkCode,msg)
	if msg==WM_KEYUP or msg==WM_SYSKEYUP then
		if g_onSettingHotkeyCtrlId==ID_BUTTON_PLAY then--设置回放快捷键
			g_onSettingHotkeyCtrlId=0
			g_hotkeyPlay=vkCode
			changeHotkeyTip(g_buttonPlay,g_hotkeyPlay)
			g_buttonPlay:SetLabel("回放(&P)")
		elseif g_onSettingHotkeyCtrlId==ID_BUTTON_RECORD then--设置录制快捷键
			g_onSettingHotkeyCtrlId=0
			g_hotkeyRecord=vkCode
			changeHotkeyTip(g_buttonRecord,g_hotkeyRecord)
			g_buttonRecord:SetLabel("记录(&R)")
		elseif vkCode==g_hotkeyRecord and g_buttonRecord:IsEnabled() then--录制命令
			g_buttonRecord:Command(wx.wxCommandEvent(wx.wxEVT_COMMAND_BUTTON_CLICKED))
		elseif vkCode==g_hotkeyPlay and g_buttonPlay:IsEnabled() then--回放命令
			g_buttonPlay:Command(wx.wxCommandEvent(wx.wxEVT_COMMAND_BUTTON_CLICKED))
		end
	end
	if g_onRecordingScript then
		if msg==WM_KEYUP or msg==WM_SYSKEYUP then
			addRecordKeyEvent(vkCode,false)
		elseif msg==WM_KEYDOWN or msg==WM_SYSKEYDOWN then
			addRecordKeyEvent(vkCode,true)
		end
	end
end

function addRecordKeyEvent(vkCode,isPressDown)
	if vkCode==g_hotkeyRecord then
		return
	end
	local now_clock=os.clock()
	g_editScript:AppendText(string.format("sleep(%d)sendKey(%d,%s)\n",(now_clock-g_lastRecordEventTime)*1000,vkCode,isPressDown and "true" or "false"))
	g_lastRecordEventTime=now_clock
	g_functionCount:addKeyCount()
end

--WindowsAPI函数调用
function sleep(milliseconds)
	if g_useSleep then
		g_kernel32.Sleep(milliseconds)
	end
end

function sendKey(vkCode,isPressDown)
	g_user32.keybd_event(vkCode,0,isPressDown and 0 or KEYEVENTF_KEYUP,0)
	g_functionCount:addKeyCount()
end

function runScript()
	if g_onRunningScript then
		return
	end
	g_onRunningScript=true
	g_functionCount:resetCount()
	g_buttonPlay:SetLabel("停止(&P)")
	g_buttonRecord:Enable(false)
	local source=""
	for i=1,g_editScript:GetNumberOfLines(),1 do
		source=source..g_editScript:GetLineText(i-1).."\n"
	end
	--TODO：由于Lua和wxLua均没有真正意义上的多线程，正准备考虑用Windows的……
	loadstring(source)()
	stopRunScript()
end

function stopRunScript()
	g_buttonRecord:Enable(true)
	g_buttonPlay:SetLabel("回放(&P)")
	g_onRunningScript=false
end

function recordScript()
	g_onRecordingScript=true
	g_buttonRecord:SetLabel("停止(&R)")
	g_buttonPlay:Enable(false)
	if g_clearOnRecord then
		g_editScript:Clear()
	end
	g_editScript:AppendText("--"..getDateTimeString().."\n")
	g_functionCount:resetCount()
	g_onRecordingScript=true
	g_lastRecordEventTime=os.clock()
end

function stopRecordScript()
	g_onRecordingScript=false
	g_buttonPlay:Enable(true)
	g_buttonRecord:SetLabel("记录(&R)")
	g_onRecordingScript=false
end

--创建对话框界面
function createDialog()
	--创建控件
	g_dialog=wx.wxDialog(wx.NULL,wx.wxID_ANY,g_appname,wx.wxDefaultPosition,wx.wxSize(400,220),wx.wxDEFAULT_DIALOG_STYLE+wx.wxMINIMIZE_BOX+wx.wxRESIZE_BORDER+wx.wxMAXIMIZE_BOX)
	local boxSizerCounter=wx.wxBoxSizer(wx.wxHORIZONTAL)
	local boxSizerFilePath=wx.wxBoxSizer(wx.wxHORIZONTAL)
	local boxSizerBase=wx.wxBoxSizer(wx.wxVERTICAL)
	g_textCounter=wx.wxStaticText(g_dialog,ID_STATIC_EVENTCOUNTER,g_startMessage)
	g_buttonRecord=wx.wxButton(g_dialog,ID_BUTTON_RECORD,"记录(&R)")
	changeHotkeyTip(g_buttonRecord,g_hotkeyRecord)
	g_buttonPlay=wx.wxButton(g_dialog,ID_BUTTON_PLAY,"回放(&P)")
	g_buttonPlay:SetDefault()
	changeHotkeyTip(g_buttonPlay,g_hotkeyPlay)
	g_buttonOpen=wx.wxButton(g_dialog,ID_BUTTON_OPEN,"打开(&O)")
	g_buttonSave=wx.wxButton(g_dialog,ID_BUTTON_SAVE,"保存(&S)")
	g_editScript=wx.wxTextCtrl(g_dialog,ID_EDIT_SCRIPT,"",wx.wxDefaultPosition,wx.wxDefaultSize,wx.wxTE_MULTILINE)
	g_editFilePath=wx.wxTextCtrl(g_dialog,ID_EDIT_FILEPATH)
	boxSizerCounter:Add(g_textCounter,1,wx.wxALIGN_CENTER_VERTICAL+wx.wxLEFT+wx.wxRIGHT,2)
	boxSizerCounter:Add(g_buttonRecord)
	boxSizerCounter:Add(g_buttonPlay)
	boxSizerFilePath:Add(g_editFilePath,1,wx.wxEXPAND)
	boxSizerFilePath:Add(g_buttonOpen)
	boxSizerFilePath:Add(g_buttonSave)
	boxSizerBase:Add(boxSizerFilePath,0,wx.wxEXPAND)
	boxSizerBase:Add(g_editScript,1,wx.wxEXPAND)
	boxSizerBase:Add(boxSizerCounter,0,wx.wxEXPAND)
	g_dialog:SetSizer(boxSizerBase)

	g_sysicon=wx.wxTaskBarIcon()
	g_sysicon:SetIcon(wx.wxArtProvider.GetIcon(wx.wxART_EXECUTABLE_FILE),g_appname)

	--创建菜单
	g_menuSysicon=wx.wxMenu()
	g_menuSysicon:Append(ID_MENUITEM_SHOW,"显示(&O)")
	g_menuSysicon:Append(ID_MENUITEM_HELP,"帮助(&H)")
	g_menuSysicon:Append(ID_MENUITEM_ABOUT,"关于(&A)")
	g_menuSysicon:Append(ID_MENUITEM_EXIT,"退出(&E)")
	g_menuRecord=wx.wxMenu()
	g_menuRecord:Append(ID_MENUITEM_CHANGEHOTKEY,"修改快捷键(&H)")
	g_menuItemClearOnRecord=wx.wxMenuItem(g_menuRecord,ID_MENUITEM_CLEARONRECORD,"记录时清空脚本(&C)","",wx.wxITEM_CHECK)
	g_menuRecord:Append(g_menuItemClearOnRecord)
	g_menuItemClearOnRecord:Check(g_clearOnRecord)
	g_menuPlay=wx.wxMenu()
	g_menuPlay:Append(ID_MENUITEM_CHANGEHOTKEY,"修改快捷键(&H)")
	g_menuItemUseSleep=wx.wxMenuItem(g_menuPlay,ID_MENUITEM_TIMEBASED,"启用&Sleep","",wx.wxITEM_CHECK)
	g_menuPlay:Append(g_menuItemUseSleep)
	g_menuItemUseSleep:Check(g_useSleep)

	--添加事件
	g_buttonOpen:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED,function(event)
		local strpath=wx.wxFileSelector("选择文件",".",g_editFilePath:GetLineText(0),"lua","Lua脚本文件|*.lua|所有文件|*",wx.wxFD_OPEN+wx.wxFD_FILE_MUST_EXIST,g_dialog)
		if #strpath~=0 then
			g_editFilePath:SetValue(strpath)
			g_editScript:LoadFile(strpath)
		end
	end)
	g_buttonPlay:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED,function(event)
		if g_onRunningScript then
			stopRunScript()
		else
			runScript()
		end
	end)
	g_buttonPlay:Connect(wx.wxEVT_RIGHT_UP,function(event)
		g_buttonPlay:PopupMenu(g_menuPlay)
	end)
	g_buttonRecord:Connect(wx.wxEVT_RIGHT_UP,function(event)
		g_buttonRecord:PopupMenu(g_menuRecord)
	end)
	g_buttonRecord:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED,function(event)
		if g_onRecordingScript then
			stopRecordScript()
		else
			recordScript()
		end
	end)
	g_buttonSave:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED,function(event)
		if g_editScript:SaveFile(g_editFilePath:GetLineText(0)) then
			wx.wxMessageBox("保存成功。")
		else
			wx.wxMessageBox("保存失败，请确认是否输入了有效的文件路径。",g_appname,wx.wxICON_EXCLAMATION,g_dialog)
		end
	end)
	g_sysicon:Connect(wx.wxEVT_TASKBAR_LEFT_DOWN,function(event)
		if not g_dialog:IsShown() then
			g_dialog:Show(true)
			g_dialog:Maximize(g_maximized)
		end
	end)
	g_sysicon:Connect(wx.wxEVT_TASKBAR_RIGHT_DOWN,function(event)
		g_sysicon:PopupMenu(g_menuSysicon)
	end)
	g_menuSysicon:Connect(ID_MENUITEM_SHOW,wx.wxEVT_COMMAND_MENU_SELECTED,function(event)
		g_dialog:Show(true)
	end)
	g_menuSysicon:Connect(ID_MENUITEM_HELP,wx.wxEVT_COMMAND_MENU_SELECTED,function(event)
		wx.wxMessageBox("录制操作：点击记录录制操作，然后点击回放可以重复已录制的操作。\n不会记录或回放快捷键。\n键盘脚本可以从文件读取或保存。\n退出：在托盘图标上右键选择退出。")
	end)
	g_menuSysicon:Connect(ID_MENUITEM_ABOUT,wx.wxEVT_COMMAND_MENU_SELECTED,function(event)
		local aboutInfo=wx.wxAboutDialogInfo()
		aboutInfo:AddDeveloper(g_author)
		aboutInfo:SetWebSite(g_appurl)
		aboutInfo:SetVersion(g_version)
		aboutInfo:SetName(g_appname)
		aboutInfo:SetDescription(g_appdesc)
		wx.wxAboutBox(aboutInfo)
	end)
	g_menuSysicon:Connect(ID_MENUITEM_EXIT,wx.wxEVT_COMMAND_MENU_SELECTED,function(event)
		wx.wxGetApp():ExitMainLoop()
	end)
	g_menuRecord:Connect(ID_MENUITEM_CHANGEHOTKEY,wx.wxEVT_COMMAND_MENU_SELECTED,function(event)
		g_onSettingHotkeyCtrlId=ID_BUTTON_RECORD
		g_buttonRecord:SetLabel("快捷键？")
	end)
	g_menuRecord:Connect(ID_MENUITEM_CLEARONRECORD,wx.wxEVT_COMMAND_MENU_SELECTED,function(event)
		g_clearOnRecord=g_menuItemClearOnRecord:IsChecked()
	end)
	g_menuPlay:Connect(ID_MENUITEM_CHANGEHOTKEY,wx.wxEVT_COMMAND_MENU_SELECTED,function(event)
		g_onSettingHotkeyCtrlId=ID_BUTTON_PLAY
		g_buttonPlay:SetLabel("快捷键？")
	end)
	g_menuPlay:Connect(ID_MENUITEM_TIMEBASED,wx.wxEVT_COMMAND_MENU_SELECTED,function(event)
		g_useSleep=g_menuItemUseSleep:IsChecked()
	end)

	--注册钩子
	g_hookKeyboard=g_user32.SetWindowsHookExA(WH_KEYBOARD_LL,g_hookproc,nil,nil)

	--显示对话框
	g_dialog:Show(true)
end

function textMsg(msg)
	g_textCounter:SetLabel(msg)
end

--释放资源
function releaseApp()
	stopRecordScript()
	stopRunScript()
	g_sysicon:RemoveIcon()
	g_user32.UnhookWindowsHookEx(g_hookKeyboard)
end

--主函数
function main()
	local akmutex=wx.wxSingleInstanceChecker()--带参数的构造函数貌似有Bug
	akmutex:Create(g_appname)
	if akmutex:IsAnotherRunning()==true then
		wx.wxMessageBox("该程序已经在运行了，如果程序窗口未出现，请找到系统托盘图标并点击以显示窗口。")
		return
	end
	getWindowsApi()
	createDialog()
	wx.wxGetApp():MainLoop()
	releaseApp()
end

--调用主函数
--注意：Lua 只能从上到下解释执行
main()
