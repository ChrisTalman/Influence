// Influence map field identifiers
#define IMAP_FIELD_SIZE 0
#define IMAP_FIELD_WSIZE 1
#define IMAP_FIELD_LAYERS 2
#define IMAP_FIELD_BACKBUFFER 3
#define IMAP_FIELD_RENDERERS 4
#define IMAP_FIELD_DIRTY 5
#define IMAP_FIELD_LOCKED 6
#define IMAP_FIELD_COVERAGE 7
#define IMAP_FIELD_TOTAL 8

// Create a new influence map
// Params
//	int numLayers	: number of unique layers in the map
//	int size		: side length in grid cells (map is square)
//	float wsize		: side length in world units
// Returns
//	influence map array (opaque)
imapCreate =
{
	private ["_numLayers", "_size", "_wsize", "_layers", "_bbuf", "_coverage", "_total"];	
	_numLayers = _this select 0;
	_size = _this select 1;
	_wsize = _this select 2;	
	_layers = [];
	_bbuf = [_size] call imapCreateLayer;
	
	for [{_i=0},{_i<_numLayers},{_i=_i+1}] do
	{
		_layers = _layers + [[_size] call imapCreateLayer];
	};
	
	_coverage = [_size, _wsize] call imapComputeCoverage;
	_total = 0;
	{
		_total = _total + _x;
	} forEach _coverage;
	
	/*return*/[_size, _wsize, _layers, _bbuf, [], false, false, _coverage, _total];
};

// ! INTERNAL !
// Create a new map layer
// Params
//	int size : side length in grid cells
// Returns
//	data array full of 0.0
imapCreateLayer =
{
	private ["_size", "_res", "_layer"];	
	_size = _this select 0;	
	_res = _size * _size;	
	_layer = [];
	
	_layer resize _res;
	for [{_i=0},{_i<_res},{_i=_i+1}] do
	{
		_layer set [_i, 0.0];
	};
	
	/*return*/_layer;
};

// ! INTERNAL !
// Compute land coverage of each grid cell
// Params
//	int size    : side length in grid cells
//	float wsize : side length in world units
// Returns
//	coverage array
imapComputeCoverage =
{
	private ["_SAMPLES"];
	_SAMPLES = 16; // _SAMPLES*_SAMPLES per cell

	private ["_size", "_wsize"];
	_size = _this select 0;
	_wsize = _this select 1;
	
	private ["_csize", "_step", "_weight"];
	_csize = _wsize / _size;
	_step = _csize / _SAMPLES;
	_weight = 1 / (_SAMPLES * _SAMPLES);
	
	private ["_res", "_cov"];
	_res = _size * _size;	
	_cov = [];	
	_cov resize _res;
	
	private ["_i", "_j", "_idx", "_x0", "_y0", "_val", "_i2", "_j2", "_x", "_y"];
	for [{_j=0},{_j<_size},{_j=_j+1}] do
	{
		for [{_i=0},{_i<_size},{_i=_i+1}] do
		{
			_idx = _j * _size + _i;
			_x0 = _i * _csize;
			_y0 = _j * _csize;
			_val = 0;
			
			for [{_j2=0},{_j2<_SAMPLES},{_j2=_j2+1}] do
			{
				_y = _y0 + (_j2+0.5) * _step;
				for [{_i2=0},{_i2<_SAMPLES},{_i2=_i2+1}] do
				{
					_x = _x0 + (_i2+0.5) * _step;
					if (!surfaceIsWater [_x, _y]) then
					{
						_val = _val + _weight;
					};
				};
			};
			_cov set [_idx, _val];
		};
		//hint format ["Computing coverage (%1%2)", floor (100*(_j+1)/_size), "%"];
	};	
	
	/*return*/_cov;
};

