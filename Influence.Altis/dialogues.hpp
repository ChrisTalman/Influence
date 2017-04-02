/*
Style Notes:
0.07 vertical gap between common menu buttons (absolute)
0.006 vertical gap between common menu buttons (safezone)
*/

class nwDialogueCommand
{
	idd = 1;
	movingenable = false;
	class controls
	{
		class nwCommandInterface: RscFrame
		{
			idc = 1000;
			text = "";
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.48 / 2);
			y = ABSOLUTE_Y + (ABSOLUTE_HEIGHT / 2) - (0.7 / 2);
			w = 0.48;
			h = 0.7;
		};
		class nwCommandInterfaceBackground: Box
		{
			idc = -1;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.48 / 2);
			y = ABSOLUTE_Y + (ABSOLUTE_HEIGHT / 2) - (0.7 / 2);
			w = 0.48;
			h = 0.7;
		};
		class nwCommandInterfaceTitle: RscText
		{
			idc = -1;
			text = "Command Menu";
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.48 / 2);
			y = ABSOLUTE_Y + (ABSOLUTE_HEIGHT / 2) - (0.7 / 2);
			w = 0.48;
			h = 0.06;
		};
		class nwCommandVoteButton: RscButton
		{
			idc = 1002;
			text = "Stand for Election to Commander";
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.44 / 2);
			y = ABSOLUTE_Y + (ABSOLUTE_HEIGHT / 2) - (0.7 / 2) + 0.06;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0; call functionStartGeneralElectionClient;";
		};
		class nwCommandBuildButton: RscButton
		{
			idc = 1003;
			text = "Build";
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.44 / 2);
			y = ABSOLUTE_Y + (ABSOLUTE_HEIGHT / 2) - (0.7 / 2) + 0.13;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0; call functionOpenBuildInterface;";
		};
		class nwCommandSupplyButton: RscButton
		{
			idc = 1004;
			text = "Supply";
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.44 / 2);
			y = ABSOLUTE_Y + (ABSOLUTE_HEIGHT / 2) - (0.7 / 2) + 0.2;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0; call functionOpenSupplyInterface;";
		};
		class nwCommandAuxiliaryButton: RscButton
		{
			idc = 1005;
			text = "Manage Roadblocks";
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.44 / 2);
			y = ABSOLUTE_Y + (ABSOLUTE_HEIGHT / 2) - (0.7 / 2) + 0.27;
			w = 0.44;
			h = 0.06;
			//action = "closeDialog 0; call functionOpenAuxiliaryInterface;";
			action = "closeDialog 0; call functionManageRoadblocks;";
		};
		class nwCommandBaseEstablishButton: RscButton
		{
			idc = 1006;
			text = "Establish New Base";
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.44 / 2);
			y = ABSOLUTE_Y + (ABSOLUTE_HEIGHT / 2) - (0.7 / 2) + 0.34;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0; call functionEstablishBaseClient;";
		};
		class nwCommandFOBEstablishButton: RscButton
		{
			idc = 1007;
			text = "Establish New FOB";
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.44 / 2);
			y = ABSOLUTE_Y + (ABSOLUTE_HEIGHT / 2) - (0.7 / 2) + 0.41;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0; call functionEstablishFOBClient;";
		};
		class provinceActivateButton: RscButton
		{
			idc = 1008;
			text = "Activate Province";
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.44 / 2);
			y = ABSOLUTE_Y + (ABSOLUTE_HEIGHT / 2) - (0.7 / 2) + 0.48;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0; call functionActivateProvinceClient;";
		};
		class manageObjectives: RscButton
		{
			idc = 1009;
			text = "Manage Objectives";
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.44 / 2);
			y = ABSOLUTE_Y + (ABSOLUTE_HEIGHT / 2) - (0.7 / 2) + 0.55;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0; call functionManageObjectivesClient;";
		};
		class closeMenu: RscButton
		{
			idc = 1090;
			text = "Close Menu";
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.44 / 2);
			y = ABSOLUTE_Y + (ABSOLUTE_HEIGHT / 2) - (0.7 / 2) + 0.62;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0;";
		};
	};
};

/*class nwDialogueRespawn
{
	idd = 3;
	movingenable = false;
	class controls
	{
		class nwRespawnInterface: RscFrame
		{
			idc = 3000;
			text = "";
			x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 0.1;
			w = 0.83;
			h = 0.78;
		};
		class nwRespawnInterfaceBackground: Box
		{
			idc = -1;
			x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 0.1;
			w = 0.83;
			h = 0.78;
		};
		class nwRespawnInterfaceTitle: RscText
		{
			idc = 3001;
			text = "Respawn Menu";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 0.1;
			w = 0.83;
			h = 0.06;
		};
		class nwRespawnInterfaceRespawnPossibleIndicator: RscText
		{
			idc = 3002;
			text = "Respawn Countdown";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 0.17;
			w = 0.83;
			h = 0.06;
		};
		class nwRespawnInterfaceSpawnLocationOptionsList: RscListBox
		{
			idc = 3003;
			x = ABSOLUTE_X + 0.26;
			y = ABSOLUTE_Y + 0.24;
			w = 0.44;
			h = 0.36;
			colorBackground[] = {0.18,0.18,0.18,0.5};
		};
		class nwRespawnButton: RscButton
		{
			idc = 3004;
			text = "Respawn at Selected Location";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.26;
			y = ABSOLUTE_Y + 0.62;
			w = 0.44;
			h = 0.06;
			action = "call functionRespawnAtSelectedLocation;";
		};
	};
};*/

