// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

@:expose
class Coopy {
    static public var VERSION = "1.1.17";

    private var format_preference : String;
    private var delim_preference : String;
    private var extern_preference : Bool;
    private var output_format : String;
    private var io : TableIO;

    // just to get code included
    private var mv : Mover;

    public function new() : Void {
        extern_preference = false;
        format_preference = null;
        delim_preference = null;
        output_format = "copy";
    }

    static public function compareTables(local: Table, remote: Table, ?flags: CompareFlags) : CompareTable {
        var ct: CompareTable = new CompareTable();
        var comp : TableComparisonState = new TableComparisonState();
        comp.a = local;
        comp.b = remote;
        comp.compare_flags = flags;
        ct.attach(comp);
        return ct;
    }

    static public function compareTables3(parent: Table, local: Table, remote: Table, ?flags: CompareFlags) : CompareTable {
        var ct: CompareTable = new CompareTable();
        var comp : TableComparisonState = new TableComparisonState();
        comp.p = parent;
        comp.a = local;
        comp.b = remote;
        comp.compare_flags = flags;
        ct.attach(comp);
        return ct;
    }

    static private  function randomTests() : Int {
        // disorganized tests from a bygone era.

        var st : SimpleTable = new SimpleTable(15,6);
        var tab : Table = st;
        trace("table size is " + tab.width + "x" + tab.height);
        tab.setCell(3,4,new SimpleCell(33));
        trace("element is " + tab.getCell(3,4));

        var compare : Compare = new Compare();
        var d1 : ViewedDatum = ViewedDatum.getSimpleView(new SimpleCell(10));
        var d2 : ViewedDatum = ViewedDatum.getSimpleView(new SimpleCell(10));
        var d3 : ViewedDatum = ViewedDatum.getSimpleView(new SimpleCell(20));
        var report : Report = new Report();
        compare.compare(d1,d2,d3,report);
        trace("report is " + report);
        d2 = ViewedDatum.getSimpleView(new SimpleCell(50));
        report.clear();
        compare.compare(d1,d2,d3,report);
        trace("report is " + report);
        d2 = ViewedDatum.getSimpleView(new SimpleCell(20));
        report.clear();
        compare.compare(d1,d2,d3,report);
        trace("report is " + report);
        d1 = ViewedDatum.getSimpleView(new SimpleCell(20));
        report.clear();
        compare.compare(d1,d2,d3,report);
        trace("report is " + report);

        var comp : TableComparisonState = new TableComparisonState();
        var ct : CompareTable = new CompareTable();
        comp.a = st;
        comp.b = st;
        ct.attach(comp);

        trace("comparing tables");
        var t1 : SimpleTable = new SimpleTable(3,2);
        var t2 : SimpleTable = new SimpleTable(3,2);
        var t3 : SimpleTable = new SimpleTable(3,2);
        var dt1 : ViewedDatum = new ViewedDatum(t1,new SimpleView());
        var dt2 : ViewedDatum = new ViewedDatum(t2,new SimpleView());
        var dt3 : ViewedDatum = new ViewedDatum(t3,new SimpleView());
        compare.compare(dt1,dt2,dt3,report);
        trace("report is " + report);
        t3.setCell(1,1,new SimpleCell("hello"));
        compare.compare(dt1,dt2,dt3,report);
        trace("report is " + report);
        t1.setCell(1,1,new SimpleCell("hello"));
        compare.compare(dt1,dt2,dt3,report);
        trace("report is " + report);

        var v : Viterbi = new Viterbi();
        var td : TableDiff = new TableDiff(null,null);
        var idx : Index = new Index();
        var dr : DiffRender = new DiffRender();
        var cf : CompareFlags = new CompareFlags();
        var hp : HighlightPatch = new HighlightPatch(null,null);
        var csv : Csv = new Csv();
        var tm : TableModifier = new TableModifier(null);

        return 0;
    }

#if !coopyhx_library

