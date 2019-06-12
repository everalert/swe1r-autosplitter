/*
	Star Wars Episode I Racer (PC) Autosplitter v0.4.2

	features
	- auto start on file open
	- auto reset at file select
	- auto split on crossing finish line based on race placement
	  - option to toggle regular or 100% race win conditions
	- load time removal (use livesplit "game time")
	  - option to use experimental, potentially more robus load time removal method
	- toggle for in-game race time as livesplit "game time" 
	- dynamically update timer refresh rate to sync with in-game frametime
	- displayable variables for use with ASL Var Viewer
	  - total race in-game time
	  - current race in-game time
	  - overheat count
	  - underheat count
	  - underheat timer (excl. start of race)
	  - underheat full timer (all time spent fully cooled)
	  - death count

	to display custom variables in livesplit
	- update this autosplitter script, then get this component and add it to your layout: https://github.com/hawkerm/LiveSplit.ASLVarViewer/releases
	- in the component settings
	  - choose "variables" in the "value" section
	  - select any value beginning with "viewable" 
	
	future
	- confirm effectiveness of new load time removal
	- real time no loads as displayable variable
	- option to remove death-related undercooling from undercool counter and timer
	- cd version support?
*/

state("SWEP1RCR")
{
	float raceTime : 0xD78A4, 0x74;
	byte racePos : 0xD78A4, 0x5C;
	byte podFlags2 : 0xD78A4, 0x84, 0x61;
	byte podFlags3 : 0xD78A4, 0x84, 0x62;
	byte podFlags8 : 0xD78A4, 0x84, 0x67;
	float podHeat : 0xD78A4, 0x84, 0x218;
	//byte56 savedataRanks : 0xA35A8A;
	byte selTrk : 0xBFDB8, 0x5D;
	//byte selCct : 0xBFDB8, 0x5E;
	//byte selPod : 0xBFDB8, 0x73;
	byte inRace : 0xA9BB81;
	//byte inTournament : 0x10C450; //1=tourney,0=freeplay
	int frmCnt: 0xA22A30;
	double frmLen: 0xA22A40;
	short sceneId : 0xA9BA62;
	byte hwndFoc : 0xB9544, 0x16C340; // (0x020000->0x18C340) not thoroughly tested, possibility that goal address is not only written on focus change, and that ad hoc fake pointer path is not static
	string17 menTxt1 : 0xA2C380;
}

startup
{
	settings.Add("ASset",true,"Autosplitter Settings");
	  settings.Add("useReqWin",false,"Require 1st place","ASset");
	  settings.SetToolTip("useReqWin","e.g. for 100%; turning off will require 3rd for SMR/BB/BEC and otherwise 4th.");
	  settings.Add("useRTNL",true,"Load screens not timed","ASset");
	  settings.SetToolTip("useRTNL","Display Real-Time without loads as LiveSplit 'game time' instead of in-game race times.");
	    settings.Add("useExRTNL",false,"Use experimental load removal method","useRTNL");
	    settings.SetToolTip("useExRTNL","Attempt to account for game window focus when calculating RT No Loads (not thoroughly tested).");
	settings.Add("ASLVV",true,"Viewable Information");
	  settings.Add("tglUHT",false,"Underheat time only counted after first race boost","ASLVV");
	  settings.SetToolTip("tglUHT","If disabled, timer starts from the first time you are able to charge boost plus 1 second.");
	//settings.Add("tglUHD",false,"Underheat metrics count deaths","ASLVV");
	//settings.SetToolTip("tglUHD","Underheat Counter and Underheat Timer include instances of underheating while crashed or respawning.");
	//settings.Add("igtReal",true,"Load time removal overwrites RT instead of IGT (allows recording both RT No Loads and real IGT at the expense of pure RT)");
	//settings.Add("reqFP",false,"Run is in Free Play");
	
	// variables for ASL Var Viewer
	vars.viewableRaceInGameTime = "0.000";
	vars.viewableTotalRaceInGameTime = "0.000";
	//vars.viewableRealTimeNoLoads = "-";
	vars.viewableOverheatCounter = "-";
	vars.viewableUnderheatCounter = "-";
	vars.viewableUnderheatTime = "0.000";
	vars.viewableUnderheatFullTime = "0.000";
	vars.viewableDeathCounter = "-";

	// config for ASLVV
	vars.fmtVRIGT = "s\\.fff";
	vars.fmtVTRIGT = "s\\.fff";
	vars.fmtVUHT = "s\\.fff";
	vars.fmtVUHFT = "s\\.fff";
	vars.vvOHC = 0;
	vars.vvUHC = 0;
	vars.vvUHTs = 3600;
	vars.vvUHTt = 0;
	vars.vvUHTrdy = false;
	vars.vvUHFTs = 3600;
	vars.vvUHFTt = 0;
	vars.vvDC = 0;
	
	// autosplitter-related
	vars.raceDone = 0;
	vars.winCond = 0;
	vars.gt = 0;
	vars.gtAdd = 0;
	vars.inRace = 0;
	refreshRate = 24; // starting point only, calculated on the fly to accommodate RTSS
}

