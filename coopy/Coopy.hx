// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * This is the main entry-point to the library and the associated
 * command-line tool.
 *
 */
@:expose
class Coopy {
    /**
     *
     * Library version.
     *
     */
    static public var VERSION = "1.3.48";

    private var format_preference : String;
    private var delim_preference : String;
    private var csv_eol_preference : String;
    private var extern_preference : Bool;
    private var output_format : String;
    private var output_format_set : Bool;
    private var nested_output : Bool;
    private var order_set : Bool;
    private var order_preference : Bool;
    private var io : TableIO;
    private var strategy : String;
    private var css_output : String;
    private var fragment : Bool;
    private var flags : CompareFlags;
    private var cache_txt : String;
    private var fail_if_diff : Bool;
    private var diffs_found : Bool;

    // just to get code included
    private var mv : Mover;

    public function new(io: TableIO = null) : Void {
        init();
        this.io = io;
    }

    private function init() : Void {
        extern_preference = false;
        format_preference = null;
        delim_preference = null;
        csv_eol_preference = null;
        output_format = "copy";
        output_format_set = false;
        nested_output = false;
        order_set = false;
        order_preference = false;
        strategy = null;
        css_output = null;
        fragment = false;
        flags = null;
        cache_txt = null;
        fail_if_diff = false;
        diffs_found = false;
    }

    /**
     * Compare two tables and visualize their difference using html
     *
     * @param local the reference version of the table
     * @param remote another version of the table
     * @param flags control how the comparison will be made
     * @return an html string like that produced by `daff --output-format html --fragment a.csv b.csv`
     *
     */
    static public function diffAsHtml(local: Table, remote: Table, ?flags: CompareFlags) : String {
        var comp : TableComparisonState = new TableComparisonState();
        var td : TableDiff = align(local,remote,flags,comp);
        var o : Table = getBlankTable(td,comp);
        if (comp.a!=null) o = comp.a.create();
        if (o==null && comp.b!=null) o = comp.b.create();
        if (o==null) o = new SimpleTable(0,0);
        var os = new Tables(o);
        td.hiliteWithNesting(os);
        var render = new DiffRender();
        return render.renderTables(os).html();
    }

    /**
     * Compare two tables and visualize their difference in text decorated with ansi console codes
     *
     * @param local the reference version of the table
     * @param remote another version of the table
     * @param flags control how the comparison will be made
     * @return a string like that produced by `daff --color a.csv b.csv`
     *
     */
    static public function diffAsAnsi(local: Table, remote: Table, ?flags: CompareFlags) : String {
        var tool = new Coopy(new TableIO());
        tool.cache_txt = "";
        if (flags == null) {
            flags = new CompareFlags();
        }
        tool.output_format = "csv";
        tool.runDiff(flags.parent, local, remote, flags, null);
        return tool.cache_txt;
    }

    /**
     * Compare two tables and visualize their difference as another table
     *
     * @param local the reference version of the table
     * @param remote another version of the table
     * @param flags control how the comparison will be made
     * @return a table like that produced by `daff a.csv b.csv`
     *
     */
    static public function diff(local: Table, remote: Table, ?flags: CompareFlags) : Table {
        var comp : TableComparisonState = new TableComparisonState();
        var td : TableDiff = align(local,remote,flags,comp);
        var o : Table = getBlankTable(td,comp);
        if (comp.a!=null) o = comp.a.create();
        if (o==null && comp.b!=null) o = comp.b.create();
        if (o==null) o = new SimpleTable(0,0);
        td.hilite(o);
        return o;
    }

    static private function getBlankTable(td : TableDiff,
                                          comp: TableComparisonState) : Table {
        var o : Table = null;
        if (comp.a!=null) o = comp.a.create();
        if (o==null && comp.b!=null) o = comp.b.create();
        if (o==null) o = new SimpleTable(0,0);
        return o;
    }

