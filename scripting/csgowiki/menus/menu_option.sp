
void GetAllProMatchStat(client) {
    new Handle:menuhandle = CreateMenu(ProMatchInfoMenuCallback);
    SetMenuTitle(menuhandle, "职业比赛合集");

    for (new idx = g_aProMatchInfo.Length - 1; idx >= 0; idx--) {
        char team1[LENGTH_NAME], team2[LENGTH_NAME], time[LENGTH_NAME];
        char matchId[LENGTH_NAME];
        JSON_Object arrval = g_aProMatchInfo.GetObject(idx);
        JSON_Object teamInfo_1 = arrval.GetObject("team1");
        JSON_Object teamInfo_2 = arrval.GetObject("team2");
        teamInfo_1.GetString("name", team1, sizeof(team1));
        teamInfo_2.GetString("name", team2, sizeof(team2));
        int score1 = teamInfo_1.GetInt("result");
        int score2 = teamInfo_2.GetInt("result");
        arrval.GetString("time", time, sizeof(time));
        arrval.GetString("matchId", matchId, sizeof(matchId));
        char msg[LENGTH_NAME * 4];
        Format(msg, sizeof(msg), "[%s] %d : %d [%s] (%s)", team1, score1, score2, team2, time);
        AddMenuItem(menuhandle, matchId, msg);
    }
    SetMenuPagination(menuhandle, 7);
    SetMenuExitBackButton(menuhandle, true);
    SetMenuExitButton(menuhandle, true);
    DisplayMenu(menuhandle, client, MENU_TIME_FOREVER);
}


public ProMatchInfoMenuCallback(Handle:menuhandle, MenuAction:action, client, Position) {
    if (MenuAction_Select == action) {
        decl String:matchId[LENGTH_NAME];
        GetMenuItem(menuhandle, Position, matchId, sizeof(matchId));

        // set index
        for (new idx = 0; idx < g_aProMatchInfo.Length; idx++) {
            char _matchId[LENGTH_NAME];
            JSON_Object arrval = g_aProMatchInfo.GetObject(idx);
            arrval.GetString("matchId", _matchId, sizeof(_matchId));
            if (StrEqual(matchId, _matchId)) {
                g_aProMatchIndex[client] = idx;
                break;
            }
        }
        ClientCommand(client, "sm_wikipro");
    }
    else if (MenuAction_Cancel == action) {
        ClientCommand(client, "sm_option");
    }
}

public Action:Command_Option(client, args) {
    Panel panel = new Panel();

    panel.SetTitle("个人设置")

    if (g_bAutoThrow[client]) {
        panel.DrawItem("道具开启自动投掷：开");
    }
    else {
        panel.DrawItem("道具开启自动投掷：关");
    }
    panel.DrawItem("快捷道具上传(双击E)：关", ITEMDRAW_DISABLED);
    if (g_bQQTrigger[client]) {
        panel.DrawItem("qq聊天触发方式：打字触发");
    }
    else {
        panel.DrawItem("qq聊天触发方式：指令触发");
    }
    panel.DrawItem("职业道具场次选择");
    panel.DrawItem("   ", ITEMDRAW_SPACER);
    panel.DrawItem("   ", ITEMDRAW_SPACER);
    panel.DrawItem("返回", ITEMDRAW_CONTROL);
    panel.DrawItem("退出", ITEMDRAW_CONTROL);
    
    panel.Send(client, OptionPanelHandler, MENU_TIME_FOREVER);

    delete panel;
    return Plugin_Handled;
}

public OptionPanelHandler(Handle:menu, MenuAction:action, client, Position) {
    if (action == MenuAction_Select) {
        switch(Position) {
            case 1: g_bAutoThrow[client] = !g_bAutoThrow[client], PrintToChat(client, "%s \x04设置已更改", PREFIX), ClientCommand(client, "sm_option");
            case 2: PrintToChat(client, "%s \x0E功能未开放，敬请期待...", PREFIX), ClientCommand(client, "sm_option");
            case 3: g_bQQTrigger[client] = !g_bQQTrigger[client], PrintToChat(client, "%s \x04设置已更改", PREFIX), ClientCommand(client, "sm_option");
            case 4: GetAllProMatchStat(client);
            case 7: ClientCommand(client, "sm_m");
            case 8: CloseHandle(menu);
        }
    }
}

void ResetDefaultOption(client) {
    g_bAutoThrow[client] = false;
    g_bQQTrigger[client] = false;
}
