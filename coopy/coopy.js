var $estr = function() { return js.Boot.__string_rec(this,''); };
var Hash = function() {
	this.h = { };
};
Hash.__name__ = true;
Hash.prototype = {
	toString: function() {
		var s = new StringBuf();
		s.b += Std.string("{");
		var it = this.keys();
		while( it.hasNext() ) {
			var i = it.next();
			s.b += Std.string(i);
			s.b += Std.string(" => ");
			s.b += Std.string(Std.string(this.get(i)));
			if(it.hasNext()) s.b += Std.string(", ");
		}
		s.b += Std.string("}");
		return s.b;
	}
	,iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref["$" + i];
		}};
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key.substr(1));
		}
		return HxOverrides.iter(a);
	}
	,remove: function(key) {
		key = "$" + key;
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,exists: function(key) {
		return this.h.hasOwnProperty("$" + key);
	}
	,get: function(key) {
		return this.h["$" + key];
	}
	,set: function(key,value) {
		this.h["$" + key] = value;
	}
	,__class__: Hash
}
var HxOverrides = function() { }
HxOverrides.__name__ = true;
HxOverrides.dateStr = function(date) {
	var m = date.getMonth() + 1;
	var d = date.getDate();
	var h = date.getHours();
	var mi = date.getMinutes();
	var s = date.getSeconds();
	return date.getFullYear() + "-" + (m < 10?"0" + m:"" + m) + "-" + (d < 10?"0" + d:"" + d) + " " + (h < 10?"0" + h:"" + h) + ":" + (mi < 10?"0" + mi:"" + mi) + ":" + (s < 10?"0" + s:"" + s);
}
HxOverrides.strDate = function(s) {
	switch(s.length) {
	case 8:
		var k = s.split(":");
		var d = new Date();
		d.setTime(0);
		d.setUTCHours(k[0]);
		d.setUTCMinutes(k[1]);
		d.setUTCSeconds(k[2]);
		return d;
	case 10:
		var k = s.split("-");
		return new Date(k[0],k[1] - 1,k[2],0,0,0);
	case 19:
		var k = s.split(" ");
		var y = k[0].split("-");
		var t = k[1].split(":");
		return new Date(y[0],y[1] - 1,y[2],t[0],t[1],t[2]);
	default:
		throw "Invalid date format : " + s;
	}
}
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
}
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
}
HxOverrides.remove = function(a,obj) {
	var i = 0;
	var l = a.length;
	while(i < l) {
		if(a[i] == obj) {
			a.splice(i,1);
			return true;
		}
		i++;
	}
	return false;
}
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
}
var IntHash = function() {
	this.h = { };
};
IntHash.__name__ = true;
IntHash.prototype = {
	toString: function() {
		var s = new StringBuf();
		s.b += Std.string("{");
		var it = this.keys();
		while( it.hasNext() ) {
			var i = it.next();
			s.b += Std.string(i);
			s.b += Std.string(" => ");
			s.b += Std.string(Std.string(this.get(i)));
			if(it.hasNext()) s.b += Std.string(", ");
		}
		s.b += Std.string("}");
		return s.b;
	}
	,iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref[i];
		}};
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key | 0);
		}
		return HxOverrides.iter(a);
	}
	,remove: function(key) {
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,exists: function(key) {
		return this.h.hasOwnProperty(key);
	}
	,get: function(key) {
		return this.h[key];
	}
	,set: function(key,value) {
		this.h[key] = value;
	}
	,__class__: IntHash
}
var IntIter = function(min,max) {
	this.min = min;
	this.max = max;
};
IntIter.__name__ = true;
IntIter.prototype = {
	next: function() {
		return this.min++;
	}
	,hasNext: function() {
		return this.min < this.max;
	}
	,__class__: IntIter
}
var Lambda = function() { }
Lambda.__name__ = true;
Lambda.array = function(it) {
	var a = new Array();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var i = $it0.next();
		a.push(i);
	}
	return a;
}
Lambda.list = function(it) {
	var l = new List();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var i = $it0.next();
		l.add(i);
	}
	return l;
}
Lambda.map = function(it,f) {
	var l = new List();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		l.add(f(x));
	}
	return l;
}
Lambda.mapi = function(it,f) {
	var l = new List();
	var i = 0;
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		l.add(f(i++,x));
	}
	return l;
}
Lambda.has = function(it,elt,cmp) {
	if(cmp == null) {
		var $it0 = $iterator(it)();
		while( $it0.hasNext() ) {
			var x = $it0.next();
			if(x == elt) return true;
		}
	} else {
		var $it1 = $iterator(it)();
		while( $it1.hasNext() ) {
			var x = $it1.next();
			if(cmp(x,elt)) return true;
		}
	}
	return false;
}
Lambda.exists = function(it,f) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(f(x)) return true;
	}
	return false;
}
Lambda.foreach = function(it,f) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(!f(x)) return false;
	}
	return true;
}
Lambda.iter = function(it,f) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		f(x);
	}
}
Lambda.filter = function(it,f) {
	var l = new List();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(f(x)) l.add(x);
	}
	return l;
}
Lambda.fold = function(it,f,first) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		first = f(x,first);
	}
	return first;
}
Lambda.count = function(it,pred) {
	var n = 0;
	if(pred == null) {
		var $it0 = $iterator(it)();
		while( $it0.hasNext() ) {
			var _ = $it0.next();
			n++;
		}
	} else {
		var $it1 = $iterator(it)();
		while( $it1.hasNext() ) {
			var x = $it1.next();
			if(pred(x)) n++;
		}
	}
	return n;
}
Lambda.empty = function(it) {
	return !$iterator(it)().hasNext();
}
Lambda.indexOf = function(it,v) {
	var i = 0;
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var v2 = $it0.next();
		if(v == v2) return i;
		i++;
	}
	return -1;
}
Lambda.concat = function(a,b) {
	var l = new List();
	var $it0 = $iterator(a)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		l.add(x);
	}
	var $it1 = $iterator(b)();
	while( $it1.hasNext() ) {
		var x = $it1.next();
		l.add(x);
	}
	return l;
}
var List = function() {
	this.length = 0;
};
List.__name__ = true;
List.prototype = {
	map: function(f) {
		var b = new List();
		var l = this.h;
		while(l != null) {
			var v = l[0];
			l = l[1];
			b.add(f(v));
		}
		return b;
	}
	,filter: function(f) {
		var l2 = new List();
		var l = this.h;
		while(l != null) {
			var v = l[0];
			l = l[1];
			if(f(v)) l2.add(v);
		}
		return l2;
	}
	,join: function(sep) {
		var s = new StringBuf();
		var first = true;
		var l = this.h;
		while(l != null) {
			if(first) first = false; else s.b += Std.string(sep);
			s.b += Std.string(l[0]);
			l = l[1];
		}
		return s.b;
	}
	,toString: function() {
		var s = new StringBuf();
		var first = true;
		var l = this.h;
		s.b += Std.string("{");
		while(l != null) {
			if(first) first = false; else s.b += Std.string(", ");
			s.b += Std.string(Std.string(l[0]));
			l = l[1];
		}
		s.b += Std.string("}");
		return s.b;
	}
	,iterator: function() {
		return { h : this.h, hasNext : function() {
			return this.h != null;
		}, next : function() {
			if(this.h == null) return null;
			var x = this.h[0];
			this.h = this.h[1];
			return x;
		}};
	}
	,remove: function(v) {
		var prev = null;
		var l = this.h;
		while(l != null) {
			if(l[0] == v) {
				if(prev == null) this.h = l[1]; else prev[1] = l[1];
				if(this.q == l) this.q = prev;
				this.length--;
				return true;
			}
			prev = l;
			l = l[1];
		}
		return false;
	}
	,clear: function() {
		this.h = null;
		this.q = null;
		this.length = 0;
	}
	,isEmpty: function() {
		return this.h == null;
	}
	,pop: function() {
		if(this.h == null) return null;
		var x = this.h[0];
		this.h = this.h[1];
		if(this.h == null) this.q = null;
		this.length--;
		return x;
	}
	,last: function() {
		return this.q == null?null:this.q[0];
	}
	,first: function() {
		return this.h == null?null:this.h[0];
	}
	,push: function(item) {
		var x = [item,this.h];
		this.h = x;
		if(this.q == null) this.q = x;
		this.length++;
	}
	,add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
	,__class__: List
}
var Std = function() { }
Std.__name__ = true;
Std["is"] = function(v,t) {
	return js.Boot.__instanceof(v,t);
}
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
}
Std["int"] = function(x) {
	return x | 0;
}
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
}
Std.parseFloat = function(x) {
	return parseFloat(x);
}
Std.random = function(x) {
	return x <= 0?0:Math.floor(Math.random() * x);
}
var StringBuf = function() {
	this.b = "";
};
StringBuf.__name__ = true;
StringBuf.prototype = {
	toString: function() {
		return this.b;
	}
	,addSub: function(s,pos,len) {
		this.b += HxOverrides.substr(s,pos,len);
	}
	,addChar: function(c) {
		this.b += String.fromCharCode(c);
	}
	,add: function(x) {
		this.b += Std.string(x);
	}
	,__class__: StringBuf
}
var coopy = coopy || {}
coopy.Alignment = function() {
	this.map_a2b = new IntHash();
	this.map_b2a = new IntHash();
	this.ha = this.hb = 0;
	this.map_count = 0;
	this.reference = null;
	this.meta = null;
	this.order_cache_has_reference = false;
};
coopy.Alignment.__name__ = true;
coopy.Alignment.prototype = {
	toOrder2: function() {
		var order = new coopy.Ordering();
		var xa = 0;
		var xas = this.ha;
		var xb = 0;
		var va = new IntHash();
		var _g1 = 0, _g = this.ha;
		while(_g1 < _g) {
			var i = _g1++;
			va.set(i,i);
		}
		while(va.keys().hasNext() || xb < this.hb) {
			if(xa >= this.ha) xa = 0;
			if(xa < this.ha && this.a2b(xa) == null) {
				if(va.exists(xa)) {
					order.add(xa,-1);
					va.remove(xa);
					xas--;
				}
				xa++;
				continue;
			}
			if(xb < this.hb) {
				var alt = this.b2a(xb);
				if(alt != null) {
					order.add(alt,xb);
					if(va.exists(alt)) {
						va.remove(alt);
						xas--;
					}
					xa = alt + 1;
				} else order.add(-1,xb);
				xb++;
				continue;
			}
			console.log("Oops, alignment problem");
			break;
		}
		return order;
	}
	,toOrder3: function() {
		var ref = this.reference;
		if(ref == null) {
			ref = new coopy.Alignment();
			ref.range(this.ha,this.ha);
			ref.tables(this.ta,this.ta);
			var _g1 = 0, _g = this.ha;
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
		var vp = new IntHash();
		var vl = new IntHash();
		var vr = new IntHash();
		var _g = 0;
		while(_g < hp) {
			var i = _g++;
			vp.set(i,i);
		}
		var _g = 0;
		while(_g < hl) {
			var i = _g++;
			vl.set(i,i);
		}
		var _g = 0;
		while(_g < hr) {
			var i = _g++;
			vr.set(i,i);
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
				if(zl == prev + 1) {
					if(vr.exists(xr)) {
						order.add(ref.a2b(zr),xr,zr);
						prev = zr;
						vp.remove(zr);
						ct_vp--;
						vl.remove(ref.a2b(zr));
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
						vr.remove(this.a2b(zl));
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
	,getTarget: function() {
		return this.tb;
	}
	,getSource: function() {
		return this.ta;
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
	,toString: function() {
		return "" + Std.string(this.map_a2b);
	}
	,count: function() {
		return this.map_count;
	}
	,b2a: function(b) {
		return this.map_b2a.get(b);
	}
	,a2b: function(a) {
		return this.map_a2b.get(a);
	}
	,link: function(a,b) {
		this.map_a2b.set(a,b);
		this.map_b2a.set(b,a);
		this.map_count++;
	}
	,setRowlike: function(flag) {
	}
	,tables: function(ta,tb) {
		this.ta = ta;
		this.tb = tb;
	}
	,range: function(ha,hb) {
		this.ha = ha;
		this.hb = hb;
	}
	,__class__: coopy.Alignment
}
coopy.Datum = function() { }
coopy.Datum.__name__ = true;
coopy.Datum.prototype = {
	__class__: coopy.Datum
}
coopy.Bag = function() { }
coopy.Bag.__name__ = true;
coopy.Bag.__interfaces__ = [coopy.Datum];
coopy.Bag.prototype = {
	__class__: coopy.Bag
}
coopy.View = function() { }
coopy.View.__name__ = true;
coopy.View.prototype = {
	__class__: coopy.View
}
coopy.BagView = function() {
};
coopy.BagView.__name__ = true;
coopy.BagView.__interfaces__ = [coopy.View];
coopy.BagView.prototype = {
	toDatum: function(str) {
		return new coopy.SimpleCell(str);
	}
	,equals: function(d1,d2) {
		console.log("BagView.equals called");
		return false;
	}
	,hasStructure: function(d) {
		return true;
	}
	,getTable: function(d) {
		return null;
	}
	,getBag: function(d) {
		var bag = d;
		return bag;
	}
	,toString: function(d) {
		return "" + Std.string(d);
	}
	,__class__: coopy.BagView
}
coopy.Change = function(txt) {
	if(txt != null) {
		this.mode = coopy.ChangeType.NOTE_CHANGE;
		this.change = txt;
	} else this.mode = coopy.ChangeType.NO_CHANGE;
};
coopy.Change.__name__ = true;
coopy.Change.prototype = {
	toString: function() {
		return (function($this) {
			var $r;
			switch( ($this.mode)[1] ) {
			case 0:
				$r = "no change";
				break;
			case 2:
				$r = "local change: " + Std.string($this.remote) + " -> " + Std.string($this.local);
				break;
			case 1:
				$r = "remote change: " + Std.string($this.local) + " -> " + Std.string($this.remote);
				break;
			case 3:
				$r = "conflicting change: " + Std.string($this.parent) + " -> " + Std.string($this.local) + " / " + Std.string($this.remote);
				break;
			case 4:
				$r = "same change: " + Std.string($this.parent) + " -> " + Std.string($this.local) + " / " + Std.string($this.remote);
				break;
			case 5:
				$r = $this.change;
				break;
			}
			return $r;
		}(this));
	}
	,__class__: coopy.Change
}
coopy.ChangeType = { __ename__ : true, __constructs__ : ["NO_CHANGE","REMOTE_CHANGE","LOCAL_CHANGE","BOTH_CHANGE","SAME_CHANGE","NOTE_CHANGE"] }
coopy.ChangeType.NO_CHANGE = ["NO_CHANGE",0];
coopy.ChangeType.NO_CHANGE.toString = $estr;
coopy.ChangeType.NO_CHANGE.__enum__ = coopy.ChangeType;
coopy.ChangeType.REMOTE_CHANGE = ["REMOTE_CHANGE",1];
coopy.ChangeType.REMOTE_CHANGE.toString = $estr;
coopy.ChangeType.REMOTE_CHANGE.__enum__ = coopy.ChangeType;
coopy.ChangeType.LOCAL_CHANGE = ["LOCAL_CHANGE",2];
coopy.ChangeType.LOCAL_CHANGE.toString = $estr;
coopy.ChangeType.LOCAL_CHANGE.__enum__ = coopy.ChangeType;
coopy.ChangeType.BOTH_CHANGE = ["BOTH_CHANGE",3];
coopy.ChangeType.BOTH_CHANGE.toString = $estr;
coopy.ChangeType.BOTH_CHANGE.__enum__ = coopy.ChangeType;
coopy.ChangeType.SAME_CHANGE = ["SAME_CHANGE",4];
coopy.ChangeType.SAME_CHANGE.toString = $estr;
coopy.ChangeType.SAME_CHANGE.__enum__ = coopy.ChangeType;
coopy.ChangeType.NOTE_CHANGE = ["NOTE_CHANGE",5];
coopy.ChangeType.NOTE_CHANGE.toString = $estr;
coopy.ChangeType.NOTE_CHANGE.__enum__ = coopy.ChangeType;
coopy.Compare = function() {
};
coopy.Compare.__name__ = true;
coopy.Compare.prototype = {
	comparePrimitive: function(ws) {
		var sparent = ws.parent.toString();
		var slocal = ws.local.toString();
		var sremote = ws.remote.toString();
		var c = new coopy.Change();
		c.parent = ws.parent;
		c.local = ws.local;
		c.remote = ws.remote;
		if(sparent == slocal && sparent != sremote) c.mode = coopy.ChangeType.REMOTE_CHANGE; else if(sparent == sremote && sparent != slocal) c.mode = coopy.ChangeType.LOCAL_CHANGE; else if(slocal == sremote && sparent != slocal) c.mode = coopy.ChangeType.SAME_CHANGE; else if(sparent != slocal && sparent != sremote) c.mode = coopy.ChangeType.BOTH_CHANGE; else c.mode = coopy.ChangeType.NO_CHANGE;
		if(c.mode != coopy.ChangeType.NO_CHANGE) ws.report.changes.push(c);
		return true;
	}
	,compareTable: function(ws) {
		ws.p2l = new coopy.TableComparisonState();
		ws.p2r = new coopy.TableComparisonState();
		ws.p2l.a = ws.tparent;
		ws.p2l.b = ws.tlocal;
		ws.p2r.a = ws.tparent;
		ws.p2r.b = ws.tremote;
		var cmp = new coopy.CompareTable();
		cmp.attach(ws.p2l);
		cmp.attach(ws.p2r);
		var c = new coopy.Change();
		c.parent = ws.parent;
		c.local = ws.local;
		c.remote = ws.remote;
		if(ws.p2l.is_equal && !ws.p2r.is_equal) c.mode = coopy.ChangeType.REMOTE_CHANGE; else if(!ws.p2l.is_equal && ws.p2r.is_equal) c.mode = coopy.ChangeType.LOCAL_CHANGE; else if(!ws.p2l.is_equal && !ws.p2r.is_equal) {
			ws.l2r = new coopy.TableComparisonState();
			ws.l2r.a = ws.tlocal;
			ws.l2r.b = ws.tremote;
			cmp.attach(ws.l2r);
			if(ws.l2r.is_equal) c.mode = coopy.ChangeType.SAME_CHANGE; else c.mode = coopy.ChangeType.BOTH_CHANGE;
		} else c.mode = coopy.ChangeType.NO_CHANGE;
		if(c.mode != coopy.ChangeType.NO_CHANGE) ws.report.changes.push(c);
		return true;
	}
	,compareStructured: function(ws) {
		ws.tparent = ws.parent.getTable();
		ws.tlocal = ws.local.getTable();
		ws.tremote = ws.remote.getTable();
		if(ws.tparent == null || ws.tlocal == null || ws.tremote == null) {
			ws.report.changes.push(new coopy.Change("structured comparisons that include non-tables are not available yet"));
			return false;
		}
		return this.compareTable(ws);
	}
	,compare: function(parent,local,remote,report) {
		var ws = new coopy.Workspace();
		ws.parent = parent;
		ws.local = local;
		ws.remote = remote;
		ws.report = report;
		report.clear();
		if(parent == null || local == null || remote == null) {
			report.changes.push(new coopy.Change("only 3-way comparison allowed right now"));
			return false;
		}
		if(parent.hasStructure() || local.hasStructure() || remote.hasStructure()) return this.compareStructured(ws);
		return this.comparePrimitive(ws);
	}
	,__class__: coopy.Compare
}
coopy.CompareTable = function() {
};
coopy.CompareTable.__name__ = true;
coopy.CompareTable.prototype = {
	compareCore: function() {
		if(this.comp.completed) return false;
		if(!this.comp.is_equal_known) return this.testIsEqual();
		if(!this.comp.has_same_columns_known) return this.testHasSameColumns();
		this.comp.completed = true;
		return false;
	}
	,isEqual2: function(a,b) {
		if(a.getWidth() != b.getWidth() || a.getHeight() != b.getHeight()) return false;
		var av = a.getCellView();
		var _g1 = 0, _g = a.getHeight();
		while(_g1 < _g) {
			var i = _g1++;
			var _g3 = 0, _g2 = a.getWidth();
			while(_g3 < _g2) {
				var j = _g3++;
				if(!av.equals(a.getCell(j,i),b.getCell(j,i))) return false;
			}
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
	,hasSameColumns2: function(a,b) {
		if(a.getWidth() != b.getWidth()) return false;
		if(a.getHeight() == 0 || b.getHeight() == 0) return true;
		var av = a.getCellView();
		var _g1 = 0, _g = a.getWidth();
		while(_g1 < _g) {
			var i = _g1++;
			var _g3 = i + 1, _g2 = a.getWidth();
			while(_g3 < _g2) {
				var j = _g3++;
				if(av.equals(a.getCell(i,0),a.getCell(j,0))) return false;
			}
			if(!av.equals(a.getCell(i,0),b.getCell(i,0))) return false;
		}
		return true;
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
	,alignColumns: function(align,a,b) {
		align.range(a.getWidth(),b.getWidth());
		align.tables(a,b);
		align.setRowlike(false);
		var wmin = a.getWidth();
		if(b.getWidth() < a.getWidth()) wmin = b.getWidth();
		var av = a.getCellView();
		var has_header = true;
		var submatch = true;
		var names = new Hash();
		var _g1 = 0, _g = a.getWidth();
		while(_g1 < _g) {
			var i = _g1++;
			var key = av.toString(a.getCell(i,0));
			if(names.exists(key)) {
				has_header = false;
				break;
			}
			names.set(key,-1);
		}
		names = new Hash();
		if(has_header) {
			var _g1 = 0, _g = b.getWidth();
			while(_g1 < _g) {
				var i = _g1++;
				var key = av.toString(b.getCell(i,0));
				if(names.exists(key)) {
					has_header = false;
					break;
				}
				names.set(key,i);
			}
		}
		if(has_header) {
			var _g = 0;
			while(_g < wmin) {
				var i = _g++;
				if(!av.equals(a.getCell(i,0),b.getCell(i,0))) {
					submatch = false;
					break;
				}
			}
			if(submatch) {
				var _g = 0;
				while(_g < wmin) {
					var i = _g++;
					align.link(i,i);
				}
				return;
			}
		}
		if(has_header) {
			var _g1 = 0, _g = a.getWidth();
			while(_g1 < _g) {
				var i = _g1++;
				var key = av.toString(a.getCell(i,0));
				var v = names.get(key);
				if(v != null) align.link(i,v);
			}
		}
	}
	,alignCore2: function(align,a,b) {
		if(align.meta == null) align.meta = new coopy.Alignment();
		this.alignColumns(align.meta,a,b);
		var column_order = align.meta.toOrder();
		var common_units = new Array();
		var _g = 0, _g1 = column_order.getList();
		while(_g < _g1.length) {
			var unit = _g1[_g];
			++_g;
			if(unit.l >= 0 && unit.r >= 0 && unit.p != -1) common_units.push(unit);
		}
		align.range(a.getHeight(),b.getHeight());
		align.tables(a,b);
		align.setRowlike(true);
		var w = a.getWidth();
		var ha = a.getHeight();
		var hb = b.getHeight();
		var av = a.getCellView();
		var indexes = new Hash();
		var N = 5;
		var columns = new Array();
		if(common_units.length > N) {
			var columns_eval = new Array();
			var _g1 = 0, _g = common_units.length;
			while(_g1 < _g) {
				var i = _g1++;
				var ct = 0;
				var mem = new Hash();
				var mem2 = new Hash();
				var ca = common_units[i].l;
				var cb = common_units[i].r;
				var _g2 = 0;
				while(_g2 < ha) {
					var j = _g2++;
					var key = av.toString(a.getCell(ca,j));
					if(!mem.exists(key)) {
						mem.set(key,1);
						ct++;
					}
				}
				var _g2 = 0;
				while(_g2 < hb) {
					var j = _g2++;
					var key = av.toString(b.getCell(cb,j));
					if(!mem2.exists(key)) {
						mem2.set(key,1);
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
		} else {
			var _g1 = 0, _g = common_units.length;
			while(_g1 < _g) {
				var i = _g1++;
				columns.push(i);
			}
		}
		var top = Math.round(Math.pow(2,columns.length));
		var pending = new IntHash();
		var _g = 0;
		while(_g < ha) {
			var j = _g++;
			pending.set(j,j);
		}
		var pending_ct = ha;
		var _g = 0;
		while(_g < top) {
			var k = _g++;
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
			var index = new coopy.IndexPair();
			var _g2 = 0, _g1 = active_columns.length;
			while(_g2 < _g1) {
				var k1 = _g2++;
				var unit = common_units[active_columns[k1]];
				index.addColumns(unit.l,unit.r);
			}
			index.indexTables(a,b);
			var h = a.getHeight();
			if(b.getHeight() > h) h = b.getHeight();
			if(h < 1) h = 1;
			var wide_top_freq = index.getTopFreq();
			var ratio = wide_top_freq;
			ratio /= h + 20;
			if(ratio >= 0.1) continue;
			var fixed = new Array();
			var $it0 = pending.keys();
			while( $it0.hasNext() ) {
				var j = $it0.next();
				var cross = index.queryLocal(j);
				var spot_a = cross.spot_a;
				var spot_b = cross.spot_b;
				if(spot_a != 1 || spot_b != 1) continue;
				fixed.push(j);
				align.link(j,cross.item_b.lst[0]);
			}
			var _g2 = 0, _g1 = fixed.length;
			while(_g2 < _g1) {
				var j = _g2++;
				pending.remove(fixed[j]);
				pending_ct--;
			}
		}
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
	,getComparisonState: function() {
		return this.comp;
	}
	,align: function() {
		var alignment = new coopy.Alignment();
		this.alignCore(alignment);
		return alignment;
	}
	,attach: function(comp) {
		this.comp = comp;
		var more = this.compareCore();
		while(more && comp.run_to_completion) more = this.compareCore();
		return !more;
	}
	,__class__: coopy.CompareTable
}
coopy.Coopy = function() { }
coopy.Coopy.__name__ = true;
coopy.Coopy.compareTables = function(local,remote) {
	var ct = new coopy.CompareTable();
	var comp = new coopy.TableComparisonState();
	comp.a = local;
	comp.b = remote;
	ct.attach(comp);
	return ct;
}
coopy.Coopy.compareTables3 = function(parent,local,remote) {
	var ct = new coopy.CompareTable();
	var comp = new coopy.TableComparisonState();
	comp.p = parent;
	comp.a = local;
	comp.b = remote;
	ct.attach(comp);
	return ct;
}
coopy.Coopy.main = function() {
	var st = new coopy.SimpleTable(15,6);
	var tab = st;
	var bag = st;
	console.log("table size is " + tab.getWidth() + "x" + tab.getHeight());
	tab.setCell(3,4,new coopy.SimpleCell(33));
	console.log("element is " + Std.string(tab.getCell(3,4)));
	console.log("table as bag is " + Std.string(bag));
	var datum = bag.getItem(4);
	var row = bag.getItemView().getBag(datum);
	console.log("element is " + Std.string(row.getItem(3)));
	var compare = new coopy.Compare();
	var d1 = coopy.ViewedDatum.getSimpleView(new coopy.SimpleCell(10));
	var d2 = coopy.ViewedDatum.getSimpleView(new coopy.SimpleCell(10));
	var d3 = coopy.ViewedDatum.getSimpleView(new coopy.SimpleCell(20));
	var report = new coopy.Report();
	compare.compare(d1,d2,d3,report);
	console.log("report is " + Std.string(report));
	d2 = coopy.ViewedDatum.getSimpleView(new coopy.SimpleCell(50));
	report.clear();
	compare.compare(d1,d2,d3,report);
	console.log("report is " + Std.string(report));
	d2 = coopy.ViewedDatum.getSimpleView(new coopy.SimpleCell(20));
	report.clear();
	compare.compare(d1,d2,d3,report);
	console.log("report is " + Std.string(report));
	d1 = coopy.ViewedDatum.getSimpleView(new coopy.SimpleCell(20));
	report.clear();
	compare.compare(d1,d2,d3,report);
	console.log("report is " + Std.string(report));
	var tv = new coopy.TableView();
	var comp = new coopy.TableComparisonState();
	var ct = new coopy.CompareTable();
	comp.a = st;
	comp.b = st;
	ct.attach(comp);
	console.log("comparing tables");
	var t1 = new coopy.SimpleTable(3,2);
	var t2 = new coopy.SimpleTable(3,2);
	var t3 = new coopy.SimpleTable(3,2);
	var dt1 = new coopy.ViewedDatum(t1,new coopy.TableView());
	var dt2 = new coopy.ViewedDatum(t2,new coopy.TableView());
	var dt3 = new coopy.ViewedDatum(t3,new coopy.TableView());
	compare.compare(dt1,dt2,dt3,report);
	console.log("report is " + Std.string(report));
	t3.setCell(1,1,new coopy.SimpleCell("hello"));
	compare.compare(dt1,dt2,dt3,report);
	console.log("report is " + Std.string(report));
	t1.setCell(1,1,new coopy.SimpleCell("hello"));
	compare.compare(dt1,dt2,dt3,report);
	console.log("report is " + Std.string(report));
	var v = new coopy.Viterbi();
	var td = new coopy.TableDiff(null);
	var idx = new coopy.Index();
	var dr = new coopy.DiffRender();
	return 0;
}
coopy.Coopy.show = function(t) {
	var w = t.getWidth();
	var h = t.getHeight();
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
}
coopy.CrossMatch = function() {
};
coopy.CrossMatch.__name__ = true;
coopy.CrossMatch.prototype = {
	__class__: coopy.CrossMatch
}
coopy.DiffRender = function() {
	this.text_to_insert = new Array();
	this.open = false;
};
coopy.DiffRender.__name__ = true;
coopy.DiffRender.prototype = {
	render: function(rows) {
		var render = this;
		render.beginTable();
		var change_row = -1;
		var v = rows.getCellView();
		var _g1 = 0, _g = rows.getHeight();
		while(_g1 < _g) {
			var row = _g1++;
			var row_mode = "";
			var txt = "";
			var open = false;
			if(rows.getWidth() > 0) {
				txt = v.toString(rows.getCell(0,row));
				if(txt == "@" || txt == "@@") row_mode = "@@"; else if(txt == "!" || txt == "+++" || txt == "---" || txt == "...") {
					row_mode = txt;
					if(txt == "!") change_row = row;
				} else if(txt.indexOf("->") >= 0) row_mode = "->"; else open = true;
			}
			var cmd = txt;
			render.beginRow(row_mode);
			var _g3 = 0, _g2 = rows.getWidth();
			while(_g3 < _g2) {
				var c = _g3++;
				txt = v.toString(rows.getCell(c,row));
				if(txt == "NULL") txt = "";
				if(txt == "null") txt = "";
				var cell_mode = "";
				var separator = "";
				if(open && change_row >= 0) {
					var change = v.toString(rows.getCell(c,change_row));
					if(change == "+++" || change == "---") cell_mode = change;
				}
				if(cmd.indexOf("->") >= 0) {
					if(txt.indexOf(cmd) >= 0) {
						cell_mode = "->";
						separator = cmd;
					}
				}
				render.insertCell(txt,cell_mode,separator);
			}
			render.endRow();
		}
		render.endTable();
	}
	,toString: function() {
		return this.html();
	}
	,html: function() {
		return this.text_to_insert.join("");
	}
	,endTable: function() {
		this.insert("</table>\n");
	}
	,endRow: function() {
		this.insert("</tr>\n");
	}
	,insertCell: function(txt,mode,separator) {
		var cell_decorate = "";
		switch(mode) {
		case "+++":
			cell_decorate += " bgcolor=\"#7fff7f\" style=\"background-color: #7fff7f;\"";
			break;
		case "---":
			cell_decorate += " bgcolor=\"#ff7f7f\" style=\"background-color: #ff7f7f;\"";
			break;
		case "->":
			cell_decorate += " bgcolor=\"#7f7fff\" style=\"background-color: #7f7fff;\"";
			break;
		}
		this.insert(this.td_open + cell_decorate + ">");
		this.insert(txt);
		this.insert(this.td_close);
	}
	,beginRow: function(mode) {
		this.td_open = "<td";
		this.td_close = "</td>";
		this.row_color = "";
		this.open = false;
		switch(mode) {
		case "@@":
			this.td_open = "<th";
			this.td_close = "</th>";
			break;
		case "!":
			this.row_color = "#aaaaaa";
			break;
		case "+++":
			this.row_color = "#7fff7f";
			break;
		case "---":
			this.row_color = "#ff7f7f";
			break;
		default:
			this.open = true;
		}
		var tr = "<tr>";
		var row_decorate = "";
		if(this.row_color != "") {
			row_decorate = " bgcolor=\"" + this.row_color + "\" style=\"background-color: " + this.row_color + ";\"";
			tr = "<tr" + row_decorate + ">";
		}
		this.insert(tr);
	}
	,beginTable: function() {
		this.insert("<table class='csv_sheet'>\n");
	}
	,insert: function(str) {
		this.text_to_insert.push(str);
	}
	,__class__: coopy.DiffRender
}
coopy.Index = function() {
	this.items = new Hash();
	this.cols = new Array();
	this.keys = new Array();
	this.top_freq = 0;
	this.height = 0;
};
coopy.Index.__name__ = true;
coopy.Index.prototype = {
	getTable: function() {
		return this.indexed_table;
	}
	,toKey: function(t,i) {
		var wide = "";
		if(this.v == null) this.v = t.getCellView();
		var _g1 = 0, _g = this.cols.length;
		while(_g1 < _g) {
			var k = _g1++;
			var d = t.getCell(this.cols[k],i);
			var txt = this.v.toString(d);
			if(txt == "" || txt == "null" || txt == "undefined") continue;
			if(k > 0) wide += " // ";
			wide += txt;
		}
		return wide;
	}
	,indexTable: function(t) {
		this.indexed_table = t;
		var _g1 = 0, _g = t.getHeight();
		while(_g1 < _g) {
			var i = _g1++;
			var key;
			if(this.keys.length > i) key = this.keys[i]; else {
				key = this.toKey(t,i);
				this.keys.push(key);
			}
			var item = this.items.get(key);
			if(item == null) {
				item = new coopy.IndexItem();
				this.items.set(key,item);
			}
			var ct = item.add(i);
			if(ct > this.top_freq) this.top_freq = ct;
		}
		this.height = t.getHeight();
	}
	,addColumn: function(i) {
		this.cols.push(i);
	}
	,__class__: coopy.Index
}
coopy.IndexItem = function() {
};
coopy.IndexItem.__name__ = true;
coopy.IndexItem.prototype = {
	add: function(i) {
		if(this.lst == null) this.lst = new Array();
		this.lst.push(i);
		return this.lst.length;
	}
	,__class__: coopy.IndexItem
}
coopy.IndexPair = function() {
	this.ia = new coopy.Index();
	this.ib = new coopy.Index();
	this.quality = 0;
};
coopy.IndexPair.__name__ = true;
coopy.IndexPair.prototype = {
	getQuality: function() {
		return this.quality;
	}
	,getTopFreq: function() {
		if(this.ib.top_freq > this.ia.top_freq) return this.ib.top_freq;
		return this.ia.top_freq;
	}
	,queryLocal: function(row) {
		var result = new coopy.CrossMatch();
		var ka = this.ia.toKey(this.ia.getTable(),row);
		result.item_a = this.ia.items.get(ka);
		result.item_b = this.ib.items.get(ka);
		result.spot_a = result.spot_b = 0;
		if(ka != "") {
			if(result.item_a != null) result.spot_a = result.item_a.lst.length;
			if(result.item_b != null) result.spot_b = result.item_b.lst.length;
		}
		return result;
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
		this.quality = good / Math.max(1.0,a.getHeight());
	}
	,addColumns: function(ca,cb) {
		this.ia.addColumn(ca);
		this.ib.addColumn(cb);
	}
	,addColumn: function(i) {
		this.ia.addColumn(i);
		this.ib.addColumn(i);
	}
	,__class__: coopy.IndexPair
}
coopy.Ordering = function() {
	this.order = new Array();
	this.ignore_parent = false;
};
coopy.Ordering.__name__ = true;
coopy.Ordering.prototype = {
	ignoreParent: function() {
		this.ignore_parent = true;
	}
	,toString: function() {
		var txt = "";
		var _g1 = 0, _g = this.order.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(i > 0) txt += ", ";
			txt += Std.string(this.order[i]);
		}
		return txt;
	}
	,getList: function() {
		return this.order;
	}
	,add: function(l,r,p) {
		if(p == null) p = -2;
		if(this.ignore_parent) p = -2;
		this.order.push(new coopy.Unit(l,r,p));
	}
	,__class__: coopy.Ordering
}
coopy.Report = function() {
	this.changes = new Array();
};
coopy.Report.__name__ = true;
coopy.Report.prototype = {
	clear: function() {
		this.changes = new Array();
	}
	,toString: function() {
		return this.changes.toString();
	}
	,__class__: coopy.Report
}
coopy.SimpleCell = function(x) {
	this.datum = x;
};
coopy.SimpleCell.__name__ = true;
coopy.SimpleCell.__interfaces__ = [coopy.Datum];
coopy.SimpleCell.prototype = {
	toString: function() {
		return this.datum;
	}
	,__class__: coopy.SimpleCell
}
coopy.SimpleRow = function(tab,row_id) {
	this.tab = tab;
	this.row_id = row_id;
	this.bag = this;
};
coopy.SimpleRow.__name__ = true;
coopy.SimpleRow.__interfaces__ = [coopy.Datum,coopy.Bag];
coopy.SimpleRow.prototype = {
	getItemView: function() {
		return new coopy.SimpleView();
	}
	,toString: function() {
		var x = "";
		var _g1 = 0, _g = this.tab.getWidth();
		while(_g1 < _g) {
			var i = _g1++;
			if(i > 0) x += " ";
			x += Std.string(this.getItem(i));
		}
		return x;
	}
	,getTable: function() {
		return null;
	}
	,setItem: function(x,c) {
		this.tab.setCell(x,this.row_id,c);
	}
	,getItem: function(x) {
		return this.tab.getCell(x,this.row_id);
	}
	,getSize: function() {
		return this.tab.getWidth();
	}
	,__class__: coopy.SimpleRow
}
coopy.Table = function() { }
coopy.Table.__name__ = true;
coopy.Table.prototype = {
	__class__: coopy.Table
}
coopy.SimpleTable = function(w,h) {
	this.data = new IntHash();
	this.w = w;
	this.h = h;
	this.bag = this;
};
coopy.SimpleTable.__name__ = true;
coopy.SimpleTable.__interfaces__ = [coopy.Bag,coopy.Table];
coopy.SimpleTable.tableToString = function(tab) {
	var x = "";
	var _g1 = 0, _g = tab.getHeight();
	while(_g1 < _g) {
		var i = _g1++;
		var _g3 = 0, _g2 = tab.getWidth();
		while(_g3 < _g2) {
			var j = _g3++;
			if(j > 0) x += " ";
			x += Std.string(tab.getCell(j,i));
		}
		x += "\n";
	}
	return x;
}
coopy.SimpleTable.prototype = {
	clear: function() {
		this.data = new IntHash();
	}
	,resize: function(w,h) {
		this.w = w;
		this.h = h;
		return true;
	}
	,isResizable: function() {
		return true;
	}
	,getItemView: function() {
		return new coopy.BagView();
	}
	,getCellView: function() {
		return new coopy.SimpleView();
	}
	,toString: function() {
		return coopy.SimpleTable.tableToString(this);
	}
	,getItem: function(y) {
		return new coopy.SimpleRow(this,y);
	}
	,setCell: function(x,y,c) {
		this.data.set(x + y * this.w,c);
	}
	,getCell: function(x,y) {
		return this.data.get(x + y * this.w);
	}
	,getSize: function() {
		return this.h;
	}
	,getHeight: function() {
		return this.h;
	}
	,getWidth: function() {
		return this.w;
	}
	,getTable: function() {
		return this;
	}
	,__class__: coopy.SimpleTable
}
coopy.SimpleView = function() {
};
coopy.SimpleView.__name__ = true;
coopy.SimpleView.__interfaces__ = [coopy.View];
coopy.SimpleView.prototype = {
	toDatum: function(str) {
		return str;
	}
	,equals: function(d1,d2) {
		if(d1 == null && d2 == null) return true;
		return "" + Std.string(d1) == "" + Std.string(d2);
	}
	,hasStructure: function(d) {
		return false;
	}
	,getTable: function(d) {
		return null;
	}
	,getBag: function(d) {
		return null;
	}
	,toString: function(d) {
		return "" + Std.string(d);
	}
	,__class__: coopy.SimpleView
}
coopy.SparseSheet = function() {
	this.h = this.w = 0;
};
coopy.SparseSheet.__name__ = true;
coopy.SparseSheet.prototype = {
	set: function(x,y,val) {
		var cursor = this.row.get(y);
		if(cursor == null) {
			cursor = new IntHash();
			this.row.set(y,cursor);
		}
		cursor.set(x,val);
	}
	,get: function(x,y) {
		var cursor = this.row.get(y);
		if(cursor == null) return this.zero;
		var val = cursor.get(x);
		if(val == null) return this.zero;
		return val;
	}
	,nonDestructiveResize: function(w,h,zero) {
		this.w = w;
		this.h = h;
		this.zero = zero;
	}
	,resize: function(w,h,zero) {
		this.row = new IntHash();
		this.nonDestructiveResize(w,h,zero);
	}
	,__class__: coopy.SparseSheet
}
coopy.TableComparisonState = function() {
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
	}
	,__class__: coopy.TableComparisonState
}
coopy.TableDiff = function(align) {
	this.align = align;
};
coopy.TableDiff.__name__ = true;
coopy.TableDiff.prototype = {
	test: function() {
		var report = new coopy.Report();
		var order = this.align.toOrder();
		var units = order.getList();
		var has_parent = this.align.reference != null;
		var a;
		var b;
		var p;
		if(has_parent) {
			p = this.align.getSource();
			a = this.align.reference.getTarget();
			b = this.align.getTarget();
		} else {
			a = this.align.getSource();
			b = this.align.getTarget();
			p = a;
		}
		var _g1 = 0, _g = units.length;
		while(_g1 < _g) {
			var i = _g1++;
			var unit = units[i];
			if(unit.p < 0 && unit.l < 0 && unit.r >= 0) report.changes.push(new coopy.Change("inserted row r:" + unit.r));
			if((unit.p >= 0 || !has_parent) && unit.l >= 0 && unit.r < 0) report.changes.push(new coopy.Change("deleted row l:" + unit.l));
			if(unit.l >= 0 && unit.r >= 0) {
				var mod = false;
				var av = a.getCellView();
				var _g3 = 0, _g2 = a.getWidth();
				while(_g3 < _g2) {
					var j = _g3++;
				}
			}
		}
		return report;
	}
	,hilite: function(output) {
		if(!output.isResizable()) return false;
		output.resize(0,0);
		output.clear();
		var order = this.align.toOrder();
		var units = order.getList();
		var has_parent = this.align.reference != null;
		var a;
		var b;
		var p;
		if(has_parent) {
			p = this.align.getSource();
			a = this.align.reference.getTarget();
			b = this.align.getTarget();
		} else {
			a = this.align.getSource();
			b = this.align.getTarget();
			p = a;
		}
		var column_order = this.align.meta.toOrder();
		var column_units = column_order.getList();
		var v = a.getCellView();
		var _g1 = 0, _g = units.length;
		while(_g1 < _g) {
			var i = _g1++;
			var unit = units[i];
			if(unit.r < 0 && unit.l < 0) continue;
			var at = output.getHeight();
			output.resize(column_units.length + 1,at + 1);
			var act = "";
			if(unit.p < 0 && unit.l < 0 && unit.r >= 0) act = "+++";
			if((unit.p >= 0 || !has_parent) && unit.l >= 0 && unit.r < 0) act = "---";
			var _g3 = 0, _g2 = column_units.length;
			while(_g3 < _g2) {
				var j = _g3++;
				var cunit = column_units[j];
				var pp = null;
				var ll = null;
				var rr = null;
				var dd = null;
				var dd_to = null;
				var have_pp = false;
				var have_ll = false;
				var have_rr = false;
				if(cunit.p >= 0 && unit.p >= 0) {
					pp = p.getCell(cunit.p,unit.p);
					have_pp = true;
				}
				if(cunit.l >= 0 && unit.l >= 0) {
					ll = a.getCell(cunit.l,unit.l);
					have_ll = true;
				}
				if(cunit.r >= 0 && unit.r >= 0) {
					rr = b.getCell(cunit.r,unit.r);
					have_rr = true;
				}
				if(have_pp) {
					if(!have_rr) dd = pp; else if(v.equals(pp,rr)) dd = pp; else {
						dd = pp;
						dd_to = rr;
					}
				} else if(have_ll) {
					if(!have_rr) dd = ll; else if(v.equals(ll,rr)) dd = ll; else {
						dd = ll;
						dd_to = rr;
					}
				} else dd = rr;
				var txt = v.toString(dd);
				if(dd_to != null) {
					txt = txt + "->" + v.toString(dd_to);
					act = "->";
				}
				output.setCell(j + 1,at,v.toDatum(txt));
			}
			output.setCell(0,at,v.toDatum(act));
		}
		return true;
	}
	,__class__: coopy.TableDiff
}
coopy.TableView = function() {
};
coopy.TableView.__name__ = true;
coopy.TableView.__interfaces__ = [coopy.View];
coopy.TableView.prototype = {
	toDatum: function(str) {
		return new coopy.SimpleCell(str);
	}
	,equals: function(d1,d2) {
		console.log("TableView.equals called");
		return false;
	}
	,hasStructure: function(d) {
		return true;
	}
	,getTable: function(d) {
		var table = d;
		return table;
	}
	,getBag: function(d) {
		return null;
	}
	,toString: function(d) {
		return "" + Std.string(d);
	}
	,__class__: coopy.TableView
}
coopy.Unit = function(l,r,p) {
	if(p == null) p = -2;
	this.l = l;
	this.r = r;
	this.p = p;
};
coopy.Unit.__name__ = true;
coopy.Unit.describe = function(i) {
	return i >= 0?"" + i:"-";
}
coopy.Unit.prototype = {
	toString: function() {
		if(this.p >= -1) return coopy.Unit.describe(this.p) + "|" + coopy.Unit.describe(this.l) + ":" + coopy.Unit.describe(this.r);
		return coopy.Unit.describe(this.l) + ":" + coopy.Unit.describe(this.r);
	}
	,__class__: coopy.Unit
}
coopy.ViewedDatum = function(datum,view) {
	this.datum = datum;
	this.view = view;
};
coopy.ViewedDatum.__name__ = true;
coopy.ViewedDatum.getSimpleView = function(datum) {
	return new coopy.ViewedDatum(datum,new coopy.SimpleView());
}
coopy.ViewedDatum.prototype = {
	hasStructure: function() {
		return this.view.hasStructure(this.datum);
	}
	,getTable: function() {
		return this.view.getTable(this.datum);
	}
	,getBag: function() {
		return this.view.getBag(this.datum);
	}
	,toString: function() {
		return this.view.toString(this.datum);
	}
	,__class__: coopy.ViewedDatum
}
coopy.Viterbi = function() {
	this.K = this.T = 0;
	this.reset();
	this.cost = new coopy.SparseSheet();
	this.src = new coopy.SparseSheet();
	this.path = new coopy.SparseSheet();
};
coopy.Viterbi.__name__ = true;
coopy.Viterbi.prototype = {
	getCost: function() {
		this.calculatePath();
		return this.best_cost;
	}
	,get: function(i) {
		this.calculatePath();
		return this.path.get(0,i);
	}
	,length: function() {
		if(this.index > 0) this.calculatePath();
		return this.index;
	}
	,toString: function() {
		this.calculatePath();
		var txt = "";
		var _g1 = 0, _g = this.index;
		while(_g1 < _g) {
			var i = _g1++;
			if(this.path.get(0,i) == -1) txt += "*"; else txt += this.path.get(0,i);
			if(this.K >= 10) txt += " ";
		}
		txt += " costs " + this.getCost();
		return txt;
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
		var _g1 = 0, _g = this.K;
		while(_g1 < _g) {
			var j = _g1++;
			if((this.cost.get(j,this.index - 1) < best || bestj == -1) && this.src.get(j,this.index - 1) != -1) {
				best = this.cost.get(j,this.index - 1);
				bestj = j;
			}
		}
		this.best_cost = best;
		var _g1 = 0, _g = this.index;
		while(_g1 < _g) {
			var j = _g1++;
			var i = this.index - 1 - j;
			this.path.set(0,i,bestj);
			if(!(bestj != -1 && (bestj >= 0 && bestj < this.K))) console.log("Problem in Viterbi");
			bestj = this.src.get(bestj,i);
		}
		this.path_valid = true;
	}
	,beginTransitions: function() {
		this.path_valid = false;
		this.assertMode(1);
	}
	,endTransitions: function() {
		this.path_valid = false;
		this.assertMode(0);
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
	,assertMode: function(next) {
		if(next == 0 && this.mode == 1) this.index++;
		this.mode = next;
	}
	,setSize: function(states,sequence_length) {
		this.K = states;
		this.T = sequence_length;
		this.cost.resize(this.K,this.T,0);
		this.src.resize(this.K,this.T,-1);
		this.path.resize(1,this.T,-1);
	}
	,reset: function() {
		this.index = 0;
		this.mode = 0;
		this.path_valid = false;
		this.best_cost = 0;
	}
	,__class__: coopy.Viterbi
}
coopy.Workspace = function() {
};
coopy.Workspace.__name__ = true;
coopy.Workspace.prototype = {
	__class__: coopy.Workspace
}
var js = js || {}
js.Boot = function() { }
js.Boot.__name__ = true;
js.Boot.__unhtml = function(s) {
	return s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
}
js.Boot.__trace = function(v,i) {
	var msg = i != null?i.fileName + ":" + i.lineNumber + ": ":"";
	msg += js.Boot.__string_rec(v,"");
	var d;
	if(typeof(document) != "undefined" && (d = document.getElementById("haxe:trace")) != null) d.innerHTML += js.Boot.__unhtml(msg) + "<br/>"; else if(typeof(console) != "undefined" && console.log != null) console.log(msg);
}
js.Boot.__clear_trace = function() {
	var d = document.getElementById("haxe:trace");
	if(d != null) d.innerHTML = "";
}
js.Boot.isClass = function(o) {
	return __define_feature__("js.Boot.isClass",o.__name__);
}
js.Boot.isEnum = function(e) {
	return __define_feature__("js.Boot.isEnum",e.__ename__);
}
js.Boot.getClass = function(o) {
	return __define_feature__("js.Boot.getClass",o.__class__);
}
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (__define_feature__("js.Boot.isClass",o.__name__) || __define_feature__("js.Boot.isEnum",o.__ename__))) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2, _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i;
			var str = "[";
			s += "\t";
			var _g = 0;
			while(_g < l) {
				var i1 = _g++;
				str += (i1 > 0?",":"") + js.Boot.__string_rec(o[i1],s);
			}
			str += "]";
			return str;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) { ;
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
}
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0, _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
}
js.Boot.__instanceof = function(o,cl) {
	try {
		if(o instanceof cl) {
			if(cl == Array) return o.__enum__ == null;
			return true;
		}
		if(js.Boot.__interfLoop(__define_feature__("js.Boot.getClass",o.__class__),cl)) return true;
	} catch( e ) {
		if(cl == null) return false;
	}
	switch(cl) {
	case Int:
		return Math.ceil(o%2147483648.0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return o === true || o === false;
	case String:
		return typeof(o) == "string";
	case Dynamic:
		return true;
	default:
		if(o == null) return false;
		if(cl == Class && o.__name__ != null) return true; else null;
		if(cl == Enum && o.__ename__ != null) return true; else null;
		return o.__enum__ == cl;
	}
}
js.Boot.__cast = function(o,t) {
	if(js.Boot.__instanceof(o,t)) return o; else throw "Cannot cast " + Std.string(o) + " to " + Std.string(t);
}
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; };
var $_;
function $bind(o,m) { var f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; return f; };
if(Array.prototype.indexOf) HxOverrides.remove = function(a,o) {
	var i = a.indexOf(o);
	if(i == -1) return false;
	a.splice(i,1);
	return true;
}; else null;
Math.__name__ = ["Math"];
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i) {
	return isNaN(i);
};
String.prototype.__class__ = String;
String.__name__ = true;
Array.prototype.__class__ = Array;
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
var Void = { __ename__ : ["Void"]};
//coopy.Coopy.main();

//@ sourceMappingURL=coopy.js.map
if (typeof exports != "undefined") {
    var lst = ["Coopy", "SimpleTable", "ViewedDatum", "TableView", "ViewedDatum", "SimpleView", "Compare", "Report", "Change", "ChangeType", "CompareTable", "TableComparisonState", "Viterbi", "TableDiff","DiffRender"];
  for (f in lst) { exports[lst[f]] = coopy[lst[f]]; } 
}


