# edit_distance

This project is a programming project for a school assignment. (Details removed for public consumption)
by Jamie Lambrecht

The code in ./lib/main.dart is free software licensed under GPLv2.
See COPYING file for details.

## Getting Started

INSTALLING FLUTTER SDK:
"For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference."

Flutter is designed to compile to a native application for all supported platforms Android, iOS, Windows (Win32 support is in beta, while UWP is alpha/dev), MacOS, Linux as well as web browsers Edge and Chrome.

NOTE: The following description was written for the assignment submission. The GitHub repository does not contain the precompiled package or the "repo" directory. The repository itself is the "repo" directory.

When Flutter is installed and configured, the program can be run using the "flutter run" command from a command prompt / terminal with the root of the repository folder as the current working directory. If there are build errors due to a pre-existing C-Make cache file, use the "flutter clean" command. The CLI will present the user with all detected "devices" that are enabled in Flutter, including web browsers. If native support for Windows is not enabled, using the Edge browser or Chrome will work just fine. In the original assignment submission, a Windows binary package including Microsoft VC++ redistributable library files can be found in the "program" folder which resides in the directory that also contains the "repo" folder. The main source code for the program is found in "../repo/lib/main.dart". The primary logic for the dynamic edit distance and alignment algorithms are both found in the "setState" subroutine of the "_calcEditDistance" function. Flutter uses a declarative UI format which does not use "setters and getters", so there are UI elements being built in the same logic as where the contents of the tables/etc are being calculated. My experience with declarative UI is very limited, so it may be a bit messier than it should be. I tried to name the variables in a way that at least makes it fairly clear what the purpose of each object is.