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
        case keycode.grave: break; /*  `  */
        case keycode.comma: dk = KeyCode.KEY_COMMA; break;
        case keycode.period: dk = KeyCode.KEY_PERIOD; break;
        case keycode.slash: dk = KeyCode.SLASH; break;
        case keycode.K_0: dk = KeyCode.KEY_0; break;

        default:
            int keytable_diff;

            if(event >= keycode.a && event <= keycode.z) // letters
                keytable_diff = KeyCode.KEY_A - keycode.a;
            else if(event >= keycode.K_1 && event <= keycode.K_9) // numbers
                keytable_diff = KeyCode.KEY_1 - keycode.K_1;
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

    Log.d("Key event "~event.to!string~" converted to "~dke.toString);

    return dke;
}

MouseEvent convertMouseEvent(BT.keycode _event, bool keyReleased)
{
    if(!(_event >= 0x80 && _event <= 0x8C)) // This is not mouse event?
        return null;

    MouseButton button;
    short wheelDelta = 0;

    with(BT.keycode)
    switch(_event)
    {
        case mouse_left:
            button = MouseButton.Left;
            break;

        case mouse_right:
            button = MouseButton.Right;
            break;

        case mouse_middle:
            button = MouseButton.Middle;
            break;

        case mouse_x1:
            button = MouseButton.XButton1;
            break;

        case mouse_x2:
            button = MouseButton.XButton2;
            break;

        case mouse_scroll:
            wheelDelta = BT.state(mouse_wheel).to!short;
            break;

        default:
            Log.d("Mouse event isn't supported: "~_event.to!string);
            return null;
    }

    MouseAction buttonDetails = keyReleased ? MouseAction.ButtonUp : MouseAction.ButtonDown;

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
    MouseEvent dme = new MouseEvent(buttonDetails, button, flags, x_coord, y_coord, wheelDelta);

    Log.d("Mouse event "~_event.to!string~" converted to "~dme.to!string, " wheelDelta="~dme.wheelDelta.to!string);

    return dme;
}
