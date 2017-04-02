// Engine
mapSize = call functionGetMapSize;
missionRoot = str missionConfigFile select [0, count str missionConfigFile - 15];

// Generic
maximumAIPerPlayer = 4;
standardUnitHeight = 2.1;
controlFatigueLossInterval = 20;
controlFatigueLossCorrection = 0.3;
serverOwnershipID = 2;

// Respawn
respawnIslandPosition = [2328.68,9268.62];
//startingPositionBLUFOR = [14726.8,16281.8]; // Central Airport Runway
//startingPositionPairs = [[[27760.3,25315,0.00123978], [2709.79,10035.8,0.00143051]]];
startingPositionPairs = [[[10597.4,15891.6,0], [19497.5,16511.3,0]]];
startingPositionSpawnRadius = 30;
//startingPositionBLUFOR = [12860,16714.5]; // Military Hill
timeInSecondsUntilPlayerRespawnAllowed = 5;
baseRespawnOuterSpawnAreaBufferSize = 10;
mobileRespawnEstablishTimeInSeconds = 10;
mobileRespawnDisestablishTimeInSeconds = 10;
mobileRespawnRadius = 1000;
mobileRespawnExclusiveEstablishmentRadius = 300;
mobileRespawnSpawnRadius = 30;

// Bases
baseRadius = 100;
baseBuildRadius = baseRadius + 20;
baseSupplyCost = 3000;
baseExclusiveEstablishmentRadius = 300;
navalSpawnRadius = 5;
baseCaptureTimeInSeconds = 300;
baseCaptureProgressIntervalInSeconds = 2;
baseCaptureProgressIntervalAmount = 200 / baseCaptureTimeInSeconds;
baseStaticDefenceInterimDisableTimeInSeconds = 10;
baseFlagPositionYOffset = 3.12796;
baseObjectEngineName = 'Land_Cargo_HQ_V1_F';
baseInfluenceAmount = 1;

baseBuildableObjects = [['Concrete Wall', 'Land_CncWall4_F', 50], ['Block Defence (x1)', 'Land_HBarrier_1_F', 25], ['Block Defence (x4)', 'Land_HBarrier_Big_F', 25], ['Block Defence Wall (x6)', 'Land_HBarrierWall6_F', 25], ['Block Defence Wall (Corner)', 'Land_HBarrierWall_corner_F', 25], ['Block Defence Wall (Corridor)', 'Land_HBarrierWall_corridor_F', 25], ['Razorwire', 'Land_Razorwire_F', 10], ['Sandbag', 'Land_BagFence_Long_F', 10], ['Halogen Light', 'Land_LampHalogen_F', 100], ['Static HMG', 'B_HMG_01_high_F', 150], ['Static AT', 'B_static_AT_F', 200], ['Static AA', 'B_static_AA_F', 200], ['Guard Tower (Small)', 'Land_Cargo_Patrol_V1_F', 150], ['Guard Tower (Tall)', 'Land_Cargo_Tower_V1_F', 200], ['Bunker Small', 'Land_BagBunker_Small_F', 200], ['Bunker Large', 'Land_BagBunker_Large_F', 250], ['Bunker Tower', 'Land_BagBunker_Tower_F', 300], ['Infantry Facility', 'Land_MilOffices_V1_F', 0], ['Light Vehicle Facility', 'Land_CarService_F', 0], ['Heavy Vehicle Facility', 'Land_dp_smallFactory_F', 0], ['Air Facility', 'Land_Airport_Tower_F', 0], ['Naval Facility', 'Land_BuoyBig_F', 0]];

baseVehicleAcquisitionOptionsLightBLUFOR = [['Hunter', 'B_MRAP_01_F', 250], ['Hunter HMG', 'B_MRAP_01_hmg_F', 500], ['Hunter GMG', 'B_MRAP_01_gmg_F', 650], ['Marshall', 'B_APC_Wheeled_01_cannon_F', 1250], ['HEMTT Transport', 'B_Truck_01_covered_F', 150], ['Mobile Respawn Vehicle', 'B_Truck_01_box_F', 250], ['Supply Transportation Vehicle', 'B_Truck_01_box_F', 100], ['HEMMT Repair', 'B_Truck_01_Repair_F', 300], ['HEMMT Ammo', 'B_Truck_01_ammo_F', 300], ['HEMMT Fuel', 'B_Truck_01_fuel_F', 300]];
baseVehicleAcquisitionOptionsHeavyBLUFOR = [['Panther', 'B_APC_Tracked_01_rcws_F', 500], ['Bobcat', 'B_APC_Tracked_01_CRV_F', 500]];
baseVehicleAcquisitionOptionsAirBLUFOR = [['Ghost Hawk', 'B_Heli_Transport_01_F', 450], ['Hummingbird', 'B_Heli_Light_01_F', 300], ['Pawnee', 'B_Heli_Light_01_armed_F', 1200]];
baseVehicleAcquisitionOptionsNavyBLUFOR = [['Speedboat Minigun', 'B_Boat_Armed_01_minigun_F', 100], ['Assault Boat', 'B_G_Boat_Transport_01_F', 50], ['Micro Submarine', 'B_SDV_01_F', 100]];

