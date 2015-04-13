// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * Represent a change to a single property.
 *
 */
class PropertyChange {
    /**
     *
     * The original name of the property. If null, the property
     * is to be created (if possible).
     *
     */
    public var prevName : String;

    /**
     *
     * The new name of the property. If null, the property
     * is to be destroyed (if possible).
     *
     */
    public var name : String;

    /**
     *
     * The value of the property.
     *
     */
    public var val : Dynamic;

    /**
     *
     *
     * Constructor.
     *
     */
    public function new() {}
}
