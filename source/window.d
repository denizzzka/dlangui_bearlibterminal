module dlangui_bearlibterminal.window;

import dlangui;

class BearLibWindow : Window
{
    import BearLibTerminal: BT = terminal;

    private bool needRedraw = true;

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

    package void updateDlanguiWindowSize()
    {
        with(BT)
        {
            onResize(
                state(keycode.width),
                state(keycode.height)
            );
        }
    }

    void redrawIfNeed()
    {
        import dlangui_bearlibterminal.drawbuf;

        if(needRedraw == true)
        {
            BT.clear();
            BearLibDrawBuf buf = new BearLibDrawBuf(width, height);
            onDraw(buf);
            BT.refresh();
            destroy(buf);

            needRedraw = false;
        }
    }

    override:

    void close()
    {
        BT.close();
    }

    /// Displays window at the first time
    void show()
    {
        import dlangui.widgets.widget;

        assert(needRedraw);

        if(mainWidget !is null)
            redrawIfNeed();
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
        needRedraw = true;
    }
}