baseVehicleAcquisitionOptionsLightOPFOR = [['Ifrit', 'O_MRAP_02_F', 250], ['Ifrit HMG', 'O_MRAP_02_hmg_F', 500], ['Ifrit GMG', 'O_MRAP_02_gmg_F', 650], ['Marid', 'O_APC_Wheeled_02_rcws_F', 1250], ['Tempest Transport', 'O_Truck_03_covered_F', 150], ['Mobile Respawn Vehicle', 'O_Truck_02_box_F', 250], ['Supply Transportation Vehicle', 'O_Truck_02_box_F', 100], ['Tempest Repair', 'O_Truck_03_repair_F', 300], ['Tempest Ammo', 'O_Truck_03_ammo_F', 300], ['Tempest Fuel', 'O_Truck_03_fuel_F', 300]];
baseVehicleAcquisitionOptionsHeavyOPFOR = [['Kamysh', 'O_APC_Tracked_02_cannon_F', 500]];
baseVehicleAcquisitionOptionsAirOPFOR = [['Orca (Unarmed)', 'O_Heli_Light_02_unarmed_F', 450], ['Orca (Armed)', 'O_Heli_Light_02_F', 1000]];
baseVehicleAcquisitionOptionsNavyOPFOR = [['Speedboat Minigun', 'O_Boat_Armed_01_hmg_F', 100], ['Assault Boat', 'O_Boat_Transport_01_F', 50], ['Micro Submarine', 'O_SDV_01_F', 100]];

baseAIAcquisitionOptionsBLUFOR = [['Crewman', 'B_crew_F', 50], ['Rifleman', 'B_Soldier_F', 200], ['Autorifleman', 'B_soldier_AR_F', 250], ['Rifleman Anti-Tank', 'B_soldier_LAT_F', 350], ['Rifleman Anti-Air', 'B_soldier_AA_F', 400]];

baseAIAcquisitionOptionsOPFOR = [['Crewman', 'O_crew_F', 50], ['Rifleman', 'O_Soldier_F', 200], ['Autorifleman', 'O_soldier_AR_F', 250], ['Rifleman Anti-Tank', 'O_soldier_LAT_F', 350], ['Rifleman Anti-Air', 'O_soldier_AA_F', 400]];

replenishStaticDefencesIntervalSeconds = 420;

// FOBs
FOBRadius = 50;
FOBBuildRadius = FOBRadius + 20;
FOBSupplyCost = 1500;
FOBExclusiveEstablishmentRadius = 300;
FOBStartingSupply = 500;
FOBFlagPositionYOffset = 2.78288;
FOBBuildableObjects = [['Concrete Wall', 'Land_CncWall4_F', 50], ['Block Defence', 'Land_HBarrier_1_F', 25], ['Sandbag', 'Land_BagFence_Long_F', 10], ['Halogen Light', 'Land_LampHalogen_F', 100], ['Static HMG', 'B_HMG_01_high_F', 150], ['Static AT', 'B_static_AT_F', 200], ['Static AA', 'B_static_AA_F', 200], ['Guard Tower (Small)', 'Land_Cargo_Patrol_V1_F', 150], ['Bunker Small', 'Land_BagBunker_Small_F', 200]];
FOBVehicleAcquisitionOptionsBLUFOR = [['Quadbike', 'B_Quadbike_01_F', 50], ['Offroad', 'B_G_Offroad_01_F', 150]];
FOBVehicleAcquisitionOptionsOPFOR = [['Quadbike', 'O_Quadbike_01_F', 50], ['Offroad', 'O_G_Offroad_01_F', 150]];
FOBAIAcquisitionOptionsBLUFOR = [['Rifleman', 'B_Soldier_F', 200]];
FOBAIAcquisitionOptionsOPFOR = [['Rifleman', 'O_Soldier_F', 200]];
FOBObjectEngineName = 'Land_BagBunker_Tower_F';
FOBInfluenceAmount = 0.5;

