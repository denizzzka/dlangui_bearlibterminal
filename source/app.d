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
    private BearLibWindow window;

    override:

    BearLibWindow createWindow(dstring windowCaption, Window parent, uint flags, uint width, uint height)
    {
        assert(window is null);

        window = new BearLibWindow(windowCaption);

        return window;
    }

    void closeWindow(Window w)
    {
        assert(window !is null);

        w.close();
        window = null;
    }

    /**
    * Starts application message loop.
    *
    * When returned from this method, application is shutting down.
    */
    int enterMessageLoop()
    {
        do
        {
            if(BT.terminal.has_input)
            {
                const event = BT.terminal.read();

                Log.d("MessageLoop event = "~event.to!string);

                with(BT.terminal)
                switch(event)
                {
                    case keycode.close:
                        destroy(window);
                        Log.d("return 0");
                        return 0;

                    case keycode.resized:
                        Log.d("resize is unsupported");
                        return 1;

                    default:
                        break;
                }
            }
        }
        while(true);
    }

    dstring getClipboardText(bool mouseBuffer)
    {
        assert(false, "Isn't implemented");
    }

    void setClipboardText(dstring text, bool mouseBuffer)
    {
        assert(false, "Isn't implemented");
    }

    void requestLayout()
    {
        if(window !is null)
            window.requestLayout();
    }
}

class BearLibWindow : Window
{
    this(dstring caption)
    {
        BT.terminal.open(caption.to!string);
    }

    ~this()
    {
        close();
    }

    void draw()
    {
        //~ mainWidget.draw();
    }

    override:

    void close()
    {
        BT.terminal.close();
    }

    void show()
    {
        static bool firstCall = true;

        if(firstCall)
        {
            firstCall = false;

            invalidate();
        }

        {
            import dlangui.widgets.widget;

            if(mainWidget !is null)
            {
                Log.d("_mainWidget available");

                draw();
            }
        }
    }

    dstring windowCaption() @property
    {
        return BT.terminal.get("window.title", "default_value").to!dstring;
    }

    void windowCaption(dstring caption) @property
    {
        BT.terminal.setf("window.title=%s", caption);
    }

    void windowIcon(DrawBufRef icon) @property
    {
        assert(false, "Isn't implemented");
    }

    void invalidate()
    {
        BT.terminal.refresh();
    }

    void requestLayout()
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