    static private function align(local: Table, remote: Table, flags: CompareFlags,
                                  comp: TableComparisonState) : TableDiff {
        comp.a = tablify(local);
        comp.b = tablify(remote);
        if (flags==null) flags = new CompareFlags();
        comp.compare_flags = flags;
        var ct: CompareTable = new CompareTable(comp);
        var align : Alignment = ct.align();
        var td : TableDiff = new TableDiff(align,flags);
        return td;
    }

    /**
     *
     * Apply a patch to a table.
     *
     * @param local the reference version of the table
     * @param patch the changes to apply (in daff format)
     * @param flags control how the patch operations will be made
     * @return true on success
     *
     */
    static public function patch(local: Table, patch: Table, ?flags: CompareFlags) : Bool {
        var patcher = new HighlightPatch(tablify(local),tablify(patch));
        return patcher.apply();
    }

    /**
     *
     * Prepare to compare two tables.
     *
     * @param local the reference version of the table
     * @param remote another version of the table
     * @param flags control how the comparison will be made
     * @return a worker you can use to make the comparison (normally you'll just want to call `.align()` on it)
     *
     */
    static public function compareTables(local: Table, remote: Table, ?flags: CompareFlags) : CompareTable {
        var comp : TableComparisonState = new TableComparisonState();
        comp.a = tablify(local);
        comp.b = tablify(remote);
        comp.compare_flags = flags;
        var ct: CompareTable = new CompareTable(comp);
        return ct;
    }

    /**
     *
     * Prepare to compare two tables, given knowledge of a common ancester.
     * The comparison will answer: what changes should be made to `local`
     * in order to incorporate the differences between `parent` and `remote`.
     * This is useful if the `local` table has changes in it that you want
     * to preserve.
     *
     * @param parent the common ancestor of the `local` and `remote` tables
     * @param local the reference version of the table
     * @param remote another version of the table
     * @param flags control how the comparison will be made
     * @return a worker you can use to make the comparison (normally you'll just want to call `.align()` on it)
     *
     */
    static public function compareTables3(parent: Table, local: Table, remote: Table, ?flags: CompareFlags) : CompareTable {
        var comp : TableComparisonState = new TableComparisonState();
        comp.p = tablify(parent);
        comp.a = tablify(local);
        comp.b = tablify(remote);
        comp.compare_flags = flags;
        var ct: CompareTable = new CompareTable(comp);
        return ct;
    }

    static private function keepAround() : Int {
        var st : SimpleTable = new SimpleTable(1,1);
        var v : Viterbi = new Viterbi();
        var td : TableDiff = new TableDiff(null,null);
        var cf : CompareFlags = new CompareFlags();
        var idx : Index = new Index(cf);
        var dr : DiffRender = new DiffRender();
        var hp : HighlightPatch = new HighlightPatch(null,null);
        var csv : Csv = new Csv();
        var tm : TableModifier = new TableModifier(null);
        var sc: SqlCompare = new SqlCompare(null,null,null,null,null);
        var sq: SqliteHelper = new SqliteHelper();
        var sm : SimpleMeta = new SimpleMeta(null);
        var ct : CombinedTable = new CombinedTable(null);
        return 0;
    }

#if !coopyhx_library

    private function checkFormat(name: String) : String {
        if (extern_preference) {
            return format_preference;
        }
        var ext = "";
        if (name!=null) {
            var pt = name.lastIndexOf(".");
            if (pt>=0) {
                ext = name.substr(pt+1).toLowerCase();
                switch(ext) {
                case "json":
                    format_preference = "json";
                case "ndjson":
                    format_preference = "ndjson";
                case "csv":
                    format_preference = "csv";
                    delim_preference = ",";
                case "tsv":
                    format_preference = "csv";
                    delim_preference = "\t";
                case "ssv":
                    format_preference = "csv";
                    delim_preference = ";";
					this.format_preference = "csv";
                case "psv":
                    format_preference = "csv";
#if js
                    delim_preference = untyped __js__('String.fromCharCode(0xD83D, 0xDCA9)');
#else
                    delim_preference = String.fromCharCode(0x1F4A9);
#end
                case "sqlite3":
                    format_preference = "sqlite";
                case "sqlite":
                    format_preference = "sqlite";
                case "html", "htm":
                    format_preference = "html";
                case "www":
                    format_preference = "www";
                default:
                    ext = "";
                }
            }
        }
        nested_output = (format_preference=="json"||format_preference=="ndjson");
        order_preference = !nested_output;
        return ext;
    }

