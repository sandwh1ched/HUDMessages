global function HUDM_addMenu;
global function HUDM_addMenuButton;

var menu;

// Initialize the menu stuff.
void function HUDM_menuInit() {
    AddMenuFooterOption(menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK")
}

// Makes the message customization menu available.
void function HUDM_addMenu() {
    AddMenu("HUDMMenu", $"resource/ui/menus/hudm.menu", HUDM_menuInit);
    menu = GetMenu("HUDMMenu");
}

// Adds the message customization menu next to the Mod Settings menu.
void function HUDM_addMenuButton() {
    AddMenuFooterOption(
        GetMenu("InGameMPMenu"),
        BUTTON_X,
        PrependControllerPrompts(BUTTON_X, " HUD Messages"),
        "HUD Messages",
        void function(var button) {
            AdvanceMenu(menu)
        }
    )
}
// InGameMPMenu 