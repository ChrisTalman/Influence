// Influence renderer field identifiers
#define IREN_FIELD_IMAP 0
#define IREN_FIELD_LAYER 1
#define IREN_FIELD_QUALITY 2
#define IREN_FIELD_CACHE 3
#define IREN_FIELD_STATE 4
#define IREN_FIELD_RADIUS 5
#define IREN_FIELD_VIEW 6

// View array field identifiers
#define IRENV_FIELD_X 0
#define IRENV_FIELD_Y 1
#define IRENV_FIELD_VPX0 2
#define IRENV_FIELD_VPY0 3
#define IRENV_FIELD_VPX1 4
#define IRENV_FIELD_VPY1 5
#define IRENV_FIELD_ZOOM 6
#define IRENV_FIELD_RADIUS 7

#define IMAP_FIELD_RENDERERS 4

// Create a new influence renderer
// You are expected to handle the draw hook yourself
// Params
//	arr imap	: influence map to render
//	int layer	: influence map layer to render
//	int quality	: maximum number of horizontal cells to display
// Returns
//	influence renderer array (opaque)
irenCreate =
{
	private ["_imap", "_layer", "_quality"];	
	_imap = _this select 0;
	_layer = _this select 1;
	_quality = _this select 2;
	
	// Create
	private ["_state", "_view"];
	_state = [true, false]; // dirty, unlocked
	_view = [0, 0, 0, 0, 0, 0, 1, 1];
	
	// Register with map
	_imap set [IMAP_FIELD_RENDERERS, (_imap select IMAP_FIELD_RENDERERS) + [_state]];

	/*return*/[_imap, _layer, _quality, [], _state, 1, _view];
};

// This should be called from the draw event handler of the attached control
// Params
//	arr iren	: influence renderer
//	ctrl ctrl	: map control to draw on
irenOnDraw =
{
	private ["_iren", "_ctrl"];	
	_iren = _this select 0;
	_ctrl = _this select 1;
	
	// Update view
	[_iren, _ctrl] call irenUpdateView;
	
	// Refresh
	private ["_state", "_dirty", "_locked"];
	_state = _iren select IREN_FIELD_STATE;
	_dirty = _state select 0;
	_locked = _state select 1;
	if (_dirty && !_locked) then
	{		
		private ["_imap"];
		_imap = _iren select IREN_FIELD_IMAP;
		[_iren, _ctrl] call irenRefresh;
	};
	
	// Draw
	[_iren, _ctrl] call irenDraw;
	
	/*return*/;
};

// Change the quality setting
// Params
//  arr iren	: influence renderer
//	int quality	: maximum number of horizontal cells to display
irenSetQuality =
{
	private ["_iren", "_quality", "_state"];
	_iren = _this select 0;
	_quality = _this select 1;
	
	_iren set [IREN_FIELD_QUALITY, _quality];
	_state = _iren select IREN_FIELD_STATE;
	_state set [0, true]; // dirty
};

// ! INTERNAL !
// Update view structure
// Will set dirty flag if new view incompatible with old one
// Params
//	arr iren	: influence renderer
//	ctrl ctrl	: map control to draw on
irenUpdateView =
{
	private ["_iren", "_ctrl", "_imap"];
	_iren = _this select 0;
	_ctrl = _this select 1;
	_imap = _iren select IREN_FIELD_IMAP;
	
	// Get view bounds
	private ["_cpos", "_p0", "_p1", "_x0", "_x1", "_y0", "_y1"];
	_cpos = ctrlPosition _ctrl;
	_p0 = _ctrl ctrlMapScreenToWorld [_cpos select 0, _cpos select 1];
	_p1 = _ctrl ctrlMapScreenToWorld [(_cpos select 0) + (_cpos select 2), (_cpos select 1) + (_cpos select 3)];
	_x0 = _p0 select 0;
	_x1 = _p1 select 0;
	_y0 = _p1 select 1;
	_y1 = _p0 select 1;
	
	// Compute zoom level
	private ["_size", "_wsize", "_csize", "_quality"];
	_size = _imap select 0;
	_wsize = _imap select 1;
	_csize = _wsize / _size;
	_quality = _iren select IREN_FIELD_QUALITY;
	
	// Round zoom to nearest power of 2
	private ["_zoom"];
	_zoom = _csize * _quality / (_x1 - _x0);
	if (_zoom >= 1) then
	{
		// Zoomed in
		_zoom = 1 max (floor _zoom);
		_zoom = floor ((ln _zoom) / (ln 2));
		_zoom = exp (_zoom * (ln 2));
	}
	else
	{
		// Zoomed out
		_zoom = 1.0 / _zoom;
		_zoom = ceil ((ln _zoom) / (ln 2));
		_zoom = exp (_zoom * (ln 2));
		_zoom = 1.0 / _zoom;
	};
	//hint format ["%1", _zoom];
	
	// Fetch previous view
	private ["_pview", "_pvpx0", "_pvpy0", "_pvpx1", "_pvpy1", "_pvzoom"];
	_pview = _iren select IREN_FIELD_VIEW;
	_pvpx0 = _pview select IRENV_FIELD_VPX0;
	_pvpy0 = _pview select IRENV_FIELD_VPY0;
	_pvpx1 = _pview select IRENV_FIELD_VPX1;
	_pvpy1 = _pview select IRENV_FIELD_VPY1;
	_pvzoom = _pview select IRENV_FIELD_ZOOM;
	
	// If we're at the same zoom level and the new viewport lies inside the rendered region, skip
	if (abs(_zoom-_pvzoom)>0.01 || _x0<_pvpx0 || _y0<_pvpy0 || _x1>_pvpx1 || _y1>_pvpy1) then
	{
		// Dirty
		(_iren select IREN_FIELD_STATE) set [0, true];
		
		// Compute new cell size
		private ["_rad"];
		_csize = _csize / _zoom;
		_rad = _csize * 0.5;
		
		// Find rendering origin
		private ["_coverage", "_startx", "_starty"];
		_coverage = _quality * _csize;
		_startx = (_x0 + _x1 - _coverage) * 0.5;
		_starty = (_y0 + _y1 - _coverage) * 0.5;
		
		// Align to grid
		//_startx = _startx - (_startx % _csize);
		//_starty = _starty - (_starty % _csize);		
		_startx = _csize * round (_startx / _csize);
		_starty = _csize * round (_starty / _csize);
		
		// Record
		_iren set [IREN_FIELD_VIEW, [
			_startx /*+ 0.5 * _csize*/,
			_starty /*+ 0.5 * _csize*/,
			_startx,
			_starty,
			_startx + _quality * _csize,
			_starty + _quality * _csize,
			_zoom,
			_rad
		]];
		//_iren set [IREN_FIELD_RADIUS, 0.5 * _csize];
		//hint format ["zoom : %1", _zoom];
		//hint format ["%1:%2 %3:%4 %5:%6 %7:%8", _x0,_pvpx0, _y0,_pvpy0, _x1,_pvpx1, _y1,_pvpy1];
	}
	
	/*return*/;
};

