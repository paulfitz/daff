#include <hxcpp.h>

#include <stdio.h>

#include <coopy/SimpleTable.h>
#include <coopy/SimpleCell.h>
#include <coopy/Coopy.h>


int main() {
  HX_TOP_OF_STACK
  hx::Boot();
  try{
    //__boot_all(); // can't do this, loads a dynamic library
    ::coopy::SimpleTable output = ::coopy::SimpleTable_obj::__new(10,20);
    ::coopy::SimpleCell cell = ::coopy::SimpleCell_obj::__new(16);
    output->setCell(3,3,cell);
    ::coopy::Datum datum = output->getCell(3,3);
    printf("value %s\n", datum->toString().__CStr());
    return 0;
  } catch (Dynamic e){
    printf("Bailing out, error : %s\n",e->toString().__CStr());
    __hx_dump_stack();
  }
  return 0;
}

