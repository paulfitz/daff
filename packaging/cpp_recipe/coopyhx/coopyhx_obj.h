
namespace hx {
  template<typename OBJ_>
    class ObjectPtr {
  public:
    //ObjectPtr() : mPtr(0) { }
    //ObjectPtr(OBJ_ *inObj) { }
    //ObjectPtr(const null &inNull) { }
    //ObjectPtr(const ObjectPtr<OBJ_> &inOther) { }
    
    inline OBJ_ *operator->() { return 0 /*NULL*/; }
    inline OBJ_ *GetPtr() const { return 0 /*NULL*/; }
  };
}