// Auxiliary
auxiliaryRoadblockSupplyCost = 350;
auxiliaryRoadblockExclusiveEstablishmentRadius = 350;
auxiliaryMaximumUnits = 100;
auxiliaryGroupAvailableUnits = [['Rifleman', ['B_Soldier_F', 'O_Soldier_F'], 50], ['Autorifleman', ['B_soldier_AR_F', 'O_soldier_AR_F'], 75], ['Medic', ['B_medic_F', 'O_medic_F'], 75], ['Rifleman Anti-Tank', ['B_soldier_LAT_F', 'O_soldier_LAT_F'], 100], ['Rifleman Anti-Air', ['B_soldier_AA_F', 'O_soldier_AA_F'], 100]];
auxiliaryBasePatrolMaximumRadius = baseRadius * 2;
auxiliaryGroupRoadblockMemberLimit = 3;
auxiliaryGroupPatrolMemberLimit = 4;
auxiliaryRoadblockAttackNotificationDelay = 15;
auxiliaryRoadblockDespawnDelay = 120;
auxiliaryRoadblockDespawnMapMarkerDelay = 180;

// Rewards
playerKillReward = 200;
playerKillRewardDelaySeconds = 300;

// Provinces
//provinces = [['province0', 'First Province', [[7851.46,12042.3,0], [7517.74,5815.16,0], [14930.7,5403.33,0], [12828.9,16089.6,0], [11962.7,16132.2,0]]]];
provinces = [['province0', 'First Province', [[2677.79,22103.4],[2677.79,22103.4],[2210.42,17940],[10384,17880.7],[13257.6,23349.4],[8616.33,24004.4],[3679.02,22656.7]], [[[8643.05,18264.3,0], 200], [[4585.03,21396.8,0], 200], [[9445.52,20235.8,0], 200]]], ['province1', 'Second Province', [[3834.48,15869.9],[9964.3,15040.3],[11029,17606.9],[3637.19,17837.7],[3637.19,17837.7]], [[[3937.88,17208.4,0], 500], [[7107.97,16436.9,0], 400], [[9286.36,15857.2,0], 500]]], ['province2', 'Third Province', [[14616.4,21316.5],[14616.4,21316.5],[12152.5,20024.2],[11037.7,18021.9],[13118.2,17255],[17442,20566.1]], [[[14040,18630.1,0], 600], [[14627.3,20766,0], 200]]], ['province3', 'Fourth Province', [[12029.4,16609.6],[12029.4,16609.6],[8335.47,11909.3],[9765.02,10712.7],[11849.5,12526.4],[13745.1,15152.5]], [[[9232.4307, 11886.366, 17.094887], 500], [[10657.2,12246.5,0], 300], [[10973.1,13420.5,0], 400], [[12517.5,14350.9,0], 300], [[12348.8,15659,0], 400]]], ['province4', 'Fifth Province', [[4734.77,15260.5],[4734.77,15260.5],[3204.36,14992.4],[2640.23,13199.5],[2539.69,11294.8],[2316.27,9473.95],[3142.92,9256.12],[5360.35,9362.25],[7239.16,12195.4]], [[[3709.26,13332.6,0], 500]]], ['province5', 'Sixth Province', [[14365.2,18049.3],[14365.2,18049.3],[13186.2,16156.9],[14152.2,15270.2],[18551.2,14789.6],[19720.3,17217],[18115.3,18336.6]], [[[14475.8,17682,0], 200], [[18257.8,15319.9,0.00128746], 400], [[18820.6,16602.5,0.0014267], 400], [[16302.3,17082.3,0.00152206], 400]]], ['province6', 'Seventh Province', [[19395.7,13699.3],[19395.7,13699.3],[16346.1,13124],[14368.8,10973.6],[14530.8,10398.3],[15963.8,10379.7],[21216,11512.2],[20671.2,13071.9]], [[[17080.6,12665.5,0.001441], 800]]], ['province7', 'Eighth Province', [[19216.4,15580.1],[19216.4,15580.1],[19015.3,14731.1],[21718.7,13742.4],[24774.1,20016.7],[23718,20655.8],[20394.3,17485.8]], [[[20959.1,16964.7,0], 600], [[21349.4,16355.1,0.00139618], 300]]], ['province8', 'Ninth Province', [[24767.9,21830.9],[24767.9,21830.9],[25362.3,20624.7],[27387.6,21067.1],[27598.5,23296.4],[28822,25822.8],[27978.7,26140.8],[25614.6,24160.4]], [[[25640.1,21292.9,0], 600]]], ['province9', 'Tenth Province', [[21245.7,11125.8],[21245.7,11125.8],[18669.7,8886.63],[20304.4,5607.18],[23544.3,6969.49],[23460,7692.75],[21894.6,11333.8]], [[[21679.7,7551.1,0], 300], [[21679.7,7551.1,0], 200], [[21679.7,7551.1,0], 300]]]];
townDefenceStandardPatrolGroupsAmount = 10;
townDefenceStandardPatrolGroupUnitsSize = 6;
townDefenceScaledPatrolGroupsAmountLarge = 14;
townDefenceScaledRoadPatrolGroupsProportion = 0.4;
townDefenceScaledFreePatrolGroupsProportion = 0.6;
townDefencePatrolVehiclesAmount = 2;
townDefenceBuildingDefenceUnitsAmount = 20;
townDefenceCoordinationIntervalSeconds = 15;
townDefenceCoordinationBackupThresholdSeconds = 10;
townDefenceSurrenderThresholdPercentage = 0.3;
townDefenceSurrenderDelayInSeconds = 300;
townDefenceDefeatParticipationSupplyQuotaReward = 500;
townDefenceRiflemanKillSupplyQuotaReward = 50;
townDefenceAutoriflemanKillSupplyQuotaReward = 50;
townDefenceMarksmanKillSupplyQuotaReward = 50;
townDefenceOfficerKillSupplyQuotaReward = 50;
townDefenceAntiTankKillSupplyQuotaReward = 100;
townDefenceAntiAirKillSupplyQuotaReward = 150;
townDefenceOffroadPatrolVehicleKillSupplyQuotaReward = 300;
townDefenceMoraKillSupplyQuotaReward = 300;
townDefenceAIStartingDamage = 0.5;
townDefenceAISkillAimingAccuracy = 0.5;
townDefenceAISkillAimingShake = 0.5;
townDefenceAISkillSpotDistance = 0.7;
townDefenceAIGroupBackupDeceasedUnitsThreshold = 0.5;
townDefenceAIKnowsAboutSpotThreshold = 1.5;
removeTownDefenceRewardActionIntervalInSeconds = 300;

