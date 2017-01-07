-------
require( GetScriptDirectory().."/mode_push_tower_mid_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_push_tower_mid.OnStart();
end

function OnEnd()
	mode_generic_push_tower_mid.OnEnd();
end

function GetDesire()
	return mode_generic_push_tower_mid.GetDesire();
end

function Think()
	mode_generic_push_tower_mid.Think();
end

--------