class iRespawnDialogue
{
	idd = 3000;
	movingenable = false;
	onLoad = "uiNamespace setVariable ['respawnMenuMap', (_this select 0) displayCtrl 3001];";
	class controls
	{
		class frame: RscFrame
		{
			idc = -1;
			text = "";
			x = ABSOLUTE_X + -0.11;
			y = ABSOLUTE_Y + 0.06;
			w = 1.09;
			h = 0.84;
		};
		class background: Box
		{
			idc = -1;
			x = ABSOLUTE_X + -0.11;
			y = ABSOLUTE_Y + 0.06;
			w = 1.09;
			h = 0.84;
		};
		class title: RscText
		{
			idc = -1;
			text = "Respawn Menu";
			style = ST_CENTER;
			x = ABSOLUTE_X + -0.11;
			y = ABSOLUTE_Y + 0.06;
			w = 1.09;
			h = 0.06;
		};
		class respawnLocationsMap: RscMapControl
		{
			idc = 3001;
			x = ABSOLUTE_X + -0.09;
			y = ABSOLUTE_Y + 0.12;
			w = 0.7;
			h = 0.75;
			onMouseButtonUp = "call functionHandleRespawnMenuMapClick";
		};
		class respawnLocationsList: RscListBox
		{
			idc = 3002;
			x = ABSOLUTE_X + 0.63;
			y = ABSOLUTE_Y + 0.12;
			w = 0.33;
			h = 0.67;
			colorBackground[] = {0.18,0.18,0.18,0.5};
			onLBSelChanged = "call functionHandleRespawnLocationListSelection;";
		};
		class respawnButton: RscButton
		{
			idc = 3003;
			text = "Respawn";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.63;
			y = ABSOLUTE_Y + 0.8;
			w = 0.33;
			h = 0.06;
			action = "call functionRespawnAtSelectedLocation;";
		};
	};
};

class nwDialogueCommanderElection
{
	idd = 2;
	movingenable = false;
	class controls
	{
		class nwCommanderElectionInterface: RscFrame
		{
			idc = 2000;
			text = "";
			x = ABSOLUTE_X + 0.17;
			y = ABSOLUTE_Y + 0.16;
			w = 0.48;
			h = 0.6;
		};
		class nwCommanderElectionInterfaceBackground: Box
		{
			idc = -1;
			x = ABSOLUTE_X + 0.17;
			y = ABSOLUTE_Y + 0.16;
			w = 0.48;
			h = 0.6;
		};
		class nwCommanderElectionInterfaceTitle: RscText
		{
			idc = 2001;
			text = "Commander Election Menu";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.16;
			w = 0.44;
			h = 0.06;
		};
		class nwCommanderElectionStandCountdown: RscText
		{
			idc = 2002;
			text = "Stand Countdown";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.36;
			w = 0.44;
			h = 0.06;
		};
		class nwCommanderElectionStandButton: RscButton
		{
			idc = 2003;
			text = "Stand for Election to Commander";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.42;
			w = 0.44;
			h = 0.06;
			action = "call functionStandForGeneralElectionClient;";
		};
		class nwCommanderElectionCountdown: RscText
		{
			idc = 2004;
			text = "Election Countdown";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.23;
			w = 0.44;
			h = 0.06;
		};
		class nwCommanderElectionCandidateList: RscListBox
		{
			idc = 2005;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.3;
			w = 0.44;
			h = 0.37;
			onLBSelChanged = "call functionHandleGeneralElectionCandidateSelection;";
		};
		class nwCommanderElectionCloseMenuButton: RscButton
		{
			idc = 2006;
			text = "Close Menu";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.68;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0;";
		};
	};
};

class nwDialogueBuildView
{
	idd = 4;
	movingenable = false;
	class controls
	{
		class nwBuildViewPanelBackground: Box
		{
			idc = -1;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.6 / 2);
			//x = ABSOLUTE_X + 0.15;
			y = ABSOLUTE_Y + 0.76;
			w = 0.6;
			h = 0.45;
		};
		class nwBuildViewControlInformation: RscStructuredText
		{
			idc = 4000;
			text = "";
			sizeEx = 0.0335;
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.6 / 2);
			y = ABSOLUTE_Y + 0.78;
			w = 0.6;
			h = 0.14;
			lineSpacing = 1; //required for multi-line style
			class Attributes
			{
				align = "center";
			};
		};
		/*class nwBuildViewBaseInformation: RscText
		{
			idc = 4005;
			text = "Base Supply Amount";
			sizeEx = 0.0335;
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.17;
			y = ABSOLUTE_Y + 0.87;
			w = 0.49;
			h = 0.06;
		};*/
		class nwBuildViewBuildButton: RscButton
		{
			idc = 4001;
			text = "Build";
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.46 / 2);
			//x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.94;
			w = 0.22;
			h = 0.06;
			action = "call functionBuildBuildableObject;";
		};
		class nwBuildViewCloseButton: RscButton
		{
			idc = 4002;
			text = "Exit Build View";
			style = ST_CENTER;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (0.46 / 2)) + 0.23;
			//x = ABSOLUTE_X + 0.43;
			y = ABSOLUTE_Y + 0.94;
			w = 0.22;
			h = 0.06;
			action = "call functionExitBuildView;";
		};
		class nwBuildViewObjectList: RscListBox
		{
			idc = 4003;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.46 / 2);
			//x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 1.01;
			w = 0.46;
			h = 0.18;
			onLBSelChanged = "call functionHandleBuildViewObjectListSelection;";
		};
		class nwBuildViewBaseSelection: RscCombo
		{
			idc = 4004;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.46 / 2);
			//x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + -0.14;
			w = 0.46;
			h = 0.06;
			onLBSelChanged = "call functionHandleBuildViewBaseSelection;";
		};
	};
};

