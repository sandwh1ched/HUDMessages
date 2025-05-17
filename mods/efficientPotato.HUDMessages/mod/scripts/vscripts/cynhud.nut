global function CynHud_Init;

#if CLIENT
var rui = null;
string mapName = "";
string message = "";
string messagePos = "";
string version = "1.4.5";
bool reloadRequest = false;
bool shouldShowWelcomeText = true;

// Threading required (use `thread`)
void function CynHud_CheckForUpdates() {
	Assert(IsNewThread(), "CynHud_CheckForUpdates method requires threading");
	FlagInit("CynHudFetchUpdateChanges");
	FlagInit("CynHudUpdateCheckP1Success");
	FlagInit("CynHudUpdateCheckP2Done");
	FlagInit("CynHudUpdateCheckP1Failed");
	if (GetMapName() != "mp_lobby") {
		void functionref(HttpRequestResponse) onSuccess = void function(HttpRequestResponse response) {
			string webVersion = response.body;
			if (version[0] < webVersion[0]) {
				CynHud_WriteChatMessage("\x1b[113mNew major update!\x1b[0m Update using your \x1b[111mmod manager\x1b[0m, \x1b[111mThunderstore\x1b[0m, or \x1b[111mGitHub\x1b[0m. (v" + webVersion + ")");
				FlagSet("CynHudFetchUpdateChanges");
			} else if (version[2] < webVersion[2]) {
				CynHud_WriteChatMessage("\x1b[113mNew update:\x1b[0m Update using your \x1b[111mmod manager\x1b[0m, \x1b[111mThunderstore\x1b[0m, or \x1b[111mGitHub\x1b[0m. (v" + webVersion + ")");
				FlagSet("CynHudFetchUpdateChanges");
			} else if (version[4] < webVersion[4]) {
				CynHud_WriteChatMessage("\x1b[113mNew patch:\x1b[0m Update using your \x1b[111mmod manager\x1b[0m, \x1b[111mThunderstore\x1b[0m, or \x1b[111mGitHub\x1b[0m. (v" + webVersion + ")");
				FlagSet("CynHudFetchUpdateChanges");
			}
			FlagSet("CynHudUpdateCheckP1Success");
		}

		void functionref(HttpRequestFailure) onFailure = void function(HttpRequestFailure failure) {
			CynHud_WriteChatMessage("\x1b[112mUpdate check failed:\x1b[0m " + failure.errorMessage);
			FlagSet("CynHudUpdateCheckP1Failed");
		}
		
		if (!(NSHttpGet("https://frothywifi.cc/netchimp-cynhud/latestver", {}, onSuccess, onFailure))) {
			CynHud_WriteChatMessage("\x1b[112mUpdate check failed:\x1b[0m Couldn't launch the HTTP request. Are they disabled in your Northstar launch options?");
			FlagSet("CynHudUpdateCheckP1Failed");
		}

		if (Flag("CynHudUpdateCheckP1Failed")) {
			if (shouldShowWelcomeText) {
				CynHud_WriteChatMessage("Welcome back, \x1b[111m" + NSGetLocalPlayerUID() + "\x1b[0m. Run \x1b[33m$ch.help\x1b[0m for a list of commands.");
				shouldShowWelcomeText = false;
			}
			return;
		}
		FlagWait("CynHudUpdateCheckP1Success");

		if (Flag("CynHudUpdateCheckP1Success") && Flag("CynHudFetchUpdateChanges")) {
			onSuccess = void function(HttpRequestResponse response) {
				CynHud_WriteChatMessage("\x1b[113mChanges/fixes:\x1b[0m " + response.body);
				FlagSet("CynHudUpdateCheckP2Done");
			}

			onFailure = void function(HttpRequestFailure failure) {
				CynHud_WriteChatMessage("Can't fetch update changes/fixes right now: " + failure.errorMessage);
				FlagSet("CynHudUpdateCheckP2Done");
			}

			if (!(NSHttpGet("https://frothywifi.cc/netchimp-cynhud/changes", {}, onSuccess, onFailure))) {
				CynHud_WriteChatMessage("Can't fetch update changes/fixes right now: Couldn't launch the HTTP request.");
				FlagSet("CynHudUpdateCheckP2Done");
			}			
		} else {
			FlagSet("CynHudUpdateCheckP2Done");
		}


		FlagWait("CynHudUpdateCheckP2Done");

		if (shouldShowWelcomeText) {
			CynHud_WriteChatMessage("Welcome back, \x1b[111m" + NSGetLocalPlayerUID() + "\x1b[0m. Run \x1b[33m$ch.help\x1b[0m for a list of commands.");
			shouldShowWelcomeText = false;
		}
	}
}

