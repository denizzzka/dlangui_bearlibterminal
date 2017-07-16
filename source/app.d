module dlangui_bearlibterminal.app;

static import BT = BearLibTerminal;
import dlangui;
import dlangui_bearlibterminal.fonts;

mixin APP_ENTRY_POINT;

extern(C) int DLANGUImain(string[] args) {
    initLogs();
    SCREEN_DPI = 10; // TODO: wtf?
    Platform.setInstance(new BearLibPlatform());
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

        updateWindowSize();
    }

    ~this()
    {
        close();
    }

    private void updateWindowSize()
    {
        with(BT.terminal)
        {
            _dx = BT.terminal.state(keycode.width);
            _dy = BT.terminal.state(keycode.height);
        }
    }

    private void draw()
    {
        import dlangui_bearlibterminal.drawbuf;

        //~ BT.terminal.clear();

        BearLibDrawBuf buf = new BearLibDrawBuf(this);

        mainWidget.onDraw(buf);

        destroy(buf);
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

            BT.terminal.refresh();
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
}

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args)
{
    // create window
    Window window = Platform.instance.createWindow("My Window", null);

    auto l = new VerticalLayout();
    l.margins(3);
    l.padding(3);

    // create some widget to show in window
    l.addChild = new TextWidget(null, "Hello world"d).margins(2).textColor(0xFF0000); // red text
    l.addChild = new TextWidget(null, "Second"d).margins(2);

    window.mainWidget = l;

    // show window
    window.show();

    // run message loop
    return Platform.instance.enterMessageLoop();
}
