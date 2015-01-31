(function ($hx_exports) { "use strict";
$hx_exports.coopy = $hx_exports.coopy || {};
var console = (1,eval)('this').console || {log:function(){}};
var HxOverrides = function() { };
HxOverrides.__name__ = true;
HxOverrides.dateStr = function(date) {
	var m = date.getMonth() + 1;
	var d = date.getDate();
	var h = date.getHours();
	var mi = date.getMinutes();
	var s = date.getSeconds();
	return date.getFullYear() + "-" + (m < 10?"0" + m:"" + m) + "-" + (d < 10?"0" + d:"" + d) + " " + (h < 10?"0" + h:"" + h) + ":" + (mi < 10?"0" + mi:"" + mi) + ":" + (s < 10?"0" + s:"" + s);
};
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var Lambda = function() { };
Lambda.__name__ = true;
Lambda.array = function(it) {
	var a = new Array();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var i = $it0.next();
		a.push(i);
	}
	return a;
};
Lambda.map = function(it,f) {
	var l = new List();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		l.add(f(x));
	}
	return l;
};
Lambda.has = function(it,elt) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(x == elt) return true;
	}
	return false;
};
var List = function() {
	this.length = 0;
};
List.__name__ = true;
List.prototype = {
	add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
	,iterator: function() {
		return new _List.ListIterator(this.h);
	}
	,__class__: List
};
var _List = {};
_List.ListIterator = function(head) {
	this.head = head;
	this.val = null;
};
_List.ListIterator.__name__ = true;
_List.ListIterator.prototype = {
	hasNext: function() {
		return this.head != null;
	}
	,next: function() {
		this.val = this.head[0];
		this.head = this.head[1];
		return this.val;
	}
	,__class__: _List.ListIterator
};
Math.__name__ = true;
var Reflect = function() { };
Reflect.__name__ = true;
Reflect.field = function(o,field) {
	try {
		return o[field];
	} catch( e ) {
		return null;
	}
};
Reflect.setField = function(o,field,value) {
	o[field] = value;
};
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
};
Reflect.isFunction = function(f) {
	return typeof(f) == "function" && !(f.__name__ || f.__ename__);
};
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
};
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
};
Std.parseFloat = function(x) {
	return parseFloat(x);
};
var StringBuf = function() {
	this.b = "";
};
StringBuf.__name__ = true;
StringBuf.prototype = {
	add: function(x) {
		this.b += Std.string(x);
	}
	,__class__: StringBuf
};
var StringTools = function() { };
StringTools.__name__ = true;
StringTools.lpad = function(s,c,l) {
	if(c.length <= 0) return s;
	while(s.length < l) s = c + s;
	return s;
};
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
};
StringTools.fastCodeAt = function(s,index) {
	return s.charCodeAt(index);
};
var ValueType = { __ename__ : true, __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] };
ValueType.TNull = ["TNull",0];
ValueType.TNull.__enum__ = ValueType;
ValueType.TInt = ["TInt",1];
ValueType.TInt.__enum__ = ValueType;
ValueType.TFloat = ["TFloat",2];
ValueType.TFloat.__enum__ = ValueType;
ValueType.TBool = ["TBool",3];
ValueType.TBool.__enum__ = ValueType;
ValueType.TObject = ["TObject",4];
ValueType.TObject.__enum__ = ValueType;
ValueType.TFunction = ["TFunction",5];
ValueType.TFunction.__enum__ = ValueType;
ValueType.TClass = function(c) { var $x = ["TClass",6,c]; $x.__enum__ = ValueType; return $x; };
ValueType.TEnum = function(e) { var $x = ["TEnum",7,e]; $x.__enum__ = ValueType; return $x; };
ValueType.TUnknown = ["TUnknown",8];
ValueType.TUnknown.__enum__ = ValueType;
var Type = function() { };
Type.__name__ = true;
Type["typeof"] = function(v) {
	var _g = typeof(v);
	switch(_g) {
	case "boolean":
		return ValueType.TBool;
	case "string":
		return ValueType.TClass(String);
	case "number":
		if(Math.ceil(v) == v % 2147483648.0) return ValueType.TInt;
		return ValueType.TFloat;
	case "object":
		if(v == null) return ValueType.TNull;
		var e = v.__enum__;
		if(e != null) return ValueType.TEnum(e);
		var c = js.Boot.getClass(v);
		if(c != null) return ValueType.TClass(c);
		return ValueType.TObject;
	case "function":
		if(v.__name__ || v.__ename__) return ValueType.TObject;
		return ValueType.TFunction;
	case "undefined":
		return ValueType.TNull;
	default:
		return ValueType.TUnknown;
	}
};
Type.enumIndex = function(e) {
	return e[1];
};
var coopy = {};
coopy.Alignment = function() {
	this.map_a2b = new haxe.ds.IntMap();
	this.map_b2a = new haxe.ds.IntMap();
	this.ha = this.hb = 0;
	this.map_count = 0;
	this.reference = null;
	this.meta = null;
	this.order_cache_has_reference = false;
	this.ia = -1;
	this.ib = -1;
};
coopy.Alignment.__name__ = true;
coopy.Alignment.prototype = {
	range: function(ha,hb) {
		this.ha = ha;
		this.hb = hb;
	}
	,tables: function(ta,tb) {
		this.ta = ta;
		this.tb = tb;
	}
	,headers: function(ia,ib) {
		this.ia = ia;
		this.ib = ib;
	}
	,setRowlike: function(flag) {
	}
	,link: function(a,b) {
		this.map_a2b.set(a,b);
		this.map_b2a.set(b,a);
		this.map_count++;
	}
	,addIndexColumns: function(unit) {
		if(this.index_columns == null) this.index_columns = new Array();
		this.index_columns.push(unit);
	}
	,getIndexColumns: function() {
		return this.index_columns;
	}
	,a2b: function(a) {
		return this.map_a2b.get(a);
	}
	,b2a: function(b) {
		return this.map_b2a.get(b);
	}
	,count: function() {
		return this.map_count;
	}
	,toString: function() {
		return "" + this.map_a2b.toString();
	}
	,toOrder: function() {
		if(this.order_cache != null) {
			if(this.reference != null) {
				if(!this.order_cache_has_reference) this.order_cache = null;
			}
		}
		if(this.order_cache == null) this.order_cache = this.toOrder3();
		if(this.reference != null) this.order_cache_has_reference = true;
		return this.order_cache;
	}
	,addToOrder: function(l,r,p) {
		if(p == null) p = -2;
		if(this.order_cache == null) this.order_cache = new coopy.Ordering();
		this.order_cache.add(l,r,p);
		this.order_cache_has_reference = p != -2;
	}
	,getSource: function() {
		return this.ta;
	}
	,getTarget: function() {
		return this.tb;
	}
	,getSourceHeader: function() {
		return this.ia;
	}
	,getTargetHeader: function() {
		return this.ib;
	}
	,toOrder3: function() {
		var ref = this.reference;
		if(ref == null) {
			ref = new coopy.Alignment();
			ref.range(this.ha,this.ha);
			ref.tables(this.ta,this.ta);
			var _g1 = 0;
			var _g = this.ha;
			while(_g1 < _g) {
				var i = _g1++;
				ref.link(i,i);
			}
		}
		var order = new coopy.Ordering();
		if(this.reference == null) order.ignoreParent();
		var xp = 0;
		var xl = 0;
		var xr = 0;
		var hp = this.ha;
		var hl = ref.hb;
		var hr = this.hb;
		var vp = new haxe.ds.IntMap();
		var vl = new haxe.ds.IntMap();
		var vr = new haxe.ds.IntMap();
		var _g2 = 0;
		while(_g2 < hp) {
			var i1 = _g2++;
			vp.set(i1,i1);
		}
		var _g3 = 0;
		while(_g3 < hl) {
			var i2 = _g3++;
			vl.set(i2,i2);
		}
		var _g4 = 0;
		while(_g4 < hr) {
			var i3 = _g4++;
			vr.set(i3,i3);
		}
		var ct_vp = hp;
		var ct_vl = hl;
		var ct_vr = hr;
		var prev = -1;
		var ct = 0;
		var max_ct = (hp + hl + hr) * 10;
		while(ct_vp > 0 || ct_vl > 0 || ct_vr > 0) {
			ct++;
			if(ct > max_ct) {
				console.log("Ordering took too long, something went wrong");
				break;
			}
			if(xp >= hp) xp = 0;
			if(xl >= hl) xl = 0;
			if(xr >= hr) xr = 0;
			if(xp < hp && ct_vp > 0) {
				if(this.a2b(xp) == null && ref.a2b(xp) == null) {
					if(vp.exists(xp)) {
						order.add(-1,-1,xp);
						prev = xp;
						vp.remove(xp);
						ct_vp--;
					}
					xp++;
					continue;
				}
			}
			var zl = null;
			var zr = null;
			if(xl < hl && ct_vl > 0) {
				zl = ref.b2a(xl);
				if(zl == null) {
					if(vl.exists(xl)) {
						order.add(xl,-1,-1);
						vl.remove(xl);
						ct_vl--;
					}
					xl++;
					continue;
				}
			}
			if(xr < hr && ct_vr > 0) {
				zr = this.b2a(xr);
				if(zr == null) {
					if(vr.exists(xr)) {
						order.add(-1,xr,-1);
						vr.remove(xr);
						ct_vr--;
					}
					xr++;
					continue;
				}
			}
			if(zl != null) {
				if(this.a2b(zl) == null) {
					if(vl.exists(xl)) {
						order.add(xl,-1,zl);
						prev = zl;
						vp.remove(zl);
						ct_vp--;
						vl.remove(xl);
						ct_vl--;
						xp = zl + 1;
					}
					xl++;
					continue;
				}
			}
			if(zr != null) {
				if(ref.a2b(zr) == null) {
					if(vr.exists(xr)) {
						order.add(-1,xr,zr);
						prev = zr;
						vp.remove(zr);
						ct_vp--;
						vr.remove(xr);
						ct_vr--;
						xp = zr + 1;
					}
					xr++;
					continue;
				}
			}
			if(zl != null && zr != null && this.a2b(zl) != null && ref.a2b(zr) != null) {
				if(zl == prev + 1 || zr != prev + 1) {
					if(vr.exists(xr)) {
						order.add(ref.a2b(zr),xr,zr);
						prev = zr;
						vp.remove(zr);
						ct_vp--;
						var key = ref.a2b(zr);
						vl.remove(key);
						ct_vl--;
						vr.remove(xr);
						ct_vr--;
						xp = zr + 1;
						xl = ref.a2b(zr) + 1;
					}
					xr++;
					continue;
				} else {
					if(vl.exists(xl)) {
						order.add(xl,this.a2b(zl),zl);
						prev = zl;
						vp.remove(zl);
						ct_vp--;
						vl.remove(xl);
						ct_vl--;
						var key1 = this.a2b(zl);
						vr.remove(key1);
						ct_vr--;
						xp = zl + 1;
						xr = this.a2b(zl) + 1;
					}
					xl++;
					continue;
				}
			}
			xp++;
			xl++;
			xr++;
		}
		return order;
	}
	,__class__: coopy.Alignment
};
coopy.CellBuilder = function() { };
coopy.CellBuilder.__name__ = true;
coopy.CellBuilder.prototype = {
	__class__: coopy.CellBuilder
};
coopy.CellInfo = $hx_exports.coopy.CellInfo = function() {
};
coopy.CellInfo.__name__ = true;
coopy.CellInfo.prototype = {
	toString: function() {
		if(!this.updated) return this.value;
		if(!this.conflicted) return this.lvalue + "::" + this.rvalue;
		return this.pvalue + "||" + this.lvalue + "::" + this.rvalue;
	}
	,__class__: coopy.CellInfo
};
coopy.CompareFlags = $hx_exports.coopy.CompareFlags = function() {
	this.ordered = true;
	this.show_unchanged = false;
	this.unchanged_context = 1;
	this.always_show_order = false;
	this.never_show_order = true;
	this.show_unchanged_columns = false;
	this.unchanged_column_context = 1;
	this.always_show_header = true;
	this.acts = null;
	this.ids = null;
	this.columns_to_ignore = null;
	this.allow_nested_cells = false;
};
coopy.CompareFlags.__name__ = true;
coopy.CompareFlags.prototype = {
	filter: function(act,allow) {
		if(this.acts == null) {
			this.acts = new haxe.ds.StringMap();
			this.acts.set("update",!allow);
			this.acts.set("insert",!allow);
			this.acts.set("delete",!allow);
		}
		if(!this.acts.exists(act)) return false;
		this.acts.set(act,allow);
		return true;
	}
	,allowUpdate: function() {
		if(this.acts == null) return true;
		return this.acts.exists("update");
	}
	,allowInsert: function() {
		if(this.acts == null) return true;
		return this.acts.exists("insert");
	}
	,allowDelete: function() {
		if(this.acts == null) return true;
		return this.acts.exists("delete");
	}
	,getIgnoredColumns: function() {
		if(this.columns_to_ignore == null) return null;
		var ignore = new haxe.ds.StringMap();
		var _g1 = 0;
		var _g = this.columns_to_ignore.length;
		while(_g1 < _g) {
			var i = _g1++;
			ignore.set(this.columns_to_ignore[i],true);
		}
		return ignore;
	}
	,addPrimaryKey: function(column) {
		if(this.ids == null) this.ids = new Array();
		this.ids.push(column);
	}
	,ignoreColumn: function(column) {
		if(this.columns_to_ignore == null) this.columns_to_ignore = new Array();
		this.columns_to_ignore.push(column);
	}
	,__class__: coopy.CompareFlags
};
coopy.CompareTable = $hx_exports.coopy.CompareTable = function(comp) {
	this.comp = comp;
};
coopy.CompareTable.__name__ = true;
coopy.CompareTable.prototype = {
	run: function() {
		var more = this.compareCore();
		while(more && this.comp.run_to_completion) more = this.compareCore();
		return !more;
	}
	,align: function() {
		while(!this.comp.completed) this.run();
		var alignment = new coopy.Alignment();
		this.alignCore(alignment);
		return alignment;
	}
	,getComparisonState: function() {
		return this.comp;
	}
	,alignCore: function(align) {
		if(this.comp.p == null) {
			this.alignCore2(align,this.comp.a,this.comp.b);
			return;
		}
		align.reference = new coopy.Alignment();
		this.alignCore2(align,this.comp.p,this.comp.b);
		this.alignCore2(align.reference,this.comp.p,this.comp.a);
		align.meta.reference = align.reference.meta;
	}
	,alignCore2: function(align,a,b) {
		if(align.meta == null) align.meta = new coopy.Alignment();
		this.alignColumns(align.meta,a,b);
		var column_order = align.meta.toOrder();
		align.range(a.get_height(),b.get_height());
		align.tables(a,b);
		align.setRowlike(true);
		var w = a.get_width();
		var ha = a.get_height();
		var hb = b.get_height();
		var av = a.getCellView();
		var ids = null;
		var ignore = null;
		if(this.comp.compare_flags != null) {
			ids = this.comp.compare_flags.ids;
			ignore = this.comp.compare_flags.getIgnoredColumns();
		}
		var common_units = new Array();
		var ra_header = align.getSourceHeader();
		var rb_header = align.getSourceHeader();
		var _g = 0;
		var _g1 = column_order.getList();
		while(_g < _g1.length) {
			var unit = _g1[_g];
			++_g;
			if(unit.l >= 0 && unit.r >= 0 && unit.p != -1) {
				if(ignore != null) {
					if(unit.l >= 0 && ra_header >= 0 && ra_header < a.get_height()) {
						var name = av.toString(a.getCell(unit.l,ra_header));
						if(ignore.exists(name)) continue;
					}
					if(unit.r >= 0 && rb_header >= 0 && rb_header < b.get_height()) {
						var name1 = av.toString(b.getCell(unit.r,rb_header));
						if(ignore.exists(name1)) continue;
					}
				}
				common_units.push(unit);
			}
		}
		if(ids != null) {
			var index = new coopy.IndexPair();
			var ids_as_map = new haxe.ds.StringMap();
			var _g2 = 0;
			while(_g2 < ids.length) {
				var id = ids[_g2];
				++_g2;
				ids_as_map.set(id,true);
				true;
			}
			var _g3 = 0;
			while(_g3 < common_units.length) {
				var unit1 = common_units[_g3];
				++_g3;
				var na = av.toString(a.getCell(unit1.l,0));
				var nb = av.toString(b.getCell(unit1.r,0));
				if(ids_as_map.exists(na) || ids_as_map.exists(nb)) {
					index.addColumns(unit1.l,unit1.r);
					align.addIndexColumns(unit1);
				}
			}
			index.indexTables(a,b);
			if(this.indexes != null) this.indexes.push(index);
			var _g4 = 0;
			while(_g4 < ha) {
				var j = _g4++;
				var cross = index.queryLocal(j);
				var spot_a = cross.spot_a;
				var spot_b = cross.spot_b;
				if(spot_a != 1 || spot_b != 1) continue;
				align.link(j,cross.item_b.lst[0]);
			}
		} else {
			var N = 5;
			var columns = new Array();
			if(common_units.length > N) {
				var columns_eval = new Array();
				var _g11 = 0;
				var _g5 = common_units.length;
				while(_g11 < _g5) {
					var i = _g11++;
					var ct = 0;
					var mem = new haxe.ds.StringMap();
					var mem2 = new haxe.ds.StringMap();
					var ca = common_units[i].l;
					var cb = common_units[i].r;
					var _g21 = 0;
					while(_g21 < ha) {
						var j1 = _g21++;
						var key = av.toString(a.getCell(ca,j1));
						if(!mem.exists(key)) {
							mem.set(key,1);
							ct++;
						}
					}
					var _g22 = 0;
					while(_g22 < hb) {
						var j2 = _g22++;
						var key1 = av.toString(b.getCell(cb,j2));
						if(!mem2.exists(key1)) {
							mem2.set(key1,1);
							ct++;
						}
					}
					columns_eval.push([i,ct]);
				}
				var sorter = function(a1,b1) {
					if(a1[1] < b1[1]) return 1;
					if(a1[1] > b1[1]) return -1;
					return 0;
				};
				columns_eval.sort(sorter);
				columns = Lambda.array(Lambda.map(columns_eval,function(v) {
					return v[0];
				}));
				columns = columns.slice(0,N);
			} else {
				var _g12 = 0;
				var _g6 = common_units.length;
				while(_g12 < _g6) {
					var i1 = _g12++;
					columns.push(i1);
				}
			}
			var top = Math.round(Math.pow(2,columns.length));
			var pending = new haxe.ds.IntMap();
			var _g7 = 0;
			while(_g7 < ha) {
				var j3 = _g7++;
				pending.set(j3,j3);
			}
			var pending_ct = ha;
			var added_columns = new haxe.ds.IntMap();
			var index_ct = 0;
			var index_top = null;
			var _g8 = 0;
			while(_g8 < top) {
				var k = _g8++;
				if(k == 0) continue;
				if(pending_ct == 0) break;
				var active_columns = new Array();
				var kk = k;
				var at = 0;
				while(kk > 0) {
					if(kk % 2 == 1) active_columns.push(columns[at]);
					kk >>= 1;
					at++;
				}
				var index1 = new coopy.IndexPair();
				var _g23 = 0;
				var _g13 = active_columns.length;
				while(_g23 < _g13) {
					var k1 = _g23++;
					var col = active_columns[k1];
					var unit2 = common_units[col];
					index1.addColumns(unit2.l,unit2.r);
					if(!added_columns.exists(col)) {
						align.addIndexColumns(unit2);
						added_columns.set(col,true);
					}
				}
				index1.indexTables(a,b);
				if(k == top - 1) index_top = index1;
				var h = a.get_height();
				if(b.get_height() > h) h = b.get_height();
				if(h < 1) h = 1;
				var wide_top_freq = index1.getTopFreq();
				var ratio = wide_top_freq;
				ratio /= h + 20;
				if(ratio >= 0.1) {
					if(index_ct > 0 || k < top - 1) continue;
				}
				index_ct++;
				if(this.indexes != null) this.indexes.push(index1);
				var fixed = new Array();
				var $it0 = pending.keys();
				while( $it0.hasNext() ) {
					var j4 = $it0.next();
					var cross1 = index1.queryLocal(j4);
					var spot_a1 = cross1.spot_a;
					var spot_b1 = cross1.spot_b;
					if(spot_a1 != 1 || spot_b1 != 1) continue;
					fixed.push(j4);
					align.link(j4,cross1.item_b.lst[0]);
				}
				var _g24 = 0;
				var _g14 = fixed.length;
				while(_g24 < _g14) {
					var j5 = _g24++;
					pending.remove(fixed[j5]);
					pending_ct--;
				}
			}
			if(index_top != null) {
				var offset = 0;
				var scale = 1;
				var _g9 = 0;
				while(_g9 < 2) {
					var sgn = _g9++;
					if(pending_ct > 0) {
						var xb = null;
						if(scale == -1 && hb > 0) xb = hb - 1;
						var _g15 = 0;
						while(_g15 < ha) {
							var xa0 = _g15++;
							var xa = xa0 * scale + offset;
							var xb2 = align.a2b(xa);
							if(xb2 != null) {
								xb = xb2 + scale;
								if(xb >= hb || xb < 0) break;
								continue;
							}
							if(xb == null) continue;
							var ka = index_top.localKey(xa);
							var kb = index_top.remoteKey(xb);
							if(ka != kb) continue;
							align.link(xa,xb);
							pending_ct--;
							xb += scale;
							if(xb >= hb || xb < 0) break;
							if(pending_ct == 0) break;
						}
					}
					offset = ha - 1;
					scale = -1;
				}
			}
		}
		if(ha > 0 && hb > 0) align.link(0,0);
	}
	,alignColumns: function(align,a,b) {
		align.range(a.get_width(),b.get_width());
		align.tables(a,b);
		align.setRowlike(false);
		var slop = 5;
		var va = a.getCellView();
		var vb = b.getCellView();
		var ra_best = 0;
		var rb_best = 0;
		var ct_best = -1;
		var ma_best = null;
		var mb_best = null;
		var ra_header = 0;
		var rb_header = 0;
		var ra_uniques = 0;
		var rb_uniques = 0;
		var _g = 0;
		while(_g < slop) {
			var ra = _g++;
			if(ra >= a.get_height()) break;
			var _g1 = 0;
			while(_g1 < slop) {
				var rb = _g1++;
				if(rb >= b.get_height()) break;
				var ma = new haxe.ds.StringMap();
				var mb = new haxe.ds.StringMap();
				var ct = 0;
				var uniques = 0;
				var _g3 = 0;
				var _g2 = a.get_width();
				while(_g3 < _g2) {
					var ca = _g3++;
					var key = va.toString(a.getCell(ca,ra));
					if(ma.exists(key)) {
						ma.set(key,-1);
						uniques--;
					} else {
						ma.set(key,ca);
						uniques++;
					}
				}
				if(uniques > ra_uniques) {
					ra_header = ra;
					ra_uniques = uniques;
				}
				uniques = 0;
				var _g31 = 0;
				var _g21 = b.get_width();
				while(_g31 < _g21) {
					var cb = _g31++;
					var key1 = vb.toString(b.getCell(cb,rb));
					if(mb.exists(key1)) {
						mb.set(key1,-1);
						uniques--;
					} else {
						mb.set(key1,cb);
						uniques++;
					}
				}
				if(uniques > rb_uniques) {
					rb_header = rb;
					rb_uniques = uniques;
				}
				var $it0 = ma.keys();
				while( $it0.hasNext() ) {
					var key2 = $it0.next();
					var i0 = ma.get(key2);
					var i1 = mb.get(key2);
					if(i1 != null) {
						if(i1 >= 0 && i0 >= 0) ct++;
					}
				}
				if(ct > ct_best) {
					ct_best = ct;
					ma_best = ma;
					mb_best = mb;
					ra_best = ra;
					rb_best = rb;
				}
			}
		}
		if(ma_best == null) {
			if(a.get_height() > 0 && b.get_height() == 0) align.headers(0,-1); else if(a.get_height() == 0 && b.get_height() > 0) align.headers(-1,0);
			return;
		}
		var $it1 = ma_best.keys();
		while( $it1.hasNext() ) {
			var key3 = $it1.next();
			var i01 = ma_best.get(key3);
			var i11 = mb_best.get(key3);
			if(i11 != null && i01 != null) align.link(i01,i11);
		}
		align.headers(ra_header,rb_header);
	}
	,testHasSameColumns: function() {
		var p = this.comp.p;
		var a = this.comp.a;
		var b = this.comp.b;
		var eq = this.hasSameColumns2(a,b);
		if(eq && p != null) eq = this.hasSameColumns2(p,a);
		this.comp.has_same_columns = eq;
		this.comp.has_same_columns_known = true;
		return true;
	}
	,hasSameColumns2: function(a,b) {
		if(a.get_width() != b.get_width()) return false;
		if(a.get_height() == 0 || b.get_height() == 0) return true;
		var av = a.getCellView();
		var _g1 = 0;
		var _g = a.get_width();
		while(_g1 < _g) {
			var i = _g1++;
			var _g3 = i + 1;
			var _g2 = a.get_width();
			while(_g3 < _g2) {
				var j = _g3++;
				if(av.equals(a.getCell(i,0),a.getCell(j,0))) return false;
			}
			if(!av.equals(a.getCell(i,0),b.getCell(i,0))) return false;
		}
		return true;
	}
	,testIsEqual: function() {
		var p = this.comp.p;
		var a = this.comp.a;
		var b = this.comp.b;
		var eq = this.isEqual2(a,b);
		if(eq && p != null) eq = this.isEqual2(p,a);
		this.comp.is_equal = eq;
		this.comp.is_equal_known = true;
		return true;
	}
	,isEqual2: function(a,b) {
		if(a.get_width() != b.get_width() || a.get_height() != b.get_height()) return false;
		var av = a.getCellView();
		var _g1 = 0;
		var _g = a.get_height();
		while(_g1 < _g) {
			var i = _g1++;
			var _g3 = 0;
			var _g2 = a.get_width();
			while(_g3 < _g2) {
				var j = _g3++;
				if(!av.equals(a.getCell(j,i),b.getCell(j,i))) return false;
			}
		}
		return true;
	}
	,compareCore: function() {
		if(this.comp.completed) return false;
		if(!this.comp.is_equal_known) return this.testIsEqual();
		if(!this.comp.has_same_columns_known) return this.testHasSameColumns();
		this.comp.completed = true;
		return false;
	}
	,storeIndexes: function() {
		this.indexes = new Array();
	}
	,getIndexes: function() {
		return this.indexes;
	}
	,__class__: coopy.CompareTable
};
coopy.Coopy = $hx_exports.coopy.Coopy = function() {
	this.extern_preference = false;
	this.format_preference = null;
	this.delim_preference = null;
	this.output_format = "copy";
	this.nested_output = false;
	this.order_set = false;
	this.order_preference = false;
};
coopy.Coopy.__name__ = true;
coopy.Coopy.compareTables = function(local,remote,flags) {
	var comp = new coopy.TableComparisonState();
	comp.a = local;
	comp.b = remote;
	comp.compare_flags = flags;
	var ct = new coopy.CompareTable(comp);
	return ct;
};
coopy.Coopy.compareTables3 = function(parent,local,remote,flags) {
	var comp = new coopy.TableComparisonState();
	comp.p = parent;
	comp.a = local;
	comp.b = remote;
	comp.compare_flags = flags;
	var ct = new coopy.CompareTable(comp);
	return ct;
};
coopy.Coopy.keepAround = function() {
	var st = new coopy.SimpleTable(1,1);
	var v = new coopy.Viterbi();
	var td = new coopy.TableDiff(null,null);
	var idx = new coopy.Index();
	var dr = new coopy.DiffRender();
	var cf = new coopy.CompareFlags();
	var hp = new coopy.HighlightPatch(null,null);
	var csv = new coopy.Csv();
	var tm = new coopy.TableModifier(null);
	var sc = new coopy.SqlCompare(null,null,null);
	return 0;
};
coopy.Coopy.cellFor = function(x) {
	return x;
};
coopy.Coopy.jsonToTable = function(json) {
	var output = null;
	var _g = 0;
	var _g1 = Reflect.fields(json);
	while(_g < _g1.length) {
		var name = _g1[_g];
		++_g;
		var t = Reflect.field(json,name);
		var columns = Reflect.field(t,"columns");
		if(columns == null) continue;
		var rows = Reflect.field(t,"rows");
		if(rows == null) continue;
		output = new coopy.SimpleTable(columns.length,rows.length);
		var has_hash = false;
		var has_hash_known = false;
		var _g3 = 0;
		var _g2 = rows.length;
		while(_g3 < _g2) {
			var i = _g3++;
			var row = rows[i];
			if(!has_hash_known) {
				if(Reflect.fields(row).length == columns.length) has_hash = true;
				has_hash_known = true;
			}
			if(!has_hash) {
				var lst = row;
				var _g5 = 0;
				var _g4 = columns.length;
				while(_g5 < _g4) {
					var j = _g5++;
					var val = lst[j];
					output.setCell(j,i,coopy.Coopy.cellFor(val));
				}
			} else {
				var _g51 = 0;
				var _g41 = columns.length;
				while(_g51 < _g41) {
					var j1 = _g51++;
					var val1 = Reflect.field(row,columns[j1]);
					output.setCell(j1,i,coopy.Coopy.cellFor(val1));
				}
			}
		}
	}
	if(output != null) output.trimBlank();
	return output;
};
coopy.Coopy.main = function() {
	return 0;
};
coopy.Coopy.show = function(t) {
	var w = t.get_width();
	var h = t.get_height();
	var txt = "";
	var _g = 0;
	while(_g < h) {
		var y = _g++;
		var _g1 = 0;
		while(_g1 < w) {
			var x = _g1++;
			txt += Std.string(t.getCell(x,y));
			txt += " ";
		}
		txt += "\n";
	}
	console.log(txt);
};
coopy.Coopy.jsonify = function(t) {
	var workbook = new haxe.ds.StringMap();
	var sheet = new Array();
	var w = t.get_width();
	var h = t.get_height();
	var txt = "";
	var _g = 0;
	while(_g < h) {
		var y = _g++;
		var row = new Array();
		var _g1 = 0;
		while(_g1 < w) {
			var x = _g1++;
			var v = t.getCell(x,y);
			row.push(v);
		}
		sheet.push(row);
	}
	workbook.set("sheet",sheet);
	return workbook;
};
coopy.Coopy.prototype = {
	checkFormat: function(name) {
		if(this.extern_preference) return this.format_preference;
		var ext = "";
		var pt = name.lastIndexOf(".");
		if(pt >= 0) {
			ext = HxOverrides.substr(name,pt + 1,null).toLowerCase();
			switch(ext) {
			case "json":
				this.format_preference = "json";
				break;
			case "ndjson":
				this.format_preference = "ndjson";
				break;
			case "csv":
				this.format_preference = "csv";
				this.delim_preference = ",";
				break;
			case "tsv":
				this.format_preference = "csv";
				this.delim_preference = "\t";
				break;
			case "ssv":
				this.format_preference = "csv";
				this.delim_preference = ";";
				break;
			case "sqlite3":
				this.format_preference = "sqlite";
				break;
			case "sqlite":
				this.format_preference = "sqlite";
				break;
			default:
				ext = "";
			}
		}
		this.nested_output = this.format_preference == "json" || this.format_preference == "ndjson";
		this.order_preference = !this.nested_output;
		return ext;
	}
	,setFormat: function(name) {
		this.extern_preference = false;
		this.checkFormat("." + name);
		this.extern_preference = true;
	}
	,saveTable: function(name,t) {
		if(this.output_format != "copy") this.setFormat(this.output_format);
		var txt = "";
		this.checkFormat(name);
		if(this.format_preference == "csv") {
			var csv = new coopy.Csv(this.delim_preference);
			txt = csv.renderTable(t);
		} else if(this.format_preference == "ndjson") txt = new coopy.Ndjson(t).render(); else if(this.format_preference == "sqlite") {
			this.io.writeStderr("! Cannot yet output to sqlite, aborting\n");
			return false;
		} else txt = haxe.Json.stringify(coopy.Coopy.jsonify(t),null,"  ");
		return this.saveText(name,txt);
	}
	,saveText: function(name,txt) {
		if(name != "-") this.io.saveContent(name,txt); else this.io.writeStdout(txt);
		return true;
	}
	,loadTable: function(name) {
		var txt = this.io.getContent(name);
		var ext = this.checkFormat(name);
		if(ext == "sqlite") {
			var sql = this.io.openSqliteDatabase(name);
			if(sql == null) {
				this.io.writeStderr("! Cannot open database, aborting\n");
				return null;
			}
			var helper = new coopy.SqliteHelper();
			var names = helper.getTableNames(sql);
			if(names == null) {
				this.io.writeStderr("! Cannot find database tables, aborting\n");
				return null;
			}
			if(names.length == 0) {
				this.io.writeStderr("! No tables in database, aborting\n");
				return null;
			}
			var tab = new coopy.SqlTable(sql,new coopy.SqlTableName(names[0]),helper);
			return tab;
		}
		if(ext == "ndjson") {
			var t = new coopy.SimpleTable(0,0);
			var ndjson = new coopy.Ndjson(t);
			ndjson.parse(txt);
			return t;
		}
		if(ext == "json" || ext == "") try {
			var json = new haxe.format.JsonParser(txt).parseRec();
			this.format_preference = "json";
			var t1 = coopy.Coopy.jsonToTable(json);
			if(t1 == null) throw "JSON failed";
			return t1;
		} catch( e ) {
			if(ext == "json") throw e;
		}
		this.format_preference = "csv";
		var csv = new coopy.Csv(this.delim_preference);
		var output = new coopy.SimpleTable(0,0);
		csv.parseTable(txt,output);
		if(output != null) output.trimBlank();
		return output;
	}
	,command: function(io,cmd,args) {
		var r = 0;
		if(io.async()) r = io.command(cmd,args);
		if(r != 999) {
			io.writeStdout("$ " + cmd);
			var _g = 0;
			while(_g < args.length) {
				var arg = args[_g];
				++_g;
				io.writeStdout(" ");
				var spaced = arg.indexOf(" ") >= 0;
				if(spaced) io.writeStdout("\"");
				io.writeStdout(arg);
				if(spaced) io.writeStdout("\"");
			}
			io.writeStdout("\n");
		}
		if(!io.async()) r = io.command(cmd,args);
		return r;
	}
	,installGitDriver: function(io,formats) {
		var r = 0;
		if(this.status == null) {
			this.status = new haxe.ds.StringMap();
			this.daff_cmd = "";
		}
		var key = "hello";
		if(!this.status.exists(key)) {
			io.writeStdout("Setting up git to use daff on");
			var _g = 0;
			while(_g < formats.length) {
				var format = formats[_g];
				++_g;
				io.writeStdout(" *." + format);
			}
			io.writeStdout(" files\n");
			this.status.set(key,r);
		}
		key = "can_run_git";
		if(!this.status.exists(key)) {
			r = this.command(io,"git",["--version"]);
			if(r == 999) return r;
			this.status.set(key,r);
			if(r != 0) {
				io.writeStderr("! Cannot run git, aborting\n");
				return 1;
			}
			io.writeStdout("- Can run git\n");
		}
		var daffs = ["daff","daff.rb","daff.py"];
		if(this.daff_cmd == "") {
			var _g1 = 0;
			while(_g1 < daffs.length) {
				var daff = daffs[_g1];
				++_g1;
				var key1 = "can_run_" + daff;
				if(!this.status.exists(key1)) {
					r = this.command(io,daff,["version"]);
					if(r == 999) return r;
					this.status.set(key1,r);
					if(r == 0) {
						this.daff_cmd = daff;
						io.writeStdout("- Can run " + daff + " as \"" + daff + "\"\n");
						break;
					}
				}
			}
			if(this.daff_cmd == "") {
				io.writeStderr("! Cannot find daff, is it in your path?\n");
				return 1;
			}
		}
		var _g2 = 0;
		while(_g2 < formats.length) {
			var format1 = formats[_g2];
			++_g2;
			key = "have_diff_driver_" + format1;
			if(!this.status.exists(key)) {
				r = this.command(io,"git",["config","--global","--get","diff.daff-" + format1 + ".command"]);
				if(r == 999) return r;
				this.status.set(key,r);
			}
			var have_diff_driver = this.status.get(key) == 0;
			key = "add_diff_driver_" + format1;
			if(!this.status.exists(key)) {
				if(!have_diff_driver) {
					r = this.command(io,"git",["config","--global","diff.daff-" + format1 + ".command",this.daff_cmd + " diff --color --git"]);
					if(r == 999) return r;
					io.writeStdout("- Added diff driver for " + format1 + "\n");
				} else {
					r = 0;
					io.writeStdout("- Already have diff driver for " + format1 + ", not touching it\n");
				}
				this.status.set(key,r);
			}
			key = "have_merge_driver_" + format1;
			if(!this.status.exists(key)) {
				r = this.command(io,"git",["config","--global","--get","merge.daff-" + format1 + ".driver"]);
				if(r == 999) return r;
				this.status.set(key,r);
			}
			var have_merge_driver = this.status.get(key) == 0;
			key = "name_merge_driver_" + format1;
			if(!this.status.exists(key)) {
				if(!have_merge_driver) {
					r = this.command(io,"git",["config","--global","merge.daff-" + format1 + ".name","daff tabular " + format1 + " merge"]);
					if(r == 999) return r;
				} else r = 0;
				this.status.set(key,r);
			}
			key = "add_merge_driver_" + format1;
			if(!this.status.exists(key)) {
				if(!have_merge_driver) {
					r = this.command(io,"git",["config","--global","merge.daff-" + format1 + ".driver",this.daff_cmd + " merge --output %A %O %A %B"]);
					if(r == 999) return r;
					io.writeStdout("- Added merge driver for " + format1 + "\n");
				} else {
					r = 0;
					io.writeStdout("- Already have merge driver for " + format1 + ", not touching it\n");
				}
				this.status.set(key,r);
			}
		}
		if(!io.exists(".git/config")) {
			io.writeStderr("! This next part needs to happen in a git repository.\n");
			io.writeStderr("! Please run again from the root of a git repository.\n");
			return 1;
		}
		var attr = ".gitattributes";
		var txt = "";
		var post = "";
		if(!io.exists(attr)) io.writeStdout("- No .gitattributes file\n"); else {
			io.writeStdout("- You have a .gitattributes file\n");
			txt = io.getContent(attr);
		}
		var need_update = false;
		var _g3 = 0;
		while(_g3 < formats.length) {
			var format2 = formats[_g3];
			++_g3;
			if(txt.indexOf("*." + format2) >= 0) io.writeStderr("- Your .gitattributes file already mentions *." + format2 + "\n"); else {
				post += "*." + format2 + " diff=daff-" + format2 + "\n";
				post += "*." + format2 + " merge=daff-" + format2 + "\n";
				io.writeStdout("- Placing the following lines in .gitattributes:\n");
				io.writeStdout(post);
				if(txt != "" && !need_update) txt += "\n";
				txt += post;
				need_update = true;
			}
		}
		if(need_update) io.saveContent(attr,txt);
		io.writeStdout("- Done!\n");
		return 0;
	}
	,coopyhx: function(io) {
		var args = io.args();
		if(args[0] == "--keep") return coopy.Coopy.keepAround();
		var more = true;
		var output = null;
		var css_output = null;
		var fragment = false;
		var pretty = true;
		var inplace = false;
		var git = false;
		var color = false;
		var flags = new coopy.CompareFlags();
		flags.always_show_header = true;
		while(more) {
			more = false;
			var _g1 = 0;
			var _g = args.length;
			while(_g1 < _g) {
				var i = _g1++;
				var tag = args[i];
				if(tag == "--output") {
					more = true;
					output = args[i + 1];
					args.splice(i,2);
					break;
				} else if(tag == "--css") {
					more = true;
					fragment = true;
					css_output = args[i + 1];
					args.splice(i,2);
					break;
				} else if(tag == "--fragment") {
					more = true;
					fragment = true;
					args.splice(i,1);
					break;
				} else if(tag == "--plain") {
					more = true;
					pretty = false;
					args.splice(i,1);
					break;
				} else if(tag == "--all") {
					more = true;
					flags.show_unchanged = true;
					args.splice(i,1);
					break;
				} else if(tag == "--act") {
					more = true;
					if(flags.acts == null) flags.acts = new haxe.ds.StringMap();
					flags.acts.set(args[i + 1],true);
					true;
					args.splice(i,2);
					break;
				} else if(tag == "--context") {
					more = true;
					var context = Std.parseInt(args[i + 1]);
					if(context >= 0) flags.unchanged_context = context;
					args.splice(i,2);
					break;
				} else if(tag == "--inplace") {
					more = true;
					inplace = true;
					args.splice(i,1);
					break;
				} else if(tag == "--git") {
					more = true;
					git = true;
					args.splice(i,1);
					break;
				} else if(tag == "--unordered") {
					more = true;
					flags.ordered = false;
					flags.unchanged_context = 0;
					this.order_set = true;
					args.splice(i,1);
					break;
				} else if(tag == "--ordered") {
					more = true;
					flags.ordered = true;
					this.order_set = true;
					args.splice(i,1);
					break;
				} else if(tag == "--color") {
					more = true;
					color = true;
					args.splice(i,1);
					break;
				} else if(tag == "--input-format") {
					more = true;
					this.setFormat(args[i + 1]);
					args.splice(i,2);
					break;
				} else if(tag == "--output-format") {
					more = true;
					this.output_format = args[i + 1];
					args.splice(i,2);
					break;
				} else if(tag == "--id") {
					more = true;
					if(flags.ids == null) flags.ids = new Array();
					flags.ids.push(args[i + 1]);
					args.splice(i,2);
					break;
				} else if(tag == "--ignore") {
					more = true;
					if(flags.columns_to_ignore == null) flags.columns_to_ignore = new Array();
					flags.columns_to_ignore.push(args[i + 1]);
					args.splice(i,2);
					break;
				} else if(tag == "--index") {
					more = true;
					flags.always_show_order = true;
					flags.never_show_order = false;
					args.splice(i,1);
					break;
				}
			}
		}
		var cmd = args[0];
		if(args.length < 2) {
			if(cmd == "version") {
				io.writeStdout(coopy.Coopy.VERSION + "\n");
				return 0;
			}
			if(cmd == "git") {
				io.writeStdout("You can use daff to improve git's handling of csv files, by using it as a\ndiff driver (for showing what has changed) and as a merge driver (for merging\nchanges between multiple versions).\n");
				io.writeStdout("\n");
				io.writeStdout("Automatic setup\n");
				io.writeStdout("---------------\n\n");
				io.writeStdout("Run:\n");
				io.writeStdout("  daff git csv\n");
				io.writeStdout("\n");
				io.writeStdout("Manual setup\n");
				io.writeStdout("------------\n\n");
				io.writeStdout("Create and add a file called .gitattributes in the root directory of your\nrepository, containing:\n\n");
				io.writeStdout("  *.csv diff=daff-csv\n");
				io.writeStdout("  *.csv merge=daff-csv\n");
				io.writeStdout("\nCreate a file called .gitconfig in your home directory (or alternatively\nopen .git/config for a particular repository) and add:\n\n");
				io.writeStdout("  [diff \"daff-csv\"]\n");
				io.writeStdout("  command = daff diff --color --git\n");
				io.writeStderr("\n");
				io.writeStdout("  [merge \"daff-csv\"]\n");
				io.writeStdout("  name = daff tabular merge\n");
				io.writeStdout("  driver = daff merge --output %A %O %A %B\n\n");
				io.writeStderr("Make sure you can run daff from the command-line as just \"daff\" - if not,\nreplace \"daff\" in the driver and command lines above with the correct way\nto call it. Omit --color if your terminal does not support ANSI colors.");
				io.writeStderr("\n");
				return 0;
			}
			io.writeStderr("daff can produce and apply tabular diffs.\n");
			io.writeStderr("Call as:\n");
			io.writeStderr("  daff [--color] [--output OUTPUT.csv] a.csv b.csv\n");
			io.writeStderr("  daff [--output OUTPUT.csv] parent.csv a.csv b.csv\n");
			io.writeStderr("  daff [--output OUTPUT.ndjson] a.ndjson b.ndjson\n");
			io.writeStderr("  daff patch [--inplace] [--output OUTPUT.csv] a.csv patch.csv\n");
			io.writeStderr("  daff merge [--inplace] [--output OUTPUT.csv] parent.csv a.csv b.csv\n");
			io.writeStderr("  daff trim [--output OUTPUT.csv] source.csv\n");
			io.writeStderr("  daff render [--output OUTPUT.html] diff.csv\n");
			io.writeStderr("  daff copy in.csv out.tsv\n");
			io.writeStderr("  daff git\n");
			io.writeStderr("  daff version\n");
			io.writeStderr("\n");
			io.writeStderr("The --inplace option to patch and merge will result in modification of a.csv.\n");
			io.writeStderr("\n");
			io.writeStderr("If you need more control, here is the full list of flags:\n");
			io.writeStderr("  daff diff [--output OUTPUT.csv] [--context NUM] [--all] [--act ACT] a.csv b.csv\n");
			io.writeStderr("     --act ACT:     show only a certain kind of change (update, insert, delete)\n");
			io.writeStderr("     --all:         do not prune unchanged rows\n");
			io.writeStderr("     --color:       highlight changes with terminal colors\n");
			io.writeStderr("     --context NUM: show NUM rows of context\n");
			io.writeStderr("     --id:          specify column to use as primary key (repeat for multi-column key)\n");
			io.writeStderr("     --ignore:      specify column to ignore completely (can repeat)\n");
			io.writeStderr("     --input-format [csv|tsv|ssv|json]: set format to expect for input\n");
			io.writeStderr("     --ordered:     assume row order is meaningful (default for CSV)\n");
			io.writeStderr("     --output-format [csv|tsv|ssv|json|copy]: set format for output\n");
			io.writeStderr("     --unordered:   assume row order is meaningless (default for json formats)\n");
			io.writeStderr("\n");
			io.writeStderr("  daff diff --git path old-file old-hex old-mode new-file new-hex new-mode\n");
			io.writeStderr("     --git:         process arguments provided by git to diff drivers\n");
			io.writeStderr("     --index:       include row/columns numbers from orginal tables\n");
			io.writeStderr("\n");
			io.writeStderr("  daff render [--output OUTPUT.html] [--css CSS.css] [--fragment] [--plain] diff.csv\n");
			io.writeStderr("     --css CSS.css: generate a suitable css file to go with the html\n");
			io.writeStderr("     --fragment:    generate just a html fragment rather than a page\n");
			io.writeStderr("     --plain:       do not use fancy utf8 characters to make arrows prettier\n");
			return 1;
		}
		var cmd1 = args[0];
		var offset = 1;
		if(!Lambda.has(["diff","patch","merge","trim","render","git","version","copy"],cmd1)) {
			if(cmd1.indexOf(".") != -1 || cmd1.indexOf("--") == 0) {
				cmd1 = "diff";
				offset = 0;
			}
		}
		if(cmd1 == "git") {
			var types = args.splice(offset,args.length - offset);
			return this.installGitDriver(io,types);
		}
		if(git) {
			var ct = args.length - offset;
			if(ct != 7) {
				io.writeStderr("Expected 7 parameters from git, but got " + ct + "\n");
				return 1;
			}
			var git_args = args.splice(offset,ct);
			args.splice(0,args.length);
			offset = 0;
			var path = git_args[0];
			var old_file = git_args[1];
			var new_file = git_args[4];
			io.writeStdout("--- a/" + path + "\n");
			io.writeStdout("+++ b/" + path + "\n");
			args.push(old_file);
			args.push(new_file);
		}
		var tool = this;
		tool.io = io;
		var parent = null;
		if(args.length - offset >= 3) {
			parent = tool.loadTable(args[offset]);
			offset++;
		}
		var aname = args[offset];
		var a = tool.loadTable(aname);
		var b = null;
		if(args.length - offset >= 2) {
			if(cmd1 != "copy") b = tool.loadTable(args[1 + offset]); else output = args[1 + offset];
		}
		if(inplace) {
			if(output != null) io.writeStderr("Please do not use --inplace when specifying an output.\n");
			output = aname;
			return 1;
		}
		if(output == null) output = "-";
		var ok = true;
		if(cmd1 == "diff") {
			if(!this.order_set) {
				flags.ordered = this.order_preference;
				if(!flags.ordered) flags.unchanged_context = 0;
			}
			flags.allow_nested_cells = this.nested_output;
			var ct1 = coopy.Coopy.compareTables3(parent,a,b,flags);
			var align = ct1.align();
			var td = new coopy.TableDiff(align,flags);
			var o = new coopy.SimpleTable(0,0);
			td.hilite(o);
			if(color) {
				var render = new coopy.TerminalDiffRender();
				tool.saveText(output,render.render(o));
			} else tool.saveTable(output,o);
		} else if(cmd1 == "patch") {
			var patcher = new coopy.HighlightPatch(a,b);
			patcher.apply();
			tool.saveTable(output,a);
		} else if(cmd1 == "merge") {
			var merger = new coopy.Merger(parent,a,b,flags);
			var conflicts = merger.apply();
			ok = conflicts == 0;
			if(conflicts > 0) io.writeStderr(conflicts + " conflict" + (conflicts > 1?"s":"") + "\n");
			tool.saveTable(output,a);
		} else if(cmd1 == "trim") tool.saveTable(output,a); else if(cmd1 == "render") {
			var renderer = new coopy.DiffRender();
			renderer.usePrettyArrows(pretty);
			renderer.render(a);
			if(!fragment) renderer.completeHtml();
			tool.saveText(output,renderer.html());
			if(css_output != null) tool.saveText(css_output,renderer.sampleCss());
		} else if(cmd1 == "copy") tool.saveTable(output,a);
		if(ok) return 0; else return 1;
	}
	,__class__: coopy.Coopy
};
coopy.CrossMatch = function() {
};
coopy.CrossMatch.__name__ = true;
coopy.CrossMatch.prototype = {
	__class__: coopy.CrossMatch
};
coopy.Csv = $hx_exports.coopy.Csv = function(delim) {
	if(delim == null) delim = ",";
	this.cursor = 0;
	this.row_ended = false;
	if(delim == null) this.delim = ","; else this.delim = delim;
};
coopy.Csv.__name__ = true;
coopy.Csv.prototype = {
	renderTable: function(t) {
		var result = "";
		var w = t.get_width();
		var h = t.get_height();
		var txt = "";
		var v = t.getCellView();
		var _g = 0;
		while(_g < h) {
			var y = _g++;
			var _g1 = 0;
			while(_g1 < w) {
				var x = _g1++;
				if(x > 0) txt += this.delim;
				txt += this.renderCell(v,t.getCell(x,y));
			}
			txt += "\r\n";
		}
		return txt;
	}
	,renderCell: function(v,d) {
		if(d == null) return "NULL";
		var str = v.toString(d);
		var need_quote = false;
		var _g1 = 0;
		var _g = str.length;
		while(_g1 < _g) {
			var i = _g1++;
			var ch = str.charAt(i);
			if(ch == "\"" || ch == "'" || ch == this.delim || ch == "\r" || ch == "\n" || ch == "\t" || ch == " ") {
				need_quote = true;
				break;
			}
		}
		var result = "";
		if(need_quote) result += "\"";
		var line_buf = "";
		var _g11 = 0;
		var _g2 = str.length;
		while(_g11 < _g2) {
			var i1 = _g11++;
			var ch1 = str.charAt(i1);
			if(ch1 == "\"") result += "\"";
			if(ch1 != "\r" && ch1 != "\n") {
				if(line_buf.length > 0) {
					result += line_buf;
					line_buf = "";
				}
				result += ch1;
			} else line_buf += ch1;
		}
		if(need_quote) result += "\"";
		return result;
	}
	,parseTable: function(txt,tab) {
		if(!tab.isResizable()) return false;
		this.cursor = 0;
		this.row_ended = false;
		this.has_structure = true;
		tab.resize(0,0);
		var w = 0;
		var h = 0;
		var at = 0;
		var yat = 0;
		while(this.cursor < txt.length) {
			var cell = this.parseCellPart(txt);
			if(yat >= h) {
				h = yat + 1;
				tab.resize(w,h);
			}
			if(at >= w) {
				w = at + 1;
				tab.resize(w,h);
			}
			tab.setCell(at,h - 1,cell);
			at++;
			if(this.row_ended) {
				at = 0;
				yat++;
			}
			this.cursor++;
		}
		return true;
	}
	,makeTable: function(txt) {
		var tab = new coopy.SimpleTable(0,0);
		this.parseTable(txt,tab);
		return tab;
	}
	,parseCellPart: function(txt) {
		if(txt == null) return null;
		this.row_ended = false;
		var first_non_underscore = txt.length;
		var last_processed = 0;
		var quoting = false;
		var quote = 0;
		var result = "";
		var start = this.cursor;
		var _g1 = this.cursor;
		var _g = txt.length;
		while(_g1 < _g) {
			var i = _g1++;
			var ch = HxOverrides.cca(txt,i);
			last_processed = i;
			if(ch != 95 && i < first_non_underscore) first_non_underscore = i;
			if(this.has_structure) {
				if(!quoting) {
					if(ch == HxOverrides.cca(this.delim,0)) break;
					if(ch == 13 || ch == 10) {
						var ch2 = HxOverrides.cca(txt,i + 1);
						if(ch2 != null) {
							if(ch2 != ch) {
								if(ch2 == 13 || ch2 == 10) last_processed++;
							}
						}
						this.row_ended = true;
						break;
					}
					if(ch == 34 || ch == 39) {
						if(i == this.cursor) {
							quoting = true;
							quote = ch;
							if(i != start) result += String.fromCharCode(ch);
							continue;
						} else if(ch == quote) quoting = true;
					}
					result += String.fromCharCode(ch);
					continue;
				}
				if(ch == quote) {
					quoting = false;
					continue;
				}
			}
			result += String.fromCharCode(ch);
		}
		this.cursor = last_processed;
		if(quote == 0) {
			if(result == "NULL") return null;
			if(first_non_underscore > start) {
				var del = first_non_underscore - start;
				if(HxOverrides.substr(result,del,null) == "NULL") return HxOverrides.substr(result,1,null);
			}
		}
		return result;
	}
	,parseCell: function(txt) {
		this.cursor = 0;
		this.row_ended = false;
		this.has_structure = false;
		return this.parseCellPart(txt);
	}
	,__class__: coopy.Csv
};
coopy.DiffRender = $hx_exports.coopy.DiffRender = function() {
	this.text_to_insert = new Array();
	this.open = false;
	this.pretty_arrows = true;
};
coopy.DiffRender.__name__ = true;
coopy.DiffRender.examineCell = function(x,y,view,raw,vcol,vrow,vcorner,cell,offset) {
	if(offset == null) offset = 0;
	var nested = view.isHash(raw);
	var value = null;
	if(!nested) value = view.toString(raw);
	cell.category = "";
	cell.category_given_tr = "";
	cell.separator = "";
	cell.pretty_separator = "";
	cell.conflicted = false;
	cell.updated = false;
	cell.pvalue = cell.lvalue = cell.rvalue = null;
	cell.value = value;
	if(cell.value == null) cell.value = "";
	cell.pretty_value = cell.value;
	if(vrow == null) vrow = "";
	if(vcol == null) vcol = "";
	var removed_column = false;
	if(vrow == ":") cell.category = "move";
	if(vrow == "" && offset == 1 && y == 0) cell.category = "index";
	if(vcol.indexOf("+++") >= 0) cell.category_given_tr = cell.category = "add"; else if(vcol.indexOf("---") >= 0) {
		cell.category_given_tr = cell.category = "remove";
		removed_column = true;
	}
	if(vrow == "!") cell.category = "spec"; else if(vrow == "@@") cell.category = "header"; else if(vrow == "...") cell.category = "gap"; else if(vrow == "+++") {
		if(!removed_column) cell.category = "add";
	} else if(vrow == "---") cell.category = "remove"; else if(vrow.indexOf("->") >= 0) {
		if(!removed_column) {
			var tokens = vrow.split("!");
			var full = vrow;
			var part = tokens[1];
			if(part == null) part = full;
			if(nested || cell.value.indexOf(part) >= 0) {
				var cat = "modify";
				var div = part;
				if(part != full) {
					if(nested) cell.conflicted = view.hashExists(raw,"theirs"); else cell.conflicted = cell.value.indexOf(full) >= 0;
					if(cell.conflicted) {
						div = full;
						cat = "conflict";
					}
				}
				cell.updated = true;
				cell.separator = div;
				cell.pretty_separator = div;
				if(nested) {
					if(cell.conflicted) tokens = [view.hashGet(raw,"before"),view.hashGet(raw,"ours"),view.hashGet(raw,"theirs")]; else tokens = [view.hashGet(raw,"before"),view.hashGet(raw,"after")];
				} else if(cell.pretty_value == div) tokens = ["",""]; else tokens = cell.pretty_value.split(div);
				var pretty_tokens = tokens;
				if(tokens.length >= 2) {
					pretty_tokens[0] = coopy.DiffRender.markSpaces(tokens[0],tokens[1]);
					pretty_tokens[1] = coopy.DiffRender.markSpaces(tokens[1],tokens[0]);
				}
				if(tokens.length >= 3) {
					var ref = pretty_tokens[0];
					pretty_tokens[0] = coopy.DiffRender.markSpaces(ref,tokens[2]);
					pretty_tokens[2] = coopy.DiffRender.markSpaces(tokens[2],ref);
				}
				cell.pretty_separator = String.fromCharCode(8594);
				cell.pretty_value = pretty_tokens.join(cell.pretty_separator);
				cell.category_given_tr = cell.category = cat;
				var offset1;
				if(cell.conflicted) offset1 = 1; else offset1 = 0;
				cell.lvalue = tokens[offset1];
				cell.rvalue = tokens[offset1 + 1];
				if(cell.conflicted) cell.pvalue = tokens[0];
			}
		}
	}
	if(x == 0 && offset > 0) cell.category_given_tr = cell.category = "index";
};
coopy.DiffRender.markSpaces = function(sl,sr) {
	if(sl == sr) return sl;
	if(sl == null || sr == null) return sl;
	var slc = StringTools.replace(sl," ","");
	var src = StringTools.replace(sr," ","");
	if(slc != src) return sl;
	var slo = new String("");
	var il = 0;
	var ir = 0;
	while(il < sl.length) {
		var cl = sl.charAt(il);
		var cr = "";
		if(ir < sr.length) cr = sr.charAt(ir);
		if(cl == cr) {
			slo += cl;
			il++;
			ir++;
		} else if(cr == " ") ir++; else {
			slo += String.fromCharCode(9251);
			il++;
		}
	}
	return slo;
};
coopy.DiffRender.renderCell = function(tab,view,x,y) {
	var cell = new coopy.CellInfo();
	var corner = view.toString(tab.getCell(0,0));
	var off;
	if(corner == "@:@") off = 1; else off = 0;
	coopy.DiffRender.examineCell(x,y,view,tab.getCell(x,y),view.toString(tab.getCell(x,off)),view.toString(tab.getCell(off,y)),corner,cell,off);
	return cell;
};
coopy.DiffRender.prototype = {
	usePrettyArrows: function(flag) {
		this.pretty_arrows = flag;
	}
	,insert: function(str) {
		this.text_to_insert.push(str);
	}
	,beginTable: function() {
		this.insert("<table>\n");
		this.section = null;
	}
	,setSection: function(str) {
		if(str == this.section) return;
		if(this.section != null) {
			this.insert("</t");
			this.insert(this.section);
			this.insert(">\n");
		}
		this.section = str;
		if(this.section != null) {
			this.insert("<t");
			this.insert(this.section);
			this.insert(">\n");
		}
	}
	,beginRow: function(mode) {
		this.td_open = "<td";
		this.td_close = "</td>";
		var row_class = "";
		if(mode == "header") {
			this.td_open = "<th";
			this.td_close = "</th>";
		}
		row_class = mode;
		var tr = "<tr>";
		if(row_class != "") tr = "<tr class=\"" + row_class + "\">";
		this.insert(tr);
	}
	,insertCell: function(txt,mode) {
		var cell_decorate = "";
		if(mode != "") cell_decorate = " class=\"" + mode + "\"";
		this.insert(this.td_open + cell_decorate + ">");
		this.insert(txt);
		this.insert(this.td_close);
	}
	,endRow: function() {
		this.insert("</tr>\n");
	}
	,endTable: function() {
		this.setSection(null);
		this.insert("</table>\n");
	}
	,html: function() {
		return this.text_to_insert.join("");
	}
	,toString: function() {
		return this.html();
	}
	,render: function(tab) {
		if(tab.get_width() == 0 || tab.get_height() == 0) return this;
		var render = this;
		render.beginTable();
		var change_row = -1;
		var cell = new coopy.CellInfo();
		var view = tab.getCellView();
		var corner = view.toString(tab.getCell(0,0));
		var off;
		if(corner == "@:@") off = 1; else off = 0;
		if(off > 0) {
			if(tab.get_width() <= 1 || tab.get_height() <= 1) return this;
		}
		var _g1 = 0;
		var _g = tab.get_height();
		while(_g1 < _g) {
			var row = _g1++;
			var open = false;
			var txt = view.toString(tab.getCell(off,row));
			if(txt == null) txt = "";
			coopy.DiffRender.examineCell(off,row,view,txt,"",txt,corner,cell,off);
			var row_mode = cell.category;
			if(row_mode == "spec") change_row = row;
			if(row_mode == "header" || row_mode == "spec" || row_mode == "index") this.setSection("head"); else this.setSection("body");
			render.beginRow(row_mode);
			var _g3 = 0;
			var _g2 = tab.get_width();
			while(_g3 < _g2) {
				var c = _g3++;
				coopy.DiffRender.examineCell(c,row,view,tab.getCell(c,row),change_row >= 0?view.toString(tab.getCell(c,change_row)):"",txt,corner,cell,off);
				render.insertCell(this.pretty_arrows?cell.pretty_value:cell.value,cell.category_given_tr);
			}
			render.endRow();
		}
		render.endTable();
		return this;
	}
	,sampleCss: function() {
		return ".highlighter .add { \n  background-color: #7fff7f;\n}\n\n.highlighter .remove { \n  background-color: #ff7f7f;\n}\n\n.highlighter td.modify { \n  background-color: #7f7fff;\n}\n\n.highlighter td.conflict { \n  background-color: #f00;\n}\n\n.highlighter .spec { \n  background-color: #aaa;\n}\n\n.highlighter .move { \n  background-color: #ffa;\n}\n\n.highlighter .null { \n  color: #888;\n}\n\n.highlighter table { \n  border-collapse:collapse;\n}\n\n.highlighter td, .highlighter th {\n  border: 1px solid #2D4068;\n  padding: 3px 7px 2px;\n}\n\n.highlighter th, .highlighter .header { \n  background-color: #aaf;\n  font-weight: bold;\n  padding-bottom: 4px;\n  padding-top: 5px;\n  text-align:left;\n}\n\n.highlighter tr.header th {\n  border-bottom: 2px solid black;\n}\n\n.highlighter tr.index td, .highlighter .index, .highlighter tr.header th.index {\n  background-color: white;\n  border: none;\n}\n\n.highlighter .gap {\n  color: #888;\n}\n\n.highlighter td {\n  empty-cells: show;\n}\n";
	}
	,completeHtml: function() {
		this.text_to_insert.splice(0,0,"<!DOCTYPE html>\n<html>\n<head>\n<meta charset='utf-8'>\n<style TYPE='text/css'>\n");
		var x = this.sampleCss();
		this.text_to_insert.splice(1,0,x);
		this.text_to_insert.splice(2,0,"</style>\n</head>\n<body>\n<div class='highlighter'>\n");
		this.text_to_insert.push("</div>\n</body>\n</html>\n");
	}
	,__class__: coopy.DiffRender
};
coopy.FlatCellBuilder = function() {
};
coopy.FlatCellBuilder.__name__ = true;
coopy.FlatCellBuilder.__interfaces__ = [coopy.CellBuilder];
coopy.FlatCellBuilder.quoteForDiff = function(v,d) {
	var nil = "NULL";
	if(v.equals(d,null)) return nil;
	var str = v.toString(d);
	var score = 0;
	var _g1 = 0;
	var _g = str.length;
	while(_g1 < _g) {
		var i = _g1++;
		if(HxOverrides.cca(str,score) != 95) break;
		score++;
	}
	if(HxOverrides.substr(str,score,null) == nil) str = "_" + str;
	return str;
};
coopy.FlatCellBuilder.prototype = {
	needSeparator: function() {
		return true;
	}
	,setSeparator: function(separator) {
		this.separator = separator;
	}
	,setConflictSeparator: function(separator) {
		this.conflict_separator = separator;
	}
	,setView: function(view) {
		this.view = view;
	}
	,update: function(local,remote) {
		return this.view.toDatum(coopy.FlatCellBuilder.quoteForDiff(this.view,local) + this.separator + coopy.FlatCellBuilder.quoteForDiff(this.view,remote));
	}
	,conflict: function(parent,local,remote) {
		return this.view.toString(parent) + this.conflict_separator + this.view.toString(local) + this.conflict_separator + this.view.toString(remote);
	}
	,marker: function(label) {
		return this.view.toDatum(label);
	}
	,links: function(unit) {
		return this.view.toDatum(unit.toString());
	}
	,__class__: coopy.FlatCellBuilder
};
coopy.Row = function() { };
coopy.Row.__name__ = true;
coopy.Row.prototype = {
	__class__: coopy.Row
};
coopy.HighlightPatch = $hx_exports.coopy.HighlightPatch = function(source,patch) {
	this.source = source;
	this.patch = patch;
	this.view = patch.getCellView();
	this.sourceView = source.getCellView();
};
coopy.HighlightPatch.__name__ = true;
coopy.HighlightPatch.__interfaces__ = [coopy.Row];
coopy.HighlightPatch.prototype = {
	reset: function() {
		this.header = new haxe.ds.IntMap();
		this.headerPre = new haxe.ds.StringMap();
		this.headerPost = new haxe.ds.StringMap();
		this.headerRename = new haxe.ds.StringMap();
		this.headerMove = null;
		this.modifier = new haxe.ds.IntMap();
		this.mods = new Array();
		this.cmods = new Array();
		this.csv = new coopy.Csv();
		this.rcOffset = 0;
		this.currentRow = -1;
		this.rowInfo = new coopy.CellInfo();
		this.cellInfo = new coopy.CellInfo();
		this.sourceInPatchCol = this.patchInSourceCol = null;
		this.patchInSourceRow = new haxe.ds.IntMap();
		this.indexes = null;
		this.lastSourceRow = -1;
		this.actions = new Array();
		this.rowPermutation = null;
		this.rowPermutationRev = null;
		this.colPermutation = null;
		this.colPermutationRev = null;
		this.haveDroppedColumns = false;
	}
	,apply: function() {
		this.reset();
		if(this.patch.get_width() < 2) return true;
		if(this.patch.get_height() < 1) return true;
		this.payloadCol = 1 + this.rcOffset;
		this.payloadTop = this.patch.get_width();
		var corner = this.patch.getCellView().toString(this.patch.getCell(0,0));
		if(corner == "@:@") this.rcOffset = 1; else this.rcOffset = 0;
		var _g1 = 0;
		var _g = this.patch.get_height();
		while(_g1 < _g) {
			var r = _g1++;
			var str = this.view.toString(this.patch.getCell(this.rcOffset,r));
			this.actions.push(str != null?str:"");
		}
		var _g11 = 0;
		var _g2 = this.patch.get_height();
		while(_g11 < _g2) {
			var r1 = _g11++;
			this.applyRow(r1);
		}
		this.finishRows();
		this.finishColumns();
		return true;
	}
	,needSourceColumns: function() {
		if(this.sourceInPatchCol != null) return;
		this.sourceInPatchCol = new haxe.ds.IntMap();
		this.patchInSourceCol = new haxe.ds.IntMap();
		var av = this.source.getCellView();
		var _g1 = 0;
		var _g = this.source.get_width();
		while(_g1 < _g) {
			var i = _g1++;
			var name = av.toString(this.source.getCell(i,0));
			var at = this.headerPre.get(name);
			if(at == null) continue;
			this.sourceInPatchCol.set(i,at);
			this.patchInSourceCol.set(at,i);
		}
	}
	,needSourceIndex: function() {
		if(this.indexes != null) return;
		var state = new coopy.TableComparisonState();
		state.a = this.source;
		state.b = this.source;
		var comp = new coopy.CompareTable(state);
		comp.storeIndexes();
		comp.run();
		comp.align();
		this.indexes = comp.getIndexes();
		this.needSourceColumns();
	}
	,applyRow: function(r) {
		this.currentRow = r;
		var code = this.actions[r];
		if(r == 0 && this.rcOffset > 0) {
		} else if(code == "@@") {
			this.applyHeader();
			this.applyAction("@@");
		} else if(code == "!") this.applyMeta(); else if(code == "+++") this.applyAction(code); else if(code == "---") this.applyAction(code); else if(code == "+" || code == ":") this.applyAction(code); else if(code.indexOf("->") >= 0) this.applyAction("->"); else this.lastSourceRow = -1;
	}
	,getDatum: function(c) {
		return this.patch.getCell(c,this.currentRow);
	}
	,getString: function(c) {
		return this.view.toString(this.getDatum(c));
	}
	,applyMeta: function() {
		var _g1 = this.payloadCol;
		var _g = this.payloadTop;
		while(_g1 < _g) {
			var i = _g1++;
			var name = this.getString(i);
			if(name == "") continue;
			this.modifier.set(i,name);
		}
	}
	,applyHeader: function() {
		var _g1 = this.payloadCol;
		var _g = this.payloadTop;
		while(_g1 < _g) {
			var i = _g1++;
			var name = this.getString(i);
			if(name == "...") {
				this.modifier.set(i,"...");
				this.haveDroppedColumns = true;
				continue;
			}
			var mod = this.modifier.get(i);
			var move = false;
			if(mod != null) {
				if(HxOverrides.cca(mod,0) == 58) {
					move = true;
					mod = HxOverrides.substr(mod,1,mod.length);
				}
			}
			this.header.set(i,name);
			if(mod != null) {
				if(HxOverrides.cca(mod,0) == 40) {
					var prev_name = HxOverrides.substr(mod,1,mod.length - 2);
					this.headerPre.set(prev_name,i);
					this.headerPost.set(name,i);
					this.headerRename.set(prev_name,name);
					continue;
				}
			}
			if(mod != "+++") this.headerPre.set(name,i);
			if(mod != "---") this.headerPost.set(name,i);
			if(move) {
				if(this.headerMove == null) this.headerMove = new haxe.ds.StringMap();
				this.headerMove.set(name,1);
			}
		}
		if(this.source.get_height() == 0) this.applyAction("+++");
	}
	,lookUp: function(del) {
		if(del == null) del = 0;
		var at = this.patchInSourceRow.get(this.currentRow + del);
		if(at != null) return at;
		var result = -1;
		this.currentRow += del;
		if(this.currentRow >= 0 && this.currentRow < this.patch.get_height()) {
			var _g = 0;
			var _g1 = this.indexes;
			while(_g < _g1.length) {
				var idx = _g1[_g];
				++_g;
				var match = idx.queryByContent(this);
				if(match.spot_a != 1) continue;
				result = match.item_a.lst[0];
				break;
			}
		}
		this.patchInSourceRow.set(this.currentRow,result);
		result;
		this.currentRow -= del;
		return result;
	}
	,applyAction: function(code) {
		var mod = new coopy.HighlightPatchUnit();
		mod.code = code;
		mod.add = code == "+++";
		mod.rem = code == "---";
		mod.update = code == "->";
		this.needSourceIndex();
		if(this.lastSourceRow == -1) this.lastSourceRow = this.lookUp(-1);
		mod.sourcePrevRow = this.lastSourceRow;
		var nextAct = this.actions[this.currentRow + 1];
		if(nextAct != "+++" && nextAct != "...") mod.sourceNextRow = this.lookUp(1);
		if(mod.add) {
			if(this.actions[this.currentRow - 1] != "+++") mod.sourcePrevRow = this.lookUp(-1);
			mod.sourceRow = mod.sourcePrevRow;
			if(mod.sourceRow != -1) mod.sourceRowOffset = 1;
		} else mod.sourceRow = this.lastSourceRow = this.lookUp();
		if(this.actions[this.currentRow + 1] == "") this.lastSourceRow = mod.sourceNextRow;
		mod.patchRow = this.currentRow;
		if(code == "@@") mod.sourceRow = 0;
		this.mods.push(mod);
	}
	,checkAct: function() {
		var act = this.getString(this.rcOffset);
		if(this.rowInfo.value != act) coopy.DiffRender.examineCell(0,0,this.view,act,"",act,"",this.rowInfo);
	}
	,getPreString: function(txt) {
		this.checkAct();
		if(!this.rowInfo.updated) return txt;
		coopy.DiffRender.examineCell(0,0,this.view,txt,"",this.rowInfo.value,"",this.cellInfo);
		if(!this.cellInfo.updated) return txt;
		return this.cellInfo.lvalue;
	}
	,getRowString: function(c) {
		var at = this.sourceInPatchCol.get(c);
		if(at == null) return "NOT_FOUND";
		return this.getPreString(this.getString(at));
	}
	,sortMods: function(a,b) {
		if(b.code == "@@" && a.code != "@@") return 1;
		if(a.code == "@@" && b.code != "@@") return -1;
		if(a.sourceRow == -1 && !a.add && b.sourceRow != -1) return 1;
		if(a.sourceRow != -1 && !b.add && b.sourceRow == -1) return -1;
		if(a.sourceRow + a.sourceRowOffset > b.sourceRow + b.sourceRowOffset) return 1;
		if(a.sourceRow + a.sourceRowOffset < b.sourceRow + b.sourceRowOffset) return -1;
		if(a.patchRow > b.patchRow) return 1;
		if(a.patchRow < b.patchRow) return -1;
		return 0;
	}
	,processMods: function(rmods,fate,len) {
		rmods.sort($bind(this,this.sortMods));
		var offset = 0;
		var last = -1;
		var target = 0;
		var _g = 0;
		while(_g < rmods.length) {
			var mod = rmods[_g];
			++_g;
			if(last != -1) {
				var _g2 = last;
				var _g1 = mod.sourceRow + mod.sourceRowOffset;
				while(_g2 < _g1) {
					var i = _g2++;
					fate.push(i + offset);
					target++;
					last++;
				}
			}
			if(mod.rem) {
				fate.push(-1);
				offset--;
			} else if(mod.add) {
				mod.destRow = target;
				target++;
				offset++;
			} else mod.destRow = target;
			if(mod.sourceRow >= 0) {
				last = mod.sourceRow + mod.sourceRowOffset;
				if(mod.rem) last++;
			} else last = -1;
		}
		if(last != -1) {
			var _g3 = last;
			while(_g3 < len) {
				var i1 = _g3++;
				fate.push(i1 + offset);
				target++;
				last++;
			}
		}
		return len + offset;
	}
	,computeOrdering: function(mods,permutation,permutationRev,dim) {
		var to_unit = new haxe.ds.IntMap();
		var from_unit = new haxe.ds.IntMap();
		var meta_from_unit = new haxe.ds.IntMap();
		var ct = 0;
		var _g = 0;
		while(_g < mods.length) {
			var mod = mods[_g];
			++_g;
			if(mod.add || mod.rem) continue;
			if(mod.sourceRow < 0) continue;
			if(mod.sourcePrevRow >= 0) {
				var v = mod.sourceRow;
				to_unit.set(mod.sourcePrevRow,v);
				v;
				var v1 = mod.sourcePrevRow;
				from_unit.set(mod.sourceRow,v1);
				v1;
				if(mod.sourcePrevRow + 1 != mod.sourceRow) ct++;
			}
			if(mod.sourceNextRow >= 0) {
				var v2 = mod.sourceNextRow;
				to_unit.set(mod.sourceRow,v2);
				v2;
				var v3 = mod.sourceRow;
				from_unit.set(mod.sourceNextRow,v3);
				v3;
				if(mod.sourceRow + 1 != mod.sourceNextRow) ct++;
			}
		}
		if(ct > 0) {
			var cursor = null;
			var logical = null;
			var starts = [];
			var _g1 = 0;
			while(_g1 < dim) {
				var i = _g1++;
				var u = from_unit.get(i);
				if(u != null) {
					meta_from_unit.set(u,i);
					i;
				} else starts.push(i);
			}
			var used = new haxe.ds.IntMap();
			var len = 0;
			var _g2 = 0;
			while(_g2 < dim) {
				var i1 = _g2++;
				if(meta_from_unit.exists(logical)) cursor = meta_from_unit.get(logical); else cursor = null;
				if(cursor == null) {
					var v4 = starts.shift();
					cursor = v4;
					logical = v4;
				}
				if(cursor == null) cursor = 0;
				while(used.exists(cursor)) cursor = (cursor + 1) % dim;
				logical = cursor;
				permutationRev.push(cursor);
				used.set(cursor,1);
				1;
			}
			var _g11 = 0;
			var _g3 = permutationRev.length;
			while(_g11 < _g3) {
				var i2 = _g11++;
				permutation[i2] = -1;
			}
			var _g12 = 0;
			var _g4 = permutation.length;
			while(_g12 < _g4) {
				var i3 = _g12++;
				permutation[permutationRev[i3]] = i3;
			}
		}
	}
	,permuteRows: function() {
		this.rowPermutation = new Array();
		this.rowPermutationRev = new Array();
		this.computeOrdering(this.mods,this.rowPermutation,this.rowPermutationRev,this.source.get_height());
	}
	,finishRows: function() {
		var fate = new Array();
		this.permuteRows();
		if(this.rowPermutation.length > 0) {
			var _g = 0;
			var _g1 = this.mods;
			while(_g < _g1.length) {
				var mod = _g1[_g];
				++_g;
				if(mod.sourceRow >= 0) mod.sourceRow = this.rowPermutation[mod.sourceRow];
			}
		}
		if(this.rowPermutation.length > 0) this.source.insertOrDeleteRows(this.rowPermutation,this.rowPermutation.length);
		var len = this.processMods(this.mods,fate,this.source.get_height());
		this.source.insertOrDeleteRows(fate,len);
		var _g2 = 0;
		var _g11 = this.mods;
		while(_g2 < _g11.length) {
			var mod1 = _g11[_g2];
			++_g2;
			if(!mod1.rem) {
				if(mod1.add) {
					var $it0 = this.headerPost.iterator();
					while( $it0.hasNext() ) {
						var c = $it0.next();
						var offset = this.patchInSourceCol.get(c);
						if(offset != null && offset >= 0) this.source.setCell(offset,mod1.destRow,this.patch.getCell(c,mod1.patchRow));
					}
				} else if(mod1.update) {
					this.currentRow = mod1.patchRow;
					this.checkAct();
					if(!this.rowInfo.updated) continue;
					var $it1 = this.headerPre.iterator();
					while( $it1.hasNext() ) {
						var c1 = $it1.next();
						var txt = this.view.toString(this.patch.getCell(c1,mod1.patchRow));
						coopy.DiffRender.examineCell(0,0,this.view,txt,"",this.rowInfo.value,"",this.cellInfo);
						if(!this.cellInfo.updated) continue;
						if(this.cellInfo.conflicted) continue;
						var d = this.view.toDatum(this.csv.parseCell(this.cellInfo.rvalue));
						this.source.setCell(this.patchInSourceCol.get(c1),mod1.destRow,d);
					}
				}
			}
		}
	}
	,permuteColumns: function() {
		if(this.headerMove == null) return;
		this.colPermutation = new Array();
		this.colPermutationRev = new Array();
		this.computeOrdering(this.cmods,this.colPermutation,this.colPermutationRev,this.source.get_width());
		if(this.colPermutation.length == 0) return;
	}
	,finishColumns: function() {
		this.needSourceColumns();
		var _g1 = this.payloadCol;
		var _g = this.payloadTop;
		while(_g1 < _g) {
			var i = _g1++;
			var act = this.modifier.get(i);
			var hdr = this.header.get(i);
			if(act == null) act = "";
			if(act == "---") {
				var at1 = this.patchInSourceCol.get(i);
				var mod = new coopy.HighlightPatchUnit();
				mod.code = act;
				mod.rem = true;
				mod.sourceRow = at1;
				mod.patchRow = i;
				this.cmods.push(mod);
			} else if(act == "+++") {
				var mod1 = new coopy.HighlightPatchUnit();
				mod1.code = act;
				mod1.add = true;
				var prev = -1;
				var cont = false;
				mod1.sourceRow = -1;
				if(this.cmods.length > 0) mod1.sourceRow = this.cmods[this.cmods.length - 1].sourceRow;
				if(mod1.sourceRow != -1) mod1.sourceRowOffset = 1;
				mod1.patchRow = i;
				this.cmods.push(mod1);
			} else if(act != "...") {
				var mod2 = new coopy.HighlightPatchUnit();
				mod2.code = act;
				mod2.patchRow = i;
				mod2.sourceRow = this.patchInSourceCol.get(i);
				this.cmods.push(mod2);
			}
		}
		var at = -1;
		var rat = -1;
		var _g11 = 0;
		var _g2 = this.cmods.length - 1;
		while(_g11 < _g2) {
			var i1 = _g11++;
			var icode = this.cmods[i1].code;
			if(icode != "+++" && icode != "---") at = this.cmods[i1].sourceRow;
			this.cmods[i1 + 1].sourcePrevRow = at;
			var j = this.cmods.length - 1 - i1;
			var jcode = this.cmods[j].code;
			if(jcode != "+++" && jcode != "---") rat = this.cmods[j].sourceRow;
			this.cmods[j - 1].sourceNextRow = rat;
		}
		var fate = new Array();
		this.permuteColumns();
		if(this.headerMove != null) {
			if(this.colPermutation.length > 0) {
				var _g3 = 0;
				var _g12 = this.cmods;
				while(_g3 < _g12.length) {
					var mod3 = _g12[_g3];
					++_g3;
					if(mod3.sourceRow >= 0) mod3.sourceRow = this.colPermutation[mod3.sourceRow];
				}
				this.source.insertOrDeleteColumns(this.colPermutation,this.colPermutation.length);
			}
		}
		var len = this.processMods(this.cmods,fate,this.source.get_width());
		this.source.insertOrDeleteColumns(fate,len);
		var _g4 = 0;
		var _g13 = this.cmods;
		while(_g4 < _g13.length) {
			var cmod = _g13[_g4];
			++_g4;
			if(!cmod.rem) {
				if(cmod.add) {
					var _g21 = 0;
					var _g31 = this.mods;
					while(_g21 < _g31.length) {
						var mod4 = _g31[_g21];
						++_g21;
						if(mod4.patchRow != -1 && mod4.destRow != -1) {
							var d = this.patch.getCell(cmod.patchRow,mod4.patchRow);
							this.source.setCell(cmod.destRow,mod4.destRow,d);
						}
					}
					var hdr1 = this.header.get(cmod.patchRow);
					this.source.setCell(cmod.destRow,0,this.view.toDatum(hdr1));
				}
			}
		}
		var _g14 = 0;
		var _g5 = this.source.get_width();
		while(_g14 < _g5) {
			var i2 = _g14++;
			var name = this.view.toString(this.source.getCell(i2,0));
			var next_name = this.headerRename.get(name);
			if(next_name == null) continue;
			this.source.setCell(i2,0,this.view.toDatum(next_name));
		}
	}
	,__class__: coopy.HighlightPatch
};
coopy.HighlightPatchUnit = $hx_exports.coopy.HighlightPatchUnit = function() {
	this.add = false;
	this.rem = false;
	this.update = false;
	this.sourceRow = -1;
	this.sourceRowOffset = 0;
	this.sourcePrevRow = -1;
	this.sourceNextRow = -1;
	this.destRow = -1;
	this.patchRow = -1;
	this.code = "";
};
coopy.HighlightPatchUnit.__name__ = true;
coopy.HighlightPatchUnit.prototype = {
	toString: function() {
		return this.code + " patchRow " + this.patchRow + " sourceRows " + this.sourcePrevRow + "," + this.sourceRow + "," + this.sourceNextRow + " destRow " + this.destRow;
	}
	,__class__: coopy.HighlightPatchUnit
};
coopy.Index = function() {
	this.items = new haxe.ds.StringMap();
	this.cols = new Array();
	this.keys = new Array();
	this.top_freq = 0;
	this.height = 0;
};
coopy.Index.__name__ = true;
coopy.Index.prototype = {
	addColumn: function(i) {
		this.cols.push(i);
	}
	,indexTable: function(t) {
		this.indexed_table = t;
		if(this.keys.length != t.get_height() && t.get_height() > 0) this.keys[t.get_height() - 1] = null;
		var _g1 = 0;
		var _g = t.get_height();
		while(_g1 < _g) {
			var i = _g1++;
			var key = this.keys[i];
			if(key == null) {
				key = this.toKey(t,i);
				this.keys[i] = key;
			}
			var item = this.items.get(key);
			if(item == null) {
				item = new coopy.IndexItem();
				this.items.set(key,item);
			}
			var ct;
			if(item.lst == null) item.lst = new Array();
			item.lst.push(i);
			ct = item.lst.length;
			if(ct > this.top_freq) this.top_freq = ct;
		}
		this.height = t.get_height();
	}
	,toKey: function(t,i) {
		var wide = "";
		if(this.v == null) this.v = t.getCellView();
		var _g1 = 0;
		var _g = this.cols.length;
		while(_g1 < _g) {
			var k = _g1++;
			var d = t.getCell(this.cols[k],i);
			var txt = this.v.toString(d);
			if(txt == null || txt == "" || txt == "null" || txt == "undefined") continue;
			if(k > 0) wide += " // ";
			wide += txt;
		}
		return wide;
	}
	,toKeyByContent: function(row) {
		var wide = "";
		var _g1 = 0;
		var _g = this.cols.length;
		while(_g1 < _g) {
			var k = _g1++;
			var txt = row.getRowString(this.cols[k]);
			if(txt == null || txt == "" || txt == "null" || txt == "undefined") continue;
			if(k > 0) wide += " // ";
			wide += txt;
		}
		return wide;
	}
	,getTable: function() {
		return this.indexed_table;
	}
	,__class__: coopy.Index
};
coopy.IndexItem = function() {
};
coopy.IndexItem.__name__ = true;
coopy.IndexItem.prototype = {
	add: function(i) {
		if(this.lst == null) this.lst = new Array();
		this.lst.push(i);
		return this.lst.length;
	}
	,length: function() {
		return this.lst.length;
	}
	,value: function() {
		return this.lst[0];
	}
	,__class__: coopy.IndexItem
};
coopy.IndexPair = function() {
	this.ia = new coopy.Index();
	this.ib = new coopy.Index();
	this.quality = 0;
};
coopy.IndexPair.__name__ = true;
coopy.IndexPair.prototype = {
	addColumns: function(ca,cb) {
		this.ia.addColumn(ca);
		this.ib.addColumn(cb);
	}
	,indexTables: function(a,b) {
		this.ia.indexTable(a);
		this.ib.indexTable(b);
		var good = 0;
		var $it0 = this.ia.items.keys();
		while( $it0.hasNext() ) {
			var key = $it0.next();
			var item_a = this.ia.items.get(key);
			var spot_a = item_a.lst.length;
			var item_b = this.ib.items.get(key);
			var spot_b = 0;
			if(item_b != null) spot_b = item_b.lst.length;
			if(spot_a == 1 && spot_b == 1) good++;
		}
		this.quality = good / Math.max(1.0,a.get_height());
	}
	,queryByKey: function(ka) {
		var result = new coopy.CrossMatch();
		result.item_a = this.ia.items.get(ka);
		result.item_b = this.ib.items.get(ka);
		result.spot_a = result.spot_b = 0;
		if(ka != "") {
			if(result.item_a != null) result.spot_a = result.item_a.lst.length;
			if(result.item_b != null) result.spot_b = result.item_b.lst.length;
		}
		return result;
	}
	,queryByContent: function(row) {
		var result = new coopy.CrossMatch();
		var ka = this.ia.toKeyByContent(row);
		return this.queryByKey(ka);
	}
	,queryLocal: function(row) {
		var ka = this.ia.toKey(this.ia.getTable(),row);
		return this.queryByKey(ka);
	}
	,localKey: function(row) {
		return this.ia.toKey(this.ia.getTable(),row);
	}
	,remoteKey: function(row) {
		return this.ib.toKey(this.ib.getTable(),row);
	}
	,getTopFreq: function() {
		if(this.ib.top_freq > this.ia.top_freq) return this.ib.top_freq;
		return this.ia.top_freq;
	}
	,getQuality: function() {
		return this.quality;
	}
	,__class__: coopy.IndexPair
};
coopy.Merger = $hx_exports.coopy.Merger = function(parent,local,remote,flags) {
	this.parent = parent;
	this.local = local;
	this.remote = remote;
	this.flags = flags;
};
coopy.Merger.__name__ = true;
coopy.Merger.makeConflictedCell = function(view,pcell,lcell,rcell) {
	return view.toDatum("((( " + view.toString(pcell) + " ))) " + view.toString(lcell) + " /// " + view.toString(rcell));
};
coopy.Merger.prototype = {
	shuffleDimension: function(dim_units,len,fate,cl,cr) {
		var at = 0;
		var _g = 0;
		while(_g < dim_units.length) {
			var cunit = dim_units[_g];
			++_g;
			if(cunit.p < 0) {
				if(cunit.l < 0) {
					if(cunit.r >= 0) {
						cr.set(cunit.r,at);
						at;
						at++;
					}
				} else {
					cl.set(cunit.l,at);
					at;
					at++;
				}
			} else if(cunit.l >= 0) {
				if(cunit.r < 0) {
				} else {
					cl.set(cunit.l,at);
					at;
					at++;
				}
			}
		}
		var _g1 = 0;
		while(_g1 < len) {
			var x = _g1++;
			var idx = cl.get(x);
			if(idx == null) fate.push(-1); else fate.push(idx);
		}
		return at;
	}
	,shuffleColumns: function() {
		this.column_mix_local = new haxe.ds.IntMap();
		this.column_mix_remote = new haxe.ds.IntMap();
		var fate = new Array();
		var wfate = this.shuffleDimension(this.column_units,this.local.get_width(),fate,this.column_mix_local,this.column_mix_remote);
		this.local.insertOrDeleteColumns(fate,wfate);
	}
	,shuffleRows: function() {
		this.row_mix_local = new haxe.ds.IntMap();
		this.row_mix_remote = new haxe.ds.IntMap();
		var fate = new Array();
		var hfate = this.shuffleDimension(this.units,this.local.get_height(),fate,this.row_mix_local,this.row_mix_remote);
		this.local.insertOrDeleteRows(fate,hfate);
	}
	,apply: function() {
		this.conflicts = 0;
		var ct = coopy.Coopy.compareTables3(this.parent,this.local,this.remote);
		var align = ct.align();
		this.order = align.toOrder();
		this.units = this.order.getList();
		this.column_order = align.meta.toOrder();
		this.column_units = this.column_order.getList();
		var allow_insert = this.flags.allowInsert();
		var allow_delete = this.flags.allowDelete();
		var allow_update = this.flags.allowUpdate();
		var view = this.parent.getCellView();
		var _g = 0;
		var _g1 = this.units;
		while(_g < _g1.length) {
			var row = _g1[_g];
			++_g;
			if(row.l >= 0 && row.r >= 0 && row.p >= 0) {
				var _g2 = 0;
				var _g3 = this.column_units;
				while(_g2 < _g3.length) {
					var col = _g3[_g2];
					++_g2;
					if(col.l >= 0 && col.r >= 0 && col.p >= 0) {
						var pcell = this.parent.getCell(col.p,row.p);
						var rcell = this.remote.getCell(col.r,row.r);
						if(!view.equals(pcell,rcell)) {
							var lcell = this.local.getCell(col.l,row.l);
							if(view.equals(pcell,lcell)) this.local.setCell(col.l,row.l,rcell); else {
								this.local.setCell(col.l,row.l,coopy.Merger.makeConflictedCell(view,pcell,lcell,rcell));
								this.conflicts++;
							}
						}
					}
				}
			}
		}
		this.shuffleColumns();
		this.shuffleRows();
		var $it0 = this.column_mix_remote.keys();
		while( $it0.hasNext() ) {
			var x = $it0.next();
			var x2 = this.column_mix_remote.get(x);
			var _g4 = 0;
			var _g11 = this.units;
			while(_g4 < _g11.length) {
				var unit = _g11[_g4];
				++_g4;
				if(unit.l >= 0 && unit.r >= 0) this.local.setCell(x2,this.row_mix_local.get(unit.l),this.remote.getCell(x,unit.r)); else if(unit.p < 0 && unit.r >= 0) this.local.setCell(x2,this.row_mix_remote.get(unit.r),this.remote.getCell(x,unit.r));
			}
		}
		var $it1 = this.row_mix_remote.keys();
		while( $it1.hasNext() ) {
			var y = $it1.next();
			var y2 = this.row_mix_remote.get(y);
			var _g5 = 0;
			var _g12 = this.column_units;
			while(_g5 < _g12.length) {
				var unit1 = _g12[_g5];
				++_g5;
				if(unit1.l >= 0 && unit1.r >= 0) this.local.setCell(this.column_mix_local.get(unit1.l),y2,this.remote.getCell(unit1.r,y));
			}
		}
		return this.conflicts;
	}
	,__class__: coopy.Merger
};
coopy.Mover = $hx_exports.coopy.Mover = function() { };
coopy.Mover.__name__ = true;
coopy.Mover.moveUnits = function(units) {
	var isrc = new Array();
	var idest = new Array();
	var len = units.length;
	var ltop = -1;
	var rtop = -1;
	var in_src = new haxe.ds.IntMap();
	var in_dest = new haxe.ds.IntMap();
	var _g = 0;
	while(_g < len) {
		var i = _g++;
		var unit = units[i];
		if(unit.l >= 0 && unit.r >= 0) {
			if(ltop < unit.l) ltop = unit.l;
			if(rtop < unit.r) rtop = unit.r;
			in_src.set(unit.l,i);
			i;
			in_dest.set(unit.r,i);
			i;
		}
	}
	var v;
	var _g1 = 0;
	var _g2 = ltop + 1;
	while(_g1 < _g2) {
		var i1 = _g1++;
		v = in_src.get(i1);
		if(v != null) isrc.push(v);
	}
	var _g11 = 0;
	var _g3 = rtop + 1;
	while(_g11 < _g3) {
		var i2 = _g11++;
		v = in_dest.get(i2);
		if(v != null) idest.push(v);
	}
	return coopy.Mover.moveWithoutExtras(isrc,idest);
};
coopy.Mover.move = function(isrc,idest) {
	var len = isrc.length;
	var len2 = idest.length;
	var in_src = new haxe.ds.IntMap();
	var in_dest = new haxe.ds.IntMap();
	var _g = 0;
	while(_g < len) {
		var i = _g++;
		in_src.set(isrc[i],i);
		i;
	}
	var _g1 = 0;
	while(_g1 < len2) {
		var i1 = _g1++;
		in_dest.set(idest[i1],i1);
		i1;
	}
	var src = new Array();
	var dest = new Array();
	var v;
	var _g2 = 0;
	while(_g2 < len) {
		var i2 = _g2++;
		v = isrc[i2];
		if(in_dest.exists(v)) src.push(v);
	}
	var _g3 = 0;
	while(_g3 < len2) {
		var i3 = _g3++;
		v = idest[i3];
		if(in_src.exists(v)) dest.push(v);
	}
	return coopy.Mover.moveWithoutExtras(src,dest);
};
coopy.Mover.moveWithoutExtras = function(src,dest) {
	if(src.length != dest.length) return null;
	if(src.length <= 1) return [];
	var len = src.length;
	var in_src = new haxe.ds.IntMap();
	var blk_len = new haxe.ds.IntMap();
	var blk_src_loc = new haxe.ds.IntMap();
	var blk_dest_loc = new haxe.ds.IntMap();
	var _g = 0;
	while(_g < len) {
		var i = _g++;
		in_src.set(src[i],i);
		i;
	}
	var ct = 0;
	var in_cursor = -2;
	var out_cursor = 0;
	var next;
	var blk = -1;
	var v;
	while(out_cursor < len) {
		v = dest[out_cursor];
		next = in_src.get(v);
		if(next != in_cursor + 1) {
			blk = v;
			ct = 1;
			blk_src_loc.set(blk,next);
			blk_dest_loc.set(blk,out_cursor);
		} else ct++;
		blk_len.set(blk,ct);
		in_cursor = next;
		out_cursor++;
	}
	var blks = new Array();
	var $it0 = blk_len.keys();
	while( $it0.hasNext() ) {
		var k = $it0.next();
		blks.push(k);
	}
	blks.sort(function(a,b) {
		return blk_len.get(b) - blk_len.get(a);
	});
	var moved = new Array();
	while(blks.length > 0) {
		var blk1 = blks.shift();
		var blen = blks.length;
		var ref_src_loc = blk_src_loc.get(blk1);
		var ref_dest_loc = blk_dest_loc.get(blk1);
		var i1 = blen - 1;
		while(i1 >= 0) {
			var blki = blks[i1];
			var blki_src_loc = blk_src_loc.get(blki);
			var to_left_src = blki_src_loc < ref_src_loc;
			var to_left_dest = blk_dest_loc.get(blki) < ref_dest_loc;
			if(to_left_src != to_left_dest) {
				var ct1 = blk_len.get(blki);
				var _g1 = 0;
				while(_g1 < ct1) {
					var j = _g1++;
					moved.push(src[blki_src_loc]);
					blki_src_loc++;
				}
				blks.splice(i1,1);
			}
			i1--;
		}
	}
	return moved;
};
coopy.Ndjson = $hx_exports.coopy.Ndjson = function(tab) {
	this.tab = tab;
	this.view = tab.getCellView();
	this.header_row = 0;
};
coopy.Ndjson.__name__ = true;
coopy.Ndjson.prototype = {
	renderRow: function(r) {
		var row = new haxe.ds.StringMap();
		var _g1 = 0;
		var _g = this.tab.get_width();
		while(_g1 < _g) {
			var c = _g1++;
			var key = this.view.toString(this.tab.getCell(c,this.header_row));
			if(c == 0 && this.header_row == 1) key = "@:@";
			var value = this.tab.getCell(c,r);
			row.set(key,value);
		}
		return haxe.format.JsonPrinter.print(row,null,null);
	}
	,render: function() {
		var txt = "";
		var offset = 0;
		if(this.tab.get_height() == 0) return txt;
		if(this.tab.get_width() == 0) return txt;
		if(this.tab.getCell(0,0) == "@:@") offset = 1;
		this.header_row = offset;
		var _g1 = this.header_row + 1;
		var _g = this.tab.get_height();
		while(_g1 < _g) {
			var r = _g1++;
			txt += this.renderRow(r);
			txt += "\n";
		}
		return txt;
	}
	,addRow: function(r,txt) {
		var json = new haxe.format.JsonParser(txt).parseRec();
		if(this.columns == null) this.columns = new haxe.ds.StringMap();
		var w = this.tab.get_width();
		var h = this.tab.get_height();
		var resize = false;
		var _g = 0;
		var _g1 = Reflect.fields(json);
		while(_g < _g1.length) {
			var name = _g1[_g];
			++_g;
			if(!this.columns.exists(name)) {
				this.columns.set(name,w);
				w++;
				resize = true;
			}
		}
		if(r >= h) {
			h = r + 1;
			resize = true;
		}
		if(resize) this.tab.resize(w,h);
		var _g2 = 0;
		var _g11 = Reflect.fields(json);
		while(_g2 < _g11.length) {
			var name1 = _g11[_g2];
			++_g2;
			var v = Reflect.field(json,name1);
			var c = this.columns.get(name1);
			this.tab.setCell(c,r,v);
		}
	}
	,addHeaderRow: function(r) {
		var names = this.columns.keys();
		while( names.hasNext() ) {
			var n = names.next();
			this.tab.setCell(this.columns.get(n),r,this.view.toDatum(n));
		}
	}
	,parse: function(txt) {
		this.columns = null;
		var rows = txt.split("\n");
		var h = rows.length;
		if(h == 0) {
			this.tab.clear();
			return;
		}
		if(rows[h - 1] == "") h--;
		var _g = 0;
		while(_g < h) {
			var i = _g++;
			var at = h - i - 1;
			this.addRow(at + 1,rows[at]);
		}
		this.addHeaderRow(0);
	}
	,__class__: coopy.Ndjson
};
coopy.NestedCellBuilder = function() {
};
coopy.NestedCellBuilder.__name__ = true;
coopy.NestedCellBuilder.__interfaces__ = [coopy.CellBuilder];
coopy.NestedCellBuilder.prototype = {
	needSeparator: function() {
		return false;
	}
	,setSeparator: function(separator) {
	}
	,setConflictSeparator: function(separator) {
	}
	,setView: function(view) {
		this.view = view;
	}
	,update: function(local,remote) {
		var h = this.view.makeHash();
		this.view.hashSet(h,"before",local);
		this.view.hashSet(h,"after",remote);
		return h;
	}
	,conflict: function(parent,local,remote) {
		var h = this.view.makeHash();
		this.view.hashSet(h,"before",parent);
		this.view.hashSet(h,"ours",local);
		this.view.hashSet(h,"theirs",remote);
		return h;
	}
	,marker: function(label) {
		return this.view.toDatum(label);
	}
	,negToNull: function(x) {
		if(x < 0) return null;
		return x;
	}
	,links: function(unit) {
		var h = this.view.makeHash();
		if(unit.p >= -1) {
			this.view.hashSet(h,"before",this.negToNull(unit.p));
			this.view.hashSet(h,"ours",this.negToNull(unit.l));
			this.view.hashSet(h,"theirs",this.negToNull(unit.r));
			return h;
		}
		this.view.hashSet(h,"before",this.negToNull(unit.l));
		this.view.hashSet(h,"after",this.negToNull(unit.r));
		return h;
	}
	,__class__: coopy.NestedCellBuilder
};
coopy.Ordering = function() {
	this.order = new Array();
	this.ignore_parent = false;
};
coopy.Ordering.__name__ = true;
coopy.Ordering.prototype = {
	add: function(l,r,p) {
		if(p == null) p = -2;
		if(this.ignore_parent) p = -2;
		this.order.push(new coopy.Unit(l,r,p));
	}
	,getList: function() {
		return this.order;
	}
	,toString: function() {
		var txt = "";
		var _g1 = 0;
		var _g = this.order.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(i > 0) txt += ", ";
			txt += Std.string(this.order[i]);
		}
		return txt;
	}
	,ignoreParent: function() {
		this.ignore_parent = true;
	}
	,__class__: coopy.Ordering
};
coopy.Table = function() { };
coopy.Table.__name__ = true;
coopy.Table.prototype = {
	__class__: coopy.Table
};
coopy.SimpleTable = $hx_exports.coopy.SimpleTable = function(w,h) {
	this.data = new haxe.ds.IntMap();
	this.w = w;
	this.h = h;
};
coopy.SimpleTable.__name__ = true;
coopy.SimpleTable.__interfaces__ = [coopy.Table];
coopy.SimpleTable.tableToString = function(tab) {
	var x = "";
	var _g1 = 0;
	var _g = tab.get_height();
	while(_g1 < _g) {
		var i = _g1++;
		var _g3 = 0;
		var _g2 = tab.get_width();
		while(_g3 < _g2) {
			var j = _g3++;
			if(j > 0) x += " ";
			x += Std.string(tab.getCell(j,i));
		}
		x += "\n";
	}
	return x;
};
coopy.SimpleTable.tableIsSimilar = function(tab1,tab2) {
	if(tab1.get_width() != tab2.get_width()) return false;
	if(tab1.get_height() != tab2.get_height()) return false;
	var v = tab1.getCellView();
	var _g1 = 0;
	var _g = tab1.get_height();
	while(_g1 < _g) {
		var i = _g1++;
		var _g3 = 0;
		var _g2 = tab1.get_width();
		while(_g3 < _g2) {
			var j = _g3++;
			if(!v.equals(tab1.getCell(j,i),tab2.getCell(j,i))) return false;
		}
	}
	return true;
};
coopy.SimpleTable.prototype = {
	getTable: function() {
		return this;
	}
	,get_width: function() {
		return this.w;
	}
	,get_height: function() {
		return this.h;
	}
	,getCell: function(x,y) {
		return this.data.get(x + y * this.w);
	}
	,setCell: function(x,y,c) {
		var value = c;
		this.data.set(x + y * this.w,value);
	}
	,toString: function() {
		return coopy.SimpleTable.tableToString(this);
	}
	,getCellView: function() {
		return new coopy.SimpleView();
	}
	,isResizable: function() {
		return true;
	}
	,resize: function(w,h) {
		this.w = w;
		this.h = h;
		return true;
	}
	,clear: function() {
		this.data = new haxe.ds.IntMap();
	}
	,insertOrDeleteRows: function(fate,hfate) {
		var data2 = new haxe.ds.IntMap();
		var _g1 = 0;
		var _g = fate.length;
		while(_g1 < _g) {
			var i = _g1++;
			var j = fate[i];
			if(j != -1) {
				var _g3 = 0;
				var _g2 = this.w;
				while(_g3 < _g2) {
					var c = _g3++;
					var idx = i * this.w + c;
					if(this.data.exists(idx)) {
						var value = this.data.get(idx);
						data2.set(j * this.w + c,value);
					}
				}
			}
		}
		this.h = hfate;
		this.data = data2;
		return true;
	}
	,insertOrDeleteColumns: function(fate,wfate) {
		var data2 = new haxe.ds.IntMap();
		var _g1 = 0;
		var _g = fate.length;
		while(_g1 < _g) {
			var i = _g1++;
			var j = fate[i];
			if(j != -1) {
				var _g3 = 0;
				var _g2 = this.h;
				while(_g3 < _g2) {
					var r = _g3++;
					var idx = r * this.w + i;
					if(this.data.exists(idx)) {
						var value = this.data.get(idx);
						data2.set(r * wfate + j,value);
					}
				}
			}
		}
		this.w = wfate;
		this.data = data2;
		return true;
	}
	,trimBlank: function() {
		if(this.h == 0) return true;
		var h_test = this.h;
		if(h_test >= 3) h_test = 3;
		var view = this.getCellView();
		var space = view.toDatum("");
		var more = true;
		while(more) {
			var _g1 = 0;
			var _g = this.get_width();
			while(_g1 < _g) {
				var i = _g1++;
				var c = this.getCell(i,this.h - 1);
				if(!(view.equals(c,space) || c == null)) {
					more = false;
					break;
				}
			}
			if(more) this.h--;
		}
		more = true;
		var nw = this.w;
		while(more) {
			if(this.w == 0) break;
			var _g2 = 0;
			while(_g2 < h_test) {
				var i1 = _g2++;
				var c1 = this.getCell(nw - 1,i1);
				if(!(view.equals(c1,space) || c1 == null)) {
					more = false;
					break;
				}
			}
			if(more) nw--;
		}
		if(nw == this.w) return true;
		var data2 = new haxe.ds.IntMap();
		var _g3 = 0;
		while(_g3 < nw) {
			var i2 = _g3++;
			var _g21 = 0;
			var _g11 = this.h;
			while(_g21 < _g11) {
				var r = _g21++;
				var idx = r * this.w + i2;
				if(this.data.exists(idx)) {
					var value = this.data.get(idx);
					data2.set(r * nw + i2,value);
				}
			}
		}
		this.w = nw;
		this.data = data2;
		return true;
	}
	,getData: function() {
		return null;
	}
	,clone: function() {
		var result = new coopy.SimpleTable(this.get_width(),this.get_height());
		var _g1 = 0;
		var _g = this.get_height();
		while(_g1 < _g) {
			var i = _g1++;
			var _g3 = 0;
			var _g2 = this.get_width();
			while(_g3 < _g2) {
				var j = _g3++;
				result.setCell(j,i,this.getCell(j,i));
			}
		}
		return result;
	}
	,__class__: coopy.SimpleTable
};
coopy.View = function() { };
coopy.View.__name__ = true;
coopy.View.prototype = {
	__class__: coopy.View
};
coopy.SimpleView = $hx_exports.coopy.SimpleView = function() {
};
coopy.SimpleView.__name__ = true;
coopy.SimpleView.__interfaces__ = [coopy.View];
coopy.SimpleView.prototype = {
	toString: function(d) {
		if(d == null) return null;
		return "" + Std.string(d);
	}
	,equals: function(d1,d2) {
		if(d1 == null && d2 == null) return true;
		if(d1 == null && "" + Std.string(d2) == "") return true;
		if("" + Std.string(d1) == "" && d2 == null) return true;
		return "" + Std.string(d1) == "" + Std.string(d2);
	}
	,toDatum: function(x) {
		return x;
	}
	,makeHash: function() {
		return new haxe.ds.StringMap();
	}
	,hashSet: function(h,str,d) {
		var hh = h;
		var value = d;
		hh.set(str,value);
	}
	,hashExists: function(h,str) {
		var hh = h;
		return hh.exists(str);
	}
	,hashGet: function(h,str) {
		var hh = h;
		return hh.get(str);
	}
	,isHash: function(h) {
		return js.Boot.__instanceof(h,haxe.ds.StringMap);
	}
	,__class__: coopy.SimpleView
};
coopy.SparseSheet = function() {
	this.h = this.w = 0;
};
coopy.SparseSheet.__name__ = true;
coopy.SparseSheet.prototype = {
	resize: function(w,h,zero) {
		this.row = new haxe.ds.IntMap();
		this.nonDestructiveResize(w,h,zero);
	}
	,nonDestructiveResize: function(w,h,zero) {
		this.w = w;
		this.h = h;
		this.zero = zero;
	}
	,get: function(x,y) {
		var cursor = this.row.get(y);
		if(cursor == null) return this.zero;
		var val = cursor.get(x);
		if(val == null) return this.zero;
		return val;
	}
	,set: function(x,y,val) {
		var cursor = this.row.get(y);
		if(cursor == null) {
			cursor = new haxe.ds.IntMap();
			this.row.set(y,cursor);
		}
		cursor.set(x,val);
	}
	,__class__: coopy.SparseSheet
};
coopy.SqlColumn = $hx_exports.coopy.SqlColumn = function() {
};
coopy.SqlColumn.__name__ = true;
coopy.SqlColumn.byNameAndPrimaryKey = function(name,primary) {
	var result = new coopy.SqlColumn();
	result.name = name;
	result.primary = primary;
	return result;
};
coopy.SqlColumn.prototype = {
	getName: function() {
		return this.name;
	}
	,isPrimaryKey: function() {
		return this.primary;
	}
	,toString: function() {
		return (this.primary?"*":"") + this.name;
	}
	,__class__: coopy.SqlColumn
};
coopy.SqlCompare = $hx_exports.coopy.SqlCompare = function(db,local,remote) {
	this.db = db;
	this.local = local;
	this.remote = remote;
};
coopy.SqlCompare.__name__ = true;
coopy.SqlCompare.prototype = {
	equalArray: function(a1,a2) {
		if(a1.length != a2.length) return false;
		var _g1 = 0;
		var _g = a1.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(a1[i] != a2[i]) return false;
		}
		return true;
	}
	,validateSchema: function() {
		var all_cols1 = this.local.getColumnNames();
		var all_cols2 = this.remote.getColumnNames();
		if(!this.equalArray(all_cols1,all_cols2)) return false;
		var key_cols1 = this.local.getPrimaryKey();
		var key_cols2 = this.remote.getPrimaryKey();
		if(!this.equalArray(key_cols1,key_cols2)) return false;
		if(key_cols1.length == 0) return false;
		return true;
	}
	,denull: function(x) {
		if(x == null) return -1;
		return x;
	}
	,link: function() {
		var i0 = this.denull(this.db.get(0));
		var i1 = this.denull(this.db.get(1));
		if(i0 == -3) {
			i0 = this.at0;
			this.at0++;
		}
		if(i1 == -3) {
			i1 = this.at1;
			this.at1++;
		}
		var factor;
		if(i0 >= 0 && i1 >= 0) factor = 2; else factor = 1;
		var offset = factor - 1;
		if(i0 >= 0) {
			var _g1 = 0;
			var _g = this.local.get_width();
			while(_g1 < _g) {
				var x = _g1++;
				this.local.setCellCache(x,i0,this.db.get(2 + factor * x));
			}
		}
		if(i1 >= 0) {
			var _g11 = 0;
			var _g2 = this.remote.get_width();
			while(_g11 < _g2) {
				var x1 = _g11++;
				this.remote.setCellCache(x1,i1,this.db.get(2 + factor * x1 + offset));
			}
		}
		this.align.link(i0,i1);
		this.align.addToOrder(i0,i1);
	}
	,linkQuery: function(query,order) {
		if(this.db.begin(query,null,order)) {
			while(this.db.read()) this.link();
			this.db.end();
		}
	}
	,apply: function() {
		if(this.db == null) return null;
		if(!this.validateSchema()) return null;
		var rowid_name = this.db.rowid();
		this.align = new coopy.Alignment();
		var key_cols = this.local.getPrimaryKey();
		var data_cols = this.local.getAllButPrimaryKey();
		var all_cols = this.local.getColumnNames();
		this.align.meta = new coopy.Alignment();
		var _g1 = 0;
		var _g = all_cols.length;
		while(_g1 < _g) {
			var i = _g1++;
			this.align.meta.link(i,i);
		}
		this.align.meta.range(all_cols.length,all_cols.length);
		this.align.tables(this.local,this.remote);
		this.align.range(999,999);
		var sql_table1 = this.local.getQuotedTableName();
		var sql_table2 = this.remote.getQuotedTableName();
		var sql_key_cols = "";
		var _g11 = 0;
		var _g2 = key_cols.length;
		while(_g11 < _g2) {
			var i1 = _g11++;
			if(i1 > 0) sql_key_cols += ",";
			sql_key_cols += this.local.getQuotedColumnName(key_cols[i1]);
		}
		var sql_all_cols = "";
		var _g12 = 0;
		var _g3 = all_cols.length;
		while(_g12 < _g3) {
			var i2 = _g12++;
			if(i2 > 0) sql_all_cols += ",";
			sql_all_cols += this.local.getQuotedColumnName(all_cols[i2]);
		}
		var sql_key_match = "";
		var _g13 = 0;
		var _g4 = key_cols.length;
		while(_g13 < _g4) {
			var i3 = _g13++;
			if(i3 > 0) sql_key_match += " AND ";
			var n = this.local.getQuotedColumnName(key_cols[i3]);
			sql_key_match += sql_table1 + "." + n + " IS " + sql_table2 + "." + n;
		}
		var sql_data_mismatch = "";
		var _g14 = 0;
		var _g5 = data_cols.length;
		while(_g14 < _g5) {
			var i4 = _g14++;
			if(i4 > 0) sql_data_mismatch += " OR ";
			var n1 = this.local.getQuotedColumnName(data_cols[i4]);
			sql_data_mismatch += sql_table1 + "." + n1 + " IS NOT " + sql_table2 + "." + n1;
		}
		var sql_dbl_cols = "";
		var dbl_cols = [];
		var _g15 = 0;
		var _g6 = all_cols.length;
		while(_g15 < _g6) {
			var i5 = _g15++;
			if(i5 > 0) sql_dbl_cols += ",";
			var n2 = this.local.getQuotedColumnName(all_cols[i5]);
			var buf = "__coopy_" + i5;
			sql_dbl_cols += sql_table1 + "." + n2 + " AS " + buf;
			dbl_cols.push(buf);
			sql_dbl_cols += ",";
			sql_dbl_cols += sql_table2 + "." + n2 + " AS " + buf + "b";
			dbl_cols.push(buf + "b");
		}
		var sql_order = "";
		var _g16 = 0;
		var _g7 = key_cols.length;
		while(_g16 < _g7) {
			var i6 = _g16++;
			if(i6 > 0) sql_order += ",";
			var n3 = this.local.getQuotedColumnName(key_cols[i6]);
			sql_order += n3;
		}
		var sql_dbl_order = "";
		var _g17 = 0;
		var _g8 = key_cols.length;
		while(_g17 < _g8) {
			var i7 = _g17++;
			if(i7 > 0) sql_dbl_order += ",";
			var n4 = this.local.getQuotedColumnName(key_cols[i7]);
			sql_dbl_order += sql_table1 + "." + n4;
		}
		var rowid = "-3";
		var rowid1 = "-3";
		var rowid2 = "-3";
		if(rowid_name != null) {
			rowid = rowid_name;
			rowid1 = sql_table1 + "." + rowid_name;
			rowid2 = sql_table2 + "." + rowid_name;
		}
		var sql_inserts = "SELECT DISTINCT NULL, " + rowid + " AS rowid, " + sql_all_cols + " FROM " + sql_table2 + " WHERE NOT EXISTS (SELECT 1 FROM " + sql_table1 + " WHERE " + sql_key_match + ")";
		var sql_inserts_order = ["NULL","rowid"].concat(all_cols);
		var sql_updates = "SELECT DISTINCT " + rowid1 + " AS __coopy_rowid0, " + rowid2 + " AS __coopy_rowid1, " + sql_dbl_cols + " FROM " + sql_table1 + " INNER JOIN " + sql_table2 + " ON " + sql_key_match + " WHERE " + sql_data_mismatch;
		var sql_updates_order = ["__coopy_rowid0","__coopy_rowid1"].concat(dbl_cols);
		var sql_deletes = "SELECT DISTINCT " + rowid + " AS rowid, NULL, " + sql_all_cols + " FROM " + sql_table1 + " WHERE NOT EXISTS (SELECT 1 FROM " + sql_table2 + " WHERE " + sql_key_match + ")";
		var sql_deletes_order = ["rowid","NULL"].concat(all_cols);
		this.at0 = 1;
		this.at1 = 1;
		this.linkQuery(sql_inserts,sql_inserts_order);
		this.linkQuery(sql_updates,sql_updates_order);
		this.linkQuery(sql_deletes,sql_deletes_order);
		return this.align;
	}
	,__class__: coopy.SqlCompare
};
coopy.SqlDatabase = function() { };
coopy.SqlDatabase.__name__ = true;
coopy.SqlDatabase.prototype = {
	__class__: coopy.SqlDatabase
};
coopy.SqlHelper = function() { };
coopy.SqlHelper.__name__ = true;
coopy.SqlHelper.prototype = {
	__class__: coopy.SqlHelper
};
coopy.SqlTable = $hx_exports.coopy.SqlTable = function(db,name,helper) {
	this.db = db;
	this.name = name;
	this.helper = helper;
	this.cache = new haxe.ds.IntMap();
	this.h = -1;
	this.id2rid = null;
	this.getColumns();
};
coopy.SqlTable.__name__ = true;
coopy.SqlTable.__interfaces__ = [coopy.Table];
coopy.SqlTable.prototype = {
	getColumns: function() {
		if(this.columns != null) return;
		if(this.db == null) return;
		this.columns = this.db.getColumns(this.name);
		this.columnNames = new Array();
		var _g = 0;
		var _g1 = this.columns;
		while(_g < _g1.length) {
			var col = _g1[_g];
			++_g;
			this.columnNames.push(col.getName());
		}
	}
	,getPrimaryKey: function() {
		this.getColumns();
		var result = new Array();
		var _g = 0;
		var _g1 = this.columns;
		while(_g < _g1.length) {
			var col = _g1[_g];
			++_g;
			if(!col.isPrimaryKey()) continue;
			result.push(col.getName());
		}
		return result;
	}
	,getAllButPrimaryKey: function() {
		this.getColumns();
		var result = new Array();
		var _g = 0;
		var _g1 = this.columns;
		while(_g < _g1.length) {
			var col = _g1[_g];
			++_g;
			if(col.isPrimaryKey()) continue;
			result.push(col.getName());
		}
		return result;
	}
	,getColumnNames: function() {
		this.getColumns();
		return this.columnNames;
	}
	,getQuotedTableName: function() {
		if(this.quotedTableName != null) return this.quotedTableName;
		this.quotedTableName = this.db.getQuotedTableName(this.name);
		return this.quotedTableName;
	}
	,getQuotedColumnName: function(name) {
		return this.db.getQuotedColumnName(name);
	}
	,getCell: function(x,y) {
		if(this.h >= 0) {
			y = y - 1;
			if(y >= 0) y = this.id2rid[y];
		}
		if(y < 0) {
			this.getColumns();
			return this.columns[x].name;
		}
		var row = this.cache.get(y);
		if(row == null) {
			row = new haxe.ds.IntMap();
			this.getColumns();
			this.db.beginRow(this.name,y,this.columnNames);
			while(this.db.read()) {
				var _g1 = 0;
				var _g = this.get_width();
				while(_g1 < _g) {
					var i = _g1++;
					var v = this.db.get(i);
					row.set(i,v);
					v;
				}
			}
			this.db.end();
			this.cache.set(y,row);
			row;
		}
		var this1 = this.cache.get(y);
		return this1.get(x);
	}
	,setCellCache: function(x,y,c) {
		var row = this.cache.get(y);
		if(row == null) {
			row = new haxe.ds.IntMap();
			this.getColumns();
			this.cache.set(y,row);
			row;
		}
		var v = c;
		row.set(x,v);
		v;
	}
	,setCell: function(x,y,c) {
		console.log("SqlTable cannot set cells yet");
	}
	,getCellView: function() {
		return new coopy.SimpleView();
	}
	,isResizable: function() {
		return false;
	}
	,resize: function(w,h) {
		return false;
	}
	,clear: function() {
	}
	,insertOrDeleteRows: function(fate,hfate) {
		return false;
	}
	,insertOrDeleteColumns: function(fate,wfate) {
		return false;
	}
	,trimBlank: function() {
		return false;
	}
	,get_width: function() {
		this.getColumns();
		return this.columns.length;
	}
	,get_height: function() {
		if(this.h >= 0) return this.h;
		if(this.helper == null) return -1;
		this.id2rid = this.helper.getRowIDs(this.db,this.name);
		this.h = this.id2rid.length + 1;
		return this.h;
	}
	,getData: function() {
		return null;
	}
	,clone: function() {
		return null;
	}
	,__class__: coopy.SqlTable
};
coopy.SqlTableName = $hx_exports.coopy.SqlTableName = function(name,prefix) {
	if(prefix == null) prefix = "";
	if(name == null) name = "";
	this.name = name;
	this.prefix = prefix;
};
coopy.SqlTableName.__name__ = true;
coopy.SqlTableName.prototype = {
	toString: function() {
		if(this.prefix == "") return this.name;
		return this.prefix + "." + this.name;
	}
	,__class__: coopy.SqlTableName
};
coopy.SqliteHelper = function() {
};
coopy.SqliteHelper.__name__ = true;
coopy.SqliteHelper.__interfaces__ = [coopy.SqlHelper];
coopy.SqliteHelper.prototype = {
	getTableNames: function(db) {
		var q = "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name";
		if(!db.begin(q,null,["name"])) return null;
		var names = new Array();
		while(db.read()) names.push(db.get(0));
		db.end();
		return names;
	}
	,countRows: function(db,name) {
		var q = "SELECT COUNT(*) AS ct FROM " + db.getQuotedTableName(name);
		if(!db.begin(q,null,["ct"])) return -1;
		var ct = -1;
		while(db.read()) ct = db.get(0);
		db.end();
		return ct;
	}
	,getRowIDs: function(db,name) {
		var result = new Array();
		var q = "SELECT ROWID AS r FROM " + db.getQuotedTableName(name) + " ORDER BY ROWID";
		if(!db.begin(q,null,["r"])) return null;
		while(db.read()) {
			var c = db.get(0);
			result.push(c);
		}
		db.end();
		return result;
	}
	,__class__: coopy.SqliteHelper
};
coopy.TableComparisonState = $hx_exports.coopy.TableComparisonState = function() {
	this.reset();
};
coopy.TableComparisonState.__name__ = true;
coopy.TableComparisonState.prototype = {
	reset: function() {
		this.completed = false;
		this.run_to_completion = true;
		this.is_equal_known = false;
		this.is_equal = false;
		this.has_same_columns = false;
		this.has_same_columns_known = false;
		this.compare_flags = null;
	}
	,__class__: coopy.TableComparisonState
};
coopy.TableDiff = $hx_exports.coopy.TableDiff = function(align,flags) {
	this.align = align;
	this.flags = flags;
	this.builder = null;
};
coopy.TableDiff.__name__ = true;
coopy.TableDiff.prototype = {
	setCellBuilder: function(builder) {
		this.builder = builder;
	}
	,getSeparator: function(t,t2,root) {
		var sep = root;
		var w = t.get_width();
		var h = t.get_height();
		var view = t.getCellView();
		var _g = 0;
		while(_g < h) {
			var y = _g++;
			var _g1 = 0;
			while(_g1 < w) {
				var x = _g1++;
				var txt = view.toString(t.getCell(x,y));
				if(txt == null) continue;
				while(txt.indexOf(sep) >= 0) sep = "-" + sep;
			}
		}
		if(t2 != null) {
			w = t2.get_width();
			h = t2.get_height();
			var _g2 = 0;
			while(_g2 < h) {
				var y1 = _g2++;
				var _g11 = 0;
				while(_g11 < w) {
					var x1 = _g11++;
					var txt1 = view.toString(t2.getCell(x1,y1));
					if(txt1 == null) continue;
					while(txt1.indexOf(sep) >= 0) sep = "-" + sep;
				}
			}
		}
		return sep;
	}
	,quoteForDiff: function(v,d) {
		var nil = "NULL";
		if(v.equals(d,null)) return nil;
		var str = v.toString(d);
		var score = 0;
		var _g1 = 0;
		var _g = str.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(HxOverrides.cca(str,score) != 95) break;
			score++;
		}
		if(HxOverrides.substr(str,score,null) == nil) str = "_" + str;
		return str;
	}
	,isReordered: function(m,ct) {
		var reordered = false;
		var l = -1;
		var r = -1;
		var _g = 0;
		while(_g < ct) {
			var i = _g++;
			var unit = m.get(i);
			if(unit == null) continue;
			if(unit.l >= 0) {
				if(unit.l < l) {
					reordered = true;
					break;
				}
				l = unit.l;
			}
			if(unit.r >= 0) {
				if(unit.r < r) {
					reordered = true;
					break;
				}
				r = unit.r;
			}
		}
		return reordered;
	}
	,spreadContext: function(units,del,active) {
		if(del > 0 && active != null) {
			var mark = -del - 1;
			var skips = 0;
			var _g1 = 0;
			var _g = units.length;
			while(_g1 < _g) {
				var i = _g1++;
				if(active[i] == -3) {
					skips++;
					continue;
				}
				if(active[i] == 0 || active[i] == 3) {
					if(i - mark <= del + skips) active[i] = 2; else if(i - mark == del + 1 + skips) active[i] = 3;
				} else if(active[i] == 1) {
					mark = i;
					skips = 0;
				}
			}
			mark = units.length + del + 1;
			skips = 0;
			var _g11 = 0;
			var _g2 = units.length;
			while(_g11 < _g2) {
				var j = _g11++;
				var i1 = units.length - 1 - j;
				if(active[i1] == -3) {
					skips++;
					continue;
				}
				if(active[i1] == 0 || active[i1] == 3) {
					if(mark - i1 <= del + skips) active[i1] = 2; else if(mark - i1 == del + 1 + skips) active[i1] = 3;
				} else if(active[i1] == 1) {
					mark = i1;
					skips = 0;
				}
			}
		}
	}
	,setIgnore: function(ignore,idx_ignore,tab,r_header) {
		var v = tab.getCellView();
		if(tab.get_height() >= r_header) {
			var _g1 = 0;
			var _g = tab.get_width();
			while(_g1 < _g) {
				var i = _g1++;
				var name = v.toString(tab.getCell(i,r_header));
				if(!ignore.exists(name)) continue;
				idx_ignore.set(i,true);
			}
		}
	}
	,countActive: function(active) {
		var ct = 0;
		var showed_dummy = false;
		var _g1 = 0;
		var _g = active.length;
		while(_g1 < _g) {
			var i = _g1++;
			var publish = active[i] > 0;
			var dummy = active[i] == 3;
			if(dummy && showed_dummy) continue;
			if(!publish) continue;
			showed_dummy = dummy;
			ct++;
		}
		return ct;
	}
	,hilite: function(output) {
		if(!output.isResizable()) return false;
		if(this.builder == null) {
			if(this.flags.allow_nested_cells) this.builder = new coopy.NestedCellBuilder(); else this.builder = new coopy.FlatCellBuilder();
		}
		output.resize(0,0);
		output.clear();
		var row_map = new haxe.ds.IntMap();
		var col_map = new haxe.ds.IntMap();
		var order = this.align.toOrder();
		var units = order.getList();
		var has_parent = this.align.reference != null;
		var a;
		var b;
		var p;
		var rp_header = 0;
		var ra_header = 0;
		var rb_header = 0;
		var is_index_p = new haxe.ds.IntMap();
		var is_index_a = new haxe.ds.IntMap();
		var is_index_b = new haxe.ds.IntMap();
		if(has_parent) {
			p = this.align.getSource();
			a = this.align.reference.getTarget();
			b = this.align.getTarget();
			rp_header = this.align.reference.meta.getSourceHeader();
			ra_header = this.align.reference.meta.getTargetHeader();
			rb_header = this.align.meta.getTargetHeader();
			if(this.align.getIndexColumns() != null) {
				var _g = 0;
				var _g1 = this.align.getIndexColumns();
				while(_g < _g1.length) {
					var p2b = _g1[_g];
					++_g;
					if(p2b.l >= 0) is_index_p.set(p2b.l,true);
					if(p2b.r >= 0) is_index_b.set(p2b.r,true);
				}
			}
			if(this.align.reference.getIndexColumns() != null) {
				var _g2 = 0;
				var _g11 = this.align.reference.getIndexColumns();
				while(_g2 < _g11.length) {
					var p2a = _g11[_g2];
					++_g2;
					if(p2a.l >= 0) is_index_p.set(p2a.l,true);
					if(p2a.r >= 0) is_index_a.set(p2a.r,true);
				}
			}
		} else {
			a = this.align.getSource();
			b = this.align.getTarget();
			p = a;
			ra_header = this.align.meta.getSourceHeader();
			rp_header = ra_header;
			rb_header = this.align.meta.getTargetHeader();
			if(this.align.getIndexColumns() != null) {
				var _g3 = 0;
				var _g12 = this.align.getIndexColumns();
				while(_g3 < _g12.length) {
					var a2b = _g12[_g3];
					++_g3;
					if(a2b.l >= 0) is_index_a.set(a2b.l,true);
					if(a2b.r >= 0) is_index_b.set(a2b.r,true);
				}
			}
		}
		var column_order = this.align.meta.toOrder();
		var column_units = column_order.getList();
		var p_ignore = new haxe.ds.IntMap();
		var a_ignore = new haxe.ds.IntMap();
		var b_ignore = new haxe.ds.IntMap();
		var ignore = this.flags.getIgnoredColumns();
		if(ignore != null) {
			this.setIgnore(ignore,p_ignore,p,rp_header);
			this.setIgnore(ignore,a_ignore,a,ra_header);
			this.setIgnore(ignore,b_ignore,b,rb_header);
			var ncolumn_units = new Array();
			var _g13 = 0;
			var _g4 = column_units.length;
			while(_g13 < _g4) {
				var j = _g13++;
				var cunit = column_units[j];
				if(p_ignore.exists(cunit.p) || a_ignore.exists(cunit.l) || b_ignore.exists(cunit.r)) continue;
				ncolumn_units.push(cunit);
			}
			column_units = ncolumn_units;
		}
		var show_rc_numbers = false;
		var row_moves = null;
		var col_moves = null;
		if(this.flags.ordered) {
			row_moves = new haxe.ds.IntMap();
			var moves = coopy.Mover.moveUnits(units);
			var _g14 = 0;
			var _g5 = moves.length;
			while(_g14 < _g5) {
				var i = _g14++;
				row_moves.set(moves[i],i);
				i;
			}
			col_moves = new haxe.ds.IntMap();
			moves = coopy.Mover.moveUnits(column_units);
			var _g15 = 0;
			var _g6 = moves.length;
			while(_g15 < _g6) {
				var i1 = _g15++;
				col_moves.set(moves[i1],i1);
				i1;
			}
		}
		var active = new Array();
		var active_column = null;
		if(!this.flags.show_unchanged) {
			var _g16 = 0;
			var _g7 = units.length;
			while(_g16 < _g7) {
				var i2 = _g16++;
				active[units.length - 1 - i2] = 0;
			}
		}
		var allow_insert = this.flags.allowInsert();
		var allow_delete = this.flags.allowDelete();
		var allow_update = this.flags.allowUpdate();
		if(!this.flags.show_unchanged_columns) {
			active_column = new Array();
			var _g17 = 0;
			var _g8 = column_units.length;
			while(_g17 < _g8) {
				var i3 = _g17++;
				var v1 = 0;
				var unit = column_units[i3];
				if(unit.l >= 0 && is_index_a.get(unit.l)) v1 = 1;
				if(unit.r >= 0 && is_index_b.get(unit.r)) v1 = 1;
				if(unit.p >= 0 && is_index_p.get(unit.p)) v1 = 1;
				active_column[i3] = v1;
			}
		}
		var v = a.getCellView();
		this.builder.setView(v);
		var outer_reps_needed;
		if(this.flags.show_unchanged && this.flags.show_unchanged_columns) outer_reps_needed = 1; else outer_reps_needed = 2;
		var sep = "";
		var conflict_sep = "";
		var schema = new Array();
		var have_schema = false;
		var _g18 = 0;
		var _g9 = column_units.length;
		while(_g18 < _g9) {
			var j1 = _g18++;
			var cunit1 = column_units[j1];
			var reordered = false;
			if(this.flags.ordered) {
				if(col_moves.exists(j1)) reordered = true;
				if(reordered) show_rc_numbers = true;
			}
			var act = "";
			if(cunit1.r >= 0 && cunit1.lp() == -1) {
				have_schema = true;
				act = "+++";
				if(active_column != null) {
					if(allow_update) active_column[j1] = 1;
				}
			}
			if(cunit1.r < 0 && cunit1.lp() >= 0) {
				have_schema = true;
				act = "---";
				if(active_column != null) {
					if(allow_update) active_column[j1] = 1;
				}
			}
			if(cunit1.r >= 0 && cunit1.lp() >= 0) {
				if(p.get_height() >= rp_header && b.get_height() >= rb_header) {
					var pp = p.getCell(cunit1.lp(),rp_header);
					var bb = b.getCell(cunit1.r,rb_header);
					if(!v.equals(pp,bb)) {
						have_schema = true;
						act = "(";
						act += v.toString(pp);
						act += ")";
						if(active_column != null) active_column[j1] = 1;
					}
				}
			}
			if(reordered) {
				act = ":" + act;
				have_schema = true;
				if(active_column != null) active_column = null;
			}
			schema.push(act);
		}
		if(have_schema) {
			var at = output.get_height();
			output.resize(column_units.length + 1,at + 1);
			output.setCell(0,at,this.builder.marker("!"));
			var _g19 = 0;
			var _g10 = column_units.length;
			while(_g19 < _g10) {
				var j2 = _g19++;
				output.setCell(j2 + 1,at,v.toDatum(schema[j2]));
			}
		}
		var top_line_done = false;
		if(this.flags.always_show_header) {
			var at1 = output.get_height();
			output.resize(column_units.length + 1,at1 + 1);
			output.setCell(0,at1,this.builder.marker("@@"));
			var _g110 = 0;
			var _g20 = column_units.length;
			while(_g110 < _g20) {
				var j3 = _g110++;
				var cunit2 = column_units[j3];
				if(cunit2.r >= 0) {
					if(b.get_height() != 0) output.setCell(j3 + 1,at1,b.getCell(cunit2.r,rb_header));
				} else if(cunit2.lp() >= 0) {
					if(p.get_height() != 0) output.setCell(j3 + 1,at1,p.getCell(cunit2.lp(),rp_header));
				}
				col_map.set(j3 + 1,cunit2);
			}
			top_line_done = true;
		}
		var output_height = output.get_height();
		var output_height_init = output.get_height();
		var _g21 = 0;
		while(_g21 < outer_reps_needed) {
			var out = _g21++;
			if(out == 1) {
				this.spreadContext(units,this.flags.unchanged_context,active);
				this.spreadContext(column_units,this.flags.unchanged_column_context,active_column);
				if(active_column != null) {
					var _g22 = 0;
					var _g111 = column_units.length;
					while(_g22 < _g111) {
						var i4 = _g22++;
						if(active_column[i4] == 3) active_column[i4] = 0;
					}
				}
				var rows = this.countActive(active) + output_height_init;
				if(top_line_done) rows--;
				output_height = output_height_init;
				if(rows > output.get_height()) output.resize(column_units.length + 1,rows);
			}
			var showed_dummy = false;
			var l = -1;
			var r = -1;
			var _g23 = 0;
			var _g112 = units.length;
			while(_g23 < _g112) {
				var i5 = _g23++;
				var unit1 = units[i5];
				var reordered1 = false;
				if(this.flags.ordered) {
					if(row_moves.exists(i5)) reordered1 = true;
					if(reordered1) show_rc_numbers = true;
				}
				if(unit1.r < 0 && unit1.l < 0) continue;
				if(unit1.r == 0 && unit1.lp() == 0 && top_line_done) continue;
				var act1 = "";
				if(reordered1) act1 = ":";
				var publish = this.flags.show_unchanged;
				var dummy = false;
				if(out == 1) {
					publish = active[i5] > 0;
					dummy = active[i5] == 3;
					if(dummy && showed_dummy) continue;
					if(!publish) continue;
				}
				if(!dummy) showed_dummy = false;
				var at2 = output_height;
				if(publish) {
					output_height++;
					if(output.get_height() < output_height) output.resize(column_units.length + 1,output_height);
				}
				if(dummy) {
					var _g41 = 0;
					var _g31 = column_units.length + 1;
					while(_g41 < _g31) {
						var j4 = _g41++;
						output.setCell(j4,at2,v.toDatum("..."));
					}
					showed_dummy = true;
					continue;
				}
				var have_addition = false;
				var skip = false;
				if(unit1.p < 0 && unit1.l < 0 && unit1.r >= 0) {
					if(!allow_insert) skip = true;
					act1 = "+++";
				}
				if((unit1.p >= 0 || !has_parent) && unit1.l >= 0 && unit1.r < 0) {
					if(!allow_delete) skip = true;
					act1 = "---";
				}
				if(skip) {
					if(!publish) {
						if(active != null) active[i5] = -3;
					}
					continue;
				}
				var _g42 = 0;
				var _g32 = column_units.length;
				while(_g42 < _g32) {
					var j5 = _g42++;
					var cunit3 = column_units[j5];
					var pp1 = null;
					var ll = null;
					var rr = null;
					var dd = null;
					var dd_to = null;
					var have_dd_to = false;
					var dd_to_alt = null;
					var have_dd_to_alt = false;
					var have_pp = false;
					var have_ll = false;
					var have_rr = false;
					if(cunit3.p >= 0 && unit1.p >= 0) {
						pp1 = p.getCell(cunit3.p,unit1.p);
						have_pp = true;
					}
					if(cunit3.l >= 0 && unit1.l >= 0) {
						ll = a.getCell(cunit3.l,unit1.l);
						have_ll = true;
					}
					if(cunit3.r >= 0 && unit1.r >= 0) {
						rr = b.getCell(cunit3.r,unit1.r);
						have_rr = true;
						if((have_pp?cunit3.p:cunit3.l) < 0) {
							if(rr != null) {
								if(v.toString(rr) != "") {
									if(this.flags.allowUpdate()) have_addition = true;
								}
							}
						}
					}
					if(have_pp) {
						if(!have_rr) dd = pp1; else if(v.equals(pp1,rr)) dd = pp1; else {
							dd = pp1;
							dd_to = rr;
							have_dd_to = true;
							if(!v.equals(pp1,ll)) {
								if(!v.equals(pp1,rr)) {
									dd_to_alt = ll;
									have_dd_to_alt = true;
								}
							}
						}
					} else if(have_ll) {
						if(!have_rr) dd = ll; else if(v.equals(ll,rr)) dd = ll; else {
							dd = ll;
							dd_to = rr;
							have_dd_to = true;
						}
					} else dd = rr;
					var cell = dd;
					if(have_dd_to && allow_update) {
						if(active_column != null) active_column[j5] = 1;
						if(sep == "") {
							if(this.builder.needSeparator()) {
								sep = this.getSeparator(a,b,"->");
								this.builder.setSeparator(sep);
							} else sep = "->";
						}
						var is_conflict = false;
						if(have_dd_to_alt) {
							if(!v.equals(dd_to,dd_to_alt)) is_conflict = true;
						}
						if(!is_conflict) {
							cell = this.builder.update(dd,dd_to);
							if(sep.length > act1.length) act1 = sep;
						} else {
							if(conflict_sep == "") {
								if(this.builder.needSeparator()) {
									conflict_sep = this.getSeparator(p,a,"!") + sep;
									this.builder.setConflictSeparator(conflict_sep);
								} else conflict_sep = "!->";
							}
							cell = this.builder.conflict(dd,dd_to_alt,dd_to);
							act1 = conflict_sep;
						}
					}
					if(act1 == "" && have_addition) act1 = "+";
					if(act1 == "+++") {
						if(have_rr) {
							if(active_column != null) active_column[j5] = 1;
						}
					}
					if(publish) {
						if(active_column == null || active_column[j5] > 0) output.setCell(j5 + 1,at2,cell);
					}
				}
				if(publish) {
					output.setCell(0,at2,this.builder.marker(act1));
					row_map.set(at2,unit1);
				}
				if(act1 != "") {
					if(!publish) {
						if(active != null) active[i5] = 1;
					}
				}
			}
		}
		if(!show_rc_numbers) {
			if(this.flags.always_show_order) show_rc_numbers = true; else if(this.flags.ordered) {
				show_rc_numbers = this.isReordered(row_map,output.get_height());
				if(!show_rc_numbers) show_rc_numbers = this.isReordered(col_map,output.get_width());
			}
		}
		var admin_w = 1;
		if(show_rc_numbers && !this.flags.never_show_order) {
			admin_w++;
			var target = new Array();
			var _g113 = 0;
			var _g24 = output.get_width();
			while(_g113 < _g24) {
				var i6 = _g113++;
				target.push(i6 + 1);
			}
			output.insertOrDeleteColumns(target,output.get_width() + 1);
			var _g114 = 0;
			var _g25 = output.get_height();
			while(_g114 < _g25) {
				var i7 = _g114++;
				var unit2 = row_map.get(i7);
				if(unit2 == null) {
					output.setCell(0,i7,"");
					continue;
				}
				output.setCell(0,i7,this.builder.links(unit2));
			}
			target = new Array();
			var _g115 = 0;
			var _g26 = output.get_height();
			while(_g115 < _g26) {
				var i8 = _g115++;
				target.push(i8 + 1);
			}
			output.insertOrDeleteRows(target,output.get_height() + 1);
			var _g116 = 1;
			var _g27 = output.get_width();
			while(_g116 < _g27) {
				var i9 = _g116++;
				var unit3 = col_map.get(i9 - 1);
				if(unit3 == null) {
					output.setCell(i9,0,"");
					continue;
				}
				output.setCell(i9,0,this.builder.links(unit3));
			}
			output.setCell(0,0,this.builder.marker("@:@"));
		}
		if(active_column != null) {
			var all_active = true;
			var _g117 = 0;
			var _g28 = active_column.length;
			while(_g117 < _g28) {
				var i10 = _g117++;
				if(active_column[i10] == 0) {
					all_active = false;
					break;
				}
			}
			if(!all_active) {
				var fate = new Array();
				var _g29 = 0;
				while(_g29 < admin_w) {
					var i11 = _g29++;
					fate.push(i11);
				}
				var at3 = admin_w;
				var ct = 0;
				var dots = new Array();
				var _g118 = 0;
				var _g30 = active_column.length;
				while(_g118 < _g30) {
					var i12 = _g118++;
					var off = active_column[i12] == 0;
					if(off) ct = ct + 1; else ct = 0;
					if(off && ct > 1) fate.push(-1); else {
						if(off) dots.push(at3);
						fate.push(at3);
						at3++;
					}
				}
				output.insertOrDeleteColumns(fate,at3);
				var _g33 = 0;
				while(_g33 < dots.length) {
					var d = dots[_g33];
					++_g33;
					var _g210 = 0;
					var _g119 = output.get_height();
					while(_g210 < _g119) {
						var j6 = _g210++;
						output.setCell(d,j6,this.builder.marker("..."));
					}
				}
			}
		}
		return true;
	}
	,__class__: coopy.TableDiff
};
coopy.TableIO = $hx_exports.coopy.TableIO = function() {
};
coopy.TableIO.__name__ = true;
coopy.TableIO.prototype = {
	getContent: function(name) {
		return "";
	}
	,saveContent: function(name,txt) {
		return false;
	}
	,args: function() {
		return [];
	}
	,writeStdout: function(txt) {
	}
	,writeStderr: function(txt) {
	}
	,command: function(cmd,args) {
		return 1;
	}
	,async: function() {
		return false;
	}
	,exists: function(path) {
		return false;
	}
	,openSqliteDatabase: function(path) {
		return null;
	}
	,__class__: coopy.TableIO
};
coopy.TableModifier = $hx_exports.coopy.TableModifier = function(t) {
	this.t = t;
};
coopy.TableModifier.__name__ = true;
coopy.TableModifier.prototype = {
	removeColumn: function(at) {
		var fate = [];
		var _g1 = 0;
		var _g = this.t.get_width();
		while(_g1 < _g) {
			var i = _g1++;
			if(i < at) fate.push(i); else if(i > at) fate.push(i - 1); else fate.push(-1);
		}
		return this.t.insertOrDeleteColumns(fate,this.t.get_width() - 1);
	}
	,__class__: coopy.TableModifier
};
coopy.TerminalDiffRender = function() {
	this.align_columns = true;
};
coopy.TerminalDiffRender.__name__ = true;
coopy.TerminalDiffRender.prototype = {
	alignColumns: function(enable) {
		this.align_columns = enable;
	}
	,render: function(t) {
		this.csv = new coopy.Csv();
		var result = "";
		var w = t.get_width();
		var h = t.get_height();
		var txt = "";
		this.t = t;
		this.v = t.getCellView();
		this.codes = new haxe.ds.StringMap();
		this.codes.set("header","\x1B[0;1m");
		this.codes.set("spec","\x1B[35;1m");
		this.codes.set("add","\x1B[32;1m");
		this.codes.set("conflict","\x1B[33;1m");
		this.codes.set("modify","\x1B[34;1m");
		this.codes.set("remove","\x1B[31;1m");
		this.codes.set("minor","\x1B[2m");
		this.codes.set("done","\x1B[0m");
		var sizes = null;
		if(this.align_columns) sizes = this.pickSizes(t);
		var _g = 0;
		while(_g < h) {
			var y = _g++;
			var _g1 = 0;
			while(_g1 < w) {
				var x = _g1++;
				if(x > 0) txt += this.codes.get("minor") + "," + this.codes.get("done");
				txt += this.getText(x,y,true);
				if(sizes != null) {
					var bit = this.getText(x,y,false);
					var _g3 = 0;
					var _g2 = sizes[x] - bit.length;
					while(_g3 < _g2) {
						var i = _g3++;
						txt += " ";
					}
				}
			}
			txt += "\r\n";
		}
		this.t = null;
		this.v = null;
		this.csv = null;
		this.codes = null;
		return txt;
	}
	,getText: function(x,y,color) {
		var val = this.t.getCell(x,y);
		var cell = coopy.DiffRender.renderCell(this.t,this.v,x,y);
		if(color) {
			var code = null;
			if(cell.category != null) code = this.codes.get(cell.category);
			if(cell.category_given_tr != null) {
				var code_tr = this.codes.get(cell.category_given_tr);
				if(code_tr != null) code = code_tr;
			}
			if(code != null) {
				if(cell.rvalue != null) {
					val = this.codes.get("remove") + cell.lvalue + this.codes.get("modify") + cell.pretty_separator + this.codes.get("add") + cell.rvalue + this.codes.get("done");
					if(cell.pvalue != null) val = this.codes.get("conflict") + cell.pvalue + this.codes.get("modify") + cell.pretty_separator + Std.string(val);
				} else {
					val = cell.pretty_value;
					val = code + Std.string(val) + this.codes.get("done");
				}
			}
		} else val = cell.pretty_value;
		return this.csv.renderCell(this.v,val);
	}
	,pickSizes: function(t) {
		var w = t.get_width();
		var h = t.get_height();
		var v = t.getCellView();
		var csv = new coopy.Csv();
		var sizes = new Array();
		var row = -1;
		var total = w - 1;
		var _g = 0;
		while(_g < w) {
			var x = _g++;
			var m = 0;
			var m2 = 0;
			var mmax = 0;
			var mmostmax = 0;
			var mmin = -1;
			var _g1 = 0;
			while(_g1 < h) {
				var y = _g1++;
				var txt = this.getText(x,y,false);
				if(txt == "@@" && row == -1) row = y;
				var len = txt.length;
				if(y == row) mmin = len;
				m += len;
				m2 += len * len;
				if(len > mmax) mmax = len;
			}
			var mean = m / h;
			var stddev = Math.sqrt(m2 / h - mean * mean);
			var most = mean + stddev * 2 + 0.5 | 0;
			var _g11 = 0;
			while(_g11 < h) {
				var y1 = _g11++;
				var txt1 = this.getText(x,y1,false);
				var len1 = txt1.length;
				if(len1 <= most) {
					if(len1 > mmostmax) mmostmax = len1;
				}
			}
			var full = mmax;
			most = mmostmax;
			if(mmin != -1) {
				if(most < mmin) most = mmin;
			}
			sizes.push(most);
			total += most;
		}
		if(total > 130) return null;
		return sizes;
	}
	,__class__: coopy.TerminalDiffRender
};
coopy.Unit = function(l,r,p) {
	if(p == null) p = -2;
	if(r == null) r = -2;
	if(l == null) l = -2;
	this.l = l;
	this.r = r;
	this.p = p;
};
coopy.Unit.__name__ = true;
coopy.Unit.describe = function(i) {
	if(i >= 0) return "" + i; else return "-";
};
coopy.Unit.prototype = {
	lp: function() {
		if(this.p == -2) return this.l; else return this.p;
	}
	,toString: function() {
		if(this.p >= -1) return coopy.Unit.describe(this.p) + "|" + coopy.Unit.describe(this.l) + ":" + coopy.Unit.describe(this.r);
		return coopy.Unit.describe(this.l) + ":" + coopy.Unit.describe(this.r);
	}
	,fromString: function(txt) {
		txt += "]";
		var at = 0;
		var _g1 = 0;
		var _g = txt.length;
		while(_g1 < _g) {
			var i = _g1++;
			var ch = HxOverrides.cca(txt,i);
			if(ch >= 48 && ch <= 57) {
				at *= 10;
				at += ch - 48;
			} else if(ch == 45) at = -1; else if(ch == 124) {
				this.p = at;
				at = 0;
			} else if(ch == 58) {
				this.l = at;
				at = 0;
			} else if(ch == 93) {
				this.r = at;
				return true;
			}
		}
		return false;
	}
	,__class__: coopy.Unit
};
coopy.Viterbi = $hx_exports.coopy.Viterbi = function() {
	this.K = this.T = 0;
	this.reset();
	this.cost = new coopy.SparseSheet();
	this.src = new coopy.SparseSheet();
	this.path = new coopy.SparseSheet();
};
coopy.Viterbi.__name__ = true;
coopy.Viterbi.prototype = {
	reset: function() {
		this.index = 0;
		this.mode = 0;
		this.path_valid = false;
		this.best_cost = 0;
	}
	,setSize: function(states,sequence_length) {
		this.K = states;
		this.T = sequence_length;
		this.cost.resize(this.K,this.T,0);
		this.src.resize(this.K,this.T,-1);
		this.path.resize(1,this.T,-1);
	}
	,assertMode: function(next) {
		if(next == 0 && this.mode == 1) this.index++;
		this.mode = next;
	}
	,addTransition: function(s0,s1,c) {
		var resize = false;
		if(s0 >= this.K) {
			this.K = s0 + 1;
			resize = true;
		}
		if(s1 >= this.K) {
			this.K = s1 + 1;
			resize = true;
		}
		if(resize) {
			this.cost.nonDestructiveResize(this.K,this.T,0);
			this.src.nonDestructiveResize(this.K,this.T,-1);
			this.path.nonDestructiveResize(1,this.T,-1);
		}
		this.path_valid = false;
		this.assertMode(1);
		if(this.index >= this.T) {
			this.T = this.index + 1;
			this.cost.nonDestructiveResize(this.K,this.T,0);
			this.src.nonDestructiveResize(this.K,this.T,-1);
			this.path.nonDestructiveResize(1,this.T,-1);
		}
		var sourced = false;
		if(this.index > 0) {
			c += this.cost.get(s0,this.index - 1);
			sourced = this.src.get(s0,this.index - 1) != -1;
		} else sourced = true;
		if(sourced) {
			if(c < this.cost.get(s1,this.index) || this.src.get(s1,this.index) == -1) {
				this.cost.set(s1,this.index,c);
				this.src.set(s1,this.index,s0);
			}
		}
	}
	,endTransitions: function() {
		this.path_valid = false;
		this.assertMode(0);
	}
	,beginTransitions: function() {
		this.path_valid = false;
		this.assertMode(1);
	}
	,calculatePath: function() {
		if(this.path_valid) return;
		this.endTransitions();
		var best = 0;
		var bestj = -1;
		if(this.index <= 0) {
			this.path_valid = true;
			return;
		}
		var _g1 = 0;
		var _g = this.K;
		while(_g1 < _g) {
			var j = _g1++;
			if((this.cost.get(j,this.index - 1) < best || bestj == -1) && this.src.get(j,this.index - 1) != -1) {
				best = this.cost.get(j,this.index - 1);
				bestj = j;
			}
		}
		this.best_cost = best;
		var _g11 = 0;
		var _g2 = this.index;
		while(_g11 < _g2) {
			var j1 = _g11++;
			var i = this.index - 1 - j1;
			this.path.set(0,i,bestj);
			if(!(bestj != -1 && (bestj >= 0 && bestj < this.K))) console.log("Problem in Viterbi");
			bestj = this.src.get(bestj,i);
		}
		this.path_valid = true;
	}
	,toString: function() {
		this.calculatePath();
		var txt = "";
		var _g1 = 0;
		var _g = this.index;
		while(_g1 < _g) {
			var i = _g1++;
			if(this.path.get(0,i) == -1) txt += "*"; else txt += this.path.get(0,i);
			if(this.K >= 10) txt += " ";
		}
		txt += " costs " + this.getCost();
		return txt;
	}
	,length: function() {
		if(this.index > 0) this.calculatePath();
		return this.index;
	}
	,get: function(i) {
		this.calculatePath();
		return this.path.get(0,i);
	}
	,getCost: function() {
		this.calculatePath();
		return this.best_cost;
	}
	,__class__: coopy.Viterbi
};
var haxe = {};
haxe.IMap = function() { };
haxe.IMap.__name__ = true;
haxe.IMap.prototype = {
	__class__: haxe.IMap
};
haxe.Json = function() { };
haxe.Json.__name__ = true;
haxe.Json.stringify = function(value,replacer,space) {
	return haxe.format.JsonPrinter.print(value,replacer,space);
};
haxe.ds = {};
haxe.ds.IntMap = function() {
	this.h = { };
};
haxe.ds.IntMap.__name__ = true;
haxe.ds.IntMap.__interfaces__ = [haxe.IMap];
haxe.ds.IntMap.prototype = {
	set: function(key,value) {
		this.h[key] = value;
	}
	,get: function(key) {
		return this.h[key];
	}
	,exists: function(key) {
		return this.h.hasOwnProperty(key);
	}
	,remove: function(key) {
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key | 0);
		}
		return HxOverrides.iter(a);
	}
	,toString: function() {
		var s = new StringBuf();
		s.b += "{";
		var it = this.keys();
		while( it.hasNext() ) {
			var i = it.next();
			if(i == null) s.b += "null"; else s.b += "" + i;
			s.b += " => ";
			s.add(Std.string(this.get(i)));
			if(it.hasNext()) s.b += ", ";
		}
		s.b += "}";
		return s.b;
	}
	,__class__: haxe.ds.IntMap
};
haxe.ds.StringMap = function() {
	this.h = { };
};
haxe.ds.StringMap.__name__ = true;
haxe.ds.StringMap.__interfaces__ = [haxe.IMap];
haxe.ds.StringMap.prototype = {
	set: function(key,value) {
		this.h["$" + key] = value;
	}
	,get: function(key) {
		return this.h["$" + key];
	}
	,exists: function(key) {
		return this.h.hasOwnProperty("$" + key);
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key.substr(1));
		}
		return HxOverrides.iter(a);
	}
	,iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref["$" + i];
		}};
	}
	,__class__: haxe.ds.StringMap
};
haxe.format = {};
haxe.format.JsonParser = function(str) {
	this.str = str;
	this.pos = 0;
};
haxe.format.JsonParser.__name__ = true;
haxe.format.JsonParser.prototype = {
	parseRec: function() {
		while(true) {
			var c = StringTools.fastCodeAt(this.str,this.pos++);
			switch(c) {
			case 32:case 13:case 10:case 9:
				break;
			case 123:
				var obj = { };
				var field = null;
				var comma = null;
				while(true) {
					var c1 = StringTools.fastCodeAt(this.str,this.pos++);
					switch(c1) {
					case 32:case 13:case 10:case 9:
						break;
					case 125:
						if(field != null || comma == false) this.invalidChar();
						return obj;
					case 58:
						if(field == null) this.invalidChar();
						Reflect.setField(obj,field,this.parseRec());
						field = null;
						comma = true;
						break;
					case 44:
						if(comma) comma = false; else this.invalidChar();
						break;
					case 34:
						if(comma) this.invalidChar();
						field = this.parseString();
						break;
					default:
						this.invalidChar();
					}
				}
				break;
			case 91:
				var arr = [];
				var comma1 = null;
				while(true) {
					var c2 = StringTools.fastCodeAt(this.str,this.pos++);
					switch(c2) {
					case 32:case 13:case 10:case 9:
						break;
					case 93:
						if(comma1 == false) this.invalidChar();
						return arr;
					case 44:
						if(comma1) comma1 = false; else this.invalidChar();
						break;
					default:
						if(comma1) this.invalidChar();
						this.pos--;
						arr.push(this.parseRec());
						comma1 = true;
					}
				}
				break;
			case 116:
				var save = this.pos;
				if(StringTools.fastCodeAt(this.str,this.pos++) != 114 || StringTools.fastCodeAt(this.str,this.pos++) != 117 || StringTools.fastCodeAt(this.str,this.pos++) != 101) {
					this.pos = save;
					this.invalidChar();
				}
				return true;
			case 102:
				var save1 = this.pos;
				if(StringTools.fastCodeAt(this.str,this.pos++) != 97 || StringTools.fastCodeAt(this.str,this.pos++) != 108 || StringTools.fastCodeAt(this.str,this.pos++) != 115 || StringTools.fastCodeAt(this.str,this.pos++) != 101) {
					this.pos = save1;
					this.invalidChar();
				}
				return false;
			case 110:
				var save2 = this.pos;
				if(StringTools.fastCodeAt(this.str,this.pos++) != 117 || StringTools.fastCodeAt(this.str,this.pos++) != 108 || StringTools.fastCodeAt(this.str,this.pos++) != 108) {
					this.pos = save2;
					this.invalidChar();
				}
				return null;
			case 34:
				return this.parseString();
			case 48:case 49:case 50:case 51:case 52:case 53:case 54:case 55:case 56:case 57:case 45:
				return this.parseNumber(c);
			default:
				this.invalidChar();
			}
		}
	}
	,parseString: function() {
		var start = this.pos;
		var buf_b = "";
		while(true) {
			var c = StringTools.fastCodeAt(this.str,this.pos++);
			if(c == 34) break;
			if(c == 92) {
				buf_b += HxOverrides.substr(this.str,start,this.pos - start - 1);
				c = StringTools.fastCodeAt(this.str,this.pos++);
				switch(c) {
				case 114:
					buf_b += "\r";
					break;
				case 110:
					buf_b += "\n";
					break;
				case 116:
					buf_b += "\t";
					break;
				case 98:
					buf_b += "\x08";
					break;
				case 102:
					buf_b += "\x0C";
					break;
				case 47:case 92:case 34:
					buf_b += String.fromCharCode(c);
					break;
				case 117:
					var uc = Std.parseInt("0x" + HxOverrides.substr(this.str,this.pos,4));
					this.pos += 4;
					buf_b += String.fromCharCode(uc);
					break;
				default:
					throw "Invalid escape sequence \\" + String.fromCharCode(c) + " at position " + (this.pos - 1);
				}
				start = this.pos;
			} else if(c != c) throw "Unclosed string";
		}
		buf_b += HxOverrides.substr(this.str,start,this.pos - start - 1);
		return buf_b;
	}
	,parseNumber: function(c) {
		var start = this.pos - 1;
		var minus = c == 45;
		var digit = !minus;
		var zero = c == 48;
		var point = false;
		var e = false;
		var pm = false;
		var end = false;
		while(true) {
			c = StringTools.fastCodeAt(this.str,this.pos++);
			switch(c) {
			case 48:
				if(zero && !point) this.invalidNumber(start);
				if(minus) {
					minus = false;
					zero = true;
				}
				digit = true;
				break;
			case 49:case 50:case 51:case 52:case 53:case 54:case 55:case 56:case 57:
				if(zero && !point) this.invalidNumber(start);
				if(minus) minus = false;
				digit = true;
				zero = false;
				break;
			case 46:
				if(minus || point) this.invalidNumber(start);
				digit = false;
				point = true;
				break;
			case 101:case 69:
				if(minus || zero || e) this.invalidNumber(start);
				digit = false;
				e = true;
				break;
			case 43:case 45:
				if(!e || pm) this.invalidNumber(start);
				digit = false;
				pm = true;
				break;
			default:
				if(!digit) this.invalidNumber(start);
				this.pos--;
				end = true;
			}
			if(end) break;
		}
		var f = Std.parseFloat(HxOverrides.substr(this.str,start,this.pos - start));
		var i = f | 0;
		if(i == f) return i; else return f;
	}
	,invalidChar: function() {
		this.pos--;
		throw "Invalid char " + this.str.charCodeAt(this.pos) + " at position " + this.pos;
	}
	,invalidNumber: function(start) {
		throw "Invalid number at position " + start + ": " + HxOverrides.substr(this.str,start,this.pos - start);
	}
	,__class__: haxe.format.JsonParser
};
haxe.format.JsonPrinter = function(replacer,space) {
	this.replacer = replacer;
	this.indent = space;
	this.pretty = space != null;
	this.nind = 0;
	this.buf = new StringBuf();
};
haxe.format.JsonPrinter.__name__ = true;
haxe.format.JsonPrinter.print = function(o,replacer,space) {
	var printer = new haxe.format.JsonPrinter(replacer,space);
	printer.write("",o);
	return printer.buf.b;
};
haxe.format.JsonPrinter.prototype = {
	ipad: function() {
		if(this.pretty) {
			var v = StringTools.lpad("",this.indent,this.nind * this.indent.length);
			if(v == null) this.buf.b += "null"; else this.buf.b += "" + v;
		}
	}
	,write: function(k,v) {
		if(this.replacer != null) v = this.replacer(k,v);
		{
			var _g = Type["typeof"](v);
			switch(_g[1]) {
			case 8:
				this.buf.b += "\"???\"";
				break;
			case 4:
				this.fieldsString(v,Reflect.fields(v));
				break;
			case 1:
				var v1 = v;
				if(v1 == null) this.buf.b += "null"; else this.buf.b += "" + v1;
				break;
			case 2:
				var v2;
				if((function($this) {
					var $r;
					var f = v;
					$r = isFinite(f);
					return $r;
				}(this))) v2 = v; else v2 = "null";
				if(v2 == null) this.buf.b += "null"; else this.buf.b += "" + v2;
				break;
			case 5:
				this.buf.b += "\"<fun>\"";
				break;
			case 6:
				var c = _g[2];
				if(c == String) this.quote(v); else if(c == Array) {
					var v3 = v;
					this.buf.b += "[";
					var len = v3.length;
					var last = len - 1;
					var _g1 = 0;
					while(_g1 < len) {
						var i = _g1++;
						if(i > 0) this.buf.b += ","; else this.nind++;
						if(this.pretty) this.buf.b += "\n";
						this.ipad();
						this.write(i,v3[i]);
						if(i == last) {
							this.nind--;
							if(this.pretty) this.buf.b += "\n";
							this.ipad();
						}
					}
					this.buf.b += "]";
				} else if(c == haxe.ds.StringMap) {
					var v4 = v;
					var o = { };
					var $it0 = v4.keys();
					while( $it0.hasNext() ) {
						var k1 = $it0.next();
						Reflect.setField(o,k1,v4.get(k1));
					}
					this.fieldsString(o,Reflect.fields(o));
				} else if(c == Date) {
					var v5 = v;
					this.quote(HxOverrides.dateStr(v5));
				} else this.fieldsString(v,Reflect.fields(v));
				break;
			case 7:
				var i1 = Type.enumIndex(v);
				var v6 = i1;
				if(v6 == null) this.buf.b += "null"; else this.buf.b += "" + v6;
				break;
			case 3:
				var v7 = v;
				if(v7 == null) this.buf.b += "null"; else this.buf.b += "" + v7;
				break;
			case 0:
				this.buf.b += "null";
				break;
			}
		}
	}
	,fieldsString: function(v,fields) {
		this.buf.b += "{";
		var len = fields.length;
		var last = len - 1;
		var first = true;
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			var f = fields[i];
			var value = Reflect.field(v,f);
			if(Reflect.isFunction(value)) continue;
			if(first) {
				this.nind++;
				first = false;
			} else this.buf.b += ",";
			if(this.pretty) this.buf.b += "\n";
			this.ipad();
			this.quote(f);
			this.buf.b += ":";
			if(this.pretty) this.buf.b += " ";
			this.write(f,value);
			if(i == last) {
				this.nind--;
				if(this.pretty) this.buf.b += "\n";
				this.ipad();
			}
		}
		this.buf.b += "}";
	}
	,quote: function(s) {
		this.buf.b += "\"";
		var i = 0;
		while(true) {
			var c = StringTools.fastCodeAt(s,i++);
			if(c != c) break;
			switch(c) {
			case 34:
				this.buf.b += "\\\"";
				break;
			case 92:
				this.buf.b += "\\\\";
				break;
			case 10:
				this.buf.b += "\\n";
				break;
			case 13:
				this.buf.b += "\\r";
				break;
			case 9:
				this.buf.b += "\\t";
				break;
			case 8:
				this.buf.b += "\\b";
				break;
			case 12:
				this.buf.b += "\\f";
				break;
			default:
				this.buf.b += String.fromCharCode(c);
			}
		}
		this.buf.b += "\"";
	}
	,__class__: haxe.format.JsonPrinter
};
var js = {};
js.Boot = function() { };
js.Boot.__name__ = true;
js.Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else {
		var cl = o.__class__;
		if(cl != null) return cl;
		var name = js.Boot.__nativeClassName(o);
		if(name != null) return js.Boot.__resolveNativeClass(name);
		return null;
	}
};
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str2 = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i1 = _g1++;
					if(i1 != 2) str2 += "," + js.Boot.__string_rec(o[i1],s); else str2 += js.Boot.__string_rec(o[i1],s);
				}
				return str2 + ")";
			}
			var l = o.length;
			var i;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js.Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
};
js.Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Array:
		return (o instanceof Array) && o.__enum__ == null;
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) return true;
				if(js.Boot.__interfLoop(js.Boot.getClass(o),cl)) return true;
			} else if(typeof(cl) == "object" && js.Boot.__isNativeObj(cl)) {
				if(o instanceof cl) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
js.Boot.__nativeClassName = function(o) {
	var name = js.Boot.__toStr.call(o).slice(8,-1);
	if(name == "Object" || name == "Function" || name == "Math" || name == "JSON") return null;
	return name;
};
js.Boot.__isNativeObj = function(o) {
	return js.Boot.__nativeClassName(o) != null;
};
js.Boot.__resolveNativeClass = function(name) {
	if(typeof window != "undefined") return window[name]; else return global[name];
};
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; }
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
String.prototype.__class__ = String;
String.__name__ = true;
Array.__name__ = true;
Date.prototype.__class__ = Date;
Date.__name__ = ["Date"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
coopy.Coopy.VERSION = "1.2.3";
js.Boot.__toStr = {}.toString;
coopy.Coopy.main();
})(typeof window != "undefined" ? window : exports);