update
{
	// autosplitter-related
	refreshRate = (1/current.frmLen>0)?1/current.frmLen:24;
	if (current.inRace==1 && old.inRace==0) {
		vars.inRace = 1;
		vars.viewableRaceInGameTime = "0.000";
		vars.vvUHTrdy = false;
		vars.vvUHTs = 3600;
		vars.vvUHFTs = 0;
	}
	
	// asl var viewer-related
	vars.vvDC = ((current.podFlags2&(1<<6))!=0 && (old.podFlags2&(1<<6))==0)?++vars.vvDC:vars.vvDC;
	vars.vvOHC = (vars.inRace==1 && current.podHeat==0 && old.podHeat>0 && (current.podFlags2&(1<<6))==0)?++vars.vvOHC:vars.vvOHC;
	if (vars.inRace==1 && (current.podFlags8&(1<<1))==0 && current.podHeat==100 && old.podHeat<100) {
		vars.vvUHTs = current.raceTime;
		vars.vvUHFTs = current.raceTime;
		++vars.vvUHC;
	}
	if (!vars.vvUHTrdy && vars.inRace==1 && (current.podFlags8&(1<<1))==0 && (current.podFlags3&(1<<5))!=0 && (old.podFlags3&(1<<5))==0) {
		vars.vvUHTrdy = true;
		if (!settings["tglUHT"]) {
			vars.vvUHTs = current.raceTime+1;
			//++vars.vvUHC;
		}
	}
	if ((vars.inRace==1 && current.podHeat<100 && old.podHeat==100) || ((current.podFlags8&(1<<1))!=0 && (old.podFlags8&(1<<1))==0) || (current.inRace==0 && old.inRace==1 && vars.inRace!=0)) {
		if (vars.vvUHTs<=current.raceTime) {
			vars.vvUHTt += (current.raceTime-vars.vvUHTs);
			vars.vvUHTs = 3600;
			vars.fmtVUHT = (vars.vvUHTt>3600)?"h\\:mm\\:ss\\.fff":((vars.vvUHTt>60)?"m\\:ss\\.fff":"s\\.fff");
		}
		if (vars.vvUHFTs<=current.raceTime) {
			vars.vvUHFTt += (current.raceTime-vars.vvUHFTs);
			vars.vvUHFTs = 3600;
			vars.fmtVUHFT = (vars.vvUHFTt>3600)?"h\\:mm\\:ss\\.fff":((vars.vvUHFTt>60)?"m\\:ss\\.fff":"s\\.fff");
		}
	}
	vars.viewableDeathCounter = (vars.vvDC>0)?vars.vvDC:"-";
	vars.viewableOverheatCounter = (vars.vvOHC>0)?vars.vvOHC:"-";
	vars.viewableUnderheatCounter = (vars.vvUHC>0)?vars.vvUHC:"-";
	vars.viewableUnderheatTime = TimeSpan.FromSeconds(vars.vvUHTt+((vars.vvUHTs<=current.raceTime)?current.raceTime-vars.vvUHTs:0)).ToString(vars.fmtVUHT);
	vars.viewableUnderheatFullTime = TimeSpan.FromSeconds(vars.vvUHFTt+((vars.vvUHFTs<=current.raceTime)?current.raceTime-vars.vvUHFTs:0)).ToString(vars.fmtVUHFT);
}

