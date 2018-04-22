--Encoding: GBK, ���л�����Lua for Windows��Lua 5.1.5��
--wx��ο�: http://docs.wxwidgets.org/2.8/wx_classref.html

--[[
�����ű����ú�����
sendKey(vkCode,isPressDown):
�޷���ֵ��
vkCode:������루�ο�MSDN��https://msdn.microsoft.com/en-us/library/windows/desktop/dd375731(v=vs.85).aspx����
isPressDown:trueΪ���£�falseΪ�ſ�
sleep(milliseconds):
�޷���ֵ��
milliseconds:�ȴ��ĺ�����

��֧�ֱ�׼Lua�﷨��
]]

--����
require("wx")
require("alien")

--�ؼ�ID
ID_DIALOG=100
ID_BUTTON_RECORD=101
ID_BUTTON_PLAY=102
ID_STATIC_EVENTCOUNTER=103
ID_EDIT_SCRIPT=104
ID_BUTTON_OPEN=105
ID_BUTTON_SAVE=106
ID_EDIT_FILEPATH=107
ID_CHECK_TIMEBASED=108
ID_BUTTON_ABOUT=109

ID_MIN=100
ID_MAX=109

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

--ȫ�ֱ���
g_appname="AutoKey"
g_author="lxfly2000"
g_appurl="https://github.com/lxfly2000/AutoKey"
g_version="1"
g_appdesc="�˳������ģ�°�������ķ�ʽ������������ظ��Եļ��̲�����"
g_hotkeyPlay=wx.WXK_F10
g_strHotkeyPlay=" �ط�:F10"

--DLL����
g_kernel32=nil
g_user32=nil

--keybd_event����3����
KEYEVENTF_KEYUP=0x0002

--�������̫�࣬�Ͳ�����д��

--��ȡWindowsAPI
function getWindowsApi()
	g_kernel32=alien.load("kernel32.dll")
	g_user32=alien.load("user32.dll")
	--Kernel32.dll:VOID WINAPI Sleep(DWORD dwMilliseconds);
	g_kernel32.Sleep:types{ret="void","ulong",abi="stdcall"}
	--User32.dll:VOID WINAPI keybd_event(BYTE bVk,BYTE bScan,DWORD dwFlags,ULONG_PTR dwExtraInfo);
	g_user32.keybd_event:types{ret="void","byte","byte","ulong","ulong",abi="stdcall"}
end

--WindowsAPI��������
function sleep(milliseconds)
	g_kernel32.Sleep(milliseconds)
end

function sendKey(vkCode,isPressDown)
	g_user32.keybd_event(vkCode,0,isPressDown and 0 or KEYEVENTF_KEYUP,0)
end

function runScript()
	if g_editFilePath:GetLineLength(0)==0 then
		wx.wxMessageBox("δѡ���ļ���",g_appname,wx.wxOK+wx.wxICON_EXCLAMATION,g_dialog)
	else
		dofile(g_editFilePath:GetLineText(0))
	end
end

--�����Ի������
function createDialog()
	--�����ؼ�
	g_dialog=wx.wxDialog(wx.NULL,ID_DIALOG,g_appname..g_strHotkeyPlay,wx.wxDefaultPosition,wx.wxSize(420,220),wx.wxDEFAULT_DIALOG_STYLE+wx.wxMINIMIZE_BOX+wx.wxRESIZE_BORDER+wx.wxMAXIMIZE_BOX)
	local boxSizerCounter=wx.wxBoxSizer(wx.wxHORIZONTAL)
	local boxSizerFilePath=wx.wxBoxSizer(wx.wxHORIZONTAL)
	local boxSizerBase=wx.wxBoxSizer(wx.wxVERTICAL)
	g_textCounter=wx.wxStaticText(g_dialog,ID_STATIC_EVENTCOUNTER,"�¼�����#/#")
	g_checkTimeBased=wx.wxCheckBox(g_dialog,ID_CHECK_TIMEBASED,"���õȴ�(&T)")
	g_buttonRecord=wx.wxButton(g_dialog,ID_BUTTON_RECORD,"��¼(&R)")
	g_buttonPlay=wx.wxButton(g_dialog,ID_BUTTON_PLAY,"�ط�(&P)")
	g_buttonPlay:SetDefault()
	g_buttonOpen=wx.wxButton(g_dialog,ID_BUTTON_OPEN,"��(&O)")
	g_buttonSave=wx.wxButton(g_dialog,ID_BUTTON_SAVE,"����(&S)")
	g_buttonAbout=wx.wxButton(g_dialog,ID_BUTTON_ABOUT,"����(&A)")
	g_editScript=wx.wxTextCtrl(g_dialog,ID_EDIT_SCRIPT,"",wx.wxDefaultPosition,wx.wxDefaultSize,wx.wxTE_MULTILINE)
	g_editFilePath=wx.wxTextCtrl(g_dialog,ID_EDIT_FILEPATH)
	boxSizerCounter:Add(g_buttonAbout)
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

	--����¼�
	g_dialog:Connect(wx.wxEVT_CLOSE_WINDOW,function(event)
		g_dialog:Destroy()
	end)
	g_buttonAbout:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED,function(event)
		local aboutInfo=wx.wxAboutDialogInfo()
		aboutInfo:AddDeveloper(g_author)
		aboutInfo:SetWebSite(g_appurl)
		aboutInfo:SetVersion(g_version)
		aboutInfo:SetName(g_appname)
		aboutInfo:SetDescription(g_appdesc)
		wx.wxAboutBox(aboutInfo)
	end)
	g_buttonOpen:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED,function(event)
		local strpath=wx.wxFileSelector("ѡ���ļ�",".",g_editFilePath:GetLineText(0),"lua","Lua�ű��ļ�|*.lua|�����ļ�|*",wx.wxFD_OPEN+wx.wxFD_FILE_MUST_EXIST,g_dialog)
		if #strpath~=0 then
			g_editFilePath:SetValue(strpath)
			local source=io.open(strpath,"r")
			g_editScript:SetValue(source:read("*all"))
			source:close()
		end
	end)
	g_buttonPlay:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED,function(event)
		runScript()
	end)

	--ע���ݼ�����δ�ҵ�ʹ��ȫ�ֿ�ݼ��ķ�����׼��������HOOK������
	local hotkeys={wx.wxAcceleratorEntry()}
	hotkeys[1]:Set(wx.wxACCEL_NORMAL,g_hotkeyPlay,ID_BUTTON_PLAY)
	local hotkeyTable=wx.wxAcceleratorTable(hotkeys)
	g_dialog:SetAcceleratorTable(hotkeyTable)

	--��ʾ�Ի���
	g_dialog:Show(true)
end

--������
function main()
	getWindowsApi()
	createDialog()
	wx.wxGetApp():MainLoop()
end

--����������
--ע�⣺Lua ֻ�ܴ��ϵ��½���ִ��
main()