    private function checkFormat(name: String) : String {
        if (extern_preference) {
            return format_preference;
        }
        var ext = "";
        var pt = name.lastIndexOf(".");
        if (pt>=0) {
            ext = name.substr(pt+1).toLowerCase();
            switch(ext) {
            case "json":
                format_preference = "json";
            case "csv":
                format_preference = "csv";
                delim_preference = ",";
            case "tsv":
                format_preference = "csv";
                delim_preference = "\t";
            case "ssv":
                format_preference = "csv";
                delim_preference = ";";
            default:
                ext = "";
            }
        }
        return ext;
    }

    private function setFormat(name: String) : Void {
        extern_preference = false;
        checkFormat("." + name);
        extern_preference = true;
    }

    private function saveTable(name: String, t: Table) : Bool {
        if (output_format!="copy") {
            setFormat(output_format);
        }
        var txt : String = "";
        checkFormat(name);
        if (format_preference!="json") {
            var csv : Csv = new Csv(delim_preference);
            txt = csv.renderTable(t);
        } else {
            txt = haxe.Json.stringify(jsonify(t));
        }
        return saveText(name,txt);
    }

    private function saveText(name: String, txt: String) : Bool {
        if (name!="-") {
            io.saveContent(name,txt);
        } else {
            io.writeStdout(txt);
        }
        return true;        
    }

    private static function cellFor(x: Dynamic) : Dynamic {
        if (x==null) return null;
        return new SimpleCell(x);
    }

    private static function jsonToTable(json: Dynamic) : Table {
        var output : Table = null;
        for (name in Reflect.fields(json)) {
            var t = Reflect.field(json,name);
            var columns : Array<String> = Reflect.field(t,"columns");
            if (columns==null) continue;
            var rows : Array<Dynamic> = Reflect.field(t,"rows");
            if (rows==null) continue;
            output = new SimpleTable(columns.length,rows.length);
            var has_hash : Bool = false;
            var has_hash_known : Bool = false;
            for (i in 0...rows.length) {
                var row = rows[i];
                if (!has_hash_known) {
                    if (Reflect.fields(row).length == columns.length) {
                        has_hash = true;
                    }
                    has_hash_known = true;
                }
                if (!has_hash) {
                    var lst : Array<Dynamic> = cast row;
                    for (j in 0...columns.length) {
                        var val = lst[j];
                        output.setCell(j,i,cellFor(val));
                    }
                } else {
                    for (j in 0...columns.length) {
                        var val = Reflect.field(row,columns[j]);
                        output.setCell(j,i,cellFor(val));
                    }
                }
            }
        }
        if (output!=null) output.trimBlank();
        return output;
    }

    private function loadTable(name: String) : Table {
        var txt : String = io.getContent(name);
        var ext = checkFormat(name);
        if (ext == "json" || ext == "") {
            try {
                var json = haxe.Json.parse(txt);
                format_preference = "json";
                var t : Table = jsonToTable(json);
                if (t==null) throw "JSON failed";
                return t;
            } catch (e: Dynamic) {
                if (ext == "json") throw e;
            }
        }
        format_preference = "csv";
        var csv : Csv = new Csv(delim_preference);
        var data : Array<Array<String>> = csv.parseTable(txt);
        var h : Int = data.length;
        var w : Int = 0;
        if (h>0) w = data[0].length;
        var output = new SimpleTable(w,h);
        for (i in 0...h) {
            for (j in 0...w) {
                var val : String = data[i][j];
                output.setCell(j,i,cellFor(val));
            }
        }
        if (output!=null) output.trimBlank();
        return output;
    }

    private var status : Map<String,Int>;
    private var daff_cmd : String;

    private function command(io: TableIO, cmd: String, args: Array<String>) : Int {
        var r = 0;
        if (io.async()) r = io.command(cmd,args);
        if (r!=999) {
            io.writeStdout("$ " + cmd);
            for (arg in args) {
                io.writeStdout(" ");
                var spaced = arg.indexOf(" ")>=0;
                if (spaced) io.writeStdout("\"");
                io.writeStdout(arg);
                if (spaced) io.writeStdout("\"");
            }
            io.writeStdout("\n");
        }
        if (!io.async()) r = io.command(cmd,args);
        return r;
    }