class nwDialogueSupply
{
	idd = 5;
	movingenable = false;
	class controls
	{
		class nwSupplyInterface: RscFrame
		{
			idc = -1;
			text = "";
			x = ABSOLUTE_X;
			y = ABSOLUTE_Y;
			w = 1;
			h = 1;
		};
		class nwSupplyInterfaceBackground: Box
		{
			idc = -1;
			x = ABSOLUTE_X;
			y = ABSOLUTE_Y;
			w = 1;
			h = 1;
		};
		class nwSupplyInterfaceTitle: RscText
		{
			idc = -1;
			text = "Supply Management";
			style = ST_CENTER;
			x = ABSOLUTE_X;
			y = ABSOLUTE_Y;
			w = 1;
			h = 0.06;
		};
		class nwSupplyDispatchToggleButton: RscButton
		{
			idc = 5001;
			text = "Monitor";
			style = ST_CENTER;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (0.9 / 2));
			//x = ABSOLUTE_X + 0.02;
			y = ABSOLUTE_Y + 0.1;
			w = 0.2175;
			h = 0.06;
			action = "call functionHandleSupplyMonitorToggle;";
		};
		class nwSupplyMonitorToggleButton: RscButton
		{
			idc = 5000;
			text = "Dispatch";
			style = ST_CENTER;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (0.9 / 2)) + 0.2275;
			//x = ABSOLUTE_X + 0.25;
			y = ABSOLUTE_Y + 0.1;
			w = 0.2175;
			h = 0.06;
			action = "call functionHandleSupplyDispatchToggle;";
		};
		class nwSupplyRulesToggleButton: RscButton
		{
			idc = 5002;
			text = "Rules";
			style = ST_CENTER;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (0.9 / 2)) + 0.455;
			//x = ABSOLUTE_X + 0.48;
			y = ABSOLUTE_Y + 0.1;
			w = 0.2175;
			h = 0.06;
			action = "call functionHandleSupplyRulesToggle;";
		};
		class nwSupplyRelaysToggleButton: RscButton
		{
			idc = 5011;
			text = "Relays";
			style = ST_CENTER;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (0.9 / 2)) + 0.6825;
			//x = ABSOLUTE_X + 0.72;
			y = ABSOLUTE_Y + 0.1;
			w = 0.2175;
			h = 0.06;
			action = "call functionManageSupplyRelays;";
		};
		class nwSupplyBaseSelection: RscCombo
		{
			idc = 5003;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (0.22 / 2));
			//x = ABSOLUTE_X + 0.37;
			y = ABSOLUTE_Y + 0.24;
			w = 0.22;
			h = 0.06;
			onLBSelChanged = "call functionHandleSupplyBaseSelection;";
		};
		class nwSupplyInformation: RscText
		{
			idc = 5004;
			text = "Select a base to view information about it.";
			style = ST_CENTER;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (1 / 2));
			//x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 0.31;
			w = 1;
			h = 0.06;
		};
		class nwSupplyDispatchAmount: RscEdit
		{
			idc = 5006;
			text = "0";
			x = 0.28;
			y = 0.388;
			w = 0.1;
			h = 0.06;
		};
		class nwSupplyDispatchBaseSelection: RscCombo
		{
			idc = 5007;
			x = ABSOLUTE_X + 0.39;
			y = ABSOLUTE_Y + 0.38;
			w = 0.22;
			h = 0.06;
			//onLBSelChanged = "closeDialog 0;";
		};
		class nwSupplyDispatchButton: RscButton
		{
			idc = 5008;
			text = "Dispatch";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.63;
			y = ABSOLUTE_Y + 0.38;
			w = 0.22;
			h = 0.06;
			action = "call functionDispatchSupply;";
		};
		class nwSupplyDispatchInformation: RscText
		{
			idc = 5010;
			text = "Provide supply amount and destination to dispatch.";
			style = ST_CENTER;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (1 / 2));
			//x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 0.45;
			w = 1;
			h = 0.06;
		};
		class generalSupplyInformation: RscText
		{
			idc = 5020;
			text = "Total supply.";
			style = ST_CENTER + ST_MULTI;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (1 / 2));
			//x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 0.2;
			w = 1;
			h = 0.16;
			lineSpacing = 1;
		};
		class supplyPackagesTitle: RscText
		{
			idc = 5021;
			text = "Supply Packages";
			style = ST_CENTER;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (1 / 2));
			//x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 0.38;
			w = 1;
			h = 0.06;
		};
		class nwSupplyMonitorList: RscListBox
		{
			idc = 5009;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (0.74 / 2));
			//x = ABSOLUTE_X + 0.11;
			y = ABSOLUTE_Y + 0.44;
			w = 0.74;
			h = 0.42;
			sizeEx = 0.03;
			colorSelectBackground[] = {1, 1, 1, 0};
			colorSelectBackground2[] = {1, 1, 1, 0};
			colorBackground[] = {1, 1, 1, 0};
		};
		class nwSupplyPrimaryBaseInformation: RscText
		{
			idc = 5016;
			text = "Select primary base. Territorial supply income is stored at primary base.";
			style = ST_CENTER;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (1 / 2));
			//x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 0.24;
			w = 1;
			h = 0.06;
		};
		class nwSupplyPrimaryBaseSelection: RscCombo
		{
			idc = 5017;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (0.22 / 2));
			//x = ABSOLUTE_X + 0.37;
			y = ABSOLUTE_Y + 0.31;
			w = 0.22;
			h = 0.06;
			onLBSelChanged = "call functionHandleSupplyPrimaryBaseSelection;";
		};
		class quotaProportionInformation: RscText
		{
			idc = 5018;
			text = "Select quota proportion. Proportion of income granted to player quotas.";
			style = ST_CENTER;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (1 / 2));
			//x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 0.38;
			w = 1;
			h = 0.06;
		};
		class quotaProportionSelection: RscCombo
		{
			idc = 5019;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (0.22 / 2));
			//x = ABSOLUTE_X + 0.37;
			y = ABSOLUTE_Y + 0.45;
			w = 0.22;
			h = 0.06;
			onLBSelChanged = "call functionHandleSupplyIncomeQuotaProportionSelection;";
		};
		class nwSupplyCloseMenuButton: RscButton
		{
			idc = 5090;
			text = "Close Menu";
			style = ST_CENTER;
			x = ABSOLUTE_X + ((ABSOLUTE_WIDTH / 2) - (0.44 / 2));
			//x = ABSOLUTE_X + 0.26;
			y = ABSOLUTE_Y + 0.88;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0;";
		};
	};
};

