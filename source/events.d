module dlangui_bearlibterminal.events;

import BearLibTerminal: BT = terminal;
import dlangui;

KeyEvent convertKeyEvent(BT.keycode event, bool keyReleased)
{
    if(!(event >= 0x04 && event <= 0x72)) // This is not keyboard event? (key_released is ignored)
        return null;

    /// DlangUI keycode
    uint dk;

    with(BT)
    switch(event)
    {
        case keycode.left: dk = KeyCode.LEFT; break;
        case keycode.right: dk = KeyCode.RIGHT; break;
        case keycode.down: dk = KeyCode.DOWN; break;
        case keycode.up: dk = KeyCode.UP; break;
        case keycode.enter: dk = KeyCode.RETURN; break;
        case keycode.tab: dk = KeyCode.TAB; break;
        case keycode.space: dk = KeyCode.SPACE; break;
        case keycode.escape: dk = KeyCode.ESCAPE; break;
        case keycode.backspace: dk = KeyCode.BACK; break;
        case keycode.minus: dk = KeyCode.KEY_SUBTRACT; break;
        case keycode.equals: dk = KeyCode.EQUAL; break;
        case keycode.lbracket: dk = KeyCode.KEY_BRACKETOPEN; break;
        case keycode.rbracket: dk = KeyCode.KEY_BRACKETCLOSE; break;
        case keycode.backslash: dk = KeyCode.BACKSLASH; break;
        case keycode.semicolon: dk = KeyCode.SEMICOLON; break;
        case keycode.apostrophe: dk = KeyCode.QUOTE; break;
        case keycode.grave: dk = KeyCode.TILDE; break;
        case keycode.comma: dk = KeyCode.KEY_COMMA; break;
        case keycode.period: dk = KeyCode.KEY_PERIOD; break;
        case keycode.slash: dk = KeyCode.SLASH; break;
        case keycode.pause: dk = KeyCode.PAUSE; break;
        case keycode.insert: dk = KeyCode.INS; break;
        case keycode.home: dk = KeyCode.HOME; break;
        case keycode.end: dk = KeyCode.END; break;
        case keycode.pageup: dk = KeyCode.PAGEUP; break;
        case keycode.pagedown: dk = KeyCode.PAGEDOWN; break;
        case keycode.KP_divide: dk = KeyCode.DIV; break;
        case keycode.KP_multiply: dk = KeyCode.MUL; break;
        case keycode.KP_plus: dk = KeyCode.ADD; break;
        case keycode.KP_minus: dk = KeyCode.SUB; break;
        case keycode.kp_period: dk = KeyCode.DECIMAL; break;
        case keycode.KP_enter: dk = KeyCode.RETURN; break;
        case keycode.K_delete: dk = KeyCode.DEL; break;
        case keycode.K_0: dk = KeyCode.KEY_0; break;
        case keycode.KP_0: dk = KeyCode.NUM_0; break;

        default:
            int keytable_diff;

            if(event >= keycode.a && event <= keycode.z) // letters
                keytable_diff = KeyCode.KEY_A - keycode.a;
            else if(event >= keycode.K_1 && event <= keycode.K_9) // numbers
                keytable_diff = KeyCode.KEY_1 - keycode.K_1;
            else if(event >= keycode.KP_1 && event <= keycode.KP_9) // numpad numbers
                keytable_diff = KeyCode.NUM_1 - keycode.KP_1;
            else if(event >= keycode.F1 && event <= keycode.F12) // Fxx keys
                keytable_diff = KeyCode.F1 - keycode.F1;
            else
                return null;

            dk = event + keytable_diff;

            break;
    }

    KeyAction buttonDetails = keyReleased ? KeyAction.KeyUp : KeyAction.KeyDown;

    uint flags;

    with(BT)
    with(BT.keycode)
    {
        if(check(shift)) flags |= KeyFlag.Shift;
        if(check(ctrl)) flags |= KeyFlag.Control;
        if(check(alt)) flags |= KeyFlag.Alt;
    }

    /// "Dlangui Key Event"
    KeyEvent dke = new KeyEvent(buttonDetails, dk, flags, null);

    Log.v("Key event "~event.to!string~" converted to "~dke.toString);

    return dke;
}

MouseEvent convertMouseEvent(BT.keycode _event, bool keyReleased)
{
    if(!(_event >= 0x80 && _event <= 0x8C)) // This is not mouse event?
        return null;

    MouseButton btn;
    MouseAction btnDetails = keyReleased ? MouseAction.ButtonUp : MouseAction.ButtonDown;
    short wheelDelta = 0;

    with(BT.keycode)
    switch(_event)
    {
        case mouse_left: btn = MouseButton.Left; break;
        case mouse_right: btn = MouseButton.Right; break;
        case mouse_middle: btn = MouseButton.Middle; break;
        case mouse_x1: btn = MouseButton.XButton1; break;
        case mouse_x2: btn = MouseButton.XButton2; break;

        case mouse_scroll:
            btnDetails = MouseAction.Wheel;
            wheelDelta = BT.state(mouse_wheel).to!short;
            break;

        case mouse_move:
            btnDetails = MouseAction.Move;
            break;

        default:
            Log.w("Mouse event isn't supported: "~_event.to!string);
            return null;
    }

    ushort flags;

    with(BT)
    with(BT.keycode)
    {
        if(check(shift)) flags |= MouseFlag.Shift;
        if(check(ctrl)) flags |= MouseFlag.Control;
        if(check(alt)) flags |= MouseFlag.Alt;
    }

    short x_coord = BT.state(BT.keycode.mouse_x).to!short;
    short y_coord = BT.state(BT.keycode.mouse_y).to!short;

    /// "Dlangui Mouse Event"
    MouseEvent dme = new MouseEvent(btnDetails, btn, flags, x_coord, y_coord, wheelDelta);

    Log.v("Mouse event "~_event.to!string~" converted to "~dme.to!string, " wheelDelta="~dme.wheelDelta.to!string);

    return dme;
}
