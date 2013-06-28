#define HX_DECLARE_MAIN 1
#include <hxcpp.h>

#include <stdio.h>

#include <coopy/SimpleTable.h>
#include <coopy/SimpleCell.h>
#include <coopy/Coopy.h>
#include <coopy/Alignment.h>
#include <coopy/CompareTable.h>
#include <coopy/CompareFlags.h>
#include <coopy/TableDiff.h>

::coopy::SimpleCell zap(const char *txt) {
  return ::coopy::SimpleCell_obj::__new(String(txt));
}

int my_main() {
  try{
    ::coopy::SimpleTable output = ::coopy::SimpleTable_obj::__new(10,20);
    ::coopy::SimpleCell cell = ::coopy::SimpleCell_obj::__new(16);
    output->setCell(3,3,cell);
    ::coopy::Datum datum = output->getCell(3,3);
    printf("value %s\n", datum->toString().__CStr());
    ::coopy::SimpleTable t1 = ::coopy::SimpleTable_obj::__new(3,3);
    ::coopy::SimpleTable t2 = ::coopy::SimpleTable_obj::__new(3,3);
    t1->setCell(0,0,zap("NAME"));
    t1->setCell(1,0,zap("AGE"));
    t1->setCell(2,0,zap("LOCATION"));
    t1->setCell(0,1,zap("Paul"));
    t1->setCell(1,1,zap("11"));
    t1->setCell(2,1,zap("Space"));
    t2->setCell(0,0,zap("NAME"));
    t2->setCell(1,0,zap("AGE"));
    t2->setCell(2,0,zap("LOCATION"));
    t2->setCell(0,1,zap("Paul"));
    t2->setCell(1,1,zap("88"));
    t2->setCell(2,1,zap("Space"));
    datum = t2->getCell(1,1);
    printf("value2 %s\n", datum->toString().__CStr());
    printf("t1: %s\n", t1->toString().__CStr());
    printf("t2: %s\n", t2->toString().__CStr());
    ::coopy::SimpleTable table_diff = ::coopy::SimpleTable_obj::__new(0,0);
    ::coopy::CompareTable cmp = ::coopy::Coopy_obj::compareTables(t1,t2);
    ::coopy::Alignment alignment = cmp->align();
    printf("align:\n", alignment->toString().__CStr());
    ::coopy::CompareFlags flags = ::coopy::CompareFlags_obj::__new();
    ::coopy::TableDiff highlighter = ::coopy::TableDiff_obj::__new(alignment,flags);
    highlighter->hilite(table_diff);
    ::String tab = table_diff->tableToString(table_diff);
    printf("diff: %s\n", tab.__CStr());
  } catch (Dynamic e){
    printf("Bailing out, error : %s\n",e->toString().__CStr());
    __hx_dump_stack();
  }
  return 0;
}

//void __boot_all() {
//}

HX_BEGIN_MAIN

my_main();
HX_END_MAIN


/*
int main() {
  HX_TOP_OF_STACK
  hx::Boot();
  try{
    __boot_all(); // can't do this, loads a dynamic library
    ::coopy::SimpleTable output = ::coopy::SimpleTable_obj::__new(10,20);
    ::coopy::SimpleCell cell = ::coopy::SimpleCell_obj::__new(16);
    output->setCell(3,3,cell);
    ::coopy::Datum datum = output->getCell(3,3);
    printf("value %s\n", datum->toString().__CStr());
    ::coopy::SimpleTable t1 = ::coopy::SimpleTable_obj::__new(3,3);
    ::coopy::SimpleTable t2 = ::coopy::SimpleTable_obj::__new(3,3);
    t1->setCell(0,0,zap("NAME"));
    t1->setCell(1,0,zap("AGE"));
    t1->setCell(2,0,zap("LOCATION"));
    t1->setCell(0,1,zap("Paul"));
    t1->setCell(1,1,zap("11"));
    t1->setCell(2,1,zap("Space"));
    t2->setCell(0,0,zap("NAME"));
    t2->setCell(1,0,zap("AGE"));
    t2->setCell(2,0,zap("LOCATION"));
    t2->setCell(0,1,zap("Paul"));
    t2->setCell(1,1,zap("88"));
    t2->setCell(2,1,zap("Space"));
    datum = t2->getCell(1,1);
    printf("value2 %s\n", datum->toString().__CStr());
    printf("t1:\n", t1->toString().__CStr());
    ::coopy::SimpleTable table_diff = ::coopy::SimpleTable_obj::__new(0,0);
    ::coopy::CompareTable cmp = ::coopy::Coopy_obj::compareTables(t1,t2);
    ::coopy::Alignment alignment = cmp->align();
    printf("align:\n", alignment->toString().__CStr());
    ::coopy::CompareFlags flags = ::coopy::CompareFlags_obj::__new();
    ::coopy::TableDiff highlighter = ::coopy::TableDiff_obj::__new(alignment,flags);
    highlighter->hilite(table_diff);
    printf("diff:\n", table_diff->toString().__CStr());
    return 0;
  } catch (Dynamic e){
    printf("Bailing out, error : %s\n",e->toString().__CStr());
    __hx_dump_stack();
  }
  return 0;
}

*/