class nwDialogueMissions
{
	idd = 6;
	movingenable = false;
	class controls
	{
		class nwMissionsInterface: RscFrame
		{
			idc = -1;
			text = "";
			x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 0.1;
			w = 0.83;
			h = 0.78;
		};
		class nwMissionsInterfaceBackground: Box
		{
			idc = -1;
			x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 0.1;
			w = 0.83;
			h = 0.78;
		};
		class nwMissionsInterfaceTitle: RscText
		{
			idc = -1;
			text = "Missions";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 0.1;
			w = 0.83;
			h = 0.06;
		};
		class nwMissionsList: RscListBox
		{
			idc = 6000;
			x = ABSOLUTE_X + 0.11;
			y = ABSOLUTE_Y + 0.17;
			w = 0.74;
			h = 0.47;
			sizeEx = 0.035;
			onLBSelChanged = "call functionHandleMissionListSelection;";
		};
		class nwMissionsInterfaceInformation: RscText
		{
			idc = 6003;
			text = "";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 0.66;
			w = 0.83;
			h = 0.06;
		};
		class nwMissionsAcceptButton: RscButton
		{
			idc = 6001;
			text = "Accept Mission";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.26;
			y = ABSOLUTE_Y + 0.73;
			w = 0.44;
			h = 0.06;
			action = "call functionAcceptMission;";
		};
		class nwMissionsCloseMenuButton: RscButton
		{
			idc = 6090;
			text = "Close Menu";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.26;
			y = ABSOLUTE_Y + 0.81;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0;";
		};
	};
};

class nwDialogueVehicleAcquisition
{
	idd = 7;
	movingenable = false;
	class controls
	{
		class nwVehicleAcquisitionInterface: RscFrame
		{
			idc = -1;
			text = "";
			x = ABSOLUTE_X + 0;
			y = ABSOLUTE_Y + 0.16;
			w = 0.83;
			h = 0.83;
		};
		class nwVehicleAcquisitionInterfaceBackground: Box
		{
			idc = -1;
			x = ABSOLUTE_X + 0;
			y = ABSOLUTE_Y + 0.16;
			w = 0.83;
			h = 0.83;
		};
		class nwVehicleAcquisitionInterfaceTitle: RscText
		{
			idc = -1;
			text = "Vehicles";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.16;
			w = 0.44;
			h = 0.06;
		};
		class nwVehicleAcquisitionBaseSelection: RscCombo
		{
			idc = 7000;
			x = ABSOLUTE_X + 0.3;
			y = ABSOLUTE_Y + 0.24;
			w = 0.22;
			h = 0.06;
			onLBSelChanged = "call functionHandleVehicleAcquisitionBaseSelection;";
		};
		class nwVehicleAcquisitionBaseInformation: RscText
		{
			idc = 7001;
			text = "Select a base to view information about it.";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0;
			y = ABSOLUTE_Y + 0.31;
			w = 0.83;
			h = 0.06;
		};
		class nwVehicleAcquisitionList: RscListBox
		{
			idc = 7002;
			x = ABSOLUTE_X + 0.11;
			y = ABSOLUTE_Y + 0.38;
			w = 0.61;
			h = 0.27;
			onLBSelChanged = "call functionHandleVehicleAcquisitionSelection;";
		};
		class nwAcquireButton: RscButton
		{
			idc = 7003;
			text = "Acquire";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.74;
			w = 0.44;
			h = 0.06;
			action = "call functionAcquireVehicle;";
		};
		class acquisitionInformation: RscText
		{
			idc = 7004;
			text = "Please select a vehicle to acquire.";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0;
			y = ABSOLUTE_Y + 0.67;
			w = 0.83;
			h = 0.06;
		};
		class nwVehicleAcquisitionCloseMenuButton: RscButton
		{
			idc = 7090;
			text = "Close Menu";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.81;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0;";
		};
	};
};

