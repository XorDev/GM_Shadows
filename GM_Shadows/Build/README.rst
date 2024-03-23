Build Instructions
-------------------

Build using cmake, ensuring the set the correct paramters poiting to the location of the tools and libraries requiored for building

Example:
---------

Debug:

`cmake -DYY_DEBUG_LIBS_DIR=C:/source/YoYoCompilerToolChain/build/Debug/lib -DTRIPLE_NAME=x86_64-pc-windows-msvc -DDEBUG=ON %1`

Release:

`cmake -DYY_RELEASE_LIBS_DIR=C:/source/YoYoCompilerToolChain/build/Release/lib -DTRIPLE_NAME=x86_64-pc-windows-msvc -DDEBUG=OFF %1`