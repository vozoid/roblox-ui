local process = require("@lune/process")
local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local serde = require("@lune/serde")

local weightValues = {
	Thin = 100,
	ExtraLight = 200,
	Light = 300,
	Regular = 400,
	Medium = 500,
	SemiBold = 600,
	Bold = 700,
	ExtraBold = 800,
	Heavy = 900,
}

local function findCurrentStudioVersion(versionsPath)
	assert(fs.isDir(versionsPath), "findCurrentStudioVersion - Given path doesn't exist")

	local latestTime = 0
	local versionsDir = fs.readDir(versionsPath)

	local latestStudioVersionPath

	for _, version in versionsDir do
		if not fs.isDir(`{versionsPath}/{version}/StudioFonts`) then
			continue
		end

		local metadata = fs.metadata(`{versionsPath}/{version}`)

		if metadata.createdAt.unixTimestamp > latestTime then
			latestTime = metadata.createdAt.unixTimestamp
			latestStudioVersionPath = `{versionsPath}/{version}`
		end
	end

	assert(latestStudioVersionPath, "findCurrentStudioVersion - Couldn't find latest studio version")

	stdio.write(stdio.color("blue"))
	print(`Found latest studio version {latestStudioVersionPath:gsub(process.args[1], "%%USERPROFILE%%")}\n`)
	stdio.write(stdio.color("reset"))

	return latestStudioVersionPath
end

local function generateFontFamily(font)
	local faces = {}
	local weights = {}

	local foundFace = false

	for _, face in fs.readDir("fonts") do
		if face:sub(1, font:len()) == font then
			foundFace = true
			weights[#weights + 1] = face

			local weight = if face:sub(1, -5) == font then "Regular" else face:sub(font:len() + 1):sub(1, -5)

			faces[#faces + 1] = {
				name = weight,
				weight = weightValues[weight],
				style = "normal", -- no italics heh...
				assetId = `rbxasset://fonts/{face}`,
			}
		end
	end

	assert(foundFace, `generateFontFamily - No faces found for font {font}`)

	return {
		name = font,
		faces = faces,
	}, weights
end

local function replaceVersionFonts(versionPath)
	local fonts = serde.decode("json", fs.readFile(`fonts.json`))

	for font, family in fonts do
		local newFamily, weights = generateFontFamily(font)

		stdio.write(stdio.color("yellow"))

		for _, weight in weights do
			fs.copy(`fonts/{weight}`, `{versionPath}/content/fonts/{weight}`, true)
			print(`Copied {weight} to content/fonts/{weight}`)
		end

		stdio.write(stdio.color("red"))

		fs.writeFile(`{versionPath}/content/fonts/families/{family}.json`, serde.encode("json", newFamily, true))
		print(`Replaced content/fonts/families/{family}.json with new {font} family\n`)
	end
end

local VERSIONS_PATH = `{process.args[1]}/AppData/Local/Roblox/Versions`
local latestStudioVersion = findCurrentStudioVersion(VERSIONS_PATH)

replaceVersionFonts(latestStudioVersion)

stdio.write(stdio.color("green"))

print("\nFinished replacing fonts\n\n")

stdio.write(stdio.color("reset"))
