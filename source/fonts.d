module dlangui_bearlibterminal.fonts;

import dlangui;

class BearLibFontManager : FontManager
{
    private static FontRef font;

    static this()
    {
        font = new BearLibFont;
    }

    override:

    ref FontRef getFont(int size, int weight, bool italic, FontFamily family, string face)
    {
        return font;
    }

    void checkpoint()
    {
        assert(false, "Isn't implemented");
    }

    void cleanup()
    {
        assert(false, "Isn't implemented");
    }
}

class BearLibFont : Font
{
    private Glyph _glyph;

    this() {
        _spaceWidth = 1;
        _glyph.blackBoxX = 1;
        _glyph.blackBoxY = 1;
        _glyph.widthPixels = 1;
        _glyph.widthScaled = 1 << 6;
        _glyph.originX = 0;
        _glyph.originY = 0;
        _glyph.subpixelMode = SubpixelRenderingMode.None;
        _glyph.glyph = [0];
    }

    private static bool isHotkeySymbol(in dchar c, uint textFlags)
    {
        return c == '&' && (textFlags & (
                TextFlag.UnderlineHotKeys |
                TextFlag.HotKeys |
                TextFlag.UnderlineHotKeysWhenAltPressed
            ));
    }

    override:

    int size() @property { return 1; }
    int height() @property { return 1; }
    int weight() @property { return 400; }
    int baseline() @property { return 0; }
    bool italic() @property { return false; }
    string face() @property { return "console"; }
    FontFamily family() @property { return FontFamily.MonoSpace; }
    bool isNull() @property { return false; }
    void checkpoint() {} /// clear usage flags for all entries
    void cleanup() {} /// removes entries not used after last call of checkpoint() or cleanup()
    void clearGlyphCache() {}

    Glyph* getCharGlyph(dchar ch, bool withImage)
    {
        return &_glyph;
    }

    import BearLibTerminal: BT = terminal;

    //TODO: use tabSize and tabOffset for printing
    void drawText(DrawBuf drawBuf, int x, int y, in dchar[] text, uint argb_color, int tabSize, int tabOffset, uint textFlags)
    {
        import dlangui_bearlibterminal.drawbuf: BearLibDrawBuf;

        const bool defaultUnderline = (textFlags & TextFlag.Underline) != 0;
        bool underline = defaultUnderline;

        foreach(dchar c; text)
        {
            if(isHotkeySymbol(c, textFlags))
            {
                underline = true;
            }
            else
            {
                auto buf = cast(BearLibDrawBuf) drawBuf;

                buf.drawCharWithEffects(x, y, c, underline, argb_color);

                underline = defaultUnderline;
                x++;
            }
        }
    }

    int measureText(const dchar[] text, ref int[] widths, int maxWidth, int tabSize, int tabOffset, uint textFlags)
    {
        int len;

        foreach(const c; text)
        {
            if(!isHotkeySymbol(c, textFlags))
                len++;
        }

        if(len > maxWidth)
            len = maxWidth;

        if(widths.length < len)
            widths.length = len;

        foreach(int i; 0 .. len)
            widths[i] = i+1;

        Log.v(__FUNCTION__~" len="~len.to!string~" widths="~widths.to!string);

        return len;
    }

    // FIXME
    Point measureMultilineText(const dchar[] text, int maxLines, int maxWidth, int tabSize, int tabOffset, uint textFlags)
    {
        auto dim = BT.measure(text.to!string);

        if(dim.width > maxWidth)
            dim.width = maxWidth;

        if(dim.height > maxLines)
            dim.height = maxLines;

        Point ret = {x: dim.width, y: dim.height};

        return ret;
    }
}
