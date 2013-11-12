#include <hxcpp.h>
#include <stdio.h>
#include <Dynamic.h>
#include <coopy/Bag.h>
#include <coopy/View.h>
#include <coopy/SimpleTable.h>
#include <coopy/SimpleCell.h>
#include <coopy/Coopy.h>
#include <coopy/CompareFlags.h>
#include <coopy/TableDiff.h>
#include <coopy/CompareTable.h>
#include <coopy/Alignment.h>
#include <coopy/DiffRender.h>
#include <coopy/HighlightPatch.h>


class Coopyhx {
public:
  static void boot() {
    HX_TOP_OF_STACK
    hx::Boot();
    __boot_all();
  }
};

namespace coopy {
  class SimpleCellFactory : public hx::ObjectPtr<coopy::SimpleCell_obj> {
  public:
  SimpleCellFactory(Dynamic x) : 
    hx::ObjectPtr<coopy::SimpleCell_obj>(coopy::SimpleCell_obj::__new(x)) {}
    coopy::SimpleCell_obj *operator->() { return GetPtr(); }
  };

  class SimpleTableFactory : public hx::ObjectPtr<coopy::SimpleTable_obj> {
  public:
  SimpleTableFactory(int w, int h) : 
    hx::ObjectPtr<coopy::SimpleTable_obj>(coopy::SimpleTable_obj::__new(w,h)) {}
    coopy::SimpleTable_obj *operator->() { return GetPtr(); }
    static ::String tableToString( ::coopy::Table tab) {
      return coopy::SimpleTable_obj::tableToString(tab);
    }
  };

  class CompareFlagsFactory : public hx::ObjectPtr<coopy::CompareFlags_obj> {
  public:
  CompareFlagsFactory() : 
    hx::ObjectPtr<coopy::CompareFlags_obj>(coopy::CompareFlags_obj::__new()) {}
    coopy::CompareFlags_obj *operator->() { return GetPtr(); }
  };

  class TableDiffFactory : public hx::ObjectPtr<coopy::TableDiff_obj> {
  public:
  TableDiffFactory(coopy::Alignment a, coopy::CompareFlags f) : 
    hx::ObjectPtr<coopy::TableDiff_obj>(coopy::TableDiff_obj::__new(a,f)) {}
    coopy::TableDiff_obj *operator->() { return GetPtr(); }
  };

  class DiffRenderFactory : public hx::ObjectPtr<coopy::DiffRender_obj> {
  public:
  DiffRenderFactory() : 
    hx::ObjectPtr<coopy::DiffRender_obj>(coopy::DiffRender_obj::__new()) {}
    coopy::DiffRender_obj *operator->() { return GetPtr(); }
  };

  class HighlightPatchFactory : public hx::ObjectPtr<coopy::HighlightPatch_obj> {
  public:
  HighlightPatchFactory(coopy::Table t1, coopy::Table t2) : 
    hx::ObjectPtr<coopy::HighlightPatch_obj>(coopy::HighlightPatch_obj::__new(t1,t2)) {}
    coopy::HighlightPatch_obj *operator->() { return GetPtr(); }
  };
}