if (typeof exports != "undefined") {
    // avoid having excess nesting (coopy.coopy) when using node
    for (f in exports.coopy) { 
	if (exports.coopy.hasOwnProperty(f)) {
	    exports[f] = exports.coopy[f]; 
	}
    } 
    // promote methods of coopy.Coopy
    for (f in exports.Coopy) { 
	if (exports.Coopy.hasOwnProperty(f)) {
	    exports[f] = exports.Coopy[f]; 
	}
    } 
} else {
    // promote methods of coopy.Coopy
    for (f in coopy.Coopy) { 
	if (coopy.Coopy.hasOwnProperty(f)) {
	    coopy[f] = coopy.Coopy[f]; 
	}
    } 
    daff = coopy;
}
(function() {

var coopy = null;
if (typeof exports != "undefined") {
    if (typeof exports.Coopy != "undefined") {
	coopy = exports;
    }
}
if (coopy == null) {
    coopy = window.daff;
}

var CellView = function() {
}

CellView.prototype.toString = function(d) {
    return ""+d;
}

CellView.prototype.equals = function(d1,d2) {
    return d1==d2;
}

CellView.prototype.toDatum = function(d) {
    return d;
}

CellView.prototype.makeHash = function() {
    return {};
}

CellView.prototype.hashSet = function(d,k,v) {
    d[k] = v;
}

CellView.prototype.hashGet = function(d,k) {
    return d[k];
}

CellView.prototype.hashExists = function(d,k) {
    return k in d;
}

CellView.prototype.isHash = function(d) {
    return d && (typeof d  === "object");
}

var TableView = function(data) {
    // variant constructor (cols, rows)
    if (arguments.length==2) {
	var lst = [];
	for (var i=0; i<arguments[1]; i++) {
	    var row = [];
	    for (var j=0; j<arguments[0]; j++) {
		row.push(null);
	    }
	    lst.push(row);
	}
	data = lst;
    }
    this.data = data;
    this.height = data.length;
    this.width = 0;
    if (this.height>0) {
	this.width = data[0].length;
    }
}

TableView.prototype.get_width = function() {
    return this.width;
}

TableView.prototype.get_height = function() {
    return this.height;
}

TableView.prototype.getCell = function(x,y) {
    return this.data[y][x];
}

TableView.prototype.setCell = function(x,y,c) {
    this.data[y][x] = c;
}

TableView.prototype.toString = function() {
    return coopy.SimpleTable.tableToString(this);
}

TableView.prototype.getCellView = function() {
    return new CellView();
    //return new coopy.SimpleView();
}

TableView.prototype.isResizable = function() {
    return true;
}

TableView.prototype.resize = function(w,h) {
    this.width = w;
    this.height = h;
    for (var i=0; i<this.data.length; i++) {
	var row = this.data[i];
	if (row==null) {
	    row = this.data[i] = [];
	}
	while (row.length<this.width) {
	    row.push(null);
	}
    }
    if (this.data.length<this.height) {
	while (this.data.length<this.height) {
	    var row = [];
	    for (var i=0; i<this.width; i++) {
		row.push(null);
	    }
	    this.data.push(row);
	}
    }
    return true;
}

TableView.prototype.clear = function() {
    for (var i=0; i<this.data.length; i++) {
	var row = this.data[i];
	for (var j=0; j<row.length; j++) {
	    row[j] = null;
	}
    }
}

TableView.prototype.trim = function() {
    var changed = this.trimRows();
    changed = changed || this.trimColumns();
    return changed;
}

TableView.prototype.trimRows = function() {
    var changed = false;
    while (true) {
	if (this.height==0) return changed;
	var row = this.data[this.height-1];
	for (var i=0; i<this.width; i++) {
	    var c = row[i];
	    if (c!=null && c!="") return changed;
	}
	this.height--;
    }
}

TableView.prototype.trimColumns = function() {
    var top_content = 0;
    for (var i=0; i<this.height; i++) {
	if (top_content>=this.width) break;
	var row = this.data[i];
	for (var j=0; j<this.width; j++) {
	    var c = row[j];
	    if (c!=null && c!="") {
		if (j>top_content) {
		    top_content = j;
		}
	    }
	}
    }
    if (this.height==0 || top_content+1==this.width) return false;
    this.width = top_content+1;
    return true;
}

TableView.prototype.getData = function() {
    return this.data;
}

TableView.prototype.clone = function() {
    var ndata = [];
    for (var i=0; i<this.get_height(); i++) {
	ndata[i] = this.data[i].slice();
    }
    return new TableView(ndata);
}

TableView.prototype.insertOrDeleteRows = function(fate, hfate) {
    var ndata = [];
    for (var i=0; i<fate.length; i++) {
        var j = fate[i];
        if (j!=-1) {
	    ndata[j] = this.data[i];
        }
    }
    // let's preserve data
    //this.data = ndata;
    this.data.length = 0;
    for (var i=0; i<ndata.length; i++) {
	this.data[i] = ndata[i];
    }
    this.resize(this.width,hfate);
    return true;
}

TableView.prototype.insertOrDeleteColumns = function(fate, wfate) {
    if (wfate==this.width && wfate==fate.length) {
	var eq = true;
	for (var i=0; i<wfate; i++) {
	    if (fate[i]!=i) {
		eq = false;
		break;
	    }
	}
	if (eq) return true;
    }
    for (var i=0; i<this.height; i++) {
	var row = this.data[i];
	var nrow = [];
	for (var j=0; j<this.width; j++) {
	    if (fate[j]==-1) continue;
	    nrow[fate[j]] = row[j];
	}
	while (nrow.length<wfate) {
	    nrow.push(null);
	}
	this.data[i] = nrow;
    }
    this.width = wfate;
    return true;
}

TableView.prototype.isSimilar = function(alt) {
    if (alt.get_width()!=this.get_width()) return false;
    if (alt.get_height()!=this.get_height()) return false;
    for (var c=0; c<this.width; c++) {
	for (var r=0; r<this.height; r++) {
	    var v1 = "" + this.getCell(c,r);
	    var v2 = "" + alt.getCell(c,r); 
	    if (v1!=v2) {
		console.log("MISMATCH "+ v1 + " " + v2);
		return false;
	    }
	}
    }
    return true;
}

if (typeof exports != "undefined") {
    exports.TableView = TableView;
} else {
    if (typeof window["daff"] == "undefined") window["daff"] = {};
    window.daff.TableView = TableView;
}

})();
if (typeof exports != "undefined") {
    (function() {
	var daff = exports;

	SqliteDatabase = function(db,Fiber) {
	    this.db = db;
	    this.row = null;
	    this.active = false;
	    this.index2name = {};
	    this.Fiber = Fiber;
	}
	
	SqliteDatabase.prototype.getQuotedColumnName = function (name) {
	    return name;
	}
	
	SqliteDatabase.prototype.getQuotedTableName = function (name) {
	    return name;
	}
	
	SqliteDatabase.prototype.getColumns = function(name) {
	    var fiber = this.Fiber.current;
	    var qname = this.getQuotedColumnName(name);
	    var self = this;
	    this.db.all("pragma table_info("+qname+")", function(err,rows) {
		var lst = [];
		for (var i in rows) {
		    var x = rows[i];
		    lst.push(new daff.SqlColumn.byNameAndPrimaryKey(x['name'],x['pk']>0));
		    self.index2name[i] = x['name'];
		}
		fiber.run(lst);
	    });
	    return this.Fiber.yield();
	}
	
	SqliteDatabase.prototype.exec = function(query,args) {
	    var fiber = this.Fiber.current;
	    if (args==null) {
		this.db.run(query,function(err) {
		    if (err) console.log(err);
		    fiber.run(err==null);
		});
		return this.Fiber.yield();
	    }
	    var statement = this.db.run(query,args,function(err) {
		if (err) console.log(err);
		fiber.run(err==null);
	    });
	    return this.Fiber.yield();
	}
	
	SqliteDatabase.prototype.beginRow = function(tab,row,order) {
	    return this.begin("SELECT * FROM " + this.getQuotedColumnName(tab) + " WHERE rowid = ?",
			      [row],
			      order);
	}
	
	SqliteDatabase.prototype.begin = function(query,args,order) {
	    if (order!=null) {
		this.index2name = {};
		var len = order.length;
		for (var i=0; i<len; i++) {
		    this.index2name[i] = order[i];
		}
	    }
	    var fiber = this.Fiber.current;
	    this.active = true;
	    var self = this;
	    this.db.each(query,(args==null)?[]:args,function(err,row) {
		if (err) { 
		    console.log(err);
		    fiber.run([false,0]);
		} else {
		    fiber.run([true,row]);
		}
	    },function(err,n) {
		fiber.run([false,n]);
	    });
	    return true;
	}

	SqliteDatabase.prototype.read = function() {
	    if (!this.active) return false;
	    var v = this.Fiber.yield();
	    if (v[0]) {
		this.row = v[1];
		return true;
	    }
	    this.row = null;
	    this.active = false;
	    return false;
	}

	SqliteDatabase.prototype.get = function(index) {
	    return this.row[this.index2name[index]];
	}

	SqliteDatabase.prototype.end = function() {
	    while (this.active) {
		this.read();
	    }
	}

	SqliteDatabase.prototype.rowid = function() {
	    return "rowid";
	}

	exports.SqliteDatabase = SqliteDatabase;

    })();
}
if (typeof exports != "undefined") {
    
    var tio = {};
    var tio_args = [];

    var coopy = exports;
    var fs = require('fs');
    var exec = require('child_process').exec;
    var readline = null;
    var Fiber = null;
    var sqlite3 = null;
    
    tio.getContent = function(name) {
	if (name=="-") {
	    // only works on Linux, all other solutions seem broken
	    return fs.readFileSync('/dev/stdin',"utf8");
	}
	return fs.readFileSync(name,"utf8");
    }
    
    tio.saveContent = function(name,txt) {
	return fs.writeFileSync(name,txt,"utf8");
    }
    
    tio.args = function() {
	return tio_args;
    }
    
    tio.writeStdout = function(txt) {
	process.stdout.write(txt);
    }
    
    tio.writeStderr = function(txt) {
	process.stderr.write(txt);
    }
    
    tio.async = function() {
	return true;
    }

    tio.exists = function(path) {
	return fs.existsSync(path);
    }

    tio.openSqliteDatabase = function(path) {
	if (Fiber) {
	    return new SqliteDatabase(new sqlite3.Database(path),Fiber);
	}
	throw("run inside Fiber plz");
	return null;
    }

    var cmd_result = 1;
    var cmd_pending = null;

    tio.command = function(cmd,args) {
	// we promise not to use any arguments with quotes in them
	for (var i=0; i<args.length; i++) {
	    var argi = args[i];
	    if (argi.indexOf(" ")>=0) {
		argi = "\"" + argi + "\"";
	    }
	    cmd += " " + argi;
	}
	var cmd = cmd; + " " + args.join(" ");
	if (cmd == cmd_pending) {
	    cmd_pending = null;
	    return cmd_result;
	} else if (cmd_pending!=null) {
	    return 998; // "hack not working correctly"
	}
	cmd_pending = cmd;
	return 999; // "cannot be executed synchronously"
    }

    function run_daff_base(main,args) {
	tio_args = args.slice();
	var code = main.coopyhx(tio);
	if (code==999) {
	    if (cmd_pending!=null) {
		exec(cmd_pending,function(error,stdout,stderr) {
		    cmd_result = 0;
		    if (error!=null) {
			cmd_result = error.code;
		    }
		    return run_daff_base(main,args);
		});
	    }
	} else {
	    return code;
	}
    }
    
    exports.run_daff_main = function() {
	var main = new exports.Coopy();
	var code = run_daff_base(main,process.argv.slice(2));
	process.exit(code);
    }

    exports.cmd = function(args) {
	var main = new exports.Coopy();
	var code = run_daff_base(main,args);
	return code;
    }
}

if (typeof require != "undefined") {
    if (require.main === module) {
	try {
	    exports.run_daff_main();
	} catch (e) {
	    if (e == "run inside Fiber plz") {
		try {
		    Fiber = require('fibers');
		    sqlite3 = require('sqlite3');
		} catch (err) {
		    // We don't have what we need for accessing the sqlite database.
		    console.log("No sqlite3/fibers");
		}
		Fiber(function() {
		    exports.run_daff_main();
		    console.log("ok");
		}).run();
	    }
	}
    }
}