// ! INTERNAL !
// Construct a 5x5 guassian kernel, returns the 3 values required for a 2-pass application
// Explanation
//	In a 5x5 gaussian kernel, all values sharing the same letter below are equal
//	   0 1 2 3 4
//	 0 a b c b a
//	 1 b d e d b
//	 2 c e f e c
//	 3 b d e d b
//	 4 a b c b a
//	For a 2-pass application, all we need is row 2, as a normalised 5x1 matrix (which equates to only 3 unique values)
// Params
//	float scale : sigma scale
// Returns
//	3 unique values from the 5x1 separated kernel (cell coordinates refer to example 5x5 matrix above)
//	[(2,2), (3,2), (4,2)]
imapCreateGaussianKernel =
{
	private ["_scale"];	
	_scale = _this select 0;

	// Kernel radius is 2 (5=2*2+1)
	// We want the range to be -2*sigma to 2*sigma
	// sigma = scale * (radius / 2) = scale
	private ["_sigma"];
	_sigma = _scale;
	
	// Compute the gaussian value of the 3 cells we care about
	private ["_m0", "_m1", "_m2"];
	#define GAUSSIAN(pos) exp(-((pos/_sigma) * (pos/_sigma)) / 2.0)
	_m0 = GAUSSIAN(0);
	_m1 = GAUSSIAN(1);
	_m2 = GAUSSIAN(2);
	#undef GAUSSIAN
	
	// Normalise the 5x1 matrix
	private ["_sum"];
	_sum = _m0 + 2 * (_m1 + _m2);
	_m0 = _m0 / _sum;
	_m1 = _m1 / _sum;
	_m2 = _m2 / _sum;
	
	/*return*/[_m0, _m1, _m2];
};

// Get an influence map layer
// Params
//	arr imap	: influence map
//	int layer	: layer index (if zero, backbuffer is returned)
// Returns
//	data array
imapGetLayer =
{
	private ["_imap", "_layer", "_data"];	
	_imap = _this select 0;
	_layer = _this select 1;	
	_data = _imap select IMAP_FIELD_BACKBUFFER;
	
	if (_layer > 0) then
	{
		_data = (_imap select IMAP_FIELD_LAYERS) select _layer;
	};
	
	/*return*/_data;
};

// Get a cleared map layer (filled with 0.0)
// Params
//	arr imap	: influence map
//	int layer	: layer index
// Returns
//	data array
imapClearLayer =
{
	private ["_imap", "_layer", "_size", "_res", "_data"];	
	_imap = _this select 0;
	_layer = _this select 1;	
	_size = _imap select IMAP_FIELD_SIZE;
	_res = _size * _size;	
	_data = [_imap, _layer] call imapGetLayer;

	for [{_i=0},{_i<_res},{_i=_i+1}] do
	{
		_data set [_i, 0.0];
	};
	
	/*return*/_data;
};

// Read an influence value (with bilinear interpolation)
// Params
//	arr imap	: influence map
//	int layer	: layer index
//	float x		: sample x position (world)
//	float y		: sample y position (world)
// Returns
//	influence value sampled from the 4 nearest cells
imapRead =
{
	private ["_imap", "_layer", "_wx", "_wy"];	
	_imap = _this select 0;
	_layer = _this select 1;
	_wx = _this select 2;
	_wy = _this select 3;
	
	// Get local coords
	private ["_size", "_wsize", "_x", "_y"];
	_size = _imap select IMAP_FIELD_SIZE;
	_wsize = _imap select IMAP_FIELD_WSIZE;
	_x = _wx * _size / _wsize;
	_y = _wy * _size / _wsize;
	
	// Read
	private ["_val", "_i", "_j", "_dx", "_dy", "_data"];
	_val = 0;	
	if (_x > 0.5 && _x < _size-0.5 && _y > 0.5 && _y < _size-0.5) then
	{
		// Offset coords so 0.5,0.5 will sample the center of cell 0,0
		_x = _x - 0.5;
		_y = _y - 0.5;
		
		// Get base cell coords and mu values
		_i = floor _x;
		_j = floor _y;
		_dx = _x - _i;
		_dy = _y - _j;
		
		// Read weighted values
		_data = (_imap select IMAP_FIELD_LAYERS) select _layer;
		_val =
			(_data select ((_j  )*_size + (_i  ))) * (1-_dy) * (1-_dx) +
			(_data select ((_j  )*_size + (_i+1))) * (1-_dy) * (  _dx) +
			(_data select ((_j+1)*_size + (_i  ))) * (  _dy) * (1-_dx) +
			(_data select ((_j+1)*_size + (_i+1))) * (  _dy) * (  _dx);
	};
	
	/*return*/_val;
};

