@echo off
"C:\\Users\\ketya\\AppData\\Local\\Android\\sdk\\cmake\\3.22.1\\bin\\cmake.exe" ^
  "-HC:\\Program Files\\flutter\\flutter\\packages\\flutter_tools\\gradle\\src\\main\\groovy" ^
  "-DCMAKE_SYSTEM_NAME=Android" ^
  "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" ^
  "-DCMAKE_SYSTEM_VERSION=21" ^
  "-DANDROID_PLATFORM=android-21" ^
  "-DANDROID_ABI=armeabi-v7a" ^
  "-DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a" ^
  "-DANDROID_NDK=C:\\Users\\ketya\\AppData\\Local\\Android\\sdk\\ndk\\21.4.7075529" ^
  "-DCMAKE_ANDROID_NDK=C:\\Users\\ketya\\AppData\\Local\\Android\\sdk\\ndk\\21.4.7075529" ^
  "-DCMAKE_TOOLCHAIN_FILE=C:\\Users\\ketya\\AppData\\Local\\Android\\sdk\\ndk\\21.4.7075529\\build\\cmake\\android.toolchain.cmake" ^
  "-DCMAKE_MAKE_PROGRAM=C:\\Users\\ketya\\AppData\\Local\\Android\\sdk\\cmake\\3.22.1\\bin\\ninja.exe" ^
  "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=C:\\Users\\ketya\\burakio_hackathon\\build\\app\\intermediates\\cxx\\Debug\\3p3it3l5\\obj\\armeabi-v7a" ^
  "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=C:\\Users\\ketya\\burakio_hackathon\\build\\app\\intermediates\\cxx\\Debug\\3p3it3l5\\obj\\armeabi-v7a" ^
  "-DCMAKE_BUILD_TYPE=Debug" ^
  "-BC:\\Users\\ketya\\burakio_hackathon\\android\\app\\.cxx\\Debug\\3p3it3l5\\armeabi-v7a" ^
  -GNinja ^
  -Wno-dev ^
  --no-warn-unused-cli
