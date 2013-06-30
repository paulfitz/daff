#include <hxcpp.h>
#include <stdio.h>

class Coopyhx {
public:
  static void boot() {
    HX_TOP_OF_STACK
    hx::Boot();
    __boot_all();
  }
};