    private function setFormat(name: String) : Void {
        extern_preference = false;
        checkFormat("." + name);
        extern_preference = true;
    }

    private function getRenderer() : DiffRender {
        var renderer : DiffRender = new DiffRender();
        renderer.usePrettyArrows(flags.use_glyphs);
        renderer.quoteHtml(flags.quote_html);
        return renderer;
    }

    private function applyRenderer(name: String, renderer: DiffRender) : Bool {
        if (!fragment) {
            renderer.completeHtml();
        }
        if (format_preference=="www") {
            io.sendToBrowser(renderer.html());
        } else {
            saveText(name,renderer.html());
        }
        if (css_output!=null) {
            saveText(css_output,renderer.sampleCss());
        }
        return true;
    }

    private function renderTable(name: String, t: Table) : Bool {
        var renderer : DiffRender = getRenderer();
        renderer.render(t);
        return applyRenderer(name, renderer);
    }

    private function renderTables(name: String, t: Tables) : Bool {
        var renderer : DiffRender = getRenderer();
        renderer.renderTables(t);
        return applyRenderer(name, renderer);
    }

    private function saveTable(name: String, t: Table, render: TerminalDiffRender = null) : Bool {
        var txt = encodeTable(name, t, render);
        if (txt == null) return true;
        return saveText(name,txt);
    }

    private function encodeTable(name: String, t: Table, render: TerminalDiffRender = null) : String {
        if (output_format!="copy") {
            setFormat(output_format);
        }
        var txt : String = "";
        checkFormat(name);
        if (format_preference=="sqlite" && !extern_preference) {
            format_preference = "csv";
        }
        if (render==null) {
            if (format_preference=="csv") {
                var csv : Csv = new Csv(delim_preference, csv_eol_preference);
                txt = csv.renderTable(t);
            } else if (format_preference=="ndjson") {
                txt = new Ndjson(t).render();
            } else if (format_preference=="html"||format_preference=="www") {
                renderTable(name,t);
                return null;
                // cannot handle multi-table output yet
            } else if (format_preference=="sqlite") {
                io.writeStderr("! Cannot yet output to sqlite, aborting\n");
                return "";
            } else {
                txt = haxe.Json.stringify(jsonify(t),null,"  ");
            }
        } else{
            txt = render.render(t);
        }
        return txt;
    }

    private function saveTables(name: String, os: Tables, use_color: Bool, is_diff: Bool) : Bool {
        if (output_format!="copy") {
            setFormat(output_format);
        }
        var txt : String = "";
        checkFormat(name);
        var render : TerminalDiffRender = null;
        if (use_color) render = new TerminalDiffRender(flags, delim_preference, is_diff);

        var order = os.getOrder();
        if (order.length==1) {
            return saveTable(name,os.one(),render);
        }
        if (format_preference=="html"||format_preference=="www") {
            return renderTables(name, os);
        }
        var need_blank = false;
        if (order.length==0 || os.hasInsDel()) {
            txt += encodeTable(name, os.one(), render);
            need_blank = true;
        }
        if (order.length>1) {
            for (i in 1...order.length) {
                var t = os.get(order[i]);
                if (t!=null) {
                    if (need_blank) {
                        txt += "\n";
                    }
                    need_blank = true;
                    txt += order[i]+"\n";
                    var line = "";
                    for (i in 0...order[i].length) {
                        line += "=";
                    }
                    txt += line + "\n";
                    txt += encodeTable(name, os.get(order[i]), render);
                }
            }
        }
        return saveText(name, txt);
    }

