Locales = {}
local locale = Config.Locale
function _(str, ...)  -- Translate string

	if Locales[locale] ~= nil then

		if Locales[locale][str] ~= nil then
			return string.format(Locales[locale][str], ...)
		else
			return '[' .. locale .. '][' .. str .. ']'
		end

	else
		return 'Locale [' .. locale .. '] does not exist'
	end

end

function _U(str, ...) -- Translate string first char uppercase
	return tostring(_(str, ...):gsub("^%l", string.upper))
end
