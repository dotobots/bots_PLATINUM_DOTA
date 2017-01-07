-------
require( GetScriptDirectory().."/mode_laning_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_laning.OnStart();
end

function OnEnd()
	mode_generic_laning.OnEnd();
end

function GetDesire()
	return mode_generic_laning.GetDesire();
end

function Think()
	mode_generic_laning.Think();
end

--------
