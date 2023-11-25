local genisys = require("genisys")

local game = genisys.create_application("game")

game.name = "Invictvs Game Jam 2023"
game.version = "0.0.69"
game.description = [[Our awesome game.]]

local exe = game:create_process()
exe.command = { genisys.get_path("Invictvs Game Jam 2023.x86_64"), "--rendering-driver", "opengl3" }

return game