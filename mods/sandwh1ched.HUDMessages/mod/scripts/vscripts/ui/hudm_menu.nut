globalize_all_functions;

// Adds the message customization window to the Pilot customization menus.
void function HUDM_addMenu() {
    AddMenu("HUDMMenu", $"resource/ui/menus/hudm.menu", "HUDM_menuInit");
}