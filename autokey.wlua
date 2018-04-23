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
ID_CHECK_TIMEBASED=108
ID_MENU_SYSICON=101
ID_MENUITEM_SHOW=1001
ID_MENUITEM_ABOUT=1002
ID_MENUITEM_HELP=1003
ID_MENUITEM_EXIT=1004

g_dialog=nil
g_textCounter=nil
g_buttonRecord=nil
g_buttonPlay=nil
g_editScript=nil
g_checkTimeBased=nil
g_editFilePath=nil
g_buttonOpen=nil
g_buttonSave=nil
g_buttonAbout=nil
g_sysicon=nil
g_menuSysicon=nil

--全局变量
g_appname="AutoKey"
g_author="lxfly2000"
g_appurl="https://github.com/lxfly2000/AutoKey"
g_version="0.1.1"
g_appdesc="此程序可以模仿按键精灵的方式来帮助你完成重复性的键盘操作。"
g_hotkeyPlay=wx.WXK_F10

--DLL变量
g_kernel32=nil
g_user32=nil

--keybd_event参数3常量
KEYEVENTF_KEYUP=0x0002

--虚拟键码太多，就不在这写了

--获取WindowsAPI
function getWindowsApi()
	g_kernel32=alien.load("kernel32.dll")
	g_user32=alien.load("user32.dll")
	--Kernel32.dll:VOID WINAPI Sleep(DWORD dwMilliseconds);
	g_kernel32.Sleep:types{ret="void","ulong",abi="stdcall"}
	--User32.dll:VOID WINAPI keybd_event(BYTE bVk,BYTE bScan,DWORD dwFlags,ULONG_PTR dwExtraInfo);
	g_user32.keybd_event:types{ret="void","byte","byte","ulong","ulong",abi="stdcall"}
end

--WindowsAPI函数调用
function sleep(milliseconds)
	g_kernel32.Sleep(milliseconds)
end

function sendKey(vkCode,isPressDown)
	g_user32.keybd_event(vkCode,0,isPressDown and 0 or KEYEVENTF_KEYUP,0)
end

function runScript()
	if g_editFilePath:GetLineLength(0)==0 then
		wx.wxMessageBox("未选择文件。",g_appname,wx.wxOK+wx.wxICON_EXCLAMATION,g_dialog)
	else
		dofile(g_editFilePath:GetLineText(0))
	end
end

--创建对话框界面
function createDialog()
	--创建控件
	g_dialog=wx.wxDialog(wx.NULL,wx.wxID_ANY,g_appname,wx.wxDefaultPosition,wx.wxSize(400,220),wx.wxDEFAULT_DIALOG_STYLE+wx.wxMINIMIZE_BOX+wx.wxRESIZE_BORDER+wx.wxMAXIMIZE_BOX)
	local boxSizerCounter=wx.wxBoxSizer(wx.wxHORIZONTAL)
	local boxSizerFilePath=wx.wxBoxSizer(wx.wxHORIZONTAL)
	local boxSizerBase=wx.wxBoxSizer(wx.wxVERTICAL)
	g_textCounter=wx.wxStaticText(g_dialog,ID_STATIC_EVENTCOUNTER,"事件数：#/#")
	g_checkTimeBased=wx.wxCheckBox(g_dialog,ID_CHECK_TIMEBASED,"启用s&leep")
	g_buttonRecord=wx.wxButton(g_dialog,ID_BUTTON_RECORD,"记录(&R)")
	g_buttonPlay=wx.wxButton(g_dialog,ID_BUTTON_PLAY,"回放(&P)")
	g_buttonPlay:SetDefault()
	g_buttonOpen=wx.wxButton(g_dialog,ID_BUTTON_OPEN,"打开(&O)")
	g_buttonSave=wx.wxButton(g_dialog,ID_BUTTON_SAVE,"保存(&S)")
	g_editScript=wx.wxTextCtrl(g_dialog,ID_EDIT_SCRIPT,"",wx.wxDefaultPosition,wx.wxDefaultSize,wx.wxTE_MULTILINE)
	g_editFilePath=wx.wxTextCtrl(g_dialog,ID_EDIT_FILEPATH)
	boxSizerCounter:Add(g_textCounter,1,wx.wxALIGN_CENTER_VERTICAL+wx.wxLEFT+wx.wxRIGHT,2)
	boxSizerCounter:Add(g_checkTimeBased,0,wx.wxALIGN_CENTER)
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

	--添加事件
	g_buttonOpen:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED,function(event)
		local strpath=wx.wxFileSelector("选择文件",".",g_editFilePath:GetLineText(0),"lua","Lua脚本文件|*.lua|所有文件|*",wx.wxFD_OPEN+wx.wxFD_FILE_MUST_EXIST,g_dialog)
		if #strpath~=0 then
			g_editFilePath:SetValue(strpath)
			g_editScript:LoadFile(strpath)
		end
	end)
	g_buttonPlay:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED,function(event)
		runScript()
	end)
	g_buttonSave:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED,function(event)
		if g_editScript:SaveFile(g_editFilePath:GetLineText(0)) then
			wx.wxMessageBox("保存成功。")
		else
			wx.wxMessageBox("保存失败。",g_appname,wx.wxICON_EXCLAMATION,g_dialog)
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
		wx.wxMessageBox("回放快捷键：F10\n退出：在托盘图标上右键选择退出。")
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

	--注册快捷键（暂未找到使用全局快捷键的方法，准备考虑用HOOK……）
	local hotkeys={wx.wxAcceleratorEntry()}
	hotkeys[1]:Set(wx.wxACCEL_NORMAL,g_hotkeyPlay,ID_BUTTON_PLAY)
	local hotkeyTable=wx.wxAcceleratorTable(hotkeys)
	g_dialog:SetAcceleratorTable(hotkeyTable)

	--显示对话框
	g_dialog:Show(true)
end

--释放资源
function releaseApp()
	g_sysicon:RemoveIcon()
end

--主函数
function main()
	getWindowsApi()
	createDialog()
	wx.wxGetApp():MainLoop()
	releaseApp()
end

--调用主函数
--注意：Lua 只能从上到下解释执行
main()
