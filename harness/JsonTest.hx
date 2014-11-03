// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package harness;

class JsonTest extends haxe.unit.TestCase {
    public function testJsonOut(){
        // Make sure haxe json is correctly configured
        var j = new Map<String,Dynamic>();
        j.set("a",1);
        j.set("b",2);
        var txt = haxe.Json.stringify(j);
        assertTrue(txt=="{\"a\":1,\"b\":2}" || txt=="{\"b\":2,\"a\":1}");
    }

    public function testNdjsonOut(){
        var t = Native.table([["a","b"],[1,2]]);
        var txt = new coopy.Ndjson(t).renderRow(1);
        assertTrue(txt=="{\"a\":1,\"b\":2}" || txt=="{\"b\":2,\"a\":1}");
    }

    public function testNdjsonInOneRow(){
        var t = Native.table([]);
        new coopy.Ndjson(t).parse("{\"a\":1,\"b\":2}");
        var ca = (t.getCell(0,0) == "a") ? 0 : 1;
        var cb = 1-ca;
        assertEquals("a",t.getCell(ca,0));
        assertEquals("b",t.getCell(cb,0));
        assertEquals(1,t.getCell(ca,1));
        assertEquals(2,t.getCell(cb,1));
    }

    public function testNdjsonIn(){
        var t = Native.table([]);
        new coopy.Ndjson(t).parse("{\"a\":1,\"b\":2}\n{\"a\":11,\"b\":22}\r\n{\"a\":111,\"b\":222}\n");
        var ca = (t.getCell(0,0) == "a") ? 0 : 1;
        var cb = 1-ca;
        assertEquals("a",t.getCell(ca,0));
        assertEquals("b",t.getCell(cb,0));
        assertEquals(1,t.getCell(ca,1));
        assertEquals(2,t.getCell(cb,1));
        assertEquals(11,t.getCell(ca,2));
        assertEquals(22,t.getCell(cb,2));
        assertEquals(111,t.getCell(ca,3));
        assertEquals(222,t.getCell(cb,3));
    }

    public function testNdjsonLoop(){
        var t = Native.table([]);
        new coopy.Ndjson(t).parse("{\"a\":1,\"b\":2}\n{\"a\":11,\"b\":22}\r\n{\"a\":111,\"b\":222}\n");
        var txt = new coopy.Ndjson(t).render();
        var t2 = Native.table([]);
        new coopy.Ndjson(t2).parse(txt);
        var ca = (t.getCell(0,0) == "a") ? 0 : 1;
        var cb = 1-ca;
        assertEquals("a",t.getCell(ca,0));
        assertEquals("b",t.getCell(cb,0));
        assertEquals(1,t.getCell(ca,1));
        assertEquals(2,t.getCell(cb,1));
        assertEquals(11,t.getCell(ca,2));
        assertEquals(22,t.getCell(cb,2));
        assertEquals(111,t.getCell(ca,3));
        assertEquals(222,t.getCell(cb,3));
    }
}
