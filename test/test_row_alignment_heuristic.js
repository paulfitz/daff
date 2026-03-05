// Test for row alignment when column selection heuristic excludes distinguishing columns.
// This tests the fix for a bug where rows that differ by only one column were incorrectly
// reported as delete+insert instead of modification, when:
// 1. The table has many columns (>5) triggering the column selection heuristic
// 2. The selected columns cannot distinguish similar rows within the same table
// 3. The only distinguishing column is also the one that differs between tables

var coopy = require('daff');
var tester = require('tester');

// Test case 1: Original broken case (broken-case/a.csv vs b.csv)
// Row 5 (Transport & storage, Bexley) differs only in column "2023" (7000 vs 8000)
// With 9 columns and 7 rows, the heuristic might not select columns that
// distinguish this row from row 4 (Construction, Bexley)
{
    var t1 = new coopy.TableView([
        ["1971","2023","sector_ID","sector","1973","gss_code","borough","1985","2019"],
        ["250","1250","16","Other services","500","E09000002","Barking and Dagenham","600","1000"],
        ["6000","10000","3","Construction","7000","E09000003","Barnet","4500","9000"],
        ["12000","15000","5","Retail","12000","E09000003","Barnet","15000","15000"],
        ["3500","6000","3","Construction","4000","E09000004","Bexley","3500","6000"],
        ["3500","7000","6","Transport & storage","4000","E09000004","Bexley","3500","6000"],
        ["1250","2500","16","Other services","1000","E09000005","Brent","1250","2250"]
    ]);
    var t2 = new coopy.TableView([
        ["1971","2023","sector_ID","sector","1973","gss_code","borough","1985","2019"],
        ["250","1250","16","Other services","500","E09000002","Barking and Dagenham","600","1000"],
        ["6000","10000","3","Construction","7000","E09000003","Barnet","4500","9000"],
        ["12000","15000","5","Retail","12000","E09000003","Barnet","15000","15000"],
        ["3500","6000","3","Construction","4000","E09000004","Bexley","3500","6000"],
        ["3500","8000","6","Transport & storage","4000","E09000004","Bexley","3500","6000"],
        ["1250","2500","16","Other services","1000","E09000005","Brent","1250","2250"]
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1, t2);
    var align = ct.align();
    
    // All rows should match to the same position
    tester.align_asserts(align, [
        [0, 0],  // header
        [1, 1],  // Barking and Dagenham
        [2, 2],  // Barnet Construction
        [3, 3],  // Barnet Retail
        [4, 4],  // Bexley Construction
        [5, 5],  // Bexley Transport & storage (the row that was incorrectly unmatched)
        [6, 6]   // Brent
    ]);
    
    // Verify round-trip patching works
    tester.bi_round_trip(t1, t2, "row alignment with many columns - single cell change");
}

// Test case 2: Verify that truly different rows are NOT matched
// When the last row is completely different, it should be delete+insert, not modify
{
    var t1 = new coopy.TableView([
        ["1971","2023","sector_ID","sector","1973","gss_code","borough","1985","2019"],
        ["250","1250","16","Other services","500","E09000002","Barking and Dagenham","600","1000"],
        ["6000","10000","3","Construction","7000","E09000003","Barnet","4500","9000"],
        ["3500","6000","3","Construction","4000","E09000004","Bexley","3500","6000"]
    ]);
    var t2 = new coopy.TableView([
        ["1971","2023","sector_ID","sector","1973","gss_code","borough","1985","2019"],
        ["250","1250","16","Other services","500","E09000002","Barking and Dagenham","600","1000"],
        ["6000","10000","3","Construction","7000","E09000003","Barnet","4500","9000"],
        ["9999","9999","99","Completely Different","9999","E09000099","Nowhere","9999","9999"]
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1, t2);
    var align = ct.align();
    
    // Row 3 should NOT match because it's completely different
    tester.align_asserts(align, [
        [0, 0],
        [1, 1],
        [2, 2],
        [3, null]  // Bexley Construction deleted
    ]);
}

// Test case 3: Multiple rows with same index key values
// When rows share values in the indexed columns but are different rows,
// the fallback should still work if only one is unmatched
{
    var t1 = new coopy.TableView([
        ["year1","year2","year3","year4","year5","sector","code"],
        ["1000","2000","3000","4000","5000","Alpha","A1"],
        ["1000","2000","3000","4000","5000","Beta","B1"],
        ["1000","2000","3000","4000","5000","Gamma","C1"],
        ["1000","2000","3000","4000","9999","Delta","D1"]
    ]);
    var t2 = new coopy.TableView([
        ["year1","year2","year3","year4","year5","sector","code"],
        ["1000","2000","3000","4000","5000","Alpha","A1"],
        ["1000","2000","3000","4000","5000","Beta","B1"],
        ["1000","2000","3000","4000","5000","Gamma","C1"],
        ["1000","2000","3000","4000","8888","Delta","D1"]
    ]);
    
    var ct = new coopy.Coopy.compareTables(t1, t2);
    var align = ct.align();
    
    // All rows should match despite having similar year columns
    // Row 4 (Delta) differs only in year5 (9999 vs 8888)
    tester.align_asserts(align, [
        [0, 0],
        [1, 1],
        [2, 2],
        [3, 3],
        [4, 4]
    ]);
    
    tester.bi_round_trip(t1, t2, "rows with similar index key values");
}

console.log("All row alignment heuristic tests passed!");
