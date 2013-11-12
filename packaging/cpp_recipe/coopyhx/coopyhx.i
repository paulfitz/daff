%module coopyhx

%nodefaultctor;

%ignore String::toString;
%rename(__str__) String::__CStr;

%rename(__str__) coopy::SimpleTable_obj::toString;

%rename(asInt) operator int;
%rename(asDouble) operator double;

%rename(SimpleTable) SimpleTableFactory;
%rename(SimpleCell) SimpleCellFactory;
%rename(CompareFlags) CompareFlagsFactory;
%rename(TableDiff) TableDiffFactory;
%rename(DiffRender) DiffRenderFactory;
%rename(HighlightPatch) HighlightPatchFactory;
%rename(Coopy) Coopy_obj;

%{

// stop haxe playing around with limits.h
#define HX_UNDEFINE_H

#include <hxcpp.h>
// haxe plays around with NULL
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
%template(ObjectPtrCompareTable_obj) hx::ObjectPtr<coopy::CompareTable_obj>;
%template(ObjectPtrAlignment_obj) hx::ObjectPtr<coopy::Alignment_obj>;
%template(ObjectPtrTableDiff_obj) hx::ObjectPtr<coopy::TableDiff_obj>;
%template(ObjectPtrView_obj) hx::ObjectPtr<coopy::View_obj>;
%template(ObjectPtrDiffRender_obj) hx::ObjectPtr<coopy::DiffRender_obj>;
%template(ObjectPtrHighlightPatch_obj) hx::ObjectPtr<coopy::HighlightPatch_obj>;
%template(ObjectPtrObject) hx::ObjectPtr<hx::Object>;
typedef char HX_CHAR;
%include <coopy/SimpleCell.h>
%include <coopy/SimpleTable.h>
%include <coopy/Coopy.h>
%include <coopy/CompareTable.h>
%include <coopy/Alignment.h>
%include <coopy/CompareFlags.h>
%include <coopy/TableDiff.h>
%include <coopy/Table.h>
%include <coopy/View.h>
%include <coopy/HighlightPatch.h>
%include <coopy/DiffRender.h>
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
