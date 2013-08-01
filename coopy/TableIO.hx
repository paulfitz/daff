// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

package coopy;

@:expose
class TableIO {
    public function new() {
    }

    public function getContent(name: String) : String {
#if (cpp && !coopyhx_library)
        return sys.io.File.getContent(name);
#else
        return "";
#end
    }

    public function saveContent(name: String, txt: String) : Bool {
#if (cpp && !coopyhx_library)
        sys.io.File.saveContent(name,txt);
        return true;
#else
        return false;
#end
    }

    public function args() : Array<String> {
#if (cpp && !coopyhx_library)
        return Sys.args();
#else
        return [];
#end
    }

    public function writeStdout(txt: String) : Void {
#if (cpp && !coopyhx_library)
        Sys.stdout().writeString(txt);
#end
    }

    public function writeStderr(txt: String) : Void {
#if (cpp && !coopyhx_library)
        Sys.stderr().writeString(txt);
#end
    }
}

