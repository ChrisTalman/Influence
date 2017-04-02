// Particle ring field identifiers
#define PRING_FIELD_POS 0
#define PRING_FIELD_RAD 1
#define PRING_FIELD_COL 2
#define PRING_FIELD_VEL 3
#define PRING_FIELD_CNT 4
#define PRING_FIELD_EMS 5

// Create a particle ring
// Params
//  arr pos			: centre position
//	float radius	: ring radius
//	arr colour		: smoke colour
//	float speed		: rotation speed (deg/s, can be negative)
//  int sources		: number of particle emitters
// Returns
//  particle ring array (opaque)
pringCreate =
{
	private ["_pos", "_radius", "_colour", "_sources", "_speed", "_ret"];
	_pos = _this select 0;
	_rad = _this select 1;
	_col = _this select 2;
	_vel = _this select 3;
	_cnt = _this select 4;
	
	_ret = [_pos, _rad, _col, _vel, _cnt, []];
	[_ret] call pringEmittersInit;
	[_ret] call pringUpdate;
	
	/*return*/_ret;
};

// Destroy a particle ring
// Params
//  arr pring : particle ring array
pringDestroy =
{
	[_this select 0] call pringEmittersClear;
};

// ! INTERNAL !
// Create particle emitters
// Params
//  arr pring : particle ring array
pringEmittersInit =
{
	private ["_pring", "_cnt", "_col", "_colEnd", "_spacing", "_ems", "_ps"];
	_pring = _this select 0;
	_cnt = _pring select PRING_FIELD_CNT;
	_col = _pring select PRING_FIELD_COL;
	
	_colEnd = [_col select 0, _col select 1, _col select 2, 0];
	_spacing = 360.0 / _cnt;	
	_ems = [];
	
	for "_i" from 0 to _cnt do
	{
		_ps = "#particlesource" createVehicleLocal [0,0,0];
		_ps setParticleClass "AutoCannonFired";		
		_ps setParticleParams [
			/*Sprite*/			["\A3\data_f\ParticleEffects\Universal\Universal",16,12,8,1],"",// File,Ntieth,Index,Count,Loop(Bool)
			/*Type*/			"Billboard",
			/*TimmerPer*/		1,
			/*Lifetime*/		2.5,
			/*Position*/		[0,0,0],
			/*MoveVelocity*/	[0,0,0.0],
			/*Simulation*/		0.01,1.30,1,5.5,//rotationVel,weight,volume,rubbing
			/*Scale*/			[0.3,0.5,0.8,0.8,0.5],
			/*Color*/			[_col, _col, _col, _colEnd],
			/*AnimSpeed*/		[1.5,0.5],
			/*randDirPeriod*/	0.0,
			/*randDirIntesity*/	0.000,
			/*onTimerScript*/	"",
			/*DestroyScript*/	"",
			/*Follow*/			_ps,
			/*Angle*/           0,
			/*onSurface*/       false,
			/*bounceOnSurface*/ 1,
			/*emissiveColor*/   [[0.5,0.5,0.5,0]]
		];			
		_ps setDropInterval 0.005;		
		_ems pushBack [_i * _spacing, _ps];
	};
	
	_pring set [PRING_FIELD_EMS, _ems];
};

// ! INTERNAL !
// Destroy particle emitters
// Params
//  arr pring : particle ring array
pringEmittersClear =
{
	private ["_pring", "_ems"];
	_pring = _this select 0;
	_ems = _pring select PRING_FIELD_EMS;
	
	{
		deleteVehicle (_x select 1);
	} forEach _ems;
	
	_pring set [PRING_FIELD_EMS, []];
};

// Update particle ring
// Params
//  arr pring : particle ring array
pringUpdate =
{
	private ["_pring", "_pos", "_rad", "_vel", "_ems", "_a0", "_ps", "_dx", "_dy"];
	_pring = _this select 0;
	_pos = _pring select PRING_FIELD_POS;
	_rad = _pring select PRING_FIELD_RAD;
	_vel = _pring select PRING_FIELD_VEL;
	_ems = _pring select PRING_FIELD_EMS;
	
	{
		_a0 = _x select 0;
		_ps = _x select 1;
		
		_a = _a0 + (_vel * time);
		_dx = (cos _a) * _rad;
		_dy = (sin _a) * _rad;
		
		_ps setPosATL [(_pos select 0) + _dx, (_pos select 1) + _dy, 0.1];
	} forEach _ems;
};

// Set particle emitter count
// Params
//  arr pring   : particle ring array
//  int sources : number of particle emitters
pringSetEmitters =
{
	private ["_pring", "_cnt"];
	_pring = _this select 0;
	_cnt = _this select 1;
	
	[_pring] call pringEmittersClear;
	_pring set [PRING_FIELD_CNT, _cnt];
	[_pring] call pringEmittersInit;
};