// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Do a Viterbi lattice calculation to calculate the optimum state 
 * to be in at each step of a sequence, given the costs of 
 * transitions between those states at each step.
 *
 */
@:expose
class Viterbi {
    private var K : Int;
    private var T : Int;
    private var index : Int;
    private var mode : Int;
    private var path_valid : Bool;
    private var best_cost : Float;
    private var cost : SparseSheet<Float>;
    private var src : SparseSheet<Int>;
    private var path : SparseSheet<Int>;

    public function new() : Void {
        K = T = 0;
        reset();
        cost = new SparseSheet<Float>();
        src = new SparseSheet<Int>();
        path = new SparseSheet<Int>();
    }

    /**
     *
     * Reset the state to its initial value.
     *
     */
    public function reset() : Void {
        index = 0;
        mode = 0;
        path_valid = false;
        best_cost = 0;
    }

    /**
     *
     * Configure the maximum number of states and the maximum sequence
     * length that we care about.
     * @param states maximum number of states
     * @param sequence_length maximum sequence length
     *
     */
    public function setSize(states: Int, sequence_length: Int) : Void {
        K = states;
        T = sequence_length;
        cost.resize(K,T,0);
        src.resize(K,T,-1);
        path.resize(1,T,-1);
    }

    private function assertMode(next: Int) : Void {
        if (next==0&&mode==1) index++;
        mode = next;
    }

    /**
     *
     * For the current step in the sequence, we assert that
     * transitioning from state `s0` to state `s1` would cost `c`.
     *
     */
    public function addTransition(s0: Int, s1: Int, c: Float) : Void {
        var resize : Bool = false;
        if (s0>=K) {
            K = s0+1;
            resize = true;
        }
        if (s1>=K) {
            K = s1+1;
            resize = true;
        }
        if (resize) {
            cost.nonDestructiveResize(K,T,0);
            src.nonDestructiveResize(K,T,-1);
            path.nonDestructiveResize(1,T,-1);
        }
        path_valid = false;
        assertMode(1);
        if (index>=T) {
            T=index+1;
            cost.nonDestructiveResize(K,T,0);
            src.nonDestructiveResize(K,T,-1);
            path.nonDestructiveResize(1,T,-1);
        }
        var sourced : Bool = false;
        if (index>0) {
            c += cost.get(s0,index-1);
            sourced = (src.get(s0,index-1)!=-1);
        } else {
            sourced = true;
        }
  
        if (sourced) {
            if (c<cost.get(s1,index)||src.get(s1,index)==-1) {
                cost.set(s1,index,c);
                src.set(s1,index,s0);
            }
        }
    }

    /**
     *
     * Declare that we are finished asserting possible state transitions
     * for the current step in the sequence.  After this, we either
     * call `beginTransitions` again for the next step, or call
     * `calculatePath`.
     *
     */
    public function endTransitions() : Void {
        path_valid = false;
        assertMode(0);
    }

    /**
     *
     * Begin one individual step in the sequence.
     * After this, we call `addTransition` for every possible state
     * transition, and then `endTransitions`.
     * Then we repeat the cycle for the next step in the sequence,
     * or call `calculatePath`.
     *
     */
    public function beginTransitions() : Void {
        path_valid = false;
        assertMode(1);
    }

    /**
     *
     * Compute the best state sequence.
     *
     */
    public function calculatePath() : Void {
        if (path_valid) return;
        endTransitions();
        var best : Float = 0;
        var bestj : Int = -1;
        if (index<=0) {
            // declare victory and exit
            path_valid = true;
            return;
        }
        for (j in 0...K) {
            if ((cost.get(j,index-1)<best||bestj==-1)&&
                src.get(j,index-1)!=-1) {
                best = cost.get(j,index-1);
                bestj = j;
            }
        }
        best_cost = best;
     
        for (j in 0...index) {
            var i : Int = index-1-j;
            path.set(0,i,bestj);
            if (!(bestj!=-1 && (bestj>=0&&bestj<K))) {
                trace("Problem in Viterbi");
            }
            bestj = src.get(bestj,i);
        }
        path_valid = true;
    }

    /**
     *
     * @return the optimal state sequence as a string
     *
     */
    public function toString() : String {
        calculatePath();
        var txt : String = "";
        for (i in 0...index) {
            if (path.get(0,i)==-1) {
                txt += "*";
            } else {
                txt += path.get(0,i);
            }
            if (K>=10) txt += " ";
        }
        txt += " costs " + getCost();
        return txt;
    }

    /**
     *
     * @return the length of the optimal state sequence
     *
     */
    public function length() : Int {
        if (index>0) {
            calculatePath();
        }
        return index;
    }

    /**
     *
     * @param the step in the sequence
     * @return the optimal state for that step
     *
     */
    public function get(i : Int) : Int {
        calculatePath();
        return path.get(0,i);
    }

    /**
     *
     * @return the total cost of the optimal state sequence
     *
     */
    public function getCost() : Float {
        calculatePath();
        return best_cost;
    }
}

