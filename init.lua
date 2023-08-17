futil.check_version({ year = 2023, month = 8, day = 17 })
persistent_monoids.check_version({ year = 2023, month = 3, day = 19 })

status_effects = fmod.create()

status_effects.dofile("util")

status_effects.dofile("status_effect")
status_effects.dofile("api")
status_effects.dofile("callbacks")
status_effects.dofile("globalstep")
status_effects.dofile("hud")

status_effects.dofile("folds")
status_effects.dofile("hud_lines")
