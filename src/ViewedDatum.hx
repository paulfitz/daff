// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

class ViewedDatum {
    public var datum : Datum;
    public var view : View;

    public function new(datum: Datum, view: View) : Void {
        this.datum = datum;
        this.view = view;
    }

    public static function getSimpleView(datum: Datum) : ViewedDatum {
        return new ViewedDatum(datum,
                               new SimpleView());
    }

    public function toString() : String {
        return view.toString(datum);
    }

    public function getBag() : Bag {
        return view.getBag(datum);
    }

    public function getTable() : Table {
        return view.getTable(datum);
    }

    public function hasStructure() : Bool {
        return view.hasStructure(datum);
    }
}