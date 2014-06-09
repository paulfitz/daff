var coopy = require('daff');
var assert = require('assert');

var v = new coopy.Viterbi();
v.setSize(10,100);
v.beginTransitions();
v.addTransition(0,0,1);
v.endTransitions();
for (var i=0; i<20; i++) {
    v.beginTransitions();
    v.addTransition(0,1,1);
    v.addTransition(1,0,1);
    v.endTransitions();
}
var out = 0;
for (var i=0; i<20; i++) {
    if (v.get(i)!=i%2) {
	out++;
    }
}
assert.equal(v.toString(),"0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0  costs 21");
assert(out==0);
