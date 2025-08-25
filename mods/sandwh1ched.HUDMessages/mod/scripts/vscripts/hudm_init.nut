// Initialization script
// All code is licensed under the BSD 2-clause license -- see `LICENSE`
//
// To-do:
// - Add minimally intrusive update checking

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

// Actually does mod logic. But it's just a wrapper for the loop.
void function HUDM_init() {
    thread HUDM_loop();
}