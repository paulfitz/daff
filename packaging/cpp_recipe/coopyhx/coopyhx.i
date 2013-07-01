%module coopyhx

%nodefaultctor;

%ignore String::toString;
%rename(__str__) String::__CStr;

%rename(__str__) coopy::SimpleTable_obj::toString;

%rename(asInt) operator int;
%rename(asDouble) operator double;


//%include std_vector.i
//%{
//  std::vector< std::vector<swig::GC_VALUE> > NativeVector;
//%}
//%template(NativeVector) std::vector< swig::GC_VALUE >;

%rename(SimpleTable) SimpleTableFactory;
%rename(SimpleCell) SimpleCellFactory;
%rename(CompareFlags) CompareFlagsFactory;
%rename(TableDiff) TableDiffFactory;
%rename(Coopy) Coopy_obj;
/*
%rename(Datum) Datum_obj;
%rename(Bag) Bag_obj;
%rename(View) View_obj;
%rename(SimpleCell) SimpleCell_obj;
%rename(Coopy) Coopy_obj;
%rename(CompareFlags) CompareFlags_obj;
%rename(TableDiff) TableDiff_obj;
%rename(CompareTable) CompareTable_obj;
%rename(Alignment) Alignment_obj;
*/

//typedef hx::ObjectPtr<coopy::SimpleTable_obj> coopy::SimpleTable;
//typedef hx::ObjectPtr<coopy::Datum_obj> coopy::Datum;


%{

  // stop haxe playing silly buggers with limits.h
#define HX_UNDEFINE_H

#include <hxcpp.h>
// haxe plays silly buggers with NULL
#ifndef NULL
#define NULL 0
#endif

#include <haxe/ds/IntMap.h>
#include <coopyhx.h>
#include <coopy/SimpleView.h>

%}

%define HXCPP_H
%enddef
%define HX_DECLARE_CLASS0(klass) class klass##_obj; typedef hx::ObjectPtr<klass##_obj> klass;
%enddef
%define HX_DECLARE_CLASS1(x,klass) namespace x { HX_DECLARE_CLASS0(klass) }
%enddef
%define HX_DECLARE_CLASS2(x,y,klass) namespace x { HX_DECLARE_CLASS1(y,klass) }
%enddef
%define HXCPP_CLASS_ATTRIBUTES
%enddef
%define HX_DO_INTERFACE_RTTI
%enddef
%define HXCPP_EXTERN_CLASS_ATTRIBUTES
%enddef
%define HX_MARK_PARAMS hx::MarkContext*
%enddef
%define HX_VISIT_PARAMS hx::VisitContext*
%enddef
%include <coopyhx.h>
%include <coopyhx_obj.h>
%template(ObjectPtrSimpleTable_obj) hx::ObjectPtr<coopy::SimpleTable_obj>;
%template(ObjectPtrTable_obj) hx::ObjectPtr<coopy::Table_obj>;
%template(ObjectPtrSimpleCell_obj) hx::ObjectPtr<coopy::SimpleCell_obj>;
//%template(ObjectPtrDatum_obj) hx::ObjectPtr<coopy::Datum_obj>;
%template(ObjectPtrCompareTable_obj) hx::ObjectPtr<coopy::CompareTable_obj>;
%template(ObjectPtrAlignment_obj) hx::ObjectPtr<coopy::Alignment_obj>;
%template(ObjectPtrTableDiff_obj) hx::ObjectPtr<coopy::TableDiff_obj>;
%template(ObjectPtrView_obj) hx::ObjectPtr<coopy::View_obj>;
%template(ObjectPtrObject) hx::ObjectPtr<hx::Object>;
//typedef ObjectPtrDatum_obj coopy::Datum;
typedef char HX_CHAR;
%include <coopy/SimpleCell.h>
%include <coopy/SimpleTable.h>
			   //%include <coopy/Datum.h>
%include <coopy/Coopy.h>
%include <coopy/CompareTable.h>
%include <coopy/Alignment.h>
%include <coopy/CompareFlags.h>
%include <coopy/TableDiff.h>
%include <coopy/Table.h>
%include <coopy/View.h>
%include <coopyhx.h>
%include <hxString.h>

%extend Dynamic {
   String __str__() { return (*self)->toString(); }
}

%extend coopy::SimpleTable_obj {
  virtual Void setCell(int x,int y,int v) {
    // for now, let's just dump things in as dynamics
    self->data->set((x + (y * self->w)),Dynamic(v));
  }
  virtual Void setCell(int x,int y,const char *v) {
    // for now, let's just dump things in as dynamics
    self->data->set((x + (y * self->w)),Dynamic(v));
  }
};
