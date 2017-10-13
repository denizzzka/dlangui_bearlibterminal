module main;

import dlangui;
import dlangui.dialogs.dialog;
import dlangui.dialogs.filedlg;
import dlangui.dialogs.msgbox;
import std.stdio;
import std.conv;
import std.utf;
import std.algorithm;
import std.path;


mixin APP_ENTRY_POINT;

class TimerTest : HorizontalLayout {
    ulong timerId;
    TextWidget _counter;
    int _value;
    Button _start;
    Button _stop;
    override bool onTimer(ulong id) {
        _value++;
        _counter.text = to!dstring(_value);
        return true;
    }
    this() {
        addChild(new TextWidget(null, "Timer test."d));
        _counter = new TextWidget(null, "0"d);
        _counter.fontSize(32);
        _start = new Button(null, "Start timer"d);
        _stop = new Button(null, "Stop timer"d);
        _stop.enabled = false;
        _start.click = delegate(Widget src) {
            _start.enabled = false;
            _stop.enabled = true;
            timerId = setTimer(1000);
            return true;
        };
        _stop.click = delegate(Widget src) {
            _start.enabled = true;
            _stop.enabled = false;
            cancelTimer(timerId);
            return true;
        };
        addChild(_start);
        addChild(_stop);
        addChild(_counter);
    }
}

static if (BACKEND_GUI) {
    class AnimatedDrawable : Drawable {
        DrawableRef background;
        this() {
            background = drawableCache.get("tx_fabric.tiled");
        }
        void drawAnimatedRect(DrawBuf buf, uint p, Rect rc, int speedx, int speedy, int sz) {
            int x = (p * speedx % rc.width);
            int y = (p * speedy % rc.height);
            if (x < 0)
                x += rc.width;
            if (y < 0)
                y += rc.height;
            uint a = 64 + ((p / 2) & 0x7F);
            uint r = 128 + ((p / 7) & 0x7F);
            uint g = 128 + ((p / 5) & 0x7F);
            uint b = 128 + ((p / 3) & 0x7F);
            uint color = (a << 24) | (r << 16) | (g << 8) | b;
            buf.fillRect(Rect(rc.left + x, rc.top + y, rc.left + x + sz, rc.top + y + sz), color);
        }
        void drawAnimatedIcon(DrawBuf buf, uint p, Rect rc, int speedx, int speedy, string resourceId) {
            int x = (p * speedx % rc.width);
            int y = (p * speedy % rc.height);
            if (x < 0)
                x += rc.width;
            if (y < 0)
                y += rc.height;
            DrawBufRef image = drawableCache.getImage(resourceId);
            buf.drawImage(x, y, image.get);
        }
        override void drawTo(DrawBuf buf, Rect rc, uint state = 0, int tilex0 = 0, int tiley0 = 0) {
            background.drawTo(buf, rc, state, cast(int)(animationProgress / 695430), cast(int)(animationProgress / 1500000));
            drawAnimatedRect(buf, cast(uint)(animationProgress / 295430), rc, 2, 3, 100);
            drawAnimatedRect(buf, cast(uint)(animationProgress / 312400) + 100, rc, 3, 2, 130);
            drawAnimatedIcon(buf, cast(uint)(animationProgress / 212400) + 200, rc, -2, 1, "dlangui-logo1");
            drawAnimatedRect(buf, cast(uint)(animationProgress / 512400) + 300, rc, 2, -2, 200);
            drawAnimatedRect(buf, cast(uint)(animationProgress / 214230) + 800, rc, 1, 2, 390);
            drawAnimatedIcon(buf, cast(uint)(animationProgress / 123320) + 900, rc, 1, 2, "cr3_logo");
            drawAnimatedRect(buf, cast(uint)(animationProgress / 100000) + 100, rc, -1, -1, 120);
        }
        @property override int width() {
            return 1;
        }
        @property override int height() {
            return 1;
        }
        ulong animationProgress;
        void animate(long interval) {
            animationProgress += interval;
        }

    }
}

class TextEditorWidget : VerticalLayout {
    EditBox _edit;
    this(string ID) {
        super(ID);
        _edit = new EditBox("editor");
        _edit.layoutWidth = FILL_PARENT;
        _edit.layoutHeight = FILL_PARENT;
        addChild(_edit);
    }
}

static if (BACKEND_GUI) {
    class SampleAnimationWidget : VerticalLayout {
        AnimatedDrawable drawable;
        DrawableRef drawableRef;
        this(string ID) {
            super(ID);
            drawable = new AnimatedDrawable();
            drawableRef = drawable;
            padding = Rect(20, 20, 20, 20);
            addChild(new TextWidget(null, "This is TextWidget on top of animated background"d));
            addChild(new EditLine(null, "This is EditLine on top of animated background"d));
            addChild(new Button(null, "This is Button on top of animated background"d));
            addChild(new VSpacer());
        }

        /// background drawable
        @property override DrawableRef backgroundDrawable() const {
            return (cast(SampleAnimationWidget)this).drawableRef;
        }

        /// returns true is widget is being animated - need to call animate() and redraw
        @property override bool animating() { return true; }
        /// animates window; interval is time left from previous draw, in hnsecs (1/10000000 of second)
        override void animate(long interval) {
            drawable.animate(interval);
            invalidate();
        }
    }
}

Widget createEditorSettingsControl(EditWidgetBase editor) {
    HorizontalLayout res = new HorizontalLayout("editor_options");
    res.addChild((new CheckBox("wantTabs", "wantTabs"d)).checked(editor.wantTabs).addOnCheckChangeListener(delegate(Widget, bool checked) { editor.wantTabs = checked; return true;}));
    res.addChild((new CheckBox("useSpacesForTabs", "useSpacesForTabs"d)).checked(editor.useSpacesForTabs).addOnCheckChangeListener(delegate(Widget, bool checked) { editor.useSpacesForTabs = checked; return true;}));
    res.addChild((new CheckBox("readOnly", "readOnly"d)).checked(editor.readOnly).addOnCheckChangeListener(delegate(Widget, bool checked) { editor.readOnly = checked; return true;}));
    res.addChild((new CheckBox("showLineNumbers", "showLineNumbers"d)).checked(editor.showLineNumbers).addOnCheckChangeListener(delegate(Widget, bool checked) { editor.showLineNumbers = checked; return true;}));
    res.addChild((new CheckBox("fixedFont", "fixedFont"d)).checked(editor.fontFamily == FontFamily.MonoSpace).addOnCheckChangeListener(delegate(Widget, bool checked) {
        if (checked)
            editor.fontFamily(FontFamily.MonoSpace).fontFace("Courier New");
        else
            editor.fontFamily(FontFamily.SansSerif).fontFace("Arial");
        return true;
    }));
    res.addChild((new CheckBox("tabSize", "Tab size 8"d)).checked(editor.tabSize == 8).addOnCheckChangeListener(delegate(Widget, bool checked) {
        if (checked)
            editor.tabSize(8);
        else
            editor.tabSize(4);
        return true;
    }));
    return res;
}

enum : int {
    ACTION_FILE_OPEN = 5500,
    ACTION_FILE_SAVE,
    ACTION_FILE_CLOSE,
    ACTION_FILE_EXIT,
}

