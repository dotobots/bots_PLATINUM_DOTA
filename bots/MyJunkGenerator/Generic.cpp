//CREATED BY: PLATINUM_DOTA2 (Pooya J.)
//EMAIL: PLATINUM.DOTA2@GMAIL.COM

#include<iostream>
#include<fstream>
#include<string>
#include<vector>

using namespace std;

const int n=21;

string  fnames[n]= {
		"laning",
		"attack",
		"roam",
		"retreat",
		"secret_shop",
		"side_shop",
		"rune",
		"push_tower_top",
		"push_tower_mid",
		"push_tower_bot",
		"defend_tower_top",
		"defend_tower_mid",
		"defend_tower_bot",
		"assemble",
		"team_roam",
		"farm",
		"defend_ally",
		"evasive_maneuvers",
		"roshan",
		"item",
		"ward"};


void init()
{
	for (int i=0;i<n;i++)
	{
		string fname=".\\GenOut\\mode_"+fnames[i]+"_generic.lua";
		ofstream op;
		op.open(fname.c_str());
		op<<
"-------\n_G._savedEnv = getfenv()\nmodule( \"mode_generic_"+fnames[i]+"\", package.seeall )\n----------\nUtility = require( GetScriptDirectory()..\"/Utility\")\n----------\n\nfunction  OnStart()\nend\n\nfunction OnEnd()\nend\n\nfunction GetDesire()\n\treturn 0.0;\nend\n\nfunction Think()\nend\n\n--------\nfor k,v in pairs( mode_generic_"+fnames[i]+" ) do	_G._savedEnv[k] = v end\n";

		op.close();
	}
}

int main()
{
	init();

}