// Add influence to the map (spread across the 4 nearest cells)
// Params
//	arr imap	: influence map
//	int layer	: layer index
//	arr pos		: sample x/y position (world)
//	float amt	: amount of influence to add
imapAdd =
{
	private ["_imap", "_layer", "_pos", "_amount", "_wx", "_wy"];
	_imap = _this select 0;
	_layer = _this select 1;
	_pos = _this select 2;
	_amount = _this select 3;	
	_wx = _pos select 0;
	_wy = _pos select 1;
	
	// Dirty the map
	_imap set [IMAP_FIELD_DIRTY, true];
	
	// Get local coords
	private ["_size", "_wsize", "_x", "_y"];
	_size = _imap select IMAP_FIELD_SIZE;
	_wsize = _imap select IMAP_FIELD_WSIZE;
	_x = _wx * _size / _wsize;
	_y = _wy * _size / _wsize;
	
	// Write
	private ["_i", "_j", "_dx", "_dy", "_data", "_idx"];
	if (_x > 0.5 && _x < _size-0.5 && _y > 0.5 && _y < _size-0.5) then
	{
		// Offset coords so 0.5,0.5 will sample the center of cell 0,0
		_x = _x - 0.5;
		_y = _y - 0.5;
		
		// Get base cell coords and mu values
		_i = floor _x;
		_j = floor _y;
		_dx = _x - _i;
		_dy = _y - _j;
		
		// Read weighted values
		_data = (_imap select IMAP_FIELD_LAYERS) select _layer;
		_idx = (_j  )*_size + (_i  );
		_data set [_idx, (_data select _idx) + _amount * (1-_dy) * (1-_dx)];
		_idx = (_j  )*_size + (_i+1);
		_data set [_idx, (_data select _idx) + _amount * (1-_dy) * (  _dx)];
		_idx = (_j+1)*_size + (_i  );
		_data set [_idx, (_data select _idx) + _amount * (  _dy) * (1-_dx)];
		_idx = (_j+1)*_size + (_i+1);
		_data set [_idx, (_data select _idx) + _amount * (  _dy) * (  _dx)];
	};
};