    public function installGitDriver(io: TableIO, formats: Array<String>) : Int {
        var r = 0;

        if (status==null) {
            status = new Map<String,Int>();
            daff_cmd = "";
        }

        var key = "hello";
        if (!status.exists(key)) {
            io.writeStdout("Setting up git to use daff on");
            for (format in formats) {
                io.writeStdout(" *." + format);
            }
            io.writeStdout(" files\n");
            status.set(key,r);
        }

        key = "can_run_git";
        if (!status.exists(key)) {
            r = command(io,"git",["--version"]);
            if (r==999) return r;
            status.set(key,r);
            if (r!=0) {
                io.writeStderr("! Cannot run git, aborting\n");
                return 1;
            }
            io.writeStdout("- Can run git\n");
        }

        var daffs = ["daff","daff.rb","daff.py"];
        if (daff_cmd == "") {
            for (daff in daffs) {
                var key = "can_run_" + daff;
                if (!status.exists(key)) {
                    r = command(io,daff,["version"]);
                    if (r==999) return r;
                    status.set(key,r);
                    if (r==0) {
                        daff_cmd = daff;
                        io.writeStdout("- Can run " + daff + " as \"" + daff + "\"\n");
                        break;
                    }
                }
            }
            if (daff_cmd=="") {
                io.writeStderr("! Cannot find daff, is it in your path?\n");
                return 1;
            }
        }


        for (format in formats) {

            key = "have_diff_driver_" + format;
            if (!status.exists(key)) {
                r = command(io,"git",["config","--global","--get","diff.daff-" + format + ".command"]);
                if (r==999) return r;
                status.set(key,r);
            }
            
            var have_diff_driver = status.get(key)==0;

            key = "add_diff_driver_" + format;
            if (!status.exists(key)) {
                if (!have_diff_driver) {
                    r = command(io,"git",["config","--global","diff.daff-" + format + ".command",daff_cmd + " diff --color --git"]);
                    if (r==999) return r;
                    io.writeStdout("- Added diff driver for " + format + "\n");
                } else {
                    r = 0;
                    io.writeStdout("- Already have diff driver for " + format + ", not touching it\n");
                }
                status.set(key,r);
            }

            key = "have_merge_driver_" + format;
            if (!status.exists(key)) {
                r = command(io,"git",["config","--global","--get","merge.daff-" + format + ".driver"]);
                if (r==999) return r;
                status.set(key,r);
            }
            
            var have_merge_driver = status.get(key)==0;

            key = "name_merge_driver_" + format;
            if (!status.exists(key)) {
                if (!have_merge_driver) {
                    r = command(io,"git",["config","--global","merge.daff-" + format + ".name","daff tabular " + format + " merge"]);
                    if (r==999) return r;
                } else {
                    r = 0;
                }
                status.set(key,r);
            }

            key = "add_merge_driver_" + format;
            if (!status.exists(key)) {
                if (!have_merge_driver) {
                    r = command(io,"git",["config","--global","merge.daff-" + format + ".driver",daff_cmd + " merge --output %A %O %A %B"]);
                    if (r==999) return r;
                    io.writeStdout("- Added merge driver for " + format + "\n");
                } else {
                    r = 0;
                    io.writeStdout("- Already have merge driver for " + format + ", not touching it\n");
                }
                status.set(key,r);
            }
        }

        if (!io.exists(".git/config")) {
            io.writeStderr("! This next part needs to happen in a git repository.\n");
            io.writeStderr("! Please run again from the root of a git repository.\n");
            return 1;
        }
            
        var attr = ".gitattributes";
        var txt = "";
        var post = "";
        if (!io.exists(attr)) {
            io.writeStdout("- No .gitattributes file\n");
        } else {
            io.writeStdout("- You have a .gitattributes file\n");
            txt = io.getContent(attr);
        }

        var need_update = false;
        for (format in formats) {
            if (txt.indexOf("*." + format)>=0) {
                io.writeStderr("- Your .gitattributes file already mentions *." + format + "\n");
            } else {
                post += "*." + format + " diff=daff-" + format + "\n";
                post += "*." + format + " merge=daff-" + format + "\n";
                io.writeStdout("- Placing the following lines in .gitattributes:\n");
                io.writeStdout(post);
                if (txt!=""&&!need_update) txt += "\n";
                txt += post;
                need_update = true;
            }
        }
        if (need_update) io.saveContent(attr,txt);

        io.writeStdout("- Done!\n");

        return 0;
    }

