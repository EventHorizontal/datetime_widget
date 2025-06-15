# DateTime Widget

A small desktop widget that displays the current date and time and uses minimal CPU. The widget can be interacted with via keyboard and allows resizing and adjusting of transparency so as to not be too obtrusive.

# Building from Source

This app can be built by exporting the project files using Godot 4.4. First clone the repository, either via the Github GUI or via the terminal using
```bash
git clone https://github.com/eventhorizontal/datetime_widget.git
```
Then import the project by navigating to the `project.godot` file in the repository and opening it in Godot. To export the binary, the appropriate export template has to be downloaded if not downloaded already. Then export the project in release mode.

# Usage

## Toggling Locked Mode
The widget opens in "locked mode", denoted via the lock symbol on the top right. This mode prevents the widget from being accidentlly closed via keyboard shortcuts (this was a usability issue in my experience). To toggle locked mode press `Ctrl+L`.
## Toggling Borderless Mode
The widget also opens in borderless mode. To toggle the window decorations, press `B`.

## Moving the Widget Around
The widget can be dragged around the screen with the mouse, but it can also be moved in a 3x3 grid on the screen by using the  arrow keys or the `hjkl` keys (for vim users).

## Changing Opacity
The opacity of the widget can be turned up via mouse wheel scroll up, `Shift+Up` or `Shift+Down`. Correspondingly its opacity can be turned down via mouse wheel scroll down, `Shift+Down` or `Shift+J`.

## Changing Size
The window size can be turned up or down via the keyboard using `Ctrl+.` (bigger) and `Ctrl+,` (smaller). Alternatively one may use the mouse to resize as usual in bordered mode.

> [!tip]
> If, like me, you'd like to have the widget open all the time, consider adding it to your startup applications.
