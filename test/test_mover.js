var coopy = require('daff');
var assert = require('assert');

function copy_list(lst) {
    var result = [];
    for (var i=0; i<lst.length; i++) {
	result[i] = lst[i];
    }
    return result;
}

var base = 17;
function unrandom() {
    base *= 257;
    base += 13;
    base %= 65537;
    return base/65537.0;
}

function shuffle_list(lst) {
    var counter = lst.length;
    while (counter--) {
        var index = (unrandom() * counter) | 0;
        var temp = lst[counter];
        lst[counter] = lst[index];
        lst[index] = temp;
    }
}

function move(x,y) {
    var result = coopy.Mover.move(x,y);
    result.sort(function(a,b){return a-b;});
    //console.log(x + " -> " + y + " via " + result);
    return result;
}

function move_units(u) {
    var result = coopy.Mover.moveUnits(u);
    result.sort(function(a,b){return a-b;});
    //console.log(x + " -> " + y + " via " + result);
    return result;
}

assert.deepEqual(move([1,2,3],[1,2,3]), []);
assert.deepEqual(move([1,2,3],[2,3,1]), [1]);
assert.deepEqual(move([1,2,3],[3,1,2]), [3]);
assert.deepEqual(move([1,2,3,4],[2,1,4,3]).length, 2);
assert.deepEqual(move([1,2,3,4,5],[4,5,1,2,3]), [4,5]);
assert.deepEqual(move([1,2,3,4,5],[5,4,3,2,1]).length, 4);
assert.deepEqual(move([5,4,3,2,1],[1,2,3,4,5]).length, 4);
assert.deepEqual(move([1,2,4,3,5],[1,2,3,4,5]).length, 1);
assert.deepEqual(move([10,11,12,20,22,33,30],
		      [33,30,20,22,10,11,12]), [20,22,30,33]);

var len = 10000;
var long_list = [];
for (var i=0; i<len; i++) { long_list[i] = i; }
var long_list2 = copy_list(long_list);
shuffle_list(long_list2);

var long_list_shift_left = copy_list(long_list);
long_list_shift_left.splice(0,1);
long_list_shift_left.push(0);

var long_list_shift_right = copy_list(long_list);
long_list_shift_right.splice(len-1,1);
long_list_shift_right.unshift(len-1);

assert.deepEqual(move(long_list,long_list), []);
assert.deepEqual(move(long_list,long_list_shift_left), [0]);
assert.deepEqual(move(long_list,long_list_shift_right), [len-1]);

move(long_list,long_list2); // should terminate in reasonable time

assert.deepEqual(move([1,2,3],[1,2,4,3]), []);
assert.deepEqual(move([5,1,2,3],[1,2,4,3]), []);
assert.deepEqual(move([5,2,3,1],[1,2,4,3]), [1]);

{
    var t1 = new coopy.TableView([["Name","Number"],
				       ["John",14],
				       ["Sam", 82]]);
    var t2 = new coopy.TableView([["Name","Number"],
				       ["Sam",82],
				       ["Mary",17],
				       ["John",15]]);
    
    var ct = new coopy.Coopy.compareTables(t1,t2);
    var align = ct.align();
    var order = align.toOrder();
    assert.equal(move_units(order.getList()).length,1);
}
