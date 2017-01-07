-------
_G._savedEnv = getfenv()
module( "mode_generic_push_tower_bot", package.seeall )
----------
Utility = require( GetScriptDirectory().."/Utility")
----------

function  OnStart()
end

function OnEnd()
end

function GetDesire()
	return 0.0;
end

function Think()
end

--------
for k,v in pairs( mode_generic_push_tower_bot ) do	_G._savedEnv[k] = v end