class nwDialogueCommanderChallengeElection
{
	idd = 8;
	movingenable = false;
	class controls
	{
		class nwCommanderChallengeElectionInterface: RscFrame
		{
			idc = -1;
			text = "";
			x = ABSOLUTE_X + 0.11;
			y = ABSOLUTE_Y + 0.16;
			w = 0.61;
			h = 0.78;
		};
		class nwCCommanderChallengeElectionInterfaceBackground: Box
		{
			idc = -1;
			x = ABSOLUTE_X + 0.11;
			y = ABSOLUTE_Y + 0.16;
			w = 0.61;
			h = 0.78;
		};
		class nwCCommanderChallengeElectionInterfaceTitle: RscText
		{
			idc = -1;
			text = "Challenge Election";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.17;
			y = ABSOLUTE_Y + 0.16;
			w = 0.48;
			h = 0.06;
		};
		class nwCommanderChallengeElectionStageInformation: RscText
		{
			idc = 8000;
			text = "Challenge Stage";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.11;
			y = ABSOLUTE_Y + 0.21;
			w = 0.61;
			h = 0.06;
		};
		class nwCommanderChallengeElectionChallengerRationale: MultiEdit
		{
			idc = 8001;
			text = "Explain your rationale for challenging the commander...";
			x = 0.22;
			y = 0.300;
			w = 0.4;
			h = 0.24;
			onMouseButtonClick = "call functionHandleChallengeElectionRationaleClick;";
			onKillFocus = "call functionHandleChallengeElectionRationaleLooseFocus;";
			onKeyDown = "call functionHandleChallengeElectionRationaleChange;";
		};
		class nwCommanderChallengeElectionRationaleInformation: RscText
		{
			idc = 8002;
			text = "Rationale Character Limit";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.17;
			y = ABSOLUTE_Y + 0.54;
			w = 0.48;
			h = 0.06;
		};
		class nwCommanderChallengeElectionLaunchButton: RscButton
		{
			idc = 8003;
			text = "Launch Challenge";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.61;
			w = 0.44;
			h = 0.06;
			action = "call functionLaunchCommanderChallenge; closeDialog 0;";
		};
		class nwCommanderChallengeElectionChallengerRationalePreview: RscText
		{
			idc = 8004;
			//text = "Challenger Rationale";
			text = "Challenger's Rationale: awwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwb";
			style = ST_MULTI;
			colorSelection[] = {0,0,0,0};
			sizeEx = 0.035;
			x = ABSOLUTE_X + 0.13;
			y = ABSOLUTE_Y + 0.27;
			w = 0.57;
			h = 0.22;
		};
		class nwCommanderChallengeElectionChallengerRebuttal: MultiEdit
		{
			idc = 8005;
			text = "Rebut your challenger's rationale...";
			x = 0.19;
			y = 0.5;
			w = 0.42;
			h = 0.24;
			onMouseButtonClick = "call functionHandleChallengeElectionRebuttalClick";
			onKeyDown = "call functionHandleChallengeElectionRebuttalChange;";
		};
		class nwCommanderChallengeElectionRebuttalInformation: RscText
		{
			idc = 8006;
			text = "Rebut Character Limit";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.17;
			y = ABSOLUTE_Y + 0.73;
			w = 0.48;
			h = 0.06;
		};
		class nwCommanderChallengeElectionIssueButton: RscButton
		{
			idc = 8007;
			text = "Issue Rebuttal";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.79;
			w = 0.44;
			h = 0.06;
			action = "call functionIssueCommanderChallengeElectionRebuttal; closeDialog 0;";
		};
		class nwCommanderChallengeElectionChallengerRationaleText: RscText
		{
			idc = 8008;
			//text = "Challenger Rationale";
			text = "Challenger's Rationale: awwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwb";
			style = ST_MULTI;
			colorSelection[] = {0,0,0,0};
			sizeEx = 0.035;
			x = ABSOLUTE_X + 0.13;
			y = ABSOLUTE_Y + 0.27;
			w = 0.57;
			h = 0.22;
		};
		class nwCommanderChallengeElectionChallengerRebuttalText: RscText
		{
			idc = 8009;
			//text = "Commander Rebuttal";
			text = "Commander's Rebuttal: awwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwb";
			style = ST_MULTI;
			colorSelection[] = {0,0,0,0};
			sizeEx = 0.035;
			x = ABSOLUTE_X + 0.13;
			y = ABSOLUTE_Y + 0.5;
			w = 0.57;
			h = 0.22;
		};
		class nwCommanderChallengeElectionSupportCommanderButton: RscButton
		{
			idc = 8010;
			text = "Support Commander";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.72;
			w = 0.44;
			h = 0.06;
			action = "call functionChallengeElectionSupportCommander; closeDialog 0;";
		};
		class nwCommanderChallengeElectionSupportChallengerButton: RscButton
		{
			idc = 8011;
			text = "Support Challenger";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.79;
			w = 0.44;
			h = 0.06;
			action = "call functionChallengeElectionSupportChallenger; closeDialog 0;";
		};
		class nwCommanderChallengeElectionCloseMenuButton: RscButton
		{
			idc = 8090;
			text = "Close Menu";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.87;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0;";
		};
	};
};

class nwDialogueRoadblockDirectionSelection
{
	idd = 9;
	movingenable = false;
	class controls
	{
		class nwDialogueRoadblockDirectionSelectionInterface: RscFrame
		{
			idc = -1;
			text = "";
			x = ABSOLUTE_X + 0.22;
			y = ABSOLUTE_Y + 0.16;
			w = 0.5;
			h = 0.21;
		};
		class nwDialogueRoadblockDirectionSelectionInterfaceBackground: Box
		{
			idc = -1;
			x = ABSOLUTE_X + 0.22;
			y = ABSOLUTE_Y + 0.16;
			w = 0.5;
			h = 0.21;
		};
		class nwDialogueRoadblockDirectionSelectionQuestion: RscText
		{
			idc = -1;
			text = "Which direction should the roadblock face?";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.22;
			y = ABSOLUTE_Y + 0.16;
			w = 0.5;
			h = 0.06;
		};
		class nwDialogueRoadblockDirectionSelectionFirstOptionButton: RscButton
		{
			idc = 9000;
			text = "North West";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.37;
			y = ABSOLUTE_Y + 0.23;
			w = 0.22;
			h = 0.06;
		};
		class nwDialogueRoadblockDirectionSelectionSecondOptionButton: RscButton
		{
			idc = 9001;
			text = "South East";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.37;
			y = ABSOLUTE_Y + 0.3;
			w = 0.22;
			h = 0.06;
		};
	};
};