    public function coopyhx(io: TableIO) : Int {
        var args : Array<String> = io.args();

        if (args[0] == "--test") {
            return randomTests();
        }

        var more : Bool = true;
        var output : String = null;
        var css_output : String = null;
        var fragment : Bool = false;
        var pretty : Bool = true;
        var inplace : Bool = false;
        var git : Bool = false;
        var color : Bool = false;

        var flags : CompareFlags = new CompareFlags();
        flags.always_show_header = true;

        while (more) {
            more = false;
            for (i in 0...args.length) {
                var tag : String = args[i];
                if (tag=="--output") {
                    more = true;
                    output = args[i+1];
                    args.splice(i,2);
                    break;
                } else if (tag=="--css") {
                    more = true;
                    fragment = true;
                    css_output = args[i+1];
                    args.splice(i,2);
                    break;
                } else if (tag=="--fragment") {
                    more = true;
                    fragment = true;
                    args.splice(i,1);
                    break;
                } else if (tag=="--plain") {
                    more = true;
                    pretty = false;
                    args.splice(i,1);
                    break;
                } else if (tag=="--all") {
                    more = true;
                    flags.show_unchanged = true;
                    args.splice(i,1);
                    break;
                } else if (tag=="--act") {
                    more = true;
                    if (flags.acts == null) {
                        flags.acts = new Map<String, Bool>();
                    }
                    flags.acts[args[i+1]] = true;
                    args.splice(i,2);
                    break;
                } else if (tag=="--context") {
                    more = true;
                    var context : Int = Std.parseInt(args[i+1]);
                    if (context>=0) flags.unchanged_context = context;
                    args.splice(i,2);
                    break;
                } else if (tag=="--inplace") {
                    more = true;
                    inplace = true;
                    args.splice(i,1);
                    break;
                } else if (tag=="--git") {
                    more = true;
                    git = true;
                    args.splice(i,1);
                    break;
                } else if (tag=="--color") {
                    more = true;
                    color = true;
                    args.splice(i,1);
                    break;
                } else if (tag=="--input-format") {
                    more = true;
                    setFormat(args[i+1]);
                    args.splice(i,2);
                    break;
                } else if (tag=="--output-format") {
                    more = true;
                    output_format = args[i+1];
                    args.splice(i,2);
                    break;
                } else if (tag=="--id") {
                    more = true;
                    if (flags.ids == null) {
                        flags.ids = new Array<String>();
                    }
                    flags.ids.push(args[i+1]);
                    args.splice(i,2);
                    break;
                } else if (tag=="--ignore") {
                    more = true;
                    if (flags.columns_to_ignore == null) {
                        flags.columns_to_ignore = new Array<String>();
                    }
                    flags.columns_to_ignore.push(args[i+1]);
                    args.splice(i,2);
                    break;
                } else if (tag=="--index") {
                    more = true;
                    flags.always_show_order = true;
                    flags.never_show_order = false;
                    args.splice(i,1);
                    break;
                }
            }
        }

        var cmd : String = args[0];
        
        if (args.length < 2) {
            if (cmd == "version") {
                io.writeStdout(VERSION + "\n");
                return 0;
            }
            if (cmd == "git") {
                io.writeStdout("You can use daff to improve git's handling of csv files, by using it as a\ndiff driver (for showing what has changed) and as a merge driver (for merging\nchanges between multiple versions).\n");
                io.writeStdout("\n");
                io.writeStdout("Automatic setup\n");
                io.writeStdout("---------------\n\n");
                io.writeStdout("Run:\n");
                io.writeStdout("  daff git csv\n");
                io.writeStdout("\n");
                io.writeStdout("Manual setup\n");
                io.writeStdout("------------\n\n");
                io.writeStdout("Create and add a file called .gitattributes in the root directory of your\nrepository, containing:\n\n");
                io.writeStdout("  *.csv diff=daff-csv\n");
                io.writeStdout("  *.csv merge=daff-csv\n");
                io.writeStdout("\nCreate a file called .gitconfig in your home directory (or alternatively\nopen .git/config for a particular repository) and add:\n\n");
                io.writeStdout("  [diff \"daff-csv\"]\n");
                io.writeStdout("  command = daff diff --color --git\n");
                io.writeStderr("\n");
                io.writeStdout("  [merge \"daff-csv\"]\n");
                io.writeStdout("  name = daff tabular merge\n");
                io.writeStdout("  driver = daff merge --output %A %O %A %B\n\n");
                
                io.writeStderr("Make sure you can run daff from the command-line as just \"daff\" - if not,\nreplace \"daff\" in the driver and command lines above with the correct way\nto call it. Omit --color if your terminal does not support ANSI colors.");
                io.writeStderr("\n");
                return 0;
            }
            io.writeStderr("daff can produce and apply tabular diffs.\n");
            io.writeStderr("Call as:\n");
            io.writeStderr("  daff [--color] [--output OUTPUT.csv] a.csv b.csv\n");
            io.writeStderr("  daff [--output OUTPUT.csv] parent.csv a.csv b.csv\n");
            io.writeStderr("  daff [--output OUTPUT.jsonbook] a.jsonbook b.jsonbook\n");
            io.writeStderr("  daff patch [--inplace] [--output OUTPUT.csv] a.csv patch.csv\n");
            io.writeStderr("  daff merge [--inplace] [--output OUTPUT.csv] parent.csv a.csv b.csv\n");
            io.writeStderr("  daff trim [--output OUTPUT.csv] source.csv\n");
            io.writeStderr("  daff render [--output OUTPUT.html] diff.csv\n");
            io.writeStderr("  daff copy in.csv out.tsv\n");
            io.writeStderr("  daff git\n");
            io.writeStderr("  daff version\n");
            io.writeStderr("\n");
            io.writeStderr("The --inplace option to patch and merge will result in modification of a.csv.\n");
            io.writeStderr("\n");
            io.writeStderr("If you need more control, here is the full list of flags:\n");
            io.writeStderr("  daff diff [--output OUTPUT.csv] [--context NUM] [--all] [--act ACT] a.csv b.csv\n");
            io.writeStderr("     --id:          specify column to use as primary key (repeat for multi-column key)\n");
            io.writeStderr("     --ignore:      specify column to ignore completely (can repeat)\n");
            io.writeStderr("     --color:       highlight changes with terminal colors\n");
            io.writeStderr("     --context NUM: show NUM rows of context\n");
            io.writeStderr("     --all:         do not prune unchanged rows\n");
            io.writeStderr("     --act ACT:     show only a certain kind of change (update, insert, delete)\n");
            io.writeStderr("     --input-format [csv|tsv|ssv|json]: set format to expect for input\n");
            io.writeStderr("     --output-format [csv|tsv|ssv|json|copy]: set format for output\n");
            io.writeStderr("\n");
            io.writeStderr("  daff diff --git path old-file old-hex old-mode new-file new-hex new-mode\n");
            io.writeStderr("     --git:         process arguments provided by git to diff drivers\n");
            io.writeStderr("     --index:       include row/columns numbers from orginal tables\n");
            io.writeStderr("\n");
            io.writeStderr("  daff render [--output OUTPUT.html] [--css CSS.css] [--fragment] [--plain] diff.csv\n");
            io.writeStderr("     --css CSS.css: generate a suitable css file to go with the html\n");
            io.writeStderr("     --fragment:    generate just a html fragment rather than a page\n");
            io.writeStderr("     --plain:       do not use fancy utf8 characters to make arrows prettier\n");
            return 1;
        }
        var cmd : String = args[0];
        var offset : Int = 1;
        // "diff" is optional when followed by a filename with a dot in it,
        // or by an --option.
        if (!Lambda.has(["diff","patch","merge","trim","render","git","version","copy"],cmd)) {
            if (cmd.indexOf(".")!=-1 || cmd.indexOf("--")==0) {
                cmd = "diff";
                offset = 0;
            }
        }
        if (cmd == "git") {
            var types = args.splice(offset,args.length-offset);
            return installGitDriver(io,types);
        }
        if (git) {
            var ct = args.length-offset;
            if (ct!=7) {
                io.writeStderr("Expected 7 parameters from git, but got " + ct + "\n");
                return 1;
            }
            var git_args = args.splice(offset,ct);
            args.splice(0,args.length);
            offset = 0;
            var path = git_args[0];
            var old_file = git_args[1];
            var new_file = git_args[4];
            io.writeStdout("--- a/" + path + "\n");
            io.writeStdout("+++ b/" + path + "\n");
            args.push(old_file);
            args.push(new_file);
        }
        var tool : Coopy = this;
        tool.io = io;
        var parent = null;
        if (args.length-offset>=3) {
            parent = tool.loadTable(args[offset]);
            offset++;
        }
        var aname = args[0+offset];
        var a = tool.loadTable(aname);
        var b = null;
        if (args.length-offset>=2) {
            if (cmd!="copy") {
                b = tool.loadTable(args[1+offset]);
            } else {
                output = args[1+offset];
            }
        }

        if (inplace) {
            if (output!=null) {
                io.writeStderr("Please do not use --inplace when specifying an output.\n");
            }
            output = aname;
            return 1;
        }

        if (output == null) {
            output = "-";
        }

        var ok : Bool = true;
        if (cmd=="diff") {
            var ct : CompareTable = compareTables3(parent,a,b,flags);
            var align : Alignment = ct.align();
            var td : TableDiff = new TableDiff(align,flags);
            var o = new SimpleTable(0,0);
            td.hilite(o);
            if (color) {
                var render = new TerminalDiffRender();
                tool.saveText(output,render.render(o));
            } else {
                tool.saveTable(output,o);
            }
        } else if (cmd=="patch") {
            var patcher : HighlightPatch = new HighlightPatch(a,b);
            patcher.apply();
            tool.saveTable(output,a);
        } else if (cmd=="merge") {
            var merger : Merger = new Merger(parent,a,b,flags);
            var conflicts = merger.apply();
            ok = (conflicts==0);
            if (conflicts>0) {
                io.writeStderr(conflicts + " conflict" + ((conflicts>1)?"s":"") + "\n");
            }
            tool.saveTable(output,a);
        } else if (cmd=="trim") {
            tool.saveTable(output,a);
        } else if (cmd=="render") {
            var renderer : DiffRender = new DiffRender();
            renderer.usePrettyArrows(pretty);
            renderer.render(a);
            if (!fragment) {
                renderer.completeHtml();
            }
            tool.saveText(output,renderer.html());
            if (css_output!=null) {
                tool.saveText(css_output,renderer.sampleCss());
            }
        } else if (cmd=="copy") {
            tool.saveTable(output,a);
        }
        return ok?0:1;
    }
#end

    public static function main() : Int {
#if coopyhx_util
    var io = new TableIO();
    var coopy = new Coopy();
    return coopy.coopyhx(io);
#else
    // do nothing
    return 0;
#end
    }

    public static function show(t: Table) : Void {
        var w : Int = t.width;
        var h : Int = t.height;
        var txt : String = "";
        for (y in 0...h) {
            for (x in 0...w) {
                txt += t.getCell(x,y);
                txt += " ";
            }
            txt += "\n";
        }
        trace(txt);
    }


    public static function jsonify(t: Table) : Dynamic {
        var workbook : Map<String,Dynamic> = new Map<String,Dynamic>();
        var sheet : Array<Array<Dynamic>> = new Array<Array<Dynamic>>();
        var w : Int = t.width;
        var h : Int = t.height;
        var txt : String = "";
        for (y in 0...h) {
            var row : Array<Dynamic> = new Array<Dynamic>();
            for (x in 0...w) {
                var v = t.getCell(x,y);
                if (v!=null) {
                    row.push(v.toString());
                } else {
                    row.push(null);
                }
            }
            sheet.push(row);
        }
        workbook.set("sheet",sheet);
        return workbook;
    }
}
