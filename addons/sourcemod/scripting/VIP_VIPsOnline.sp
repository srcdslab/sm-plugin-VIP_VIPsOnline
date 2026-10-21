//------------------------------------------------------------------------------
// GPL LISENCE (short)
//------------------------------------------------------------------------------
/*
 * Copyright (c) 2014 R1KO

 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 * ChangeLog:
		1.0.0 -	Релиз
		1.0.1 -	Кнопка "Назад" изменена из 1 на 8
				Исправлено закрытие меню при нажатии "Назад"
		1.0.2 - Update syntax to SM 1.11
		1.0.3 - Minor convar fix
		1.0.4 - Fix and complete translations
*/
#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <vip_core>

public Plugin myinfo =
{
	name = "[VIP] VIPs Online",
	author = "R1KO (skype: vova.andrienko1)",
	description = "Display the list of active vips",
	version = "1.0.5",
	url = "hlmod.ru"
}

bool g_bShowGroup;
bool g_bShowExpired;

public void OnPluginStart()
{
	ConVar hCvar = CreateConVar("vip_vo_show_group", "1", "Показывать ли VIP-группу при нажатии на игрока (0 - Отключено)", 0, true, 0.0, true, 1.0);
	hCvar.AddChangeHook(OnShowGroupChange);
	g_bShowGroup = hCvar.BoolValue;

	ConVar hCvar1 = CreateConVar("vip_vo_show_expired", "1", "Показывать ли время окончания VIP-статуса при нажатии на игрока (0 - Отключено)", 0, true, 0.0, true, 1.0);
	hCvar1.AddChangeHook(OnShowExpiredChange);
	g_bShowExpired = hCvar1.BoolValue;

	AutoExecConfig(true, "vips_online", "vip");

	RegConsoleCmd("sm_viplist", VIPList_CMD);
	RegConsoleCmd("sm_vips", VIPList_CMD);
	RegConsoleCmd("sm_випс", VIPList_CMD);

	LoadTranslations("vip_online.phrases");
	LoadTranslations("vip_core.phrases");
}

public void OnShowGroupChange(ConVar convar, const char[] oldValue, const char[] newValue)
{	
    g_bShowGroup = convar.BoolValue;
}
public void OnShowExpiredChange(ConVar convar, const char[] oldValue, const char[] newValue)
{	
    g_bShowExpired = convar.BoolValue;
}

public Action VIPList_CMD(int iClient, int args)
{
	if(iClient)
	{
		Menu hMenu;
		char sName[64], sBuffer[16];
		hMenu = new Menu(Handler_VIPListMenu);
		hMenu.SetTitle("%T:\n \n", "VIP_PLAYERS_ONLINE", iClient);

		sBuffer[0] = '\0';
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i) && VIP_IsClientVIP(i) && GetClientName(i, sName, sizeof(sName)))
			{
				IntToString(GetClientUserId(i), sBuffer, sizeof(sBuffer));
				hMenu.AddItem(sBuffer, sName);
			}
		}
		
		if(sBuffer[0] == '\0')
		{
			FormatEx(sName, sizeof(sName), "%T", "NO_VIP_PLAYERS_ONLINE", iClient);
			hMenu.AddItem("", sName, ITEMDRAW_DISABLED);
		}

		hMenu.Display(iClient, 30);
	}

	return Plugin_Handled;
}

public int Handler_VIPListMenu(Menu hMenu, MenuAction action, int iClient, int iOption)
{
	switch(action)
	{
		case MenuAction_End:
		{
			delete hMenu;
		}
		case MenuAction_Select:
		{
			if(g_bShowGroup || g_bShowExpired)
			{
				Panel hPanel;
				char sBuffer[64];
				int iTarget;
				hMenu.GetItem(iOption, sBuffer, sizeof(sBuffer));
				hPanel = new Panel();
				SetGlobalTransTarget(iClient);
				iTarget = GetClientOfUserId(StringToInt(sBuffer));
				if(iTarget)
				{
					FormatEx(sBuffer, sizeof(sBuffer), "%t\n \n", "INFO");
					hPanel.SetTitle(sBuffer);
					if(g_bShowGroup)
					{
						FormatEx(sBuffer, sizeof(sBuffer), "%t:", "GROUP");
						hPanel.DrawText(sBuffer);
						if(VIP_GetClientVIPGroup(iTarget, sBuffer, sizeof(sBuffer)))
						{
							hPanel.DrawText(sBuffer);
						}

						hPanel.DrawText(" \n");
					}
					
					if(g_bShowExpired)
					{
						FormatEx(sBuffer, sizeof(sBuffer), "%t:", "EXPIRES");
						hPanel.DrawText(sBuffer);
						int iExpire = VIP_GetClientAccessTime(iTarget);
						if(iExpire == -1)
						{
							FormatEx(sBuffer, sizeof(sBuffer), "%t", "TEMPORARY");
							hPanel.DrawText(sBuffer);
						}
						else if(iExpire == 0)
						{
							FormatEx(sBuffer, sizeof(sBuffer), "%t", "NEVER");
							hPanel.DrawText(sBuffer);
						}
						else
						{
							char sTimeEnd[128];
							if(VIP_GetTimeFromStamp(sTimeEnd, sizeof(sTimeEnd), iExpire-GetTime(), iClient))
							{
								Format(sTimeEnd, sizeof(sTimeEnd), "%t %s", "EXPIRE", sTimeEnd);
							}
							else
							{
								FormatEx(sTimeEnd, sizeof(sTimeEnd), "%t", "ERROR");
							}
							hPanel.DrawText(sTimeEnd);
						}
						
						hPanel.DrawText(" \n");
					}
				}
				else
				{
					FormatEx(sBuffer, sizeof(sBuffer), "%t", "ERROR");
					hPanel.SetTitle(sBuffer);

					FormatEx(sBuffer, sizeof(sBuffer), "%t", "PLAYER_NO_LONGER_AVAILABLE");
					hPanel.DrawText(sBuffer);
					
					hPanel.DrawText(" \n");
				}

				hPanel.DrawText(" \n");

				FormatEx(sBuffer, sizeof(sBuffer), "%t", "PANEL_BACK");
				hPanel.CurrentKey = 8;
				hPanel.DrawItem(sBuffer, ITEMDRAW_CONTROL);

				hPanel.DrawItem(" ", ITEMDRAW_SPACER|ITEMDRAW_RAWLINE);
				
				FormatEx(sBuffer, sizeof(sBuffer), "%t", "PANEL_CLOSE");
				hPanel.CurrentKey = 10;
				hPanel.DrawItem(sBuffer, ITEMDRAW_CONTROL);
				
				hPanel.Send(iClient, Handler_InfoMenu, 30);
				delete hPanel;
			}
			else
			{
				VIPList_CMD(iClient, 0);
			}
		}
	}
	
	return 0;
}

public int Handler_InfoMenu(Menu hMenu, MenuAction action, int iClient, int iOption)
{
	if(action == MenuAction_Select && iOption == 8)
	{
		VIPList_CMD(iClient, 0);
	}
	
	return 0;
}