class nwDialogueAuxiliary
{
	idd = 10;
	movingenable = false;
	class controls
	{
		class nwAuxiliaryInterface: RscFrame
		{
			idc = -1;
			text = "";
			x = ABSOLUTE_X + -0.15;
			y = ABSOLUTE_Y + 0.1;
			w = 1.22;
			h = 1.15;
		};
		class nwAuxiliaryInterfaceBackground: Box
		{
			idc = -1;
			x = ABSOLUTE_X + -0.15;
			y = ABSOLUTE_Y + 0.1;
			w = 1.22;
			h = 1.15;
		};
		class nwAuxiliaryInterfaceTitle: RscText
		{
			idc = -1;
			text = "Auxiliary Management";
			style = ST_CENTER;
			x = ABSOLUTE_X + -0.15;
			y = ABSOLUTE_Y + 0.1;
			w = 1.22;
			h = 0.06;
		};
		// Section Toggles
		class nwAuxiliaryStaticsToggleButton: RscButton
		{
			idc = 10000;
			text = "Statics";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.12;
			y = ABSOLUTE_Y + 0.17;
			w = 0.22;
			h = 0.06;
			//action = "";
		};
		class nwAuxiliaryGroupsToggleButton: RscButton
		{
			idc = 10001;
			text = "Groups";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.35;
			y = ABSOLUTE_Y + 0.17;
			w = 0.22;
			h = 0.06;
			//action = "";
		};
		class nwAuxiliaryRoadblocksToggleButton: RscButton
		{
			idc = 10002;
			text = "Roadblocks";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.58;
			y = ABSOLUTE_Y + 0.17;
			w = 0.22;
			h = 0.06;
			action = "closeDialog 0; call functionManageRoadblocks;";
		};
		// Group Management
		class nwManageGroupsTitle: RscText
		{
			idc = -1;
			text = "Manage Groups";
			style = ST_CENTER;
			x = ABSOLUTE_X + -0.15;
			y = ABSOLUTE_Y + 0.24;
			w = 1.22;
			h = 0.06;
		};
		class nwGroupSelection: RscCombo
		{
			idc = 10004;
			x = ABSOLUTE_X + 0.24;
			y = ABSOLUTE_Y + 0.31;
			w = 0.44;
			h = 0.06;
			onLBSelChanged = "call functionHandleGroupSelection;";
		};
		class nwGroupNameInput: RscEdit
		{
			idc = 10005;
			text = "Group Name";
			x = 0.26;
			y = 0.39;
			w = 0.4;
			h = 0.06;
			onMouseButtonDown = "if ((ctrlText 10005) == 'Group Name') then { ctrlSetText [10005, ''] };";
			onKillFocus = "if ((ctrlText 10005) == '') then { ctrlSetText [10005, 'Group Name'] };";
		};
		class nwGroupMembersList: RscListBox
		{
			idc = 10006;
			x = ABSOLUTE_X + 0.24;
			y = ABSOLUTE_Y + 0.45;
			w = 0.44;
			h = 0.27;
			onLBSelChanged = "ctrlEnable [10007, true];";
		};
		class nwGroupInformation: RscText
		{
			idc = 10019;
			text = "";
			style = ST_CENTER;
			x = ABSOLUTE_X + -0.15;
			y = ABSOLUTE_Y + 0.74;
			w = 1.22;
			h = 0.06;
		};
		class nwGroupRemoveMemberButton: RscButton
		{
			idc = 10007;
			text = "Remove Member";
			style = ST_CENTER;
			x = ABSOLUTE_X + -0.13;
			y = ABSOLUTE_Y + 0.81;
			w = 0.28;
			h = 0.06;
			action = "call functionAuxiliaryGroupRemoveMember;";
		};
		class nwGroupAddStaticMemberButton: RscButton
		{
			idc = 10008;
			text = "Add Static Member";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.17;
			y = ABSOLUTE_Y + 0.81;
			w = 0.28;
			h = 0.06;
			action = "call functionAuxiliaryGroupAddStaticMember;";
		};
		class nwGroupLocationButton: RscButton
		{
			idc = 10009;
			text = "Select Location";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.46;
			y = ABSOLUTE_Y + 0.81;
			w = 0.28;
			h = 0.06;
		};
		class nwGroupClearLocationButton: RscButton
		{
			idc = 10010;
			text = "Clear Location";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.76;
			y = ABSOLUTE_Y + 0.81;
			w = 0.28;
			h = 0.06;
		};
		class nwGroupAddMemberSelection: RscCombo
		{
			idc = 10011;
			x = ABSOLUTE_X + -0.13;
			y = ABSOLUTE_Y + 0.88;
			w = 0.39;
			h = 0.06;
		};
		class nwGroupAddMemberBaseSelection: RscCombo
		{
			idc = 10012;
			x = ABSOLUTE_X + 0.28;
			y = ABSOLUTE_Y + 0.88;
			w = 0.28;
			h = 0.06;
			onLBSelChanged = "call functionHandleAddMemberBaseSelection;";
		};
		class nwGroupAddMemberBaseSelectionInformation: RscText
		{
			idc = 10013;
			text = "Base Information";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.57;
			y = ABSOLUTE_Y + 0.88;
			w = 0.24;
			h = 0.06;
		};
		class nwGroupAddMemberButton: RscButton
		{
			idc = 10014;
			text = "Add Member";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.83;
			y = ABSOLUTE_Y + 0.88;
			w = 0.22;
			h = 0.06;
			action = "call functionAuxiliaryGroupAddMember;";
		};
		class nwCreateGroupTitle: RscText
		{
			idc = -1;
			text = "Create Group";
			style = ST_CENTER;
			x = ABSOLUTE_X + -0.02;
			y = ABSOLUTE_Y + 0.95;
			w = 1.05;
			h = 0.06;
		};
		class nwCreateGroupTaskSelection: RscCombo
		{
			idc = 10015;
			x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 1.02;
			w = 0.22;
			h = 0.06;
			//onLBSelChanged = "call functionHandleRoadblockBaseSelection;";
		};
		class nwCreateGroupNameInput: RscEdit
		{
			idc = 10016;
			text = "Group Name";
			x = 0.30;
			y = 1.02;
			w = 0.4;
			h = 0.06;
			onMouseButtonDown = "if ((ctrlText 10015) == 'Group Name') then { ctrlSetText [10015, ''] };";
			onKillFocus = "if ((ctrlText 10015) == '') then { ctrlSetText [10015, 'Group Name'] };";
		};
		class nwCreateGroupButton: RscButton
		{
			idc = -1;
			text = "Create Group";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.72;
			y = ABSOLUTE_Y + 1.02;
			w = 0.22;
			h = 0.06;
			action = "call functionAuxiliaryCreateGroup;";
		};
		class nwGroupsInformation: RscText
		{
			idc = 10017;
			text = "";
			style = ST_CENTER;
			x = ABSOLUTE_X + -0.15;
			y = ABSOLUTE_Y + 1.1;
			w = 1.22;
			h = 0.06;
		};
		// Roadblock Management
		/*class nwSupplyBaseSelection: RscCombo
		{
			idc = 10017;
			x = ABSOLUTE_X + 0.37;
			y = ABSOLUTE_Y + 0.24;
			w = 0.22;
			h = 0.06;
			onLBSelChanged = "call functionHandleRoadblockBaseSelection;";
		};
		class nwSupplyInformation: RscText
		{
			idc = 10018;
			text = "Select a base to view information about it.";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.06;
			y = ABSOLUTE_Y + 0.73;
			w = 0.83;
			h = 0.06;
		};*/
		// Close Menu
		class nwAuxiliaryCloseMenuButton: RscButton
		{
			idc = -1;
			text = "Close Menu";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.24;
			y = ABSOLUTE_Y + 1.17;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0;";
		};
	};
};