ClClient_MessageStruct function CynHud_CommandFilter(ClClient_MessageStruct message) {
	if (message.message == "$ch.help") {
		message.shouldBlock = true;
		Chat_GameWriteLine("\x1b[33m--== CYNHUD commands ==--\x1b[0m");
		Chat_GameWriteLine("All CYNHUD commands \x1b[112mmust\x1b[0m be prefaced with \x1b[33m\"$ch.\"\x1b[0m, for example \x1b[33m$ch.uid\x1b[0m.");
		Chat_GameWriteLine("\x1b[33mhelp\x1b[0m - Show available commands.");
		Chat_GameWriteLine("\x1b[33mreload\x1b[0m - Manually reload the HUD message.")
		Chat_GameWriteLine("\x1b[33muid\x1b[0m - Show your user ID. CYNHUD also uses this to greet you.");
		Chat_GameWriteLine("\x1b[33mckupdate\x1b[0m - Manually check for updates.");
	} else if (message.message == "$ch.reload") {
		message.shouldBlock = true;
		reloadRequest = true;
	} else if (message.message == "$ch.uid") {
		message.shouldBlock = true;
		CynHud_WriteChatMessage("You are Pilot \x1b[111m" + NSGetLocalPlayerUID() + "\x1b[0m.");
	} else if (message.message == "$ch.ckupdate") {
		message.shouldBlock = true;
		thread CynHud_CheckForUpdates();
	}
	return message;
}

void function CynHud_ConfigureRui() {
  	RuiSetInt(rui, "maxLines", 1);
  	RuiSetInt(rui, "lineNum", 1);
	if (messagePos == "Bottom") {
  		RuiSetFloat2(rui, "msgPos", <0.825, 0.92, 0.0>);
	} else if (messagePos == "Middle") {
  		RuiSetFloat2(rui, "msgPos", <0.825, 0.46, 0.0>);
	} else if (messagePos == "Top") {
		RuiSetFloat2(rui, "msgPos", <0.825, 0.0, 0.0>);
	} else {
		RuiSetFloat2(rui, "msgPos", <0.825, 0.46, 0.0>);
	}
  	RuiSetString(rui, "msgText", message);
  	RuiSetFloat(rui, "msgFontSize", 25.0);
  	RuiSetFloat(rui, "msgAlpha", 0.5);
  	RuiSetFloat(rui, "thicken", 0.0);
 	RuiSetFloat3(rui, "msgColor", <1.0, 1.0, 1.0>);
}

void function CynHud_DoMessage() {
	WaitFrame();

	mapName = GetMapName();
  	rui = RuiCreate($"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0);
	message = GetConVarString("ch_hud_message");
	messagePos = GetConVarString("ch_hud_message_pos");

	WaitFrame();
	
	CynHud_ConfigureRui();
	
	while (mapName == GetMapName()) {
		WaitFrame();
		if (reloadRequest) {
			reloadRequest = false;
			RuiDestroy(rui);
			CynHud_WriteChatMessage("Manual reload request recieved; reloading HUD message.");
			CynHud_DoMessage();
		}
		if (GetConVarString("ch_hud_message") != message) {
			RuiDestroy(rui);
			CynHud_WriteChatMessage("Message changed; reloading HUD message.");
			CynHud_DoMessage();
		}
		if (GetConVarString("ch_hud_message_pos") != messagePos) {
			RuiDestroy(rui);
			CynHud_WriteChatMessage("Message position changed; reloading HUD message.");
			CynHud_DoMessage();
		}
	}
	RuiDestroy(rui);
	shouldShowWelcomeText = true;
}

void function CynHud_WriteChatMessage(string message) {
	Chat_GameWriteLine("\x1b[33mCYNHUD:\x1b[0m " + message);
}

void function CynHud_Init() {
	AddCallback_OnReceivedSayTextMessage(CynHud_CommandFilter);
	thread CynHud_CheckForUpdates();
	thread CynHud_DoMessage();
}
#endif