local M = {}
local json = require("json")

function M.saveTable(theTable, filename, location)
    if location == nil then location = system.DocumentsDirectory; end
    local path = system.pathForFile( filename, location)
    local file = io.open(path, "w")
    if file then
        local contents = json.encode(theTable)
        file:write( contents )
        io.close( file )
        return true
    else
        return false
    end
end
 
function M.loadTable(filename, location)
    if location == nil then location = system.DocumentsDirectory; end
    local path = system.pathForFile( filename, location)
    local contents = ""
    local myTable = {}
    local file = io.open( path, "r" )
    if file then
        -- read all contents of file into a string
        local contents = file:read( "*a" )
        myTable = json.decode(contents);
        io.close( file )
        return myTable
    end
    return nil
end

return M