// Supply
supplyRelayStationSupplyCost = 150;
supplyRelayStationRadius = 300;
supplyRelayStationProcessTimeInSeconds = 10;
supplyRelayStationSupplyCapacity = 200;
manageSupplyRelaysStartMessage = 'Left-click on a base for a new supply relay station construction vehicle to be deployed from.<br/><br/>Shift right-click to remove a supply relay station (currently nonfunctional).';

supplyTransportationVehicleMobileRespawnVehicleTransferRadius = 50;
supplyTransportationVehicleSupplyCapacity = 1000;

personalSupplyQuotaStartingAmount = 500;

regularSupplyIncomeInterval = 10;
regularSupplyIncomeInfluenceAmount = 2000;
regularSupplyIncomeProvinceAmount = 50;
regularSupplyIncomeDefaultQuotaProportion = 0.5;
regularSupplyIncomeObjectiveReward = 5;

// Objectives
objectiveMaximumSimultaneous = 1;
objectiveRadius = 1000;

// Missions
missionRemoteConstructionPositionRadius = 100;

// Elections
commanderElectionStandLengthInSeconds = 10;
commanderElectionLengthInSeconds = 20;
commanderChallengeElectionRebutPeriodInSeconds = 0;
commanderChallengeElectionChallengePeriodInSeconds = 20;
challengeElectionRationaleMinimumLength = 8;
challengeElectionRationaleCharacterLimit = 140;
challengeElectionRebuttalMinimumLength = 8;
challengeElectionRebuttalCharacterLimit = 140;

// HUD
panelHUDUpdateIntervalInSeconds = 5;
teamsInformationHUDUpdateIntervalInSeconds = 30;
vehicleOccupancyHUDUpdateIntervalInSeconds = 5;

// Sling Loading
slingLoadingMaximumMassBLUFOR = 4000;
slingLoadingMaximumMassOPFOR = 2000;
slingLoadingPrepareDuration = 180;
slingLoadingManualHookDuration = 180;
slingLoadingManualHookLength = 7;

// Spot
manualSpotRenewInterval = 5;
manualSpotDelayedRemovalInterval = 20;

