// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Hooks to allow customization of how cells in a diff are represented.
 * For example, normally a modified cell is represented as a string
 * of the form `version1->version2`, but you might prefer to represent
 * it as a hash `{before: 'version1', after: 'version2'}`.  If so,
 * you'd just need to override the `update` method here.  Then call
 * `TableDiff.setCellBuilder` before generating your diff.
 *
 */
interface CellBuilder {

    /**
     *
     * Regular diffs make use of separators of the form "->" or "-->"
     * or "--->" or ... that is chosen so as to not collide with any
     * actual text in the tables being compared.  This method gives
     * you a chance to say you don't need that, saving some cycles.
     *
     * @return true if a standard unique separator should be computed
     *
     */
    function needSeparator() : Bool;

    /**
     *
     * This method will be called with an appropriate separator
     * for cell updates, if `needSeparator` returns true.
     *
     * @param separator a unique string that is not present in the 
     * tables being compared, suitable for use in representing cell
     * updates.
     *
     */
    function setSeparator(separator: String) : Void;

    /**
     *
     * This method will be called with an appropriate separator
     * for cell conflicts, if `needSeparator` returns true.
     *
     * @param separator a unique string that is not present in the 
     * tables being compared, suitable for use in representing cell
     * conflicts.
     *
     */
    function setConflictSeparator(separator: String) : Void;

    /**
     *
     * This method is called with a helper for interpreting the contents
     * of cells.  It is prepared by calling `getCellView` on one of 
     * the tables.
     *
     * @param view a helper for interpreting cell contents (e.g. converting
     * them to a string)
     *
     */
    function setView(view: View) : Void;

    /**
     *
     * Build a cell that represents a change from `local` to `remote`
     *
     * @param local the value of the cell before an update
     * @param remote the value of the cell after an update
     *
     * @return a cell representing an update
     *
     */
    function update(local: Dynamic, remote: Dynamic) : Dynamic;

    /**
     *
     * Build a cell that represents a conflicting change, where a
     * cell changed from `parent` to `local` in one table, and
     * from `parent` to `remote` in another.
     *
     * @param parent the value of the cell before any update
     * @param local the value of the cell after an update locally
     * @param remote the value of the cell after an update remotely
     *
     * @return a cell representing a conflict
     *
     */
    function conflict(parent: Dynamic, local: Dynamic, remote: Dynamic) : Dynamic;

    /**
     *
     * Create a cell representing one of the many tags used in 
     * data diffs.
     *
     * @param label the desired tag
     *
     * @return a cell representing that tag
     *
     */
    function marker(label: String) : Dynamic;

    /**
     *
     * Create a cell representing the numeric relationship between rows/columns
     *
     * @param unit the desired relationship, in terms of a local row/column number, a remote row/column number and when present a parent row/column number
     *
     * @param row_like true if working with rows, false if working with columns
     *
     * @return a cell representing the numeric relationship between a row/column
     *
     */
    function links(unit: Unit, row_like: Bool) : Dynamic;
}
