import dlangui;

mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args)
{
    // create window
    Window window = Platform.instance.createWindow("My Window", null);

    window.mainWidget = new VerticalLayout();
    //~ window.mainWidget = new HorizontalLayout();

    // create some widget to show in window
    auto someText = new TextWidget(null, "Hello world"d);
    someText.textColor(0xFF0000); // red text

    window.mainWidget.addChild = someText;
    window.mainWidget.addChild = new EditLine(null, "Some text for parameter 1"d);

    auto btn2 = (new Button).text("Button 2"d);

    btn2.click =
        delegate(Widget w)
        {
            Log.i("Button click!");
            return true;
        };

    window.mainWidget.addChild = btn2;

    {
        VerticalLayout col2 = new VerticalLayout();
        GroupBox gb31 = new GroupBox("switches", "SwitchButton"d, Orientation.Vertical);
        gb31.addChild(new SwitchButton("sb1"));
        gb31.addChild(new SwitchButton("sb2").checked(true));
        gb31.addChild(new SwitchButton("sb3").enabled(false));
        gb31.addChild(new SwitchButton("sb4").enabled(false).checked(true));
        col2.addChild(gb31);
        window.mainWidget.addChild(col2);
    }

    //~ window.mainWidget.measure(SIZE_UNSPECIFIED, SIZE_UNSPECIFIED);

    //~ window.requestLayout();

    window.show();

    Log.d(window.width);
    Log.d(window.height);

    Log.d(window.mainWidget.measuredWidth);
    Log.d(window.mainWidget.measuredHeight);

    Log.d(window.mainWidget.width);
    Log.d(window.mainWidget.height);

    Log.d(window.mainWidget.left);
    Log.d(window.mainWidget.top);

    // run message loop
    return Platform.instance.enterMessageLoop();
}