isLoading
{
	// replace IGT with RT No Loads based on setting
	if (settings["useRTNL"]) {
		if (settings["useExRTNL"]) {
			return (current.frmCnt==old.frmCnt && current.hwndFoc==16);
		} else {
			return (current.frmCnt == old.frmCnt);
		}
	} else {
		return true;
	}
}

gameTime
{
	vars.fmtVRIGT = (current.raceTime>60)?"m\\:ss\\.fff":"s\\.fff";
	vars.gtAdd = (vars.inRace==1&&(current.podFlags8&(1<<1))==0)?current.raceTime:0;
	vars.viewableRaceInGameTime = (vars.gtAdd>0)?TimeSpan.FromSeconds(vars.gtAdd).ToString(vars.fmtVRIGT):vars.viewableRaceInGameTime;
	if (((current.podFlags8&(1<<1))!=0 && (old.podFlags8&(1<<1))==0) || (current.inRace==0 && old.inRace==1 && vars.inRace!=0)) {
		vars.viewableRaceInGameTime = TimeSpan.FromSeconds(current.raceTime).ToString(vars.fmtVRIGT);
		vars.gt = vars.gt+current.raceTime;
		vars.gtAdd = 0;
		vars.inRace = 0;
	}
	vars.fmtVTRIGT = (vars.gt+vars.gtAdd>3600)?"h\\:mm\\:ss\\.fff":((vars.gt+vars.gtAdd>60)?"m\\:ss\\.fff":"s\\.fff");
	vars.viewableTotalRaceInGameTime = TimeSpan.FromSeconds(vars.gt+vars.gtAdd).ToString(vars.fmtVTRIGT);
	// only use real IGT when RT No Loads disabled
	if (!settings["useRTNL"]) {
		return TimeSpan.FromSeconds(vars.gt+vars.gtAdd);
	}
}

reset
{
	return (current.sceneId!=60 && current.menTxt1=="~F6Current Player");
}

split
{
	vars.raceDone = (((current.podFlags8 & (1 << 1))!=0) && ((old.podFlags8 & (1 << 1))==0));
	if (settings["useReqWin"]) {
		vars.winCond = (current.racePos==1);
	} else {
		vars.winCond = (current.selTrk==17||current.selTrk==8||current.selTrk==1)?(current.racePos<=3):(current.racePos<=4);
	}
	return (vars.raceDone && vars.winCond);
}

start
{
	// for ASL Var Viewer
	vars.viewableRaceInGameTime = "0.000";
	vars.viewableTotalRaceInGameTime = "0.000";
	//vars.viewableRealTimeNoLoads = "-";
	vars.viewableOverheatCounter = "-";
	vars.viewableUnderheatCounter = "-";
	vars.viewableUnderheatTime = "0.000";
	vars.viewableUnderheatFullTime = "0.000";
	vars.viewableDeathCounter = "-";
	vars.fmtVRIGT = "s\\.fff";
	vars.fmtVTRIGT = "s\\.fff";
	vars.fmtVUHT = "s\\.fff";
	vars.fmtVUHFT = "s\\.fff";
	vars.vvOHC = 0;
	vars.vvUHC = 0;
	vars.vvUHTs = 3600;
	vars.vvUHTt = 0;
	vars.vvUHTrdy = false;
	vars.vvUHFTs = 3600;
	vars.vvUHFTt = 0;
	vars.vvDC = 0;

	// autosplitter-related
	vars.gt = 0;
	vars.gtAdd = 0;
	vars.inRace = 0;

	return (current.sceneId==60);
}

/* tracks
	0	BTC
	16	MGS
	2	BWR
	6	AC
	22	M100
	19	Ven
	17	SMR
	7	SC
	3	HG
	23	DD
	9	SR
	18	ZC
	12	BC
	8	BB
	20	Exe
	24	SL
	13	GVG
	4	AMR
	10	DR
	14	FMR
	1	BEC
	5	APC
	11	Aby
	21	Gnt
	15	Inf
*/