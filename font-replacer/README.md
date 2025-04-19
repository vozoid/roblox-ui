requires https://github.com/rojo-rbx/rokit or https://github.com/lune-org/lune to run

for use with linux (tested on mint) replace the line 

```print(`Found latest studio version {latestStudioVersionPath:gsub(process.args[1], "%%USERPROFILE%%")}\n`)```

with

```print(`Found latest studio version {latestStudioVersionPath}\n`)```

and the line

```local VERSIONS_PATH = `{process.args[1]}/AppData/Local/Roblox/Versions```

with

```local VERSIONS_PATH = "/home/(YOUR USERNAME HERE)/.var/app/org.vinegarhq.Vinegar/data/vinegar/versions"```
