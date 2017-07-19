module dlangui_bearlibterminal.events;

import BearLibTerminal: BT = terminal;
import dlangui;

package:

KeyEvent getKeyEvent(BT.keycode event, bool keyReleased)
{
    if(!(event >= 0x04 && event <= 0x72)) // This is not keyboard event? (key_released is ignored)
        return;

    /// DlangUI keycode
    uint dKeyCode;

    with(BT)
    switch(event)
    {
        case keycode.left:
            dKeyCode = KeyCode.LEFT;
            break;

        case keycode.right:
            dKeyCode = KeyCode.RIGHT;
            break;

        case keycode.down:
            dKeyCode = KeyCode.DOWN;
            break;

        case keycode.up:
            dKeyCode = KeyCode.UP;
            break;

        case keycode.enter:
            dKeyCode = KeyCode.RETURN;
            break;

        case keycode.tab:
            dKeyCode = KeyCode.TAB;
            break;

        case keycode.space:
            dKeyCode = KeyCode.SPACE;
            break;

        case keycode.K_0:
            dKeyCode = KeyCode.KEY_0;
            break;

        default:
            int keytable_diff;

            if(event >= keycode.a && event <= keycode.z) // letters
                keytable_diff = KeyCode.KEY_A - keycode.a;
            else if(event >= keycode.K_1 && event <= keycode.K_9) // numbers
                keytable_diff = KeyCode.KEY_1 - keycode.K_1;
            else
                return;

            dKeyCode = event + keytable_diff;

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
    KeyEvent dke = new KeyEvent(buttonDetails, dKeyCode, flags, null);

    Log.d("Key event "~event.to!string~" converted to "~dke.toString);

    return dke;
}

MouseEvent getMouseEvent(BT.keycode _event, bool keyReleased)
{
    if(!(_event >= 0x80 && _event <= 0x8C)) // This is not mouse event?
        return;

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
            return;
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
