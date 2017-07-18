module dlangui_bearlibterminal.drawbuf;

import BearLibTerminal: BT = terminal;
import dlangui;

class BearLibDrawBuf : DrawBuf
{
    private int _width;
    private int _height;

    this(int w, int h)
    {
        _width = w;
        _height = h;
    }

    void printText(int x, int y, string text)
    {
        Log.d(__FUNCTION__~": x="~x.to!string~" y="~y.to!string~" drawText="~text.to!string);

        BT.print(x, y, text);
    }

    override:

    @property int width() { return _width; }
    @property int height() { return _height; }

    void resize(int _width, int _height)
    {
        if(width == _width && width == _height)
            return;
        else
            assert(false, __FUNCTION__~": resizing isn't implemented");

        //~ _dx = width;
        //~ _dy = height;

        //~ resetClipping();
    }

    void fill(uint color)
    {
        assert(false, __FUNCTION__~" isn't implemented");
    }

    void fillRect(Rect rc, uint color)
    {
        assert(false, __FUNCTION__~" isn't implemented");
    }

    void drawPixel(int x, int y, uint color)
    {
        assert(false, __FUNCTION__~" isn't implemented");
    }

    void drawGlyph(int x, int y, Glyph* glyph, uint color)
    {
        assert(false, __FUNCTION__~" isn't implemented");
    }

    void drawFragment(int x, int y, DrawBuf src, Rect srcrect)
    {
        assert(false, __FUNCTION__~" isn't implemented");
    }

    void drawRescaled(Rect dstrect, DrawBuf src, Rect srcrect)
    {
        assert(false, __FUNCTION__~" isn't implemented");
    }
}
