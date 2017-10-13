import dlangui;

mixin APP_ENTRY_POINT;

/// entry point for dlangui based application
extern (C) int UIAppMain(string[] args)
{
    // create window
    Window window = Platform.instance.createWindow("My Window", null);

    Widget vl = new VerticalLayout();

    window.mainWidget = vl;

    vl.addChild = new GroupBox("groupbox", "GroupBox1");

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
