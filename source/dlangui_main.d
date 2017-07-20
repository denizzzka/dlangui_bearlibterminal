module dlangui_bearlibterminal.dlangui_main;

public import dlangui;

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
