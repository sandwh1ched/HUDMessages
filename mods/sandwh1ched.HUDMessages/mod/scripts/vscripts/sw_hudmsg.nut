// HUDMessages primary logic code
// All code is licensed under the BSD 2-clause license -- see `LICENSE`
// To-do:
// - Add minimally intrusive update checking

global function HUDM_init;

// Assembles a new static message RUI.
var function HUDM_createStaticMessage(vector position, string text) {
    var rui = RuiCreate($"ui/cockpit_console_text_top_left.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0);
  	RuiSetInt(rui, "maxLines", 1);
  	RuiSetInt(rui, "lineNum", 1);
  	RuiSetFloat2(rui, "msgPos", position);
  	RuiSetString(rui, "msgText", text);
  	RuiSetFloat(rui, "msgFontSize", 25.0);
  	RuiSetFloat(rui, "msgAlpha", 0.5);
  	RuiSetFloat(rui, "thicken", 0.0);
 	RuiSetFloat3(rui, "msgColor", <1.0, 1.0, 1.0>);
}

// Does the logic loop.
// Requires threading.
void function HUDM_loop() {
    string mapName = GetMapName();
    var message = HUDM_createStaticMessage(<0.825, 0.92, 0.0>, "i want a sandwich :(");
	while (mapName == GetMapName()) {
		WaitFrame();
	}
    RuiDestroy(message);
}

void function HUDM_init() {
    thread HUDM_loop();
}