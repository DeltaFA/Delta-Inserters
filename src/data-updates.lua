for _, inserter in pairs(data.raw.inserter) do
	inserter.allow_custom_vectors = true
end

if settings.startup["inserter-config-remove-long-inserters"] then
	data.raw.recipe["long-handed-inserter"].hidden = true
	if mods["Kux-SlimInserters"] then
		data.raw.recipe["long-slim-inserter"].hidden = true
		data.raw.recipe["long-double-slim-inserter"].hidden = true
	end
end