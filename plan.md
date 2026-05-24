I have:
  - the ModEngine2 project on "/mnt/storage/launchers/mod_engine_2/"
  - Game Dark Souls 3 on Steam "/mnt/storage/SteamLibrary/steamapps/common/DARK SOULS III/"
  - Im on Bazzite
  - The program will run on Windows in later update's.
  - It will support Elden Ring later


This will be a GUI managing the mods on the mod_engine_2 folder just like the .toml files.
the comand on steam is:
`bash -c 'cd "/mnt/storage/launchers/mod_engine_2" && exec "${@:1:$(($#-1))}" "/mnt/storage/launchers/mod_engine_2/modengine2_launcher.exe" -t ds3 -c config_darksouls3.toml' -- %command%`
we wont define the comand now

Wanna change that for the this project/program, so it will act like a wrapper when launching on steam.
It will open a UI using material ui style (default for flutter)
Just in the toml files:
  - CRUD for the mods/folders.
  - Create:
    - Will ask for name of the mod, it will slugfy in snake case that name.
    - Name shall be uniqu since the mod foldeers will be as well.
    - It should have a validation showing if the name is available.
  - Create and Update:
    - User must have the option to import files.
    - Should have a hint with the button to the user to move the files from the mod after extracted to this folder.
    - Path's for thee mods shall be saved using relative path.
  - Read:
    - The folders shall be listed as Mods.
    - Empty folders shall have a warning to the user
    - Empty fodlers cant be selected
  - Delete:
    - Ask for confirmation to delete the mod's folder.
  - It shall edit the game_name.toml (gam_name will b replaced with th selcted game, which currntly will be only dark_souls_3 mak the fil name to be dark_souls_3.toml)
  - [modengine] section from toml:
    - debug option warning it only for developers.
    - external_dlls list:
      - user can select the file he wants from inside the any of th mods folders
      - user can dit their order with drag annd drog
      - the order will affect the order the lines are written in the .toml file
  - [extension.mod_loader] section from toml:
    - enabled option (booleean)
    - loose_params option (booleean)
    - mods: where is where the mods list go, the current main point of this project
      - forgot to say they must have a follow the structure: { enabled = true, name ="default", path = "mod" } when saving the file
  - always when launch update the file timestamp
  - when opening the app it will fetch the last toml file edited.
  - in case the toml does not exist consider this content:
    ```
    [modengine]
    debug = false
    external_dlls = []

    [extension.mod_loader]
    enabled = true
    loose_params = false
    mods = [
        { enabled = true, name ="default", path = "mod" }
    ]

    [extension.scylla_hide]
    enabled = false
    ```
