// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Summarize the changes in a diff of a pair of tables
 *
 */
@:expose
class DiffSummary {
    public var row_deletes : Int;
    public var row_inserts : Int;
    public var row_updates : Int;
    public var row_reorders : Int;

    public var col_deletes : Int;
    public var col_inserts : Int;
    public var col_updates : Int;
    public var col_renames : Int;
    public var col_reorders : Int;

    public var row_count_initial_with_header : Int;
    public var row_count_final_with_header : Int;
    public var row_count_initial : Int;
    public var row_count_final : Int;
    public var col_count_initial : Int;
    public var col_count_final : Int;

    public var different : Bool;

    public function new() {
    }
}