    private function saveText(name: String, txt: String) : Bool {
        if (name==null) {
            cache_txt += txt;
        } else if (name!="-") {
            io.saveContent(name,txt);
        } else {
            io.writeStdout(txt);
        }
        return true;
    }

    private static function cellFor(x: Dynamic) : Dynamic {
#if cpp
        if (x==null) return null;
        return new SimpleCell(x);
#else
        return x;
#end
    }

    private function jsonToTables(json: Dynamic) : Table {
        var tables = Reflect.field(json,"tables");
        if (tables==null) {
            return jsonToTable(json);
        }
        return new JsonTables(json,flags);
    }

    private function jsonToTable(json: Dynamic) : Table {
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

    private function useColor(flags: CompareFlags, output: String) : Bool {
        var use_color = flags.terminal_format == "ansi";
        if (flags.terminal_format == null) {
            if ((output==null || output=="-") && 
                (output_format=="copy"||output_format=="csv"||output_format=="psv")) {
                if (io!=null) {
                    if (io.isTtyKnown()) use_color = io.isTty();
                }
            }
        }
        return use_color;
    }

    private function runDiff(parent: Table, a: Table, b: Table, flags: CompareFlags,
                             output: String) {
        var ct : CompareTable = compareTables3(parent,a,b,flags);
        var align : Alignment = ct.align();
        var td : TableDiff = new TableDiff(align,flags);
        var o = new SimpleTable(0,0);
        var os = new Tables(o);
        td.hiliteWithNesting(os);
        var use_color = useColor(flags,output);
        saveTables(output,os,use_color,true);

        if (fail_if_diff) {
            var summary = td.getSummary();
            if (summary.different) {
                diffs_found = true;
            }
        }
    }


    /**
     *
     * Load a table from a file.
     *
     * @param name filename to read from
     * @param role one of "parent", "local", or "remote"
     * @return a table
     *
     */
    public function loadTable(name: String, role: String) : Table {
        var ext = checkFormat(name);
        if (ext == "sqlite") {
            var sql = io.openSqliteDatabase(name);
            if (sql==null) {
                io.writeStderr("! Cannot open database, aborting\n");
                return null;
            }
            var tab = new SqlTables(sql,flags,role);
            return tab;
        }
        var txt : String = io.getContent(name);
        if (ext == "ndjson") {
            var t : Table = new SimpleTable(0,0);
            var ndjson = new Ndjson(t);
            ndjson.parse(txt);
            return t;
        }
        if (ext == "json" || ext == "") {
            try {
                var json = haxe.Json.parse(txt);
                format_preference = "json";
                var t : Table = jsonToTables(json);
                if (t==null) throw "JSON failed";
                return t;
            } catch (e: Dynamic) {
                if (ext == "json") throw e;
            }
        }
        format_preference = "csv";
        var csv : Csv = new Csv(delim_preference);
        var output = new SimpleTable(0,0);
        csv.parseTable(txt,output);
        if (csv_eol_preference == null) {
            csv_eol_preference = csv.getDiscoveredEol();
        }
        if (output!=null) output.trimBlank();
        return output;
    }

    private var status : Map<String,Int>;
    private var daff_cmd : String;

    private function command(io: TableIO, cmd: String, args: Array<String>) : Int {
        var r = 0;
        if (io.hasAsync()) r = io.command(cmd,args);
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
        if (!io.hasAsync()) r = io.command(cmd,args);
        return r;
    }

    private function installGitDriver(io: TableIO, formats: Array<String>) : Int {
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
                r = command(io,"git",["config","--global","diff.daff-" + format + ".command",daff_cmd + " diff --git"]);
                if (r==999) return r;
                if (have_diff_driver) {
                    io.writeStdout("- Cleared existing daff diff driver for " + format + "\n");
                }
                io.writeStdout("- Added diff driver for " + format + "\n");
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
                r = command(io,"git",["config","--global","merge.daff-" + format + ".driver",daff_cmd + " merge --output %A %O %A %B"]);
                if (r==999) return r;
                if (have_merge_driver) {
                    io.writeStdout("- Cleared existing daff merge driver for " + format + "\n");
                }
                io.writeStdout("- Added merge driver for " + format + "\n");
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


    /**
     *
     * This implements the daff command-line utility.
     *
     * @param args the list of command-line arguments
     * @param io should be an implementation of all the system services daff needs,
     * if null one will be created
     * @return 0 on success, non-zero on error.
     *
     */
    public function run(args : Array<String>, io: TableIO = null) : Int {
#if coopyhx_util
        if (io == null) {
            io = new TableIO();
        }
#end
        if (io == null) {
            trace("No system interface available");
            return 1;
        }

        init();
        this.io = io;

        var more : Bool = true;
        var output : String = null;
        var inplace : Bool = false;
        var git : Bool = false;
        var help : Bool = false;

        flags = new CompareFlags();
        flags.always_show_header = true;

        // this command line processing method is totally daft, sorry!
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
                    flags.use_glyphs = false;
                    args.splice(i,1);
                    break;
                } else if (tag=="--unquote") {
                    more = true;
                    flags.quote_html = false;
                    args.splice(i,1);
                    break;
                } else if (tag=="--all") {
                    more = true;
                    flags.show_unchanged = true;
                    flags.show_unchanged_columns = true;
                    args.splice(i,1);
                    break;
                } else if (tag=="--all-rows") {
                    more = true;
                    flags.show_unchanged = true;
                    args.splice(i,1);
                    break;
                } else if (tag=="--all-columns") {
                    more = true;
                    flags.show_unchanged_columns = true;
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
                } else if (tag=="--context-columns") {
                    more = true;
                    var context : Int = Std.parseInt(args[i+1]);
                    if (context>=0) flags.unchanged_column_context = context;
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
                } else if (tag=="--unordered") {
                    more = true;
                    flags.ordered = false;
                    flags.unchanged_context = 0;
                    order_set = true;
                    args.splice(i,1);
                    break;
                } else if (tag=="--ordered") {
                    more = true;
                    flags.ordered = true;
                    order_set = true;
                    args.splice(i,1);
                    break;
                } else if (tag=="--color") {
                    more = true;
                    flags.terminal_format = "ansi";
                    args.splice(i,1);
                    break;
                } else if (tag=="--no-color") {
                    more = true;
                    flags.terminal_format = "plain";
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
                    output_format_set = true;
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
                    flags.ignoreColumn(args[i+1]);
                    args.splice(i,2);
                    break;
                } else if (tag=="--index") {
                    more = true;
                    flags.always_show_order = true;
                    flags.never_show_order = false;
                    args.splice(i,1);
                    break;
                } else if (tag=="--www") {
                    more = true;
                    output_format = "www";
                    output_format_set = true;
                    args.splice(i,1);
                } else if (tag=="--table") {
                    more = true;
                    flags.addTable(args[i+1]);
                    args.splice(i,2);
                    break;
                } else if (tag=="-w" || tag=="--ignore-whitespace") {
                    more = true;
                    flags.ignore_whitespace = true;
                    args.splice(i,1);
                    break;
                } else if (tag=="-i" || tag=="--ignore-case") {
                    more = true;
                    flags.ignore_case = true;
                    args.splice(i,1);
                    break;
                } else if (tag=="-d" || tag=="--ignore-epsilon") {
                    more = true;
                    var eps = args[i+1];
                    flags.ignore_epsilon = Std.parseFloat(eps);
                    if (Math.isNaN(flags.ignore_epsilon)) {
                        io.writeStderr("Epsilon for numeric comparison must be numeric\n");
                        return 1;
                    }
                    args.splice(i,2);
                    break;
                } else if (tag=="--padding") {
                    more = true;
                    flags.padding_strategy = args[i+1];
                    args.splice(i,2);
                    break;
                } else if (tag=="-e" || tag=="--eol") {
                    more = true;
                    var ending = args[i+1];
                    if (ending=="crlf") {
                        ending = "\r\n";
                    } else if (ending=="lf") {
                        ending = "\n";
                    } else if (ending=="cr") {
                        ending = "\r";
                    } else if (ending=="auto") {
                        ending = null;
                    } else {
                        io.writeStderr("Expected line ending of either 'crlf' or 'lf' but got " + ending + "\n");
                        return 1;
                    }
                    csv_eol_preference = ending;
                    args.splice(i,2);
                    break;
                } else if (tag=="--fail-if-diff") {
                    more = true;
                    fail_if_diff = true;
                    args.splice(i,1);
                    break;
                } else if (tag=="help"||tag=="-h"||tag=="--help") {
                    more = true;
                    args.splice(i,1);
                    help = true;
                    break;
                }
            }
        }