// Perform a diffusion / decay pass
// Params
//	arr imap	: influence map
//	int layer	: layer index
//	float speed	: diffusion speed (0 < speed <= 1), higher values give faster diffusion
//	float decay	: decay value (>=0), all values will approach zero by (at most) this amount
// Returns
//	array of total influence values per side [totalNegative, totalPositive]
imapUpdate =
{	
	private ["_imap", "_layer", "_speed", "_decay"];
	_imap = _this select 0;
	_layer = _this select 1;
	_speed = _this select 2;
	_decay = _this select 3;
	
	// Dirty the map
	_imap set [IMAP_FIELD_DIRTY, true];
	
	// We're doing a 5x5 gaussian blur, split into 2 passes
	// This 2-pass approach takes only 10 (5+5) samples per cell, compared to 25 (5*5) using the 5x5 kernel directly
	private ["_blur", "_m0", "_m1", "_m2"];
	_blur = [_speed] call imapCreateGaussianKernel;
	_m0 = _blur select 0;
	_m1 = _blur select 1;
	_m2 = _blur select 2;
	
	// Layer data and backbuffer
	private ["_buf0", "_buf1", "_size", "_coverage"];
	_buf0 = (_imap select IMAP_FIELD_LAYERS) select _layer;
	_buf1 = _imap select IMAP_FIELD_BACKBUFFER;
	_size = _imap select IMAP_FIELD_SIZE;
	_coverage = _imap select IMAP_FIELD_COVERAGE;
	
	// Totals
	private ["_totNeg", "_totPos"];
	_totNeg = 0;
	_totPos = 0;
	
	// Diffuse
	private ["_i", "_j", "_idx"];
	// Blur pass 1 : from layer to backbuffer, blur horizontally
	for [{_j=2},{_j<_size-2},{_j=_j+1}] do
	{
		for [{_i=2},{_i<_size-2},{_i=_i+1}] do
		{
			_idx = _j * _size + _i;
			if ((_coverage select _idx) > 0.001) then
			{
				_buf1 set [_idx,
					_m2 * (_buf0 select (_idx-2)) +
					_m1 * (_buf0 select (_idx-1)) +
					_m0 * (_buf0 select (_idx  )) +
					_m1 * (_buf0 select (_idx+1)) +
					_m2 * (_buf0 select (_idx+2))
				];
			}
		};
	};	
	// Blur pass 2 : from backbuffer to layer, blur vertically
	for [{_j=2},{_j<_size-2},{_j=_j+1}] do
	{
		for [{_i=2},{_i<_size-2},{_i=_i+1}] do
		{
			_idx = _j * _size + _i;
			if ((_coverage select _idx) > 0.001) then
			{
				_buf0 set [_idx,
					_m2 * (_buf1 select (_idx-2*_size)) +
					_m1 * (_buf1 select (_idx-  _size)) +
					_m0 * (_buf1 select (_idx        )) +
					_m1 * (_buf1 select (_idx+  _size)) +
					_m2 * (_buf1 select (_idx+2*_size))
				];
			};
		};
	};

	// Decay, clamp and calculate totals
	private ["_val", "_abs", "_cov"];
	for [{_j=0},{_j<_size},{_j=_j+1}] do
	{
		for [{_i=0},{_i<_size},{_i=_i+1}] do
		{
			_idx = _j * _size + _i;
			_val = _buf0 select _idx;
			_abs = abs _val;
			_cov = _coverage select _idx;
			
			if (_abs > _decay) then
			{
				_val = _val - (_decay min _abs) * (_val / _abs); // why no sign function BIS?!
			}
			else
			{
				_val = 0.0;
			};
			
			_val = (-_cov max (_val min _cov));
			_buf0 set [_idx, _val];
			
			if (_val < 0) then {
				_totNeg = _totNeg - _val;
			} else {
				_totPos = _totPos + _val;
			};
		};
	};
	
	// Return totals
	private ["_total"];
	_total = (_imap select IMAP_FIELD_TOTAL);
	/*return*/[_totNeg / _total, _totPos / _total];
};

// Lock/unlock the map
// Params
//	arr imap	: influence map
//	bool lock	: true=lock, false=unlock
imapSetLock =
{	
	private ["_imap", "_lock", "_rends", "_dirty"];
	_imap = _this select 0;
	_lock = _this select 1;
	_rends = _imap select IMAP_FIELD_RENDERERS;
	_dirty = _imap select IMAP_FIELD_DIRTY;
	_locked = _imap select IMAP_FIELD_LOCKED;
	
	if (_lock && !_locked) then
	{
		// Lock
		_imap set [IMAP_FIELD_LOCKED, true];
		{
			_x set [1, true];
		} forEach _rends;
	}
	else
	{
		if (!_lock && _locked) then
		{
			// Unlock
			_imap set [IMAP_FIELD_LOCKED, false];
			{
				_x set [1, false];
			} forEach _rends;
			
			// Trigger renderer refresh
			if (_dirty) then
			{				
				_imap set [IMAP_FIELD_DIRTY, false];
				{
					_x set [0, true];
				} forEach _rends;
			};
		};
	};
};

// Get a state dump to send over the network
// WARNING: should be called from the main influence update loop, just after an update
// Params
//	arr imap	: influence map
imapGetDump =
{
	private ["_imap"];
	_imap = _this select 0;
	
	/*return*/(_imap select IMAP_FIELD_LAYERS);
};

// Set the state from a dump that was sent over the network
// Params
//	arr imap	: influence map
//  arr dump	: received state dump
imapSetDump =
{
	private ["_imap", "_dump"];
	_imap = _this select 0;
	_dump = _this select 1;
	
	[_imap, _dump] spawn
	{
		private ["_imap", "_dump"];
		_imap = _this select 0;
		_dump = _this select 1;
		
		waitUntil {!(_imap select IMAP_FIELD_LOCKED)};
		[_imap, true] call imapSetLock;
		_imap set [IMAP_FIELD_LAYERS, _dump];
		_imap set [IMAP_FIELD_DIRTY, true];
		[_imap, false] call imapSetLock;
	};
};

