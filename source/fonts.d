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

    void drawText(DrawBuf drawBuf, int x, int y, const dchar[] text, uint color, int tabSize, int tabOffset, uint textFlags)
    {
        Log.d("drawText="~text.to!string);
    }
}
