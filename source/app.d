static import BT = BearLibTerminal;
import dlangui;

mixin APP_ENTRY_POINT;

extern(C) int DLANGUImain(string[] args) {
    initLogs();
    SCREEN_DPI = 10; // TODO: wtf?
    Platform.setInstance(new BearLibPlatform());
    //~ FontManager.instance = new ConsoleFontManager();
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

import dlangui.platforms.common.platform;

class BearLibPlatform : Platform
{
    override:

    BearLibWindow createWindow(dstring windowCaption, Window parent, uint flags, uint width, uint height)
    {
        return new BearLibWindow;
    }

    void closeWindow(Window w)
    {
        w.close();
    }

    int enterMessageLoop()
    {
        return -1;
    }

    dstring getClipboardText(bool mouseBuffer = false)
    {
        return "text from clipboard";
    }

    void setClipboardText(dstring text, bool mouseBuffer = false)
    {
    }

    void requestLayout()
    {
    }
}

class BearLibWindow : Window
{
    debug private bool windowDisplayed;

    this()
    {
        assert(!windowDisplayed);

        BT.terminal.open();

        debug windowDisplayed = true;
    }

    override:

    void close()
    {
        assert(!windowDisplayed);

        BT.terminal.close();

        debug windowDisplayed = false;
    }

    void show()
    {
        BT.terminal.refresh();
    }

    dstring windowCaption() @property
    {
        return "this is window caption";
    }

    void windowCaption(dstring caption) @property
    {
    }

    void windowIcon(Ref!(DrawBuf) icon) @property
    {
    }

    void invalidate()
    {
    }
}

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args)
{
    // create window
    Window window = Platform.instance.createWindow("My Window", null);

    // create some widget to show in window
    window.mainWidget = (new Button()).text("Hello world"d).textColor(0xFF0000); // red text

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