        var cmd : String = args[0];
        var ok : Bool = true;
        if (help) {
            cmd = "";
            args = [];
        }
        try {
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
                    io.writeStdout("  command = daff diff --git\n");
                    io.writeStderr("\n");
                    io.writeStdout("  [merge \"daff-csv\"]\n");
                    io.writeStdout("  name = daff tabular merge\n");
                    io.writeStdout("  driver = daff merge --output %A %O %A %B\n\n");

                    io.writeStderr("Make sure you can run daff from the command-line as just \"daff\" - if not,\nreplace \"daff\" in the driver and command lines above with the correct way\nto call it. Add --no-color if your terminal does not support ANSI colors.");
                    io.writeStderr("\n");
                    return 0;
                }
                if (args.length < 1) {
                    io.writeStderr("daff can produce and apply tabular diffs.\n");
                    io.writeStderr("Call as:\n");
                    io.writeStderr("  daff a.csv b.csv\n");
                    io.writeStderr("  daff [--color] [--no-color] [--output OUTPUT.csv] a.csv b.csv\n");
                    io.writeStderr("  daff [--output OUTPUT.html] a.csv b.csv\n");
                    io.writeStderr("  daff [--www] a.csv b.csv\n");
                    io.writeStderr("  daff parent.csv a.csv b.csv\n");
                    io.writeStderr("  daff --input-format sqlite a.db b.db\n");
                    io.writeStderr("  daff patch [--inplace] a.csv patch.csv\n");
                    io.writeStderr("  daff merge [--inplace] parent.csv a.csv b.csv\n");
                    io.writeStderr("  daff trim [--output OUTPUT.csv] source.csv\n");
                    io.writeStderr("  daff render [--output OUTPUT.html] diff.csv\n");
                    io.writeStderr("  daff copy in.csv out.tsv\n");
                    io.writeStderr("  daff in.csv\n");
                    io.writeStderr("  daff git\n");
                    io.writeStderr("  daff version\n");
                    io.writeStderr("\n");
                    io.writeStderr("The --inplace option to patch and merge will result in modification of a.csv.\n");
                    io.writeStderr("\n");
                    io.writeStderr("If you need more control, here is the full list of flags:\n");
                    io.writeStderr("  daff diff [--output OUTPUT.csv] [--context NUM] [--all] [--act ACT] a.csv b.csv\n");
                    io.writeStderr("     --act ACT:     show only a certain kind of change (update, insert, delete, column)\n");
                    io.writeStderr("     --all:         do not prune unchanged rows or columns\n");
                    io.writeStderr("     --all-rows:    do not prune unchanged rows\n");
                    io.writeStderr("     --all-columns: do not prune unchanged columns\n");
                    io.writeStderr("     --color:       highlight changes with terminal colors (default in terminals)\n");
                    io.writeStderr("     --context NUM: show NUM rows of context (0=none)\n");
                    io.writeStderr("     --context-columns NUM: show NUM columns of context (0=none)\n");
                    io.writeStderr("     --fail-if-diff: return status is 0 if equal, 1 if different, 2 if problem\n");
                    io.writeStderr("     --id:          specify column name to use as primary key (repeat for multi-column key)\n");
                    io.writeStderr("     --ignore:      specify column name to ignore completely (can repeat)\n");
                    io.writeStderr("     --index:       include row/columns numbers from original tables\n");
                    io.writeStderr("     --input-format [csv|tsv|ssv|psv|json|sqlite]: set format to expect for input\n");
                    io.writeStderr("     --eol [crlf|lf|cr|auto]: separator between rows of csv output.\n");
                    io.writeStderr("     --no-color:    make sure terminal colors are not used\n");
                    io.writeStderr("     --ordered:     assume row order is meaningful (default for CSV)\n");
                    io.writeStderr("     --output-format [csv|tsv|ssv|psv|json|copy|html]: set format for output\n");
                    io.writeStderr("     --padding [dense|sparse|smart]: set padding method for aligning columns\n");
                    io.writeStderr("     --table NAME:  compare the named table, used with SQL sources. If name changes, use 'n1:n2'\n");
                    io.writeStderr("     --unordered:   assume row order is meaningless (default for json formats)\n");
                    io.writeStderr("     -w / --ignore-whitespace: ignore changes in leading/trailing whitespace\n");
                    io.writeStderr("     -i / --ignore-case: ignore differences in case\n");
                    io.writeStderr("     -d EPS / --ignore-epsilon EPS: ignore small floating point differences\n");
                    io.writeStderr("\n");
                    io.writeStderr("  daff render [--output OUTPUT.html] [--css CSS.css] [--fragment] [--plain] diff.csv\n");
                    io.writeStderr("     --css CSS.css: generate a suitable css file to go with the html\n");
                    io.writeStderr("     --fragment:    generate just a html fragment rather than a page\n");
                    io.writeStderr("     --plain:       do not use fancy utf8 characters to make arrows prettier\n");
                    io.writeStderr("     --unquote:     do not quote html characters in html diffs\n");
                    io.writeStderr("     --www:         send output to a browser\n");
                    return 1;
                }
            }
            var cmd : String = args[0];
            var offset : Int = 1;
            // "diff" or "copy" is optional when followed by a filename with a dot in it,
            // or (for "diff") by a --option.
            if (!Lambda.has(["diff","patch","merge","trim","render","git","version","copy"],cmd)) {
                if (cmd.indexOf("--")==0) {
                    cmd = "diff";
                    offset = 0;
                } else if (cmd.indexOf(".")!=-1) {
                    if (args.length == 2) {
                        cmd = "diff";
                        offset = 0;
                    } else if (args.length == 1) {
                        cmd = "copy";
                        offset = 0;
                    }
                }
            }
            if (cmd == "git") {
                var types = args.splice(offset,args.length-offset);
                return installGitDriver(io,types);
            }
            if (git) {
                var ct = args.length-offset;
                if (ct!=7 && ct!=9) {
                    io.writeStderr("Expected 7 or 9 parameters from git, but got " + ct + "\n");
                    return 1;
                }
                var git_args = args.splice(offset,ct);
                args.splice(0,args.length);
                offset = 0;
                var old_display_path = git_args[0];
                var new_display_path = git_args[0];
                var old_file = git_args[1];
                var new_file = git_args[4];
                if (ct==9) {
                    io.writeStdout(git_args[8]);
                    new_display_path = git_args[7];
                }
                io.writeStdout("--- a/" + old_display_path + "\n");
                io.writeStdout("+++ b/" + new_display_path + "\n");
                args.push(old_file);
                args.push(new_file);
            }
            var parent = null;
            if (args.length-offset>=3) {
                parent = loadTable(args[offset], 'parent');
                offset++;
            }
            var aname = args[0+offset];
            var a = loadTable(aname, 'local');
            var b = null;
            if (args.length-offset>=2) {
                if (cmd!="copy") {
                    b = loadTable(args[1+offset], 'remote');
                } else {
                    output = args[1+offset];
                }
            }
            flags.diff_strategy = strategy;

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

            if (cmd=="diff") {
                if (!order_set) {
                    flags.ordered = order_preference;
                    if (!flags.ordered) flags.unchanged_context = 0;
                }
                flags.allow_nested_cells = nested_output;
                if (fail_if_diff) {
                    try {
                        runDiff(parent,a,b,flags,output);
                    } catch (e: Dynamic) {
                        return 2;
                    }
                    if (diffs_found) {
                        return 1;
                    }
                } else {
                    runDiff(parent,a,b,flags,output);
                }
            } else if (cmd=="patch") {
                var patcher : HighlightPatch = new HighlightPatch(a,b);
                patcher.apply();
                saveTable(output,a);
            } else if (cmd=="merge") {
                var merger : Merger = new Merger(parent,a,b,flags);
                var conflicts = merger.apply();
                ok = (conflicts==0);
                if (conflicts>0) {
                    io.writeStderr(conflicts + " conflict" + ((conflicts>1)?"s":"") + "\n");
                }
                saveTable(output,a);
            } else if (cmd=="trim") {
                saveTable(output,a);
            } else if (cmd=="render") {
                renderTable(output,a);
            } else if (cmd=="copy") {
                var os = new Tables(a);
                os.add("untitled");
                saveTables(output,os,useColor(flags,output),false);
            }
        } catch (e: Dynamic) {
            if (!fail_if_diff) {
                throw e;
            }
            return 2;
        }
        return ok?0:(fail_if_diff?2:1);
    }

    public function coopyhx(io: TableIO) : Int {

        var args : Array<String> = io.args();

        // Quick code path to keep certain classes from being optimized out.
        if (args[0] == "--keep") {
            return keepAround();
        }

        return run(args, io);
    }
