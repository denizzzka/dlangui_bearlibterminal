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
        _glyph.width = 0;
        _glyph.originX = 0;
        _glyph.originY = 0;
        _glyph.subpixelMode = SubpixelRenderingMode.None;
        _glyph.glyph = [0];
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

    static import BT = BearLibTerminal;

    void drawText(DrawBuf drawBuf, int x, int y, const dchar[] text, uint color, int tabSize, int tabOffset, uint textFlags)
    {
        import dlangui_bearlibterminal.drawbuf: BearLibDrawBuf;

        auto buf = cast(BearLibDrawBuf) drawBuf;

        buf.printText(x, y, text.to!string);
    }

    int measureText(const dchar[] text, ref int[] widths, int maxWidth, int tabSize, int tabOffset, uint textFlags)
    {
        int w = BT.terminal.measure(text.to!string).width;

        if(w > maxWidth)
            w = maxWidth;

        widths ~= w;

        Log.d(__FUNCTION__~"="~w.to!string);

        return w;
    }

    Point measureMultilineText(const dchar[] text, int maxLines, int maxWidth, int tabSize, int tabOffset, uint textFlags)
    {
        assert(false, __FUNCTION__~" isn't implemented");
    }
}
