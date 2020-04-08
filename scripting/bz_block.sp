#pragma semicolon 1
#pragma newdecls required
#include <sdkhooks>
#include <sourcemod>

ConVar g_cvBZTime;
Handle g_hProtectionTimer;

#define VERSION 				"2.0.5"

public Plugin myinfo =
{
	name = "BuyZone Damage Bloker",
	author = "1mpulse (Discord -> 1mpulse#6496)",
	version = VERSION,
	url = "http://plugins.thebestcsgo.ru"
}

public void OnPluginStart()  
{
	g_cvBZTime = FindConVar("mp_buytime");
	HookEvent("round_start", Ev_RoundStart);
}

public void OnClientPutInServer(int iClient) { SDKHook(iClient, SDKHook_OnTakeDamage, OnTakeDamage); }
public void OnMapStart() { g_hProtectionTimer = null; }
public void Ev_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(g_hProtectionTimer)
	{
		KillTimer(g_hProtectionTimer);
		g_hProtectionTimer = null;
	}
	
	g_hProtectionTimer = CreateTimer(g_cvBZTime.FloatValue, Timer_RemoveProtection, _, TIMER_FLAG_NO_MAPCHANGE);  
}  

public Action OnTakeDamage(int iClient, int &iAttaker, int &inflictor, float &damage, int &damagetype)
{
	if(g_hProtectionTimer != null)
	{
		if(0 < iAttaker <= MaxClients && iAttaker != iClient)
		{
			if(GetEntProp(iClient, Prop_Send, "m_bInBuyZone"))
			{
				SetHudTextParamsEx(-1.00, -0.60, 1.1, {66, 170, 255, 255}, {66, 170, 255, 255}, 0, 0.0, 0.0, 0.0);
				ShowHudText(iAttaker, -1, "Игрок находится в BuyZone, не получает урон");
				return Plugin_Handled;
			}
			else if(GetEntProp(iAttaker, Prop_Send, "m_bInBuyZone"))
			{
				SetHudTextParamsEx(-1.00, -0.60, 1.1, {66, 170, 255, 255}, {66, 170, 255, 255}, 0, 0.0, 0.0, 0.0);
				ShowHudText(iClient, -1, "Находясь в BuyZone, вы не наносите урон");
				return Plugin_Handled;
			}	
		}
	}
	return Plugin_Continue;	
}

public Action Timer_RemoveProtection(Handle hTimer)
{
	g_hProtectionTimer = null;
	return Plugin_Stop;
}