#end

    /**
     *
     * This is the entry point for the daff command-line utility.
     * It is a thin wrapper around the `coopyhx` method.
     *
     */
    public static function main() : Void {
#if coopyhx_util
    var io = new TableIO();
    var coopy = new Coopy();
    var ret = coopy.coopyhx(io);
    if (ret!=0) Sys.exit(ret);
#else
    // do nothing
#end
    }

    private static function show(t: Table) : Void {
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


    private static function jsonify(t: Table) : Dynamic {
        var workbook : Map<String,Dynamic> = new Map<String,Dynamic>();
        var sheet : Array<Array<Dynamic>> = new Array<Array<Dynamic>>();
        var w : Int = t.width;
        var h : Int = t.height;
        var txt : String = "";
        for (y in 0...h) {
            var row : Array<Dynamic> = new Array<Dynamic>();
            for (x in 0...w) {
                var v = t.getCell(x,y);
                row.push(v);
            }
            sheet.push(row);
        }
        workbook.set("sheet",sheet);
        return workbook;
    }

    /**
     *
     * This takes input in an unknown format and tries to make a table out of it,
     * through the power of guesswork.
     *
     * @param t an alleged table
     * @return a daff-compatible table, or null
     *
     */
    public static function tablify(data: Dynamic) : Table {
        if (data==null) return data;
#if rb
        if (untyped __rb__("data.respond_to? :get_cell_view")) return data;
#else
        var get_cell_view = Reflect.field(data,"getCellView");
        if (get_cell_view!=null) return data;
#end

        // emergency! try to find and use native wrapper
#if js
        return untyped __js__("new daff.TableView(data)");
#elseif python
        python.Syntax.code("daff = __import__('daff')");
        return python.Syntax.code("daff.PythonTableView(data)");
#elseif rb
        return untyped __rb__("::Coopy::TableView.new(data)");
#elseif php
        return php.Syntax.code("new coopy_PhpTableView($data)");
#elseif java
        return untyped __java__("new JavaTableView((Object[][])data)");
#else
        return null;
#end
    }
}
