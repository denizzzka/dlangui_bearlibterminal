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

    void printText(int x, int y, uint argb_color, string text)
    {
        BT.color(argb_color.toColor);
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

    /// fill rectangle with solid color (clipping is applied)
    void fillRect(Rect rc, uint color)
    {
        uint alpha = color >> 24;

        if (alpha >= 128)
            return; // transparent

        BT.bkcolor(color);
        BT.clear_area(rc.left, rc.top, rc.width, rc.height);
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

package:

static import BearLibTerminal;

BearLibTerminal.color_t toColor(uint fromColor) pure
{
    return fromColor ^ 0xFF_00_00_00;
}
