#include <hxString.h>

namespace hx {
  template<typename OBJ_>
    class ObjectPtr {
  public:
    inline OBJ_ *operator->() { return 0 /*NULL*/; }
    inline OBJ_ *GetPtr() const { return 0 /*NULL*/; }
  };
  class Object {
  public:
    String toString() { return ""; }
  };
}

class Dynamic : public hx::ObjectPtr<hx::Object> {
public:
  Dynamic() {};
   Dynamic(int inVal);
   Dynamic(const cpp::CppInt32__ &inVal);
   Dynamic(bool inVal);
   Dynamic(double inVal);
   Dynamic(float inVal);
   Dynamic(hx::Object *inObj) : super(inObj) { }
   Dynamic(const String &inString);
   Dynamic(const null &inNull) : super(0) { }
   Dynamic(const Dynamic &inRHS) : super(inRHS.mPtr) { }
   explicit Dynamic(const HX_CHAR *inStr);
   hx::Object *operator->() { return 0; }
   inline operator double () const { return mPtr ? mPtr->__ToDouble() : 0.0; }
   inline operator float () const { return mPtr ? (float)mPtr->__ToDouble() : 0.0f; }
   inline operator int () const { return mPtr ? mPtr->__ToInt() : 0; }
};
