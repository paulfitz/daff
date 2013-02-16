var $estr = function() { return js.Boot.__string_rec(this,''); };
var Alignment = function() {
	this.map_a2b = new IntHash();
	this.map_b2a = new IntHash();
	this.ha = this.hb = 0;
	this.map_count = 0;
	this.reference = null;
	this.meta = null;
};
Alignment.__name__ = true;
Alignment.prototype = {
	toOrder2: function() {
		var order = new Ordering();
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
			ref = new Alignment();
			ref.range(this.ha,this.ha);
			ref.tables(this.ta,this.ta);
			var _g1 = 0, _g = this.ha;
			while(_g1 < _g) {
				var i = _g1++;
				ref.link(i,i);
			}
		}
		var order = new Ordering();
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
		if(this.order_cache == null) this.order_cache = this.toOrder3();
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
	,__class__: Alignment
}
var Datum = function() { }
Datum.__name__ = true;
Datum.prototype = {
	__class__: Datum
}
var Bag = function() { }
Bag.__name__ = true;
Bag.__interfaces__ = [Datum];
Bag.prototype = {
	__class__: Bag
}
var View = function() { }
View.__name__ = true;
View.prototype = {
	__class__: View
}
var BagView = function() {
};
BagView.__name__ = true;
BagView.__interfaces__ = [View];
BagView.prototype = {
	equals: function(d1,d2) {
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
	,__class__: BagView
}
var Change = function(txt) {
	if(txt != null) {
		this.mode = ChangeType.NOTE_CHANGE;
		this.change = txt;
	} else this.mode = ChangeType.NO_CHANGE;
};
Change.__name__ = true;
Change.prototype = {
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
	,__class__: Change
}
var ChangeType = { __ename__ : true, __constructs__ : ["NO_CHANGE","REMOTE_CHANGE","LOCAL_CHANGE","BOTH_CHANGE","SAME_CHANGE","NOTE_CHANGE"] }
ChangeType.NO_CHANGE = ["NO_CHANGE",0];
ChangeType.NO_CHANGE.toString = $estr;
ChangeType.NO_CHANGE.__enum__ = ChangeType;
ChangeType.REMOTE_CHANGE = ["REMOTE_CHANGE",1];
ChangeType.REMOTE_CHANGE.toString = $estr;
ChangeType.REMOTE_CHANGE.__enum__ = ChangeType;
ChangeType.LOCAL_CHANGE = ["LOCAL_CHANGE",2];
ChangeType.LOCAL_CHANGE.toString = $estr;
ChangeType.LOCAL_CHANGE.__enum__ = ChangeType;
ChangeType.BOTH_CHANGE = ["BOTH_CHANGE",3];
ChangeType.BOTH_CHANGE.toString = $estr;
ChangeType.BOTH_CHANGE.__enum__ = ChangeType;
ChangeType.SAME_CHANGE = ["SAME_CHANGE",4];
ChangeType.SAME_CHANGE.toString = $estr;
ChangeType.SAME_CHANGE.__enum__ = ChangeType;
ChangeType.NOTE_CHANGE = ["NOTE_CHANGE",5];
ChangeType.NOTE_CHANGE.toString = $estr;
ChangeType.NOTE_CHANGE.__enum__ = ChangeType;
var Compare = function() {
};
Compare.__name__ = true;
Compare.prototype = {
	comparePrimitive: function(ws) {
		var sparent = ws.parent.toString();
		var slocal = ws.local.toString();
		var sremote = ws.remote.toString();
		var c = new Change();
		c.parent = ws.parent;
		c.local = ws.local;
		c.remote = ws.remote;
		if(sparent == slocal && sparent != sremote) c.mode = ChangeType.REMOTE_CHANGE; else if(sparent == sremote && sparent != slocal) c.mode = ChangeType.LOCAL_CHANGE; else if(slocal == sremote && sparent != slocal) c.mode = ChangeType.SAME_CHANGE; else if(sparent != slocal && sparent != sremote) c.mode = ChangeType.BOTH_CHANGE; else c.mode = ChangeType.NO_CHANGE;
		if(c.mode != ChangeType.NO_CHANGE) ws.report.changes.push(c);
		return true;
	}
	,compareTable: function(ws) {
		ws.p2l = new Comparison();
		ws.p2r = new Comparison();
		ws.p2l.a = ws.tparent;
		ws.p2l.b = ws.tlocal;
		ws.p2r.a = ws.tparent;
		ws.p2r.b = ws.tremote;
		var cmp = new CompareTable();
		cmp.compare(ws.p2l);
		cmp.compare(ws.p2r);
		var c = new Change();
		c.parent = ws.parent;
		c.local = ws.local;
		c.remote = ws.remote;
		if(ws.p2l.is_equal && !ws.p2r.is_equal) c.mode = ChangeType.REMOTE_CHANGE; else if(!ws.p2l.is_equal && ws.p2r.is_equal) c.mode = ChangeType.LOCAL_CHANGE; else if(!ws.p2l.is_equal && !ws.p2r.is_equal) {
			ws.l2r = new Comparison();
			ws.l2r.a = ws.tlocal;
			ws.l2r.b = ws.tremote;
			cmp.compare(ws.l2r);
			if(ws.l2r.is_equal) c.mode = ChangeType.SAME_CHANGE; else c.mode = ChangeType.BOTH_CHANGE;
		} else c.mode = ChangeType.NO_CHANGE;
		if(c.mode != ChangeType.NO_CHANGE) ws.report.changes.push(c);
		return true;
	}
	,compareStructured: function(ws) {
		ws.tparent = ws.parent.getTable();
		ws.tlocal = ws.local.getTable();
		ws.tremote = ws.remote.getTable();
		if(ws.tparent == null || ws.tlocal == null || ws.tremote == null) {
			ws.report.changes.push(new Change("structured comparisons that include non-tables are not available yet"));
			return false;
		}
		return this.compareTable(ws);
	}
	,compare: function(parent,local,remote,report) {
		var ws = new Workspace();
		ws.parent = parent;
		ws.local = local;
		ws.remote = remote;
		ws.report = report;
		report.clear();
		if(parent == null || local == null || remote == null) {
			report.changes.push(new Change("only 3-way comparison allowed right now"));
			return false;
		}
		if(parent.hasStructure() || local.hasStructure() || remote.hasStructure()) return this.compareStructured(ws);
		return this.comparePrimitive(ws);
	}
	,__class__: Compare
}
var CompareTable = function() {
};
CompareTable.__name__ = true;
CompareTable.prototype = {
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
	,alignCore2_slow: function(align,a,b) {
		if(!this.comp.has_same_columns) return;
		align.range(a.getHeight(),b.getHeight());
		align.tables(a,b);
		var w = a.getWidth();
		var ha = a.getHeight();
		var hb = b.getHeight();
		var av = a.getCellView();
		var indexes = new Hash();
		var _g = 0;
		while(_g < ha) {
			var i = _g++;
			var _g1 = 0;
			while(_g1 < hb) {
				var j = _g1++;
				var match = 0;
				var mt = new MatchTypes(this.comp,align,a,b,indexes);
				var _g2 = 0;
				while(_g2 < w) {
					var k = _g2++;
					var va = a.getCell(k,i);
					var vb = b.getCell(k,j);
					if(av.equals(va,vb)) mt.add(k,va);
				}
				if(mt.evaluate()) align.link(i,j);
			}
		}
	}
	,alignCore2: function(align,a,b) {
		if(align.meta == null) align.meta = new Alignment();
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
			var index = new IndexPair();
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
		align.reference = new Alignment();
		this.alignCore2(align,this.comp.p,this.comp.b);
		this.alignCore2(align.reference,this.comp.p,this.comp.a);
	}
	,align: function() {
		var alignment = new Alignment();
		this.alignCore(alignment);
		return alignment;
	}
	,compare: function(comp) {
		this.comp = comp;
		var more = this.compareCore();
		while(more && comp.run_to_completion) more = this.compareCore();
		return !more;
	}
	,__class__: CompareTable
}
var Comparison = function() {
	this.reset();
};
Comparison.__name__ = true;
Comparison.compareTables = function(ct,t1,t2) {
	var comp = new Comparison();
	comp.a = t1;
	comp.b = t2;
	ct.compare(comp);
	return comp;
}
Comparison.compareTables3 = function(ct,t1,t2,t3) {
	var comp = new Comparison();
	comp.p = t1;
	comp.a = t2;
	comp.b = t3;
	ct.compare(comp);
	return comp;
}
Comparison.prototype = {
	reset: function() {
		this.completed = false;
		this.run_to_completion = true;
		this.is_equal_known = false;
		this.is_equal = false;
		this.has_same_columns = false;
		this.has_same_columns_known = false;
	}
	,__class__: Comparison
}
var Coopy = function() { }
Coopy.__name__ = true;
Coopy.main = function() {
	var st = new SimpleTable(15,6);
	var tab = st;
	var bag = st;
	console.log("table size is " + tab.getWidth() + "x" + tab.getHeight());
	tab.setCell(3,4,new SimpleCell(33));
	console.log("element is " + Std.string(tab.getCell(3,4)));
	console.log("table as bag is " + Std.string(bag));
	var datum = bag.getItem(4);
	var row = bag.getItemView().getBag(datum);
	console.log("element is " + Std.string(row.getItem(3)));
	var compare = new Compare();
	var d1 = ViewedDatum.getSimpleView(new SimpleCell(10));
	var d2 = ViewedDatum.getSimpleView(new SimpleCell(10));
	var d3 = ViewedDatum.getSimpleView(new SimpleCell(20));
	var report = new Report();
	compare.compare(d1,d2,d3,report);
	console.log("report is " + Std.string(report));
	d2 = ViewedDatum.getSimpleView(new SimpleCell(50));
	report.clear();
	compare.compare(d1,d2,d3,report);
	console.log("report is " + Std.string(report));
	d2 = ViewedDatum.getSimpleView(new SimpleCell(20));
	report.clear();
	compare.compare(d1,d2,d3,report);
	console.log("report is " + Std.string(report));
	d1 = ViewedDatum.getSimpleView(new SimpleCell(20));
	report.clear();
	compare.compare(d1,d2,d3,report);
	console.log("report is " + Std.string(report));
	var tv = new TableView();
	var comp = new Comparison();
	var ct = new CompareTable();
	comp.a = st;
	comp.b = st;
	ct.compare(comp);
	console.log("comparing tables");
	var t1 = new SimpleTable(3,2);
	var t2 = new SimpleTable(3,2);
	var t3 = new SimpleTable(3,2);
	var dt1 = new ViewedDatum(t1,new TableView());
	var dt2 = new ViewedDatum(t2,new TableView());
	var dt3 = new ViewedDatum(t3,new TableView());
	compare.compare(dt1,dt2,dt3,report);
	console.log("report is " + Std.string(report));
	t3.setCell(1,1,new SimpleCell("hello"));
	compare.compare(dt1,dt2,dt3,report);
	console.log("report is " + Std.string(report));
	t1.setCell(1,1,new SimpleCell("hello"));
	compare.compare(dt1,dt2,dt3,report);
	console.log("report is " + Std.string(report));
	var v = new Viterbi();
	var td = new TableDiff(null);
	var idx = new Index();
	return 0;
}
Coopy.show = function(t) {
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
var CrossMatch = function() {
};
CrossMatch.__name__ = true;
CrossMatch.prototype = {
	__class__: CrossMatch
}
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
var Index = function() {
	this.items = new Hash();
	this.cols = new Array();
	this.keys = new Array();
	this.top_freq = 0;
	this.height = 0;
};
Index.__name__ = true;
Index.prototype = {
	getTable: function() {
		return this.indexed_table;
	}
	,matchToKey: function(m) {
		var wide = "";
		if(this.v == null) this.v = this.indexed_table.getCellView();
		var _g1 = 0, _g = m.matches.length;
		while(_g1 < _g) {
			var k = _g1++;
			var d = m.matches[k].val;
			var txt = this.v.toString(d);
			if(txt == "" || txt == "null" || txt == "undefined") continue;
			if(k > 0) wide += " // ";
			wide += txt;
		}
		return wide;
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
				item = new IndexItem();
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
	,__class__: Index
}
var IndexItem = function() {
};
IndexItem.__name__ = true;
IndexItem.prototype = {
	add: function(i) {
		if(this.lst == null) this.lst = new Array();
		this.lst.push(i);
		return this.lst.length;
	}
	,__class__: IndexItem
}
var IndexPair = function() {
	this.ia = new Index();
	this.ib = new Index();
	this.quality = 0;
};
IndexPair.__name__ = true;
IndexPair.prototype = {
	getQuality: function() {
		return this.quality;
	}
	,getTopFreq: function() {
		if(this.ib.top_freq > this.ia.top_freq) return this.ib.top_freq;
		return this.ia.top_freq;
	}
	,query: function(match) {
		var result = new CrossMatch();
		var ka = this.ia.matchToKey(match);
		var kb = this.ib.matchToKey(match);
		result.item_a = this.ia.items.get(ka);
		result.item_b = this.ib.items.get(kb);
		result.spot_a = result.spot_b = 0;
		if(ka != "" || kb != "") {
			if(result.item_a != null) result.spot_a = result.item_a.lst.length;
			if(result.item_b != null) result.spot_b = result.item_b.lst.length;
		}
		return result;
	}
	,queryLocal: function(row) {
		var result = new CrossMatch();
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
	,__class__: IndexPair
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
var Match = function() {
	this.matches = new Array();
};
Match.__name__ = true;
Match.prototype = {
	__class__: Match
}
var MatchType = function() {
	this.col = -1;
};
MatchType.__name__ = true;
MatchType.prototype = {
	__class__: MatchType
}
var MatchTypes = function(comp,align,local,remote,indexes) {
	this.matches = new Match();
	this.indexes = indexes;
	this.comp = comp;
	this.align = align;
	this.local = local;
	this.remote = remote;
};
MatchTypes.__name__ = true;
MatchTypes.prototype = {
	evaluate: function() {
		if(this.matches.matches.length == 0) return false;
		var add_col = function(c,total) {
			return total += c;
		};
		var get_col = function(m) {
			return m.col;
		};
		var indexName = Lambda.fold(Lambda.map(this.matches.matches,get_col),add_col,"");
		this.index = this.indexes.get(indexName);
		if(this.index == null) {
			this.index = new IndexPair();
			var _g1 = 0, _g = this.matches.matches.length;
			while(_g1 < _g) {
				var k = _g1++;
				var mt = this.matches.matches[k];
				this.index.addColumn(mt.col);
			}
			this.index.indexTables(this.local,this.remote);
			this.indexes.set(indexName,this.index);
		}
		var cross = this.index.query(this.matches);
		var spot_a = cross.spot_a;
		var spot_b = cross.spot_b;
		var wide_top_freq = this.index.getTopFreq();
		if(spot_a != 1 || spot_b != 1) return false;
		if(wide_top_freq == 1) return true;
		var h = this.local.getHeight();
		if(this.remote.getHeight() > h) h = this.remote.getHeight();
		if(h < 1) h = 1;
		var ratio = wide_top_freq;
		ratio /= h + 20;
		if(ratio < 0.1) return true;
		return false;
	}
	,add: function(col,val) {
		var mt = new MatchType();
		mt.col = col;
		mt.val = val;
		this.matches.matches.push(mt);
	}
	,__class__: MatchTypes
}
var Ordering = function() {
	this.order = new Array();
	this.ignore_parent = false;
};
Ordering.__name__ = true;
Ordering.prototype = {
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
		this.order.push(new Unit(l,r,p));
	}
	,__class__: Ordering
}
var Report = function() {
	this.changes = new Array();
};
Report.__name__ = true;
Report.prototype = {
	clear: function() {
		this.changes = new Array();
	}
	,toString: function() {
		return this.changes.toString();
	}
	,__class__: Report
}
var SimpleCell = function(x) {
	this.datum = x;
};
SimpleCell.__name__ = true;
SimpleCell.__interfaces__ = [Datum];
SimpleCell.prototype = {
	toString: function() {
		return this.datum;
	}
	,__class__: SimpleCell
}
var SimpleRow = function(tab,row_id) {
	this.tab = tab;
	this.row_id = row_id;
	this.bag = this;
};
SimpleRow.__name__ = true;
SimpleRow.__interfaces__ = [Datum,Bag];
SimpleRow.prototype = {
	getItemView: function() {
		return new SimpleView();
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
	,__class__: SimpleRow
}
var Table = function() { }
Table.__name__ = true;
Table.prototype = {
	__class__: Table
}
var SimpleTable = function(w,h) {
	this.data = new IntHash();
	this.w = w;
	this.h = h;
	this.bag = this;
};
SimpleTable.__name__ = true;
SimpleTable.__interfaces__ = [Bag,Table];
SimpleTable.tableToString = function(tab) {
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
SimpleTable.prototype = {
	getItemView: function() {
		return new BagView();
	}
	,getCellView: function() {
		return new SimpleView();
	}
	,toString: function() {
		return SimpleTable.tableToString(this);
	}
	,getItem: function(y) {
		return new SimpleRow(this,y);
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
	,__class__: SimpleTable
}
var SimpleView = function() {
};
SimpleView.__name__ = true;
SimpleView.__interfaces__ = [View];
SimpleView.prototype = {
	equals: function(d1,d2) {
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
	,__class__: SimpleView
}
var SparseSheet = function() {
	this.h = this.w = 0;
};
SparseSheet.__name__ = true;
SparseSheet.prototype = {
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
	,__class__: SparseSheet
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
var TableDiff = function(align) {
	this.align = align;
};
TableDiff.__name__ = true;
TableDiff.prototype = {
	test: function() {
		var report = new Report();
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
		if(a.getWidth() != b.getWidth() || p.getWidth() != b.getWidth()) {
			console.log("TableDiff currently expects constant columns");
			return null;
		}
		var _g1 = 0, _g = units.length;
		while(_g1 < _g) {
			var i = _g1++;
			var unit = units[i];
			if(unit.p < 0 && unit.l < 0 && unit.r >= 0) report.changes.push(new Change("inserted row r:" + unit.r));
			if((unit.p >= 0 || !has_parent) && unit.l >= 0 && unit.r < 0) report.changes.push(new Change("deleted row l:" + unit.l));
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
	,__class__: TableDiff
}
var TableView = function() {
};
TableView.__name__ = true;
TableView.__interfaces__ = [View];
TableView.prototype = {
	equals: function(d1,d2) {
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
	,__class__: TableView
}
var Unit = function(l,r,p) {
	if(p == null) p = -2;
	this.l = l;
	this.r = r;
	this.p = p;
};
Unit.__name__ = true;
Unit.describe = function(i) {
	return i >= 0?"" + i:"-";
}
Unit.prototype = {
	toString: function() {
		if(this.p >= -1) return Unit.describe(this.p) + "|" + Unit.describe(this.l) + ":" + Unit.describe(this.r);
		return Unit.describe(this.l) + ":" + Unit.describe(this.r);
	}
	,__class__: Unit
}
var ViewedDatum = function(datum,view) {
	this.datum = datum;
	this.view = view;
};
ViewedDatum.__name__ = true;
ViewedDatum.getSimpleView = function(datum) {
	return new ViewedDatum(datum,new SimpleView());
}
ViewedDatum.prototype = {
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
	,__class__: ViewedDatum
}
var Viterbi = function() {
	this.K = this.T = 0;
	this.reset();
	this.cost = new SparseSheet();
	this.src = new SparseSheet();
	this.path = new SparseSheet();
};
Viterbi.__name__ = true;
Viterbi.prototype = {
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
	,__class__: Viterbi
}
var Workspace = function() {
};
Workspace.__name__ = true;
Workspace.prototype = {
	__class__: Workspace
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
//Coopy.main();

//@ sourceMappingURL=coopy.js.map
if (typeof exports != "undefined") {
    var lst = ["Coopy", "SimpleTable", "ViewedDatum", "TableView", "ViewedDatum", "SimpleView", "Compare", "Report", "Change", "ChangeType", "CompareTable", "Comparison", "Viterbi", "TableDiff"];
  for (f in lst) { exports[lst[f]] = eval(lst[f]); } 
}


