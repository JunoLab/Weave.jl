# # to update `themes`
# let
#     using HTTP, JSON
#     r = HTTP.request("GET", "https://bootswatch.com/api/4.json") |> HTTP.payload |> String |> JSON.parse
#     lowercase.(get.(values(r["themes"]), "name", "")) |> repr |> clipboard
# end

bootswatch_version = "4"
themes = ["cerulean", "cosmo", "cyborg", "darkly", "flatly", "journal", "litera", "lumen", "lux", "materia", "minty", "pulse", "sandstone", "simplex", "sketchy", "slate", "solar", "spacelab", "superhero", "united", "yeti"]
targets = ["bootstrap.min.css", "_bootswatch.scss", "_variables.scss"]

BOOTSWATCH_DIR = normpath(@__DIR__, "..", "stylesheets", "bootswatch")
isdir(BOOTSWATCH_DIR) || mkdir(BOOTSWATCH_DIR)

function download_theme(theme)
    theme_dir = normpath(BOOTSWATCH_DIR, theme)
    isdir(theme_dir) || mkdir(theme_dir)
    for target in targets
        file = normpath(theme_dir, target)
        isfile(file) || download("https://bootswatch.com/$(bootswatch_version)/$(theme)/$(target)", file)
    end
end

download_theme.(themes)
