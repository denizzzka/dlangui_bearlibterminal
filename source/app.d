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

    private void processMouseEvent(BT.terminal.keycode event)
    {
        if(!(event >= 0x80 && event <= 0x8C)) // This is not mouse event?
            return;

        Log.d("Mouse event "~event.to!string);

        int x = BT.terminal.state(BT.terminal.keycode.mouse_x);
        int y = BT.terminal.state(BT.terminal.keycode.mouse_y);

        MouseEvent dme; // Dlangui Mouse Event

        with(BT.terminal.keycode)
        switch(event)
        {
            case mouse_left:
                dme = new MouseEvent(MouseAction.ButtonUp, MouseButton.Left, 0, x, y);
                break;

            //~ case mouse_right:

            //~ mouse_middle = 0x82,
            //~ mouse_x1 = 0x83,
            //~ mouse_x2 = 0x84,
            //~ mouse_move = 0x85 /* Movement event */,
            //~ mouse_scroll = 0x86 /* Mouse scroll event */,
            //~ mouse_x = 0x87 /* Cusor position in cells */,
            //~ mouse_y = 0x88,
            //~ mouse_pixel_x = 0x89 /* Cursor position in pixels */,
            //~ mouse_pixel_y = 0x8A,
            //~ mouse_wheel = 0x8B /* Scroll direction and amount */,
            //~ mouse_clicks = 0x8C /* Number of consecutive clicks */,

            default:
                assert(false, "Mouse event isn't supported: "~event.to!string);
        }

        window.dispatchMouseEvent(dme);
    }

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
                        window.updateDlanguiWindowSize();
                        window.show();
                        break;

                    default:
                        // If here is some mouse event it will be processed here:
                        processMouseEvent(event);
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

        BT.terminal.open(caption.to!string);
        BT.terminal.set("window.resizeable=true");

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
        with(BT.terminal)
        {
            onResize(
                BT.terminal.state(keycode.width),
                BT.terminal.state(keycode.height)
            );
        }
    }

    private void redraw()
    {
        import dlangui_bearlibterminal.drawbuf;

        BT.terminal.clear();

        BearLibDrawBuf buf = new BearLibDrawBuf(width, height);

        onDraw(buf);

        BT.terminal.refresh();

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

                redraw();
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
}

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args)
{
    // embed resources into executable
    embeddedResourceList.addResources(embedResourcesFromList!("console_standard_resources.list")());

    // create window
    Window window = Platform.instance.createWindow("My Window", null);

    //~ window.mainWidget = new VerticalLayout();
    window.mainWidget = new HorizontalLayout();

    // create some widget to show in window
    auto someText = new TextWidget(null, "Hello world"d);
    someText.textColor(0xFF0000); // red text

    window.mainWidget.addChild = someText;
    window.mainWidget.addChild = new TextWidget(null, "Second"d);
    window.mainWidget.addChild = new TextWidget(null, "Три"d);
    window.mainWidget.addChild = new TextWidget(null, "НЕЧТО ДЛИННОЕ ПРЕДЛИННОЕ"d);
    window.mainWidget.addChild = new TextWidget(null, "Покороче"d);
    window.mainWidget.addChild = (new Button).text("Some button"d);

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
