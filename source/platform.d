module dlangui_bearlibterminal.platform;

import dlangui;
import dlangui.platforms.common.platform;

class BearLibPlatform : Platform
{
    import dlangui_bearlibterminal.window: BearLibWindow;
    import BearLibTerminal: BT = terminal;

    private BearLibWindow window;

    // In BT ecosystem keycode contains any type of event
    private bool dispatchBTEventToDlangui(in BT.keycode event)
    {
        import core.bitop: btr;
        import dlangui_bearlibterminal.events;

        const bool keyReleased = btr(cast(size_t*) &event, 8) != 0;

        bool eventCatched;

        {
            auto ke = convertKeyEvent(event, keyReleased);
            if(ke !is null)
                eventCatched = window.dispatchKeyEvent(ke);
        }

        {
            auto me = convertMouseEvent(event, keyReleased);
            if(me !is null)
                eventCatched = window.dispatchMouseEvent(me);
        }

        return eventCatched;
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
            auto event = BT.read();

            Log.v("MessageLoop event = "~event.to!string);

            with(BT)
            switch(event)
            {
                case keycode.close:
                    destroy(window);
                    Log.d("return 0");
                    return 0;

                case keycode.resized:
                    window.updateDlanguiWindowSize();
                    window.invalidate();
                    break;

                default:
                    if(dispatchBTEventToDlangui(event))
                        window.invalidate();

                    break;
            }

            if(BT.has_input == 0)
                window.redrawIfNeed();
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

    bool hasClipboardText(bool mouseBuffer)
    {
        assert(false, "Isn't implemented");
    }
}
