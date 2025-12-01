#!/usr/bin/env texlua

-- Identify the bundle and module
bundle = ""
module = "unibidi-lua"

stdengine    = "luatex"
checkengines = {"luatex"}
checkruns = 1
sourcefiles = {"*.opm", "*.sty", "*.lua", module .. ".tex"}
installfiles = sourcefiles
auxfiles = {"*.aux", "*.lof", "*.lot", "*.toc", '*.ref'}
docfiles = {module .. '-doc.pdf'}
textfiles = {"*.md", "COPYING"}
typesetexe = "optex"
typesetfiles = {module .. ".opm"}
ctanzip = module
tdsroot = "luatex"
packtdszip = true

checkconfigs = {
    "configfiles/config-optex",
    "configfiles/config-latex",
    "configfiles/config-plain",
    "configfiles/config-nil",
}

specialformats = specialformats or { }
specialformats.optex  = {luatex = {binary = "optex", format = ""}}
specialformats.plain  = {luatex = {binary = "luahbtex", format = ""}}

tdslocations =
  {
    "tex/optex/" .. module .. "/*.opm",
    "tex/lualatex/" .. module .. "/*.sty",
    "tex/luatex/" .. module .. "/*.tex",
    "tex/luatex/" .. module .. "/*.lua",
  }

specialtypesetting = specialtypesetting or {}
function optex_doc()
    local error_level = 0
    if not direxists('./build') then
        error_level = error_level + mkdir('./build')
    end
    if not direxists('./build/doc') then
        error_level = error_level + mkdir('./build/doc')
    end
    error_level = error_level + cp('*opm', '.', './build/doc')
    error_level = error_level + run('./build/doc', "optex -jobname " .. module .. "-doc '\\docgen " .. module .. "'")
    error_level = error_level + run('./build/doc', "optex -jobname " .. module .. "-doc '\\docgen " .. module .. "'")
    error_level = error_level + run('./build/doc', "optex -jobname " .. module .. "-doc '\\docgen " .. module .. "'")
    error_level = error_level + cp('*pdf', './build/doc', '.')
    return error_level
end
specialtypesetting[module .. ".opm"] = {func = optex_doc}

tagfiles = {"*.opm", "*.sty", "*.lua", module .. ".tex", "*.md"}
function update_tag(file,content,tagname,tagdate)
  if string.match(file, "%.opm$") then
    return string.gsub(content,
      "version {%d+%.%d+, %d%d%d%d%-%d%d%-%d%d",
      "version {" .. tagname .. ", " .. tagdate)
  elseif string.match(file, "%.lua$") then
    return string.gsub(content,
      "version   = %d+%.%d+, %d%d%d%d%-%d%d%-%d%d",
      "version   = " .. tagname .. ", " .. tagdate)
  elseif string.match(file, "%.sty$") then
    return string.gsub(content,
      "} %[%d%d%d%d%-%d%d%-%d%d v%d+%.%d+\n",
      "} [" .. tagdate .. " v" .. tagname .. "\n")
  elseif string.match(file, "%.tex$") then
    return string.gsub(content,
      "version %d+%.%d+, %d%d%d%d%-%d%d%-%d%d",
      "version " .. tagname .. ", " .. tagdate)
  elseif string.match(file, "%.md$") then
    return string.gsub(content,
      "version %d+%.%d+, %d%d%d%d%-%d%d%-%d%d",
      "version " .. tagname .. ", " .. tagdate)
  end
end

function pre_release()
    call({"."}, "tag")
    call({"."}, "ctan", {config = options['config']})
    run(".", "zip -d " .. module .. ".zip " .. module .. ".tds.zip")
    rm(".", "*.pdf")
end

target_list["prerelease"] = { func = pre_release, 
			desc = "update tags, generate pdfs, build zip for ctan"}
