-------
require( GetScriptDirectory().."/mode_attack_generic" )
Utility = require(GetScriptDirectory().."/Utility")
----------

function OnStart()
	mode_generic_attack.OnStart();
end

function OnEnd()
	mode_generic_attack.OnEnd();
end

function GetDesire()
	return mode_generic_attack.GetDesire();
end

function Think()
	mode_generic_attack.Think();
end

--------
