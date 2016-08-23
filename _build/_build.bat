del love.zip

7z.exe a love.zip "..\*"

7z.exe d love.zip "_build*"
7z.exe d love.zip "*.git*"

copy "C:\Program Files\LOVE\love.dll"     "love.dll"
copy "C:\Program Files\LOVE\lua51.dll"    "lua51.dll"
copy "C:\Program Files\LOVE\mpg123.dll"   "mpg123.dll"
copy "C:\Program Files\LOVE\OpenAL32.dll" "OpenAL32.dll"
copy "C:\Program Files\LOVE\SDL2.dll"     "SDL2.dll"

copy /b "C:\Program Files\LOVE\love.exe"+love.zip "StrawberryLetters-64bit.exe"

del love.zip

@pause