// Build View
buildViewStartingAltitude = 30;
buildViewMaximumAltitude = 50;

// Cheats
townDefenceCheat = false;
commanderCheat = false;

// Colours
colourTeamMapMarkersBLUFOR = 'ColorBlue';
colourTeamMapMarkersOPFOR = 'ColorRed';
colourTeamMapDrawingsBLUFOR = [0, 0, 1, 1];
//colourTeamMapDrawingsBLUFOR = [0.419, 0.729, 1, 0.9];
colourTeamMapDrawingsOPFOR = [1, 0, 0, 1];
colourTeamMapDrawingsDeceased = [0.518, 0.518, 0.518, 1];
colourTeamMapDrawingsIndependent = [0, 1, 0, 1];

// Loadouts
defaultLoadoutBLUFOR = ["U_B_CombatUniform_mcam","V_PlateCarrier1_rgr","","H_HelmetB","",[["arifle_MX_ACO_pointer_F","","acc_pointer_IR","optic_Aco",["30Rnd_65x39_caseless_mag",30],""],["hgun_P07_F","","","",["16Rnd_9x21_Mag",16],""]],["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","NVGoggles"],["FirstAidKit","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","Chemlight_green"],["30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","30Rnd_65x39_caseless_mag","16Rnd_9x21_Mag","16Rnd_9x21_Mag","SmokeShell","SmokeShellGreen","Chemlight_green","HandGrenade","HandGrenade"],[]];
defaultLoadoutOPFOR = ["U_O_CombatUniform_ocamo","V_HarnessO_brn","","H_HelmetO_ocamo","",[["arifle_Katiba_ACO_pointer_F","","acc_pointer_IR","optic_ACO_grn",["30Rnd_65x39_caseless_green",30],""],["hgun_Rook40_F","","","",["16Rnd_9x21_Mag",16],""]],["ItemMap","ItemCompass","ItemWatch","ItemRadio","ItemGPS","NVGoggles_OPFOR"],["FirstAidKit","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","Chemlight_red"],["30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","16Rnd_9x21_Mag","16Rnd_9x21_Mag","HandGrenade","HandGrenade","SmokeShell","SmokeShellRed","Chemlight_red"],[]];

// Screen Display ID
screenDisplayID = 46;
mapDisplayID = 12;

// Textures
textureMapBLUFORTerritory = '#(rgb,8,8,3)color(0,0,1,0.3)';
textureMapOPFORTerritory = '#(rgb,8,8,3)color(1,0,0,0.3)';
textureMapNeutralTerritory = '#(rgb,8,8,3)color(0,0,0,0.3)';