class nwDialogueSupplyTransportationInterface
{
	idd = 11;
	movingenable = false;
	class controls
	{
		class frame: RscFrame
		{
			idc = 11000;
			text = "";
			x = ABSOLUTE_X + 0.17;
			y = ABSOLUTE_Y + 0.16;
			w = 0.48;
			h = 0.6;
		};
		class background: Box
		{
			idc = -1;
			x = ABSOLUTE_X + 0.17;
			y = ABSOLUTE_Y + 0.16;
			w = 0.48;
			h = 0.6;
		};
		class title: RscText
		{
			idc = -1;
			text = "Supply Transportation Management";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.17;
			y = ABSOLUTE_Y + 0.16;
			w = 0.48;
			h = 0.06;
		};
		class vehicleInformation: RscText
		{
			idc = 11001;
			text = "Supply Transportation Vehicle Supply Amount";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.17;
			y = ABSOLUTE_Y + 0.24;
			w = 0.48;
			h = 0.06;
		};
		class supplyTransferFocusSelection: RscCombo
		{
			idc = 11002;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.31;
			w = 0.44;
			h = 0.06;
			onLBSelChanged = "call functionHandleSupplyTransferFocusSelection;";
		};
		class supplyTransferSourceInformation: RscText
		{
			idc = 11003;
			text = "Transfer Focus Source Information";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.17;
			y = ABSOLUTE_Y + 0.38;
			w = 0.48;
			h = 0.06;
		};
		class transferAmount: RscEdit
		{
			idc = 11004;
			text = "0";
			x = 0.3;
			y = 0.44;
			w = 0.2;
			h = 0.06;
		};
		class exportTransfer: RscButton
		{
			idc = 11005;
			text = "Import";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.52;
			w = 0.21;
			h = 0.06;
			action = "call functionSupplyTransportationVehicleImportTransfer;";
		};
		class importTransfer: RscButton
		{
			idc = 11006;
			text = "Export";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.42;
			y = ABSOLUTE_Y + 0.52;
			w = 0.21;
			h = 0.06;
			action = "call functionSupplyTransportationVehicleExportTransfer;";
		};
		class transferStatus: RscText
		{
			idc = 11007;
			text = "";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.17;
			y = ABSOLUTE_Y + 0.59;
			w = 0.48;
			h = 0.06;
		};
		class closeMenu: RscButton
		{
			idc = 11008;
			text = "Close Menu";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.66;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0;";
		};
	};
};

class nwDialogueAIAcquisition
{
	idd = 12;
	movingenable = false;
	class controls
	{
		class frame: RscFrame
		{
			idc = -1;
			text = "";
			x = ABSOLUTE_X + 0;
			y = ABSOLUTE_Y + 0.16;
			w = 0.83;
			h = 0.83;
		};
		class background: Box
		{
			idc = -1;
			x = ABSOLUTE_X + 0;
			y = ABSOLUTE_Y + 0.16;
			w = 0.83;
			h = 0.83;
		};
		class title: RscText
		{
			idc = -1;
			text = "AI";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.16;
			w = 0.44;
			h = 0.06;
		};
		class baseSelection: RscCombo
		{
			idc = 12000;
			x = ABSOLUTE_X + 0.3;
			y = ABSOLUTE_Y + 0.24;
			w = 0.22;
			h = 0.06;
			onLBSelChanged = "call functionHandleAIAcquisitionBaseSelection;";
		};
		class baseInformation: RscText
		{
			idc = 12001;
			text = "Select a base to view information about it.";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0;
			y = ABSOLUTE_Y + 0.31;
			w = 0.83;
			h = 0.06;
		};
		class acquisitionList: RscListBox
		{
			idc = 12002;
			x = ABSOLUTE_X + 0.11;
			y = ABSOLUTE_Y + 0.38;
			w = 0.61;
			h = 0.27;
			onLBSelChanged = "call functionHandleAIAcquisitionSelection;";
		};
		class acquireButton: RscButton
		{
			idc = 12003;
			text = "Acquire";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.74;
			w = 0.44;
			h = 0.06;
			action = "call functionAcquireAI;";
		};
		class manageButton: RscButton
		{
			idc = 12005;
			text = "Manage";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.81;
			w = 0.44;
			h = 0.06;
			action = "call functionManageAI;";
		};
		class acquisitionInformation: RscText
		{
			idc = 12004;
			text = "Please select an AI to acquire.";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0;
			y = ABSOLUTE_Y + 0.67;
			w = 0.83;
			h = 0.06;
		};
		class closeMenuButton: RscButton
		{
			idc = 12090;
			text = "Close Menu";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.88;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0;";
		};
	};
};

