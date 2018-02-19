DSMapParser
===========
Parse your .map-file to find units that bloat your application.

![DSMapParser](https://delphi-sucks.com/wp-content/uploads/2018/02/DSMapParser.png)

Installation
------------
Download the latest [Release](https://github.com/delphi-sucks/DSMapParser/releases) and extract it.

Requirements for compiling
--------------------------
You need to have [VirtualTreeView](https://github.com/Virtual-TreeView/Virtual-TreeView) installed to compile it.

Usage
-----
Before you can actually use the map-parser you probably need to adjust some settings in your project to generate a map-file:

* Go to your project options: Project > Options
* Navigate to “Delphi-Compiler > Linking”
* Change the setting “Map-File” to “Segments”

Ensure that you have changed the options in your corresponding release-configuration.

After changing these settings your compiler creates beside your .exe-file also a .map-file, which can be used by the Map-Parser.

Author
------
- Sebastian | [Github](https://github.com/delphi-sucks) | <sebastian@delphi-sucks.com> | [Delphi-sucks.com](https://www.delphi-sucks.com/)

License
-------
DSMapParser is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.