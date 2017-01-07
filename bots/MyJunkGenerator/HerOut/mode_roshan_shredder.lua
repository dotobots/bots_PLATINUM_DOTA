-------
require( GetScriptDirectory().."/mode_roshan_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_roshan.OnStart();
end

function OnEnd()
	mode_generic_roshan.OnEnd();
end

function GetDesire()
	return mode_generic_roshan.GetDesire();
end

function Think()
	mode_generic_roshan.Think();
end

--------