class nwDialogueTownDefenceReward
{
	idd = 14;
	movingenable = false;
	class controls
	{
		class frame: RscFrame
		{
			idc = -1;
			text = "";
			x = ABSOLUTE_X + 0;
			y = ABSOLUTE_Y + 0.16;
			w = 0.83;
			h = 0.83;
		};
		class background: Box
		{
			idc = -1;
			x = ABSOLUTE_X + 0;
			y = ABSOLUTE_Y + 0.16;
			w = 0.83;
			h = 0.83;
		};
		class title: RscText
		{
			idc = -1;
			text = "Province Resistance Reward";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.16;
			w = 0.44;
			h = 0.06;
		};
		class rewardTextContainer: RscControlsGroup
		{
			idc = -1;
			x = ABSOLUTE_X + 0.10;
			y = ABSOLUTE_Y + 0.23;
			w = 0.62;
			h = 0.52;
			class Controls
			{
				class rewardText: RscStructuredText
				{
					idc = 14000;
					x = 0;//ABSOLUTE_X + 0.11;
					y = 0;//ABSOLUTE_Y + 0.23;
					w = 0.61;
					h = 0.52;
					text = "";
					lineSpacing = 1; //required for multi-line style
					class Attributes
					{
						align = "center";
					};
				};
			};
		};
		class closeWindowButton: RscButton
		{
			idc = 14090;
			text = "Close Window";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.81;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0;";
		};
	};
};

class nwDialogueAIManagement
{
	idd = 15;
	movingenable = false;
	class controls
	{
		class frame: RscFrame
		{
			idc = -1;
			text = "";
			x = ABSOLUTE_X + 0;
			y = ABSOLUTE_Y + 0.16;
			w = 0.83;
			h = 0.83;
		};
		class background: Box
		{
			idc = -1;
			x = ABSOLUTE_X + 0;
			y = ABSOLUTE_Y + 0.16;
			w = 0.83;
			h = 0.83;
		};
		class title: RscText
		{
			idc = -1;
			text = "AI Management";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.16;
			w = 0.44;
			h = 0.06;
		};
		class squadList: RscListBox
		{
			idc = 15002;
			x = ABSOLUTE_X + 0.11;
			y = ABSOLUTE_Y + 0.38;
			w = 0.61;
			h = 0.27;
		};
		class disbandButton: RscButton
		{
			idc = 15003;
			text = "Disband";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.74;
			w = 0.44;
			h = 0.06;
			action = "call functionDisbandAI;";
		};
		class closeMenuButton: RscButton
		{
			idc = 15090;
			text = "Return";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.19;
			y = ABSOLUTE_Y + 0.81;
			w = 0.44;
			h = 0.06;
			action = "call functionCloseAIManagement;";
		};
	};
};

class nwDialogueSlingLoadingRequest
{
	idd = 16;
	movingenable = false;
	class controls
	{
		class interface: RscFrame
		{
			idc = -1;
			text = "";
			x = ABSOLUTE_X + 0.22;
			y = ABSOLUTE_Y + 0.16;
			w = 0.5;
			h = 0.33;
		};
		class background: Box
		{
			idc = -1;
			x = ABSOLUTE_X + 0.22;
			y = ABSOLUTE_Y + 0.16;
			w = 0.5;
			h = 0.33;
		};
		class information: RscText
		{
			idc = 16000;
			text = "Sling Load Request Information";
			style = ST_CENTER + ST_MULTI;
			x = ABSOLUTE_X + 0.22;
			y = ABSOLUTE_Y + 0.16;
			w = 0.5;
			h = 0.12;
		};
		class approve: RscButton
		{
			idc = 16001;
			text = "Aprove";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.37;
			y = ABSOLUTE_Y + 0.29;
			w = 0.22;
			h = 0.06;
		};
		class decline: RscButton
		{
			idc = 16002;
			text = "Decline";
			style = ST_CENTER;
			x = ABSOLUTE_X + 0.37;
			y = ABSOLUTE_Y + 0.36;
			w = 0.22;
			h = 0.06;
		};
	};
};

class DialogueOptions
{
	idd = 17;
	movingenable = false;
	class controls
	{
		class interface: RscFrame
		{
			idc = -1;
			text = "";
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.48 / 2);
			y = ABSOLUTE_Y + (ABSOLUTE_HEIGHT / 2) - (0.7 / 2);
			w = 0.48;
			h = 0.7;
		};
		class background: Box
		{
			idc = -1;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.48 / 2);
			y = ABSOLUTE_Y + (ABSOLUTE_HEIGHT / 2) - (0.7 / 2);
			w = 0.48;
			h = 0.7;
		};
		class title: RscText
		{
			idc = -1;
			text = "Options";
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.48 / 2);
			y = ABSOLUTE_Y + (ABSOLUTE_HEIGHT / 2) - (0.7 / 2);
			w = 0.48;
			h = 0.06;
		};
		class influenceMapQuality: RscButton
		{
			idc = 17000;
			text = "Influence Map Quality";
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.44 / 2);
			y = 0.24;
			w = 0.44;
			h = 0.06;
			onMouseButtonClick = "call functionCycleInfluenceMapQuality;";
		};
		class buildViewBorderQuality: RscButton
		{
			idc = 17001;
			text = "Build View Border Quality";
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.44 / 2);
			y = 0.31;
			w = 0.44;
			h = 0.06;
			onMouseButtonClick = "call functionCycleBuildViewBorderQuality;";
		};
		class closeMenu: RscButton
		{
			idc = 17090;
			text = "Close Menu";
			style = ST_CENTER;
			x = ABSOLUTE_X + (ABSOLUTE_WIDTH / 2) - (0.44 / 2);
			y = 0.38;
			w = 0.44;
			h = 0.06;
			action = "closeDialog 0;";
		};
	};
};