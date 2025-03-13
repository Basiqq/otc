setDefaultTab("Tools")

UI.Button("FPS 25", function()
    modules.client_options.setOption("backgroundFrameRate", 25)
end)

UI.Button("FPS 165", function()
    modules.client_options.setOption("backgroundFrameRate", 165)
end)
