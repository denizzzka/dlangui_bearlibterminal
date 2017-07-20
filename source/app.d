module dlangui_bearlibterminal.app;

import dlangui;

mixin APP_ENTRY_POINT;

extern(C) int DLANGUImain(string[] args)
{
    import dlangui_bearlibterminal.platform: BearLibPlatform;
    import dlangui_bearlibterminal.fonts: BearLibFontManager;

    initLogs();
    SCREEN_DPI = 10; // TODO: wtf?
    Platform.setInstance = new BearLibPlatform();
    FontManager.instance = new BearLibFontManager();
    initResourceManagers();

    version (Windows)
    {
        import core.sys.windows.winuser;
        DOUBLE_CLICK_THRESHOLD_MS = GetDoubleClickTime();
    }

    currentTheme = createDefaultTheme();
    Platform.instance.uiTheme = "theme_default";

    Log.i("Entering UIAppMain: ", args);

    int result = -1;
    try
    {
        result = UIAppMain(args);
        Log.i("UIAppMain returned ", result);
    }
    catch (Exception e)
    {
        Log.e("Abnormal UIAppMain termination");
        Log.e("UIAppMain exception: ", e);
    }

    Platform.setInstance(null);

    releaseResourcesOnAppExit();

    Log.d("Exiting main");
    APP_IS_SHUTTING_DOWN = true;

    return result;
}

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args)
{
    // create window
    Window window = Platform.instance.createWindow("My Window", null);

    window.mainWidget = new VerticalLayout();
    //~ window.mainWidget = new HorizontalLayout();

    // create some widget to show in window
    auto someText = new TextWidget(null, "Hello world"d);
    someText.textColor(0xFF0000); // red text

    window.mainWidget.addChild = someText;
    window.mainWidget.addChild = new EditLine(null, "Some text for parameter 1"d);

    auto btn2 = (new Button).text("Button 2"d);

    btn2.click =
        delegate(Widget w)
        {
            Log.d("Button click!");
            return true;
        };

    window.mainWidget.addChild = btn2;

    //~ window.mainWidget.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);

    //~ window.requestLayout();

    window.show();

    Log.d(window.width);
    Log.d(window.height);

    Log.d(window.mainWidget.measuredWidth);
    Log.d(window.mainWidget.measuredHeight);

    Log.d(window.mainWidget.width);
    Log.d(window.mainWidget.height);

    Log.d(window.mainWidget.left);
    Log.d(window.mainWidget.top);

    // run message loop
    return Platform.instance.enterMessageLoop();
}