debug(SDLSettings) {
    import dlangui.core.settings;
    void testSDL(string fn) {
        Log.d("Loading SDL from ", fn);
        Setting s = new Setting();
        if (s.load(fn)) {
            Log.d("JSON:\n", s.toJSON(true));
        } else {
            Log.e("failed to read SDL from ", fn);
        }
    }
    void testSDLSettings() {
        testSDL(`C:\Users\vlopatin\AppData\Roaming\.dlangide\settings.json`);
        testSDL("dub.json");
        testSDL("test1.sdl");
    }
}

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args) {
    // select translation file - for english language
    Platform.instance.uiLanguage = "en";
    // load theme from file "theme_default.xml"
    //~ Platform.instance.uiTheme = "theme_default";
    //Platform.instance.uiTheme = "theme_dark";

    Window window = Platform.instance.createWindow("DlangUI Example 1", null, WindowFlag.Resizable | WindowFlag.ExpandSize, 800, 700);

    static if (true) {
        VerticalLayout contentLayout = new VerticalLayout();

        TabWidget tabs = new TabWidget("TABS");
        tabs.tabClose = delegate(string tabId) {
            tabs.removeTab(tabId);
        };

        //=========================================================================
        // create main menu

        MenuItem mainMenuItems = new MenuItem();
        MenuItem fileItem = new MenuItem(new Action(1, "MENU_FILE"c));
        fileItem.add(new Action(ACTION_FILE_OPEN, "MENU_FILE_OPEN"c, "document-open", KeyCode.KEY_O, KeyFlag.Control));
        fileItem.add(new Action(ACTION_FILE_SAVE, "MENU_FILE_SAVE"c, "document-save", KeyCode.KEY_S, KeyFlag.Control));
        MenuItem openRecentItem = new MenuItem(new Action(13, "MENU_FILE_OPEN_RECENT", "document-open-recent"));
        openRecentItem.add(new Action(100, "&1: File 1"d));
        openRecentItem.add(new Action(101, "&2: File 2"d));
        openRecentItem.add(new Action(102, "&3: File 3"d));
        openRecentItem.add(new Action(103, "&4: File 4"d));
        openRecentItem.add(new Action(104, "&5: File 5"d));
        fileItem.add(openRecentItem);
        fileItem.add(new Action(ACTION_FILE_EXIT, "MENU_FILE_EXIT"c, "document-close"c, KeyCode.KEY_X, KeyFlag.Alt));

        MenuItem editItem = new MenuItem(new Action(2, "MENU_EDIT"));
        editItem.add(new Action(EditorActions.Copy, "MENU_EDIT_COPY"c, "edit-copy", KeyCode.KEY_C, KeyFlag.Control));
        editItem.add(new Action(EditorActions.Paste, "MENU_EDIT_PASTE"c, "edit-paste", KeyCode.KEY_V, KeyFlag.Control));
        editItem.add(new Action(EditorActions.Cut, "MENU_EDIT_CUT"c, "edit-cut", KeyCode.KEY_X, KeyFlag.Control));
        editItem.add(new Action(EditorActions.Undo, "MENU_EDIT_UNDO"c, "edit-undo", KeyCode.KEY_Z, KeyFlag.Control));
        editItem.add(new Action(EditorActions.Redo, "MENU_EDIT_REDO"c, "edit-redo", KeyCode.KEY_Y, KeyFlag.Control));
        editItem.add(new Action(EditorActions.Indent, "MENU_EDIT_INDENT"c, "edit-indent", KeyCode.TAB, 0));
        editItem.add(new Action(EditorActions.Unindent, "MENU_EDIT_UNINDENT"c, "edit-unindent", KeyCode.TAB, KeyFlag.Control));
        editItem.add(new Action(20, "MENU_EDIT_PREFERENCES"));

        MenuItem editPopupItem = new MenuItem(null);
        editPopupItem.add(new Action(EditorActions.Copy, "MENU_EDIT_COPY"c, "edit-copy", KeyCode.KEY_C, KeyFlag.Control));
        editPopupItem.add(new Action(EditorActions.Paste, "MENU_EDIT_PASTE"c, "edit-paste", KeyCode.KEY_V, KeyFlag.Control));
        editPopupItem.add(new Action(EditorActions.Cut, "MENU_EDIT_CUT"c, "edit-cut", KeyCode.KEY_X, KeyFlag.Control));
        editPopupItem.add(new Action(EditorActions.Undo, "MENU_EDIT_UNDO"c, "edit-undo", KeyCode.KEY_Z, KeyFlag.Control));
        editPopupItem.add(new Action(EditorActions.Redo, "MENU_EDIT_REDO"c, "edit-redo", KeyCode.KEY_Y, KeyFlag.Control));
        editPopupItem.add(new Action(EditorActions.Indent, "MENU_EDIT_INDENT"c, "edit-indent", KeyCode.TAB, 0));
        editPopupItem.add(new Action(EditorActions.Unindent, "MENU_EDIT_UNINDENT"c, "edit-unindent", KeyCode.TAB, KeyFlag.Control));

        MenuItem viewItem = new MenuItem(new Action(60, "MENU_VIEW"));
        MenuItem langItem = new MenuItem(new Action(61, "MENU_VIEW_LANGUAGE"));
        auto onLangChange = delegate (MenuItem item) {
            if (!item.checked)
                return false;
            if (item.id == 611) {
                // set interface language to english
                platform.instance.uiLanguage = "en";
            } else if (item.id == 612) {
                // set interface language to russian
                platform.instance.uiLanguage = "ru";
            }
            return true;
        };
        MenuItem enLang = (new MenuItem(new Action(611, "MENU_VIEW_LANGUAGE_EN"))).type(MenuItemType.Radio).checked(true);
        MenuItem ruLang = (new MenuItem(new Action(612, "MENU_VIEW_LANGUAGE_RU"))).type(MenuItemType.Radio);
        enLang.menuItemClick = onLangChange;
        ruLang.menuItemClick = onLangChange;
        langItem.add(enLang);
        langItem.add(ruLang);
        viewItem.add(langItem);
        MenuItem themeItem = new MenuItem(new Action(62, "MENU_VIEW_THEME"));
        MenuItem theme1 = (new MenuItem(new Action(621, "MENU_VIEW_THEME_DEFAULT"))).type(MenuItemType.Radio).checked(true);
        MenuItem theme2 = (new MenuItem(new Action(622, "MENU_VIEW_THEME_DARK"))).type(MenuItemType.Radio);
        MenuItem theme3 = (new MenuItem(new Action(623, "MENU_VIEW_THEME_CUSTOM1"))).type(MenuItemType.Radio);
        auto onThemeChange = delegate (MenuItem item) {
            if (!item.checked)
                return false;
            if (item.id == 621) {
                platform.instance.uiTheme = "theme_default";
            } else if (item.id == 622) {
                platform.instance.uiTheme = "theme_dark";
            } else if (item.id == 623) {
                platform.instance.uiTheme = "theme_custom1";
            }
            return true;
        };
        theme1.menuItemClick = onThemeChange;
        theme2.menuItemClick = onThemeChange;
        theme3.menuItemClick = onThemeChange;
        themeItem.add(theme1);
        themeItem.add(theme2);
        themeItem.add(theme3);
        viewItem.add(themeItem);

        MenuItem windowItem = new MenuItem(new Action(3, "MENU_WINDOW"c));
        windowItem.add(new Action(30, "MENU_WINDOW_PREFERENCES"));
        windowItem.add(new Action(31, UIString.fromId("MENU_WINDOW_MINIMIZE")));
        windowItem.add(new Action(32, UIString.fromId("MENU_WINDOW_MAXIMIZE")));
        windowItem.add(new Action(33, UIString.fromId("MENU_WINDOW_RESTORE")));
        MenuItem helpItem = new MenuItem(new Action(4, "MENU_HELP"c));
        helpItem.add(new Action(40, "MENU_HELP_VIEW_HELP"));
        MenuItem aboutItem = new MenuItem(new Action(41, "MENU_HELP_ABOUT"));
        helpItem.add(aboutItem);
        mainMenuItems.add(fileItem);
        mainMenuItems.add(editItem);
        mainMenuItems.add(viewItem);
        mainMenuItems.add(windowItem);
        mainMenuItems.add(helpItem);
        MainMenu mainMenu = new MainMenu(mainMenuItems);
        contentLayout.addChild(mainMenu);
        // to let main menu handle keyboard shortcuts
        contentLayout.keyToAction = delegate(Widget source, uint keyCode, uint flags) {
            return mainMenu.findKeyAction(keyCode, flags);
        };
        contentLayout.onAction = delegate(Widget source, const Action a) {
            if (a.id == ACTION_FILE_EXIT) {
                window.close();
                return true;
            } else if (a.id == 31) {
                window.minimizeWindow();
                return true;
            } else if (a.id == 32) {
                window.maximizeWindow();
                return true;
            } else if (a.id == 33) {
                window.restoreWindow();
                return true;
            } else if (a.id == 41) {
                window.showMessageBox(UIString.fromRaw("About"d), UIString.fromRaw("DLangUI demo app\n(C) Vadim Lopatin, 2014\nhttp://github.com/buggins/dlangui"d));
                return true;
            } else if (a.id == ACTION_FILE_OPEN) {
                UIString caption;
                caption = "Open Text File"d;
                FileDialog dlg = new FileDialog(caption, window, null);
                dlg.allowMultipleFiles = true;
                dlg.addFilter(FileFilterEntry(UIString("FILTER_ALL_FILES", "All files (*)"d), "*"));
                dlg.addFilter(FileFilterEntry(UIString("FILTER_TEXT_FILES", "Text files (*.txt)"d), "*.txt"));
                dlg.addFilter(FileFilterEntry(UIString("FILTER_SOURCE_FILES", "Source files"d), "*.d;*.dd;*.c;*.cc;*.cpp;*.h;*.hpp"));
                dlg.addFilter(FileFilterEntry(UIString("FILTER_EXECUTABLE_FILES", "Executable files"d), "*", true));
                //dlg.filterIndex = 2;
                dlg.dialogResult = delegate(Dialog dlg, const Action result) {
                    if (result.id == ACTION_OPEN.id) {
                        string[] filenames = (cast(FileDialog)dlg).filenames;
                        foreach (filename; filenames) {
                            if (filename.endsWith(".d") || filename.endsWith(".txt") || filename.endsWith(".cpp") || filename.endsWith(".h") || filename.endsWith(".c")
                                || filename.endsWith(".json") || filename.endsWith(".dd") || filename.endsWith(".ddoc") || filename.endsWith(".xml") || filename.endsWith(".html")
                                || filename.endsWith(".html") || filename.endsWith(".css") || filename.endsWith(".log") || filename.endsWith(".hpp")) {
                                    // open source file in tab
                                    int index = tabs.tabIndex(filename);
                                    if (index >= 0) {
                                        // file is already opened in tab
                                        tabs.selectTab(index, true);
                                    } else {
                                        SourceEdit editor = new SourceEdit(filename);
                                        if (editor.load(filename)) {
                                            tabs.addTab(editor, toUTF32(baseName(filename)), null, true);
                                            tabs.selectTab(filename);
                                        } else {
                                            destroy(editor);
                                            window.showMessageBox(UIString.fromRaw("File open error"d), UIString.fromRaw("Cannot open file "d ~ toUTF32(filename)));
                                        }
                                    }
                                } else {
                                    Log.d("FileDialog.onDialogResult: ", result, " param=", result.stringParam);
                                    window.showMessageBox(UIString.fromRaw("FileOpen result"d), UIString.fromRaw("Filename: "d ~ toUTF32(filename)));
                                }
                        }
                    }

                };
                dlg.show();
                return true;
            }
            //else
            //return contentLayout.dispatchAction(a);
            return false;
        };
        mainMenu.menuItemClick = delegate(MenuItem item) {
            Log.d("mainMenu.onMenuItemListener", item.label);
            const Action a = item.action;
            if (a) {
                return contentLayout.dispatchAction(a);
            }
            return false;
        };

        // ========= create tabs ===================

        tabs.tabChanged = delegate(string newTabId, string oldTabId) {
            window.windowCaption = tabs.tab(newTabId).text.value ~ " - dlangui example 1"d;
        };
        tabs.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

        // most of controls example
        {
            LinearLayout controls = new VerticalLayout("controls");
            controls.layoutHeight(FILL_PARENT);
            controls.padding = Rect(12.pointsToPixels,12.pointsToPixels,12.pointsToPixels,12.pointsToPixels);

            HorizontalLayout line1 = new HorizontalLayout();
            controls.addChild(line1);

            GroupBox gb = new GroupBox("checkboxes", "CheckBox"d);
            gb.addChild(new CheckBox("cb1", "CheckBox 1"d));
            gb.addChild(new CheckBox("cb2", "CheckBox 2"d).checked(true));
            gb.addChild(new CheckBox("cb3", "CheckBox disabled"d).enabled(false));
            gb.addChild(new CheckBox("cb4", "CheckBox disabled"d).checked(true).enabled(false));
            line1.addChild(gb);

            GroupBox gb2 = new GroupBox("radiobuttons", "RadioButton"d);
            gb2.addChild(new RadioButton("rb1", "RadioButton 1"d).checked(true));
            gb2.addChild(new RadioButton("rb2", "RadioButton 2"d));
            gb2.addChild(new RadioButton("rb3", "RadioButton disabled"d).enabled(false));
            line1.addChild(gb2);

            VerticalLayout col1 = new VerticalLayout();
            GroupBox gb3 = new GroupBox("textbuttons", "Button"d, Orientation.Horizontal);
            gb3.addChild(new Button("tb1", "Button"d));
            gb3.addChild(new Button("tb2", "Button disabled"d).enabled(false));
            col1.addChild(gb3);
            GroupBox gb4 = new GroupBox("imagetextbuttons", "ImageTextButton"d, Orientation.Horizontal);
            gb4.addChild(new ImageTextButton("itb1", "document-open", "Enabled"d));
            gb4.addChild(new ImageTextButton("itb2", "document-save", "Disabled"d).enabled(false));
            col1.addChild(gb4);
            GroupBox gbtext = new GroupBox("text", "TextWidget"d, Orientation.Horizontal);
            gbtext.addChild(new TextWidget("t1", "Red text"d).fontSize(12.pointsToPixels).textColor(0xFF0000));
            gbtext.addChild(new TextWidget("t2", "Italic text"d).fontSize(12.pointsToPixels).fontItalic(true));
            col1.addChild(gbtext);
            line1.addChild(col1);

            VerticalLayout col2 = new VerticalLayout();
            GroupBox gb31 = new GroupBox("switches", "SwitchButton"d, Orientation.Vertical);
            gb31.addChild(new SwitchButton("sb1"));
            gb31.addChild(new SwitchButton("sb2").checked(true));
            gb31.addChild(new SwitchButton("sb3").enabled(false));
            gb31.addChild(new SwitchButton("sb4").enabled(false).checked(true));
            col2.addChild(gb31);
            line1.addChild(col2);

            VerticalLayout col3 = new VerticalLayout();
            GroupBox gb32 = new GroupBox("switches", "ImageButton"d, Orientation.Vertical);
            gb32.addChild(new ImageButton("ib1", "edit-copy"));
            gb32.addChild(new ImageButton("ib3", "edit-paste").enabled(false));
            col3.addChild(gb32);
            GroupBox gb33 = new GroupBox("images", "ImageWidget"d, Orientation.Vertical);
            gb33.addChild(new ImageWidget("cr3_logo", "cr3_logo"));
            col3.addChild(gb33);
            line1.addChild(col3);


            HorizontalLayout line2 = new HorizontalLayout();
            controls.addChild(line2);

            GroupBox gb5 = new GroupBox("scrollbar", "horizontal ScrollBar"d);
            gb5.addChild(new ScrollBar("sb1", Orientation.Horizontal));
            line2.addChild(gb5);
            GroupBox gb6 = new GroupBox("slider", "horizontal SliderWidget"d);
            gb6.addChild(new SliderWidget("sb2", Orientation.Horizontal));
            line2.addChild(gb6);
            GroupBox gb7 = new GroupBox("editline1", "EditLine"d);
            gb7.addChild(new EditLine("ed1", "Some text"d).minWidth(120.pointsToPixels));
            line2.addChild(gb7);
            GroupBox gb8 = new GroupBox("editline2", "EditLine disabled"d);
            gb8.addChild(new EditLine("ed2", "Some text"d).enabled(false).minWidth(120.pointsToPixels));
            line2.addChild(gb8);

            HorizontalLayout line3 = new HorizontalLayout();
            line3.layoutWidth(FILL_PARENT);
            GroupBox gbeditbox = new GroupBox("editbox", "EditBox"d, Orientation.Horizontal);
            gbeditbox.layoutWidth(FILL_PARENT);
            EditBox ed1 = new EditBox("ed1", "Some text in EditBox\nOne more line\nYet another text line");
            ed1.layoutHeight(FILL_PARENT);
            gbeditbox.addChild(ed1);
            line3.addChild(gbeditbox);
            GroupBox gbtabs = new GroupBox(null, "TabWidget"d);
            gbtabs.layoutWidth(FILL_PARENT);
            TabWidget tabs1 = new TabWidget("tabs1");
            tabs1.addTab(new TextWidget("tab1", "TextWidget on tab page\nTextWidgets can be\nMultiline"d).maxLines(3), "Tab 1"d);
            tabs1.addTab(new ImageWidget("tab2", "dlangui-logo1"), "Tab 2"d);
            tabs1.tabHost.backgroundColor = 0xE0E0E0;
            tabs1.tabHost.padding = Rect(10.pointsToPixels, 10.pointsToPixels, 10.pointsToPixels, 10.pointsToPixels);
            gbtabs.addChild(tabs1);
            line3.addChild(gbtabs);
            controls.addChild(line3);

            HorizontalLayout line4 = new HorizontalLayout();
            line4.layoutWidth(FILL_PARENT);
            line4.layoutHeight(FILL_PARENT);
            GroupBox gbgrid = new GroupBox("grid", "StringGridWidget"d, Orientation.Horizontal);
            StringGridWidget grid = new StringGridWidget("stringgrid");
            grid.resize(12, 10);
            gbgrid.layoutWidth(FILL_PARENT);
            gbgrid.layoutHeight(FILL_PARENT);
            grid.layoutWidth(FILL_PARENT);
            grid.layoutHeight(FILL_PARENT);
            foreach (index, month; ["January"d, "February"d, "March"d, "April"d, "May"d, "June"d, "July"d, "August"d, "September"d, "October"d, "November"d, "December"d])
                grid.setColTitle(cast(int)index, month);
            for (int y = 0; y < 10; y++)
                grid.setRowTitle(y, to!dstring(y+1));
            //grid.alignment = Align.Right;
            grid.setColWidth(0, 30.pointsToPixels);
            grid.autoFit();
            import std.random;
            import std.string;
            for (int x = 0; x < 12; x++) {
                for (int y = 0; y < 10; y++) {
                    int n = uniform(0, 10000);
                    grid.setCellText(x, y, to!dstring("%.2f".format(n / 100.0)));
                }
            }
            //grid.autoFit();
            gbgrid.addChild(grid);
            line4.addChild(gbgrid);

            GroupBox gbtree = new GroupBox("tree", "TreeWidget"d, Orientation.Vertical);
            auto tree = new TreeWidget("gbtree");
            //tree.layoutWidth(WRAP_CONTENT).layoutHeight(FILL_PARENT);
            tree.maxHeight(200.pointsToPixels);
            TreeItem tree1 = tree.items.newChild("group1", "Group 1"d, "document-open");
            tree1.newChild("g1_1", "Group 1 item 1"d);
            tree1.newChild("g1_2", "Group 1 item 2"d);
            tree1.newChild("g1_3", "Group 1 item 3"d);
            TreeItem tree2 = tree.items.newChild("group2", "Group 2"d, "document-save");
            tree2.newChild("g2_1", "Group 2 item 1"d, "edit-copy");
            tree2.newChild("g2_2", "Group 2 item 2"d, "edit-cut");
            tree2.newChild("g2_3", "Group 2 item 3"d, "edit-paste");
            tree2.newChild("g2_4", "Group 2 item 4"d);
            TreeItem tree3 = tree.items.newChild("group3", "Group 3"d);
            tree3.newChild("g3_1", "Group 3 item 1"d);
            tree3.newChild("g3_2", "Group 3 item 2"d);
            TreeItem tree32 = tree3.newChild("g3_3", "Group 3 item 3"d);
            tree3.newChild("g3_4", "Group 3 item 4"d);
            tree32.newChild("group3_2_1", "Group 3 item 2 subitem 1"d);
            tree32.newChild("group3_2_2", "Group 3 item 2 subitem 2"d);
            tree32.newChild("group3_2_3", "Group 3 item 2 subitem 3"d);
            tree32.newChild("group3_2_4", "Group 3 item 2 subitem 4"d);
            tree32.newChild("group3_2_5", "Group 3 item 2 subitem 5"d);
            tree3.newChild("g3_5", "Group 3 item 5"d);
            tree3.newChild("g3_6", "Group 3 item 6"d);
            gbtree.addChild(tree);
            tree.items.selectItem(tree1);
            // test adding new tree items
            HorizontalLayout newTreeItem = new HorizontalLayout();
            newTreeItem.layoutWidth = FILL_PARENT;
            EditLine edNewTreeItem = new EditLine("newTreeItem", "new item"d);
            edNewTreeItem.layoutWidth = FILL_PARENT;
            Button btnAddItem = new Button("btnAddTreeItem", "Add"d);
            Button btnRemoveItem = new Button("btnRemoveTreeItem", "Remove"d);
            newTreeItem.addChild(edNewTreeItem);
            newTreeItem.addChild(btnAddItem);
            newTreeItem.addChild(btnRemoveItem);
            btnAddItem.click = delegate(Widget source) {
                import std.random;
                dstring label = edNewTreeItem.text;
                string id = "item%d".format(uniform(1000000, 9999999, rndGen));
                TreeItem item = tree.items.selectedItem;
                if (item) {
                    Log.d("Creating new tree item ", id, " ", label);
                    TreeItem newItem = new TreeItem(id, label);
                    item.addChild(newItem);
                }
                return true;
            };
            btnRemoveItem.click = delegate(Widget source) {
                TreeItem item = tree.items.selectedItem;
                if (item) {
                    Log.d("Removing tree item ", item.id, " ", item.text);
                    item.parent.removeChild(item);
                }
                return true;
            };
            gbtree.addChild(newTreeItem);
            line4.addChild(gbtree);

            controls.addChild(line4);

            tabs.addTab(controls, "Controls"d);
        }

        LinearLayout layout = new LinearLayout("tab1");


        layout.addChild((new TextWidget()).textColor(0x00802000).text("Text widget 0"));
        layout.addChild((new TextWidget()).textColor(0x40FF4000).text("Text widget"));
        layout.addChild(new ProgressBarWidget().progress(300).animationInterval(50));
        layout.addChild(new ProgressBarWidget().progress(-1).animationInterval(50));
        layout.addChild((new Button("BTN1")).textResource("EXIT")); //.textColor(0x40FF4000)
        layout.addChild(new TimerTest());

        static if (true) {


        LinearLayout hlayout = new HorizontalLayout();
        hlayout.layoutWidth(FILL_PARENT);
        //hlayout.addChild((new Button()).text("<<")); //.textColor(0x40FF4000)
        hlayout.addChild((new TextWidget()).text("Several").alignment(Align.Center));
        hlayout.addChild((new ImageWidget()).drawableId("btn_radio").padding(Rect(5,5,5,5)).alignment(Align.Center));
        hlayout.addChild((new TextWidget()).text("items").alignment(Align.Center));
        hlayout.addChild((new ImageWidget()).drawableId("btn_check").padding(Rect(5,5,5,5)).alignment(Align.Center));
        hlayout.addChild((new TextWidget()).text("in horizontal layout"));
        hlayout.addChild((new ImageWidget()).drawableId("exit").padding(Rect(5,5,5,5)).alignment(Align.Center));
        hlayout.addChild((new EditLine("editline", "Some text to edit"d)).popupMenu(editPopupItem).alignment(Align.Center).layoutWidth(FILL_PARENT));
        hlayout.addChild((new EditLine("passwd", "Password"d)).passwordChar('*').popupMenu(editPopupItem).alignment(Align.Center).layoutWidth(FILL_PARENT));
        //hlayout.addChild((new Button()).text(">>")); //.textColor(0x40FF4000)
        hlayout.backgroundColor = 0x8080C0;
        layout.addChild(hlayout);

        LinearLayout vlayoutgroup = new HorizontalLayout();
        LinearLayout vlayout = new VerticalLayout();
        vlayout.addChild((new TextWidget()).text("VLayout line 1").textColor(0x40FF4000)); //
        vlayout.addChild((new TextWidget()).text("VLayout line 2").textColor(0x40FF8000));
        vlayout.addChild((new TextWidget()).text("VLayout line 2").textColor(0x40008000));
        vlayout.addChild(new RadioButton("rb1", "Radio button 1"d));
        vlayout.addChild(new RadioButton("rb2", "Radio button 2"d));
        vlayout.addChild(new RadioButton("rb3", "Radio button 3"d));
        vlayout.layoutWidth(FILL_PARENT);
        vlayoutgroup.addChild(vlayout);
        vlayoutgroup.layoutWidth(FILL_PARENT);
        ScrollBar vsb = new ScrollBar("vscroll", Orientation.Vertical);
        vlayoutgroup.addChild(vsb);
        layout.addChild(vlayoutgroup);

        ScrollBar sb = new ScrollBar("hscroll", Orientation.Horizontal);
        layout.addChild(sb.layoutHeight(WRAP_CONTENT).layoutWidth(FILL_PARENT));

        layout.addChild((new CheckBox("BTN2", "Some checkbox"d)));
        layout.addChild((new TextWidget()).textColor(0x40FF4000).text("Text widget"));
        layout.addChild((new ImageWidget()).drawableId("exit").padding(Rect(5,5,5,5)));
        layout.addChild((new TextWidget()).textColor(0xFF4000).text("Text widget2").padding(Rect(5,5,5,5)).margins(Rect(5,5,5,5)).backgroundColor(0xA0A0A0));
        layout.addChild((new RadioButton("BTN3", "Some radio button"d)));
        layout.addChild((new TextWidget(null, "Text widget3 with very long text"d)).textColor(0x004000));
        layout.addChild(new VSpacer()); // vertical spacer to fill extra space


        Widget w = parseML(q{
            VerticalLayout {
                id: vlayout
                margins: Rect { left: 5; right: 3; top: 2; bottom: 4 }
                padding: Rect { 5, 4, 3, 2 } // same as Rect { left: 5; top: 4; right: 3; bottom: 2 }
                TextWidget {
                    /* this widget can be accessed via id myLabel1
                    e.g. w.childById!TextWidget("myLabel1")
                    */
                    id: myLabel1
                    text: "Some text"; padding: 5
                    enabled: false
                }
                TextWidget {
                    id: myLabel2
                    text: SOME_TEXT_RESOURCE_ID; margins: 5
                    enabled: true
                }
            }
        });
        Log.d("id=", w.id, " text=", w.text, " padding=", w.padding, " margins=", w.margins,
              " lbl1.text=", w.childById!TextWidget("myLabel1").text,
              " lbl1.enabled=", w.childById!TextWidget("myLabel1").enabled,
              " lbl2.text=", w.childById!TextWidget("myLabel2").text
              );
        destroy(w);

        layout.childById("BTN1").click = delegate (Widget w) {
            Log.d("onClick ", w.id);
            //w.backgroundImageId = null;
            //w.backgroundColor = 0xFF00FF;
            w.textColor = 0xFF00FF;
            w.styleId = STYLE_BUTTON_NOMARGINS;
            return true;
        };
        layout.childById("BTN2").click = delegate (Widget w) { Log.d("onClick ", w.id); return true; };
        layout.childById("BTN3").click = delegate (Widget w) { Log.d("onClick ", w.id); return true; };

        }

        layout.layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);

        tabs.addTab(layout, "Misc"d);

        static if (true) {
            // two long lists
            // left one is list with widgets as items
            // right one is list with string list adapter
            HorizontalLayout longLists = new HorizontalLayout("tab2");
            longLists.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

            ListWidget list = new ListWidget("list1", Orientation.Vertical);
            list.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

            StringListAdapter stringList = new StringListAdapter();
            WidgetListAdapter listAdapter = new WidgetListAdapter();
            listAdapter.add((new TextWidget()).text("This is a list of widgets"d).styleId("LIST_ITEM"));
            stringList.add("This is a list of strings from StringListAdapter"d);
            stringList.add("If you type with your keyboard,"d);
            stringList.add("then you can find the"d);
            stringList.add("item in the list"d);
            stringList.add("neat!"d);
            for (int i = 1; i < 1000; i++) {
                dstring label = "List item "d ~ to!dstring(i);
                listAdapter.add((new TextWidget()).text("Widget list - "d ~ label).styleId("LIST_ITEM"));
                stringList.add("Simple string - "d ~ label);
            }
            list.ownAdapter = listAdapter;
            listAdapter.resetItemState(0, State.Enabled);
            listAdapter.resetItemState(5, State.Enabled);
            listAdapter.resetItemState(7, State.Enabled);
            listAdapter.resetItemState(12, State.Enabled);
            assert(list.itemEnabled(5) == false);
            assert(list.itemEnabled(6) == true);
            list.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
            list.selectItem(0);

            longLists.addChild(list);

            ListWidget list2 = new StringListWidget("list2");
            list2.ownAdapter = stringList;
            list2.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
            list2.selectItem(0);
            longLists.addChild(list2);

            VerticalLayout itemedit = new VerticalLayout();
            itemedit.addChild(new TextWidget(null, "New item text:"d));
            EditLine itemtext = new EditLine(null, "Text for new item"d);
            itemedit.addChild(itemtext);
            Button btn = new Button(null, "Add item"d);
            itemedit.addChild(btn);
            longLists.addChild(itemedit);
            btn.click = delegate(Widget src)
            {
                stringList.add(itemtext.text);
                listAdapter.add((new TextWidget()).text(itemtext.text).styleId("LIST_ITEM"));
                return true;
            };
            tabs.addTab(longLists, "TAB_LONG_LIST"c);
        }

        {
            LinearLayout layout3 = new VerticalLayout("tab3");
            // 3 types of buttons: Button, ImageButton, ImageTextButton
            layout3.addChild(new TextWidget(null, "Buttons in HorizontalLayout"d));
            WidgetGroup buttons1 = new HorizontalLayout();
            buttons1.addChild(new TextWidget(null, "Button widgets: "d));
            buttons1.addChild((new Button("btn1", "Button"d)).tooltipText("Tooltip text for button"d));
            buttons1.addChild((new Button("btn2", "Disabled Button"d)).enabled(false));
            buttons1.addChild(new TextWidget(null, "ImageButton widgets: "d));
            buttons1.addChild(new ImageButton("btn3", "text-plain"));
            buttons1.addChild(new TextWidget(null, "disabled: "d));
            buttons1.addChild((new ImageButton("btn4", "folder")).enabled(false));
            layout3.addChild(buttons1);

            WidgetGroup buttons10 = new HorizontalLayout();
            buttons10.addChild(new TextWidget(null, "ImageTextButton widgets: "d));
            buttons10.addChild(new ImageTextButton("btn5", "text-plain", "Enabled"d));
            buttons10.addChild((new ImageTextButton("btn6", "folder", "Disabled"d)).enabled(false));
            buttons10.addChild(new TextWidget(null, "SwitchButton widgets: "d));
            buttons10.addChild((new SwitchButton("SW1")).checked(true));
            buttons10.addChild((new SwitchButton("SW2")).checked(false));
            buttons10.addChild((new SwitchButton("SW3")).checked(true).enabled(false));
            buttons10.addChild((new SwitchButton("SW4")).checked(false).enabled(false));
            layout3.addChild(buttons10);

            WidgetGroup buttons11 = new HorizontalLayout();
            buttons11.addChild(new TextWidget(null, "Construct buttons by action (Button, ImageButton, ImageTextButton): "d));
            Action FILE_OPEN_ACTION = new Action(ACTION_FILE_OPEN, "MENU_FILE_OPEN"c, "document-open", KeyCode.KEY_O, KeyFlag.Control);
            buttons11.addChild(new Button(FILE_OPEN_ACTION));
            buttons11.addChild(new ImageButton(FILE_OPEN_ACTION));
            buttons11.addChild(new ImageTextButton(FILE_OPEN_ACTION));
            layout3.addChild(buttons11);

            WidgetGroup buttons12 = new HorizontalLayout();
            buttons12.addChild(new TextWidget(null, "The same in disabled state: "d));
            buttons12.addChild((new Button(FILE_OPEN_ACTION)).enabled(false));
            buttons12.addChild((new ImageButton(FILE_OPEN_ACTION)).enabled(false));
            buttons12.addChild((new ImageTextButton(FILE_OPEN_ACTION)).enabled(false));
            layout3.addChild(buttons12);

            layout3.addChild(new VSpacer());
            layout3.addChild(new TextWidget(null, "CheckBoxes in HorizontalLayout"d));
            WidgetGroup buttons2 = new HorizontalLayout();
            buttons2.addChild(new CheckBox("btn1", "CheckBox 1"d));
            buttons2.addChild(new CheckBox("btn2", "CheckBox 2"d));
            //buttons2.addChild(new ResizerWidget());
            buttons2.addChild(new CheckBox("btn3", "CheckBox 3"d));
            buttons2.addChild(new CheckBox("btn4", "CheckBox 4"d));
            layout3.addChild(buttons2);

            layout3.addChild(new VSpacer());
            layout3.addChild(new TextWidget(null, "RadioButtons in HorizontalLayout"d));
            WidgetGroup buttons3 = new HorizontalLayout();
            buttons3.addChild(new RadioButton("btn1", "RadioButton 1"d));
            buttons3.addChild(new RadioButton("btn2", "RadioButton 2"d));
            buttons3.addChild(new RadioButton("btn3", "RadioButton 3"d));
            buttons3.addChild(new RadioButton("btn4", "RadioButton 4"d));
            layout3.addChild(buttons3);

            layout3.addChild(new VSpacer());
            layout3.addChild(new TextWidget(null, "ImageButtons HorizontalLayout"d));
            WidgetGroup buttons4 = new HorizontalLayout();
            buttons4.addChild(new ImageButton("btn1", "fileclose"));
            buttons4.addChild(new ImageButton("btn2", "fileopen"));
            buttons4.addChild(new ImageButton("btn3", "exit"));
            layout3.addChild(buttons4);

            layout3.addChild(new VSpacer());
            layout3.addChild(new TextWidget(null, "In vertical layouts:"d));
            HorizontalLayout hlayout2 = new HorizontalLayout();
            hlayout2.layoutHeight(FILL_PARENT); //layoutWidth(FILL_PARENT).

            buttons1 = new VerticalLayout();
            buttons1.addChild(new TextWidget(null, "Buttons"d));
            buttons1.addChild(new Button("btn1", "Button 1"d));
            buttons1.addChild(new Button("btn2", "Button 2"d));
            buttons1.addChild((new Button("btn3", "Button 3 - disabled"d)).enabled(false));
            buttons1.addChild(new Button("btn4", "Button 4"d));
            hlayout2.addChild(buttons1);
            hlayout2.addChild(new HSpacer());

            buttons2 = new VerticalLayout();
            buttons2.addChild(new TextWidget(null, "CheckBoxes"d));
            buttons2.addChild(new CheckBox("btn1", "CheckBox 1"d));
            buttons2.addChild(new CheckBox("btn2", "CheckBox 2"d));
            buttons2.addChild(new CheckBox("btn3", "CheckBox 3"d));
            buttons2.addChild(new CheckBox("btn4", "CheckBox 4"d));
            hlayout2.addChild(buttons2);
            hlayout2.addChild(new HSpacer());

            buttons3 = new VerticalLayout();
            buttons3.addChild(new TextWidget(null, "RadioButtons"d));
            buttons3.addChild(new RadioButton("btn1", "RadioButton 1"d));
            buttons3.addChild(new RadioButton("btn2", "RadioButton 2"d));
            //buttons3.addChild(new ResizerWidget());
            buttons3.addChild(new RadioButton("btn3", "RadioButton 3"d));
            buttons3.addChild(new RadioButton("btn4", "RadioButton 4"d));
            hlayout2.addChild(buttons3);
            hlayout2.addChild(new HSpacer());

            buttons4 = new VerticalLayout();
            buttons4.addChild(new TextWidget(null, "ImageButtons"d));
            buttons4.addChild(new ImageButton("btn1", "fileclose"));
            buttons4.addChild(new ImageButton("btn2", "fileopen"));
            buttons4.addChild(new ImageButton("btn3", "exit"));
            hlayout2.addChild(buttons4);
            hlayout2.addChild(new HSpacer());

            WidgetGroup buttons5 = new VerticalLayout();
            buttons5.addChild(new TextWidget(null, "ImageTextButtons"d));
            buttons5.addChild(new ImageTextButton("btn1", "fileclose", "Close"d));
            buttons5.addChild(new ImageTextButton("btn2", "fileopen", "Open"d));
            buttons5.addChild(new ImageTextButton("btn3", "exit", "Exit"d));
            hlayout2.addChild(buttons5);


            layout3.addChild(hlayout2);

            layout3.addChild(new VSpacer());
            layout3.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
            tabs.addTab(layout3, "TAB_BUTTONS"c);
        }

        TableLayout table = new TableLayout("TABLE");
        table.colCount = 2;
        // headers
        table.addChild((new TextWidget(null, "Parameter Name"d)).alignment(Align.Right | Align.VCenter));
        table.addChild((new TextWidget(null, "Edit Box to edit parameter"d)).alignment(Align.Left | Align.VCenter));
        // row 1
        table.addChild((new TextWidget(null, "Parameter 1 name"d)).alignment(Align.Right | Align.VCenter));
        table.addChild((new EditLine("edit1", "Text 1"d)).layoutWidth(FILL_PARENT));
        // row 2
        table.addChild((new TextWidget(null, "Parameter 2 name bla bla"d)).alignment(Align.Right | Align.VCenter));
        table.addChild((new EditLine("edit2", "Some text for parameter 2"d)).layoutWidth(FILL_PARENT));
        // row 3
        table.addChild((new TextWidget(null, "Param 3 is disabled"d)).alignment(Align.Right | Align.VCenter).enabled(false));
        table.addChild((new EditLine("edit3", "Parameter 3 value"d)).layoutWidth(FILL_PARENT).enabled(false));
        // normal readonly combo box
        ComboBox combo1 = new ComboBox("combo1", ["item value 1"d, "item value 2"d, "item value 3"d, "item value 4"d, "item value 5"d, "item value 6"d]);
        table.addChild((new TextWidget(null, "Combo box param"d)).alignment(Align.Right | Align.VCenter));
        combo1.selectedItemIndex = 3;
        table.addChild(combo1).layoutWidth(FILL_PARENT);
        // disabled readonly combo box
        ComboBox combo2 = new ComboBox("combo2", ["item value 1"d, "item value 2"d, "item value 3"d]);
        table.addChild((new TextWidget(null, "Disabled combo box"d)).alignment(Align.Right | Align.VCenter));
        combo2.enabled = false;
        combo2.selectedItemIndex = 0;
        table.addChild(combo2).layoutWidth(FILL_PARENT);

        table.margins(Rect(2,2,2,2)).layoutWidth(FILL_PARENT);
        tabs.addTab(table, "TAB_TABLE_LAYOUT"c);

        //tabs.addTab((new TextWidget()).id("tab5").textColor(0x00802000).text("Tab 5 contents"), "Tab 5"d);

        //==========================================================================
        // create Editors test tab
        VerticalLayout editors = new VerticalLayout("editors");

        // EditLine sample
        editors.addChild(new TextWidget(null, "EditLine: Single line editor"d));
        EditLine editLine = new EditLine("editline1", "Single line editor sample text");
        editors.addChild(createEditorSettingsControl(editLine));
        editors.addChild(editLine);
        editLine.popupMenu = editPopupItem;

        // EditBox sample
        editors.addChild(new TextWidget(null, "SourceEdit: multiline editor, for source code editing"d));

        SourceEdit editBox = new SourceEdit("editbox1");
        editBox.text = q{#!/usr/bin/env rdmd
// Computes average line length for standard input.
import std.stdio;

void main()
{
    ulong lines = 0;
    double sumLength = 0;
    foreach (line; stdin.byLine())
    {
        ++lines;
        sumLength += line.length;
    }
    writeln("Average line length: ",
            lines ? sumLength / lines : 0);
}
        }d;
        editors.addChild(createEditorSettingsControl(editBox));
        editors.addChild(editBox);
        editBox.popupMenu = editPopupItem;

        editors.addChild(new TextWidget(null, "EditBox: additional view for the same content (split view testing)"d));
        SourceEdit editBox2 = new SourceEdit("editbox2");
        editBox2.content = editBox.content; // view the same content as first editbox
        editors.addChild(editBox2);
        editors.layoutHeight(FILL_PARENT).layoutWidth(FILL_PARENT);

        tabs.addTab(editors, "TAB_EDITORS"c);

        //==========================================================================

        VerticalLayout gridContent = new VerticalLayout("GRID_CONTENT");
        gridContent.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        HorizontalLayout gridSettings = new HorizontalLayout();
        StringGridWidget grid = new StringGridWidget("GRID1");

        gridSettings.addChild((new CheckBox("fullColumnOnLeft", "fullColumnOnLeft"d)).checked(grid.fullColumnOnLeft).tooltipText("Extends scroll area to show full column at left when scrolled to rightmost column"d).addOnCheckChangeListener(delegate(Widget, bool checked) { grid.fullColumnOnLeft = checked; return true;}));
        gridSettings.addChild((new CheckBox("fullRowOnTop", "fullRowOnTop"d)).checked(grid.fullRowOnTop).tooltipText("Extends scroll area to show full row at top when scrolled to end row"d).addOnCheckChangeListener(delegate(Widget, bool checked) { grid.fullRowOnTop = checked; return true;}));
        gridContent.addChild(gridSettings);

        grid.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        grid.showColHeaders = true;
        grid.showRowHeaders = true;
        grid.resize(30, 50);
        grid.fixedCols = 3;
        grid.fixedRows = 2;
        //grid.rowSelect = true; // testing full row selection
        grid.multiSelect = true;
        grid.selectCell(4, 6, false);
        // create sample grid content
        for (int y = 0; y < grid.rows; y++) {
            for (int x = 0; x < grid.cols; x++) {
                grid.setCellText(x, y, "cell("d ~ to!dstring(x + 1) ~ ","d ~ to!dstring(y + 1) ~ ")"d);
            }
            grid.setRowTitle(y, to!dstring(y + 1));
        }
        for (int x = 0; x < grid.cols; x++) {
            int col = x + 1;
            dstring res;
            int n1 = col / 26;
            int n2 = col % 26;
            if (n1)
                res ~= n1 + 'A';
            res ~= n2 + 'A';
            grid.setColTitle(x, res);
        }
        grid.autoFit();
        gridContent.addChild(grid);
        tabs.addTab(gridContent, "Grid"d);

        //==========================================================================
        // Scroll view example
        ScrollWidget scroll = new ScrollWidget("SCROLL1");
        scroll.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);
        WidgetGroup scrollContent = new VerticalLayout("CONTENT");
        scrollContent.layoutWidth(FILL_PARENT).layoutHeight(FILL_PARENT);

        TableLayout table2 = new TableLayout("TABLE2");
        table2.colCount = 2;
        // headers
        table2.addChild((new TextWidget(null, "Parameter Name"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new TextWidget(null, "Edit Box to edit parameter"d)).alignment(Align.Left | Align.VCenter));
        // row 1
        table2.addChild((new TextWidget(null, "Parameter 1 name"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit1", "Text 1"d)).layoutWidth(FILL_PARENT));
        // row 2
        table2.addChild((new TextWidget(null, "Parameter 2 name bla bla"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit2", "Some text for parameter 2 blah blah blah"d)).layoutWidth(FILL_PARENT));
        // row 3
        table2.addChild((new TextWidget(null, "Param 3"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit3", "Parameter 3 value"d)).layoutWidth(FILL_PARENT));
        // row 4
        table2.addChild((new TextWidget(null, "Param 4"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit3", "Parameter 4 value shdjksdfh hsjdfas hdjkf hdjsfk ah"d)).layoutWidth(FILL_PARENT));
        // row 5
        table2.addChild((new TextWidget(null, "Param 5 - edit text here - blah blah blah"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT));
        // row 6
        table2.addChild((new TextWidget(null, "Param 6 - just to fill content widget (DISABLED)"d)).alignment(Align.Right | Align.VCenter).enabled(false));
        table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT).enabled(false));
        // row 7
        table2.addChild((new TextWidget(null, "Param 7 - just to fill content widget (DISABLED)"d)).alignment(Align.Right | Align.VCenter).enabled(false));
        table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT).enabled(false));
        // row 8
        table2.addChild((new TextWidget(null, "Param 8 - just to fill content widget"d)).alignment(Align.Right | Align.VCenter));
        table2.addChild((new EditLine("edit3", "Parameter 5 value"d)).layoutWidth(FILL_PARENT));
        table2.margins(Rect(10,10,10,10)).layoutWidth(FILL_PARENT);
        scrollContent.addChild(table2);

        scrollContent.addChild(new TextWidget(null, "Now - some buttons"d));
        scrollContent.addChild(new ImageTextButton("btn1", "fileclose", "Close"d));
        scrollContent.addChild(new ImageTextButton("btn2", "fileopen", "Open"d));
        scrollContent.addChild(new TextWidget(null, "And checkboxes"d));
        scrollContent.addChild(new CheckBox("btn1", "CheckBox 1"d));
        scrollContent.addChild(new CheckBox("btn2", "CheckBox 2"d));

        scroll.contentWidget = scrollContent;
        tabs.addTab(scroll, "Scroll"d);
        //==========================================================================
        // tree view example
        TreeWidget tree = new TreeWidget("TREE1");
        tree.layoutWidth(WRAP_CONTENT).layoutHeight(FILL_PARENT);
        TreeItem tree1 = tree.items.newChild("group1", "Group 1"d, "document-open");
        tree1.newChild("g1_1", "Group 1 item 1"d);
        tree1.newChild("g1_2", "Group 1 item 2"d);
        tree1.newChild("g1_3", "Group 1 item 3"d);
        TreeItem tree2 = tree.items.newChild("group2", "Group 2"d, "document-save");
        tree2.newChild("g2_1", "Group 2 item 1"d, "edit-copy");
        tree2.newChild("g2_2", "Group 2 item 2"d, "edit-cut");
        tree2.newChild("g2_3", "Group 2 item 3"d, "edit-paste");
        tree2.newChild("g2_4", "Group 2 item 4"d);
        TreeItem tree3 = tree.items.newChild("group3", "Group 3"d);
        tree3.newChild("g3_1", "Group 3 item 1"d);
        tree3.newChild("g3_2", "Group 3 item 2"d);
        TreeItem tree32 = tree3.newChild("g3_3", "Group 3 item 3"d);
        tree3.newChild("g3_4", "Group 3 item 4"d);
        tree32.newChild("group3_2_1", "Group 3 item 2 subitem 1"d);
        tree32.newChild("group3_2_2", "Group 3 item 2 subitem 2"d);
        tree32.newChild("group3_2_3", "Group 3 item 2 subitem 3"d);
        tree32.newChild("group3_2_4", "Group 3 item 2 subitem 4"d);
        tree32.newChild("group3_2_5", "Group 3 item 2 subitem 5"d);
        tree3.newChild("g3_5", "Group 3 item 5"d);
        tree3.newChild("g3_6", "Group 3 item 6"d);

        LinearLayout treeLayout = new HorizontalLayout("TREE");
        LinearLayout treeControlledPanel = new VerticalLayout();
        treeLayout.layoutWidth = FILL_PARENT;
        treeControlledPanel.layoutWidth = FILL_PARENT;
        treeControlledPanel.layoutHeight = FILL_PARENT;
        TextWidget treeItemLabel = new TextWidget("TREE_ITEM_DESC");
        treeItemLabel.layoutWidth = FILL_PARENT;
        treeItemLabel.layoutHeight = FILL_PARENT;
        treeItemLabel.alignment = Align.Center;
        treeItemLabel.text = "Sample text"d;
        treeControlledPanel.addChild(treeItemLabel);
        treeLayout.addChild(tree);
        treeLayout.addChild(new ResizerWidget());
        treeLayout.addChild(treeControlledPanel);

        tree.selectionChange = delegate(TreeItems source, TreeItem selectedItem, bool activated) {
            dstring label = "Selected item: "d ~ toUTF32(selectedItem.id) ~ (activated ? " selected + activated"d : " selected"d);
            treeItemLabel.text = label;
        };

        tree.items.selectItem(tree.items.child(0));

        tabs.addTab(treeLayout, "Tree"d);
        //==========================================================================
        // charts example
        SimpleBarChart barChart1 = new SimpleBarChart("barChart1","SimpleBarChart Example"d);
        barChart1.addBar(12.0, makeRGBA(255,0,0,0), "Red bar"d);
        barChart1.addBar(24.0, makeRGBA(0,255,0,0), "Green bar"d);
        barChart1.addBar(5.0, makeRGBA(0,0,255,0), "Blue bar"d);
        barChart1.addBar(12.0, makeRGBA(230,126,34,0), "Orange bar"d);
        //barChart1.layoutWidth = FILL_PARENT;
        //barChart1.layoutHeight = FILL_PARENT;

        SimpleBarChart barChart2 = new SimpleBarChart("barChart2","SimpleBarChart Example - long descriptions"d);
        barChart2.addBar(12.0, makeRGBA(255,0,0,0), "Red bar\n(12.0)"d);
        barChart2.addBar(24.0, makeRGBA(0,255,0,0), "Green bar\n(24.0)"d);
        barChart2.addBar(5.0, makeRGBA(0,0,255,0), "Blue bar\n(5.0)"d);
        barChart2.addBar(12.0, makeRGBA(230,126,34,0), "Orange bar\n(12.0)\nlong long long description added here"d);

        SimpleBarChart barChart3 = new SimpleBarChart("barChart3","SimpleBarChart Example with axis ratio 0.3"d);
        barChart3.addBar(12.0, makeRGBA(255,0,0,0), "Red bar"d);
        barChart3.addBar(24.0, makeRGBA(0,255,0,0), "Green bar"d);
        barChart3.addBar(5.0, makeRGBA(0,0,255,0), "Blue bar"d);
        barChart3.addBar(12.0, makeRGBA(230,126,34,0), "Orange bar"d);
        barChart3.axisRatio = 0.3;

        SimpleBarChart barChart4 = new SimpleBarChart("barChart4","SimpleBarChart Example with axis ratio 1.3"d);
        barChart4.addBar(12.0, makeRGBA(255,0,0,0), "Red bar"d);
        barChart4.addBar(24.0, makeRGBA(0,255,0,0), "Green bar"d);
        barChart4.addBar(5.0, makeRGBA(0,0,255,0), "Blue bar"d);
        barChart4.addBar(12.0, makeRGBA(230,126,34,0), "Orange bar"d);
        barChart4.axisRatio = 1.3;

        HorizontalLayout chartsLayout = new HorizontalLayout("CHARTS");
        chartsLayout.layoutWidth = FILL_PARENT;
        chartsLayout.layoutHeight = FILL_PARENT;

        VerticalLayout chartColumn1 = new VerticalLayout();
        VerticalLayout chartColumn2 = new VerticalLayout();

        chartColumn1.addChild(barChart1);
        chartColumn1.addChild(barChart2);
        chartsLayout.addChild(chartColumn1);
        chartColumn2.addChild(barChart3);
        chartColumn2.addChild(barChart4);
        chartsLayout.addChild(chartColumn2);
        tabs.addTab(chartsLayout, "Charts"d);

        //==========================================================================

        contentLayout.addChild(tabs);
        window.mainWidget = contentLayout;

        tabs.selectTab("controls");
    } else {
        window.mainWidget = (new Button()).text("sample button");
    }

    window.show();

    Log.i("HOME path: ", homePath);
    Log.i("APPDATA path: ", appDataPath(".dlangui"));
    Log.i("Root paths: ", getRootPaths);

    return Platform.instance.enterMessageLoop();
}
