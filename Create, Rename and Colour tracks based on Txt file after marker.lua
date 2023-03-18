--[[
 * ReaScript Name: Import tracks from file after "***"
 * About: Import tracks from a TXT or CSV file, starting after "***". One track name per line.
 * Instructions: Select an item. Use it.
 * Screenshot: http://i.giphy.com/3oEduTrQlzj80oPpWE.gif
 * Author: X-Raym, adapted by ChatGPT
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Import track titles from file (eg: CSV)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1564559
 * REAPER: 5.0 pre 36
 * Version: 1.0
]]


--[[
 * Changelog:
 * v1.0 (2023-03-18)
  + Initial Release
]]

--[[
 * Dependent on having a txt fil that can have anything above the list so long as the list begins with "***" as a marker for where the parse begins. 

]]
function Msg(variable)
  reaper.ShowConsoleMsg(tostring(variable).."\n")
end

----------------------------------------------------------------------

function read_lines(filepath)

  reaper.Undo_BeginBlock() -- Begin undo group

  local f = io.input(filepath)
  local skip = true -- start by skipping lines until "***" is found
  repeat

    s = f:read ("*l") -- read one line

    if s then  -- if not end of file (EOF)

      if skip and s:find("***") then
        skip = false
      elseif not skip then
        count_tracks = reaper.CountTracks(0)

        i = 0

        last_track_id = count_tracks + i
        reaper.InsertTrackAtIndex(last_track_id, true)
        last_track = reaper.GetTrack(0, last_track_id)

        retval, track_name = reaper.GetSetMediaTrackInfo_String(last_track, "P_NAME", s, true)
        reaper.SetTrackColor(last_track, reaper.ColorToNative(math.random(0,255), math.random(0,255), math.random(0,255)) )
      
      end

    end

  until not s  -- until end of file

  f:close()

  reaper.Undo_EndBlock("Display script infos in the console", -1) -- End undo group

end



-- START -----------------------------------------------------
local retval, filetxt = reaper.GetUserFileNameForRead("", "Import tracks from file", "txt")

if retval then

  reaper.PreventUIRefresh(1)
  read_lines(filetxt)

  -- Update TCP
  reaper.TrackList_AdjustWindows(false)
  reaper.UpdateTimeline()

  reaper.UpdateArrange()
  reaper.PreventUIRefresh(-1)

end