// ! INTERNAL !
// Refresh the cache
// Params
//	arr iren	: influence renderer
//	ctrl ctrl	: map control to
irenRefresh =
{
	disableSerialization;
	
	private ["_iren", "_ctrl", "_cache", "_imap", "_layer", "_state"];	
	_iren = _this select 0;
	_ctrl = _this select 1;
	_cache = [];
	_imap = _iren select IREN_FIELD_IMAP;
	_layer = _iren select IREN_FIELD_LAYER;
	_state = _iren select IREN_FIELD_STATE;
		
	// Get view
	private ["_view", "_vx", "_vy", "_rad", "_qual"];
	_view = _iren select IREN_FIELD_VIEW;
	_vx = _view select IRENV_FIELD_X;
	_vy = _view select IRENV_FIELD_Y;
	_rad = _view select IRENV_FIELD_RADIUS;
	_qual = _iren select IREN_FIELD_QUALITY;
	
	// Set new radius
	_iren set [IREN_FIELD_RADIUS, _rad];
	
	// Render
	private ["_i", "_j", "_x", "_y", "_val", "_r", "_g", "_b", "_a", "_col"];
	for [{_j=0},{_j<_qual},{_j=_j+1}] do
	{
		_y = _vy + (0.5 + _j) * (2 * _rad);
		for [{_i=0},{_i<_qual},{_i=_i+1}] do
		{
			_x = _vx + (0.5 + _i) * (2 * _rad);
			_val = [_imap, _layer, _x, _y] call imapRead;
			
			if (!surfaceIsWater [_x, _y]) then
			{			
				_r = (0.01 max (_val*10000.0 min 1.0));
				_g = 0.01;
				_b = (0.1 max (-_val*10000.0 min 1.0));
				_a = 0.05 * floor ((0.5 min (abs _val * 0.5)) * 20);
				
				if (_a > 0) then
				{
					_col = format ["#(rgb,8,8,3)color(%1,%2,%3,%4)", _r, _g, _b, _a];
					_cache pushBack [_x, _y, _col];
					//_ctrl drawRectangle [[_x, _y], _hdx, _hdy, 0, [1, 1, 1, 1], _col];
				};
			};
		};
	};

	_iren set [IREN_FIELD_CACHE, _cache];
	_state set [0, false]; // un-dirty
	
	/*return*/;
};

// ! INTERNAL !
// Draw
// Params
//	arr iren	: influence renderer
//	ctrl ctrl	: map control to
irenDraw =
{
	private ["_iren", "_ctrl", "_cache", "_rad"];	
	_iren = _this select 0;
	_ctrl = _this select 1;
	_cache = _iren select IREN_FIELD_CACHE;
	_rad = _iren select IREN_FIELD_RADIUS;
	
	// Draw
	{
		_rx = _x select 0;
		_ry = _x select 1;
		_rcol = _x select 2;
		_ctrl drawRectangle [[_rx, _ry], _rad, _rad, 0, [1, 1, 1, 1], _rcol];
	} forEach _cache;
};