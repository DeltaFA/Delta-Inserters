for _, inserter in pairs(data.raw.inserter) do
	inserter.allow_custom_vectors = true
end

if settings.startup["inserter-config-remove-long-inserters"].value then
	log("Hiding long inserters")
	data.raw.recipe["long-handed-inserter"].hidden = true
end

if mods["Kux-SlimInserters"] then
	data.raw.recipe["long-slim-inserter"].hidden = true
	data.raw.recipe["long-double-slim-inserter"].hidden = true
end