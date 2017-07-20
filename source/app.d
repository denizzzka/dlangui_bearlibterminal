module dlangui_bearlibterminal.app;

import BearLibTerminal: BT = terminal;
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
        assert(w == window);
        assert(window !is null);

        w.close();
        destroy(w);

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
            if(BT.has_input)
            {
                auto event = BT.read();

                Log.d("MessageLoop event = "~event.to!string);

                with(BT)
                switch(event)
                {
                    case keycode.close:
                        destroy(window);
                        Log.d("return 0");
                        return 0;

                    case keycode.resized:
                        window.updateDlanguiWindowSize();
                        window.show();
                        break;

                    default:
                        import core.bitop: btr;
                        import dlangui_bearlibterminal.events;

                        const bool keyReleased = btr(cast(size_t*) &event, 8) != 0;

                        {
                            auto ke = convertKeyEvent(event, keyReleased);
                            if(ke !is null)
                                window.dispatchKeyEvent(ke);
                        }

                        {
                            auto me = convertMouseEvent(event, keyReleased);
                            if(me !is null)
                                window.dispatchMouseEvent(me);
                        }

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
        windowOrContentResizeMode = WindowOrContentResizeMode.shrinkWidgets;
        super();

        BT.open(caption.to!string);
        BT.set("window.resizeable=true");
        BT.set("input.filter={keyboard+, mouse+}");

        // set background color:
        {
            BT.bkcolor(backgroundColor);
            BT.clear();
            BT.refresh();
        }

        updateDlanguiWindowSize();

        //FIXME: why this is need here?
        updateWindowOrContentSize();
    }

    ~this()
    {
        close();
    }

    private void updateDlanguiWindowSize()
    {
        with(BT)
        {
            onResize(
                state(keycode.width),
                state(keycode.height)
            );
        }
    }

    private void redraw()
    {
        import dlangui_bearlibterminal.drawbuf;

        BT.clear();

        BearLibDrawBuf buf = new BearLibDrawBuf(width, height);

        onDraw(buf);

        BT.refresh();

        destroy(buf);
    }

    override:

    void close()
    {
        BT.close();
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

                redraw();
            }
        }
    }

    dstring windowCaption() @property
    {
        return BT.get("window.title", "default_value").to!dstring;
    }

    void windowCaption(dstring caption) @property
    {
        BT.setf("window.title=%s", caption);
    }

    void windowIcon(DrawBufRef icon) @property
    {
        assert(false, "Isn't implemented");
    }

    void invalidate()
    {
    }
}

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args)
{
    // embed resources into executable
    //~ embeddedResourceList.addResources(embedResourcesFromList!("bearlib_resources.list")());

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