// Diary Entries
gameModeDiaryEntryDescriptionIntroduction = 'Welcome to Influence. You are part of a team, whose objective it is to capture hostile bases. You may acquire equipment, vehicles, and AI through the scroll menu. Make sure to check the map on a regular basis to be apprised of objectives and other battlefield intelligence, and to communicate and coordinate with your team.';
gameModeDiaryEntryDescriptionBases = 'Bases are the most important element in Influence. Players spawn at them, and they provide facilities, necessary to acquire assets such as equipment and vehicles. They also emit influence, providing team income. Bases come in two forms: bases and FOBs. Bases provide all facilities, while FOBs are more limited.<br/><br/>Bases can be captured by a hostile team if players are within the capture radius of the base for a period of time. Capture progress will be indicated by a progress bar for those players within the capture radius.';
gameModeDiaryEntryDescriptionSupply = 'Equipment, vehicles, AI, and other assets are acquired through the expenditure of supply, symbolised by the euro symbol €. Supply only exists in bases, and is shared by the team as a whole.<br/><br/>Players possess a supply quota, which entitles them to expend a certain amount of the team supply. Players obtain the bulk of their quota from a regular dividend determined by their commander, which is sourced from the regular team supply income. In addition to this, players may supplement their income with bonuses, such as those obtained by participating in defeating province resistance, or pursuing objectives.';
gameModeDiaryEntryDescriptionCommanders = 'Commanders are responsible for managing team resources and assets, and determining objectives. They are elected by their team.';
gameModeDiaryEntryDescriptionInfluence = 'Bases emit influence. Influence is visible on the map, represented by team colour. The principal source of supply for a team derives from their influence, in the form of a regular income.';
gameModeDiaryEntryDescriptionProvinces = 'Provinces can provide an income bonus to teams. In order for this bonus to be achieved, a team must establish at least one base or FOB within a province. The team must also prevent the opposing team from establishing any base or FOB within the province. If both teams have at least one base or FOB within a province, the province is neutralised and neither team obtains a bonus.<br/><br/>Before a province may be controlled by a team or neutralised by both teams, players must first defeat the province resistance. An area will be marked on the map, indicating where resistance has appeared. Resistance takes the form of AI. Players will receive rewards for killing AI, in addition to a participation award. Once the AI has been largely defeated, the resistance will despawn and the province become either captured by one team, or neutralised by both.';
gameModeDiaryEntryDescriptionMissions = 'Missions are vital tasks issued by the commander which need to be completed. These include the establishment of bases, FOBs, and roadblocks. Players may only accept one mission at a time.';
gameModeDiaryEntryDescriptionOperationalHUD = 'The Operational HUD may be toggled as enabled or disabled by pressing the WINDOWS key.<br/><br/>The Operational HUD displays 3D battlefield intelligence in the game world. This includes friendly units.';
gameModeDiaryEntryDescriptionSpotting = 'Influence provides a limited spotting mechanism. You may spot bases and vehicles. Spotted hostile bases will be visible on the map permanently, just as friendly bases are. Spotted vehicles will appear on the map and in the Operational HUD.<br/><br/>In order to spot, you must have a laser designator with a battery. The action ‘Spot’ will appear in your scroll menu if you activate your laser designator and point it towards an object that can be spotted. You will receive a notification if you spot a hostile base. If you spot a vehicle, the spotted location will update on a regular interval, rather than in realtime, so long as you maintain laser designation. If you stop laser designation, the spotted location will disappear after a period of time.';
gameModeDiaryEntryDescriptionSlingLoading = 'Influence affords players the opportunity to sling load all land and sea vehicles with the non-DLC helicopter that is capable of lifting the most weight on each team. In reality, this means that players wishing to sling load vehicles should use the Ghost Hawk as BLUFOR, or the Orca as OPFOR.<br/><br/>In order for a vehicle to be sling loaded, it must first be prepared for sling loading. Vehicles can be prepared for sling loading by approaching the vehicle and selecting the option ‘Prepare Sling Loading’ in the scroll menu. If the vehicle is not owned by the person preparing it for sling loading, if the owner of the vehicle is online, they must approve sling loading preparation.<br/><br/>Once the vehicle is prepared for sling loading, any helicopter should be able to hover above the vehicle, and either employ the native ‘Hook’ scroll menu action, or the Influence ‘Manual Hook’ scroll menu action. The former is only available for a small selection of vehicles, while the latter is available for all.';

// Key Codes
keyCodeA = 0x1E;
keyCodeB = 0x30;
keyCodeC = 0x2E;
keyCodeD = 0x20;
keyCodeE = 0x12;
keyCodeF = 0x21;
keyCodeG = 0x22;
keyCodeH = 0x23;
keyCodeI = 0x17;
keyCodeJ = 0x24;
keyCodeK = 0x25;
keyCodeL = 0x26;
keyCodeM = 0x32;
keyCodeN = 0x31;
keyCodeO = 0x18;
keyCodeP = 0x19;
keyCodeQ = 0x10;
keyCodeR = 0x13;
keyCodeS = 0x1F;
keyCodeT = 0x14;
keyCodeU = 0x16;
keyCodeV = 0x2F;
keyCodeW = 0x11;
keyCodeX = 0x2D;
keyCodeY = 0x15;
keyCodeZ = 0x2C;

keyCodeESCAPE = 0x01;
keyCodeTAB = 0x0F;
keyCodeLSHIFT = 0x2A;
keyCodeRSHIFT = 0x36;
keyCodeLCONTROL = 0x1D;
keyCodeRCONTROL = 0x9D;
keyCodeBACK = 0x0E;
keyCodeBACKSPACE = keyCodeBACK;
keyCodeRETURN = 0x1C;
keyCodeNUMPADENTER = 0x9C;
keyCodeLMENU =  0x38;
keyCodeLALT = keyCodeLMENU;
keyCodeSPACE =  0x39;
keyCodeCAPITAL =  0x3A;
keyCodeCAPSLOCK = keyCodeCAPITAL;
keyCodeNUMLOCK =  0x45;
keyCodeSCROLL = 0x46;
keyCodeRMENU =  0xB8;
keyCodeRALT = keyCodeRMENU;
keyCodeLWIN = 0xDB;

keyCodeDELETE = 0xD3;