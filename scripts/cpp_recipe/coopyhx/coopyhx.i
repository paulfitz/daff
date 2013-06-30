%module coopyhxwrap

%include "std_string.i"

typedef hx::ObjectPtr<coopy::SimpleTable_obj> coopy::SimpleTable;
typedef hx::ObjectPtr<coopy::Datum_obj> coopy::Datum;


%{
  // stop haxe playing silly buggers with limits.h
#define HX_UNDEFINE_H

#include <hxcpp.h>
// haxe plays silly buggers with NULL
#ifndef NULL
#define NULL 0
#endif

#include <coopy/Datum.h>
#include <coopy/Bag.h>
#include <coopy/View.h>
#include <coopy/SimpleTable.h>
#include <coopy/SimpleCell.h>
#include <coopy/Coopy.h>
#include <coopy/CompareFlags.h>
#include <coopy/TableDiff.h>
#include <coopy/CompareTable.h>
#include <coopy/Alignment.h>
#include <coopyhx.h>
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
%template(ObjectPtrSimpleCell_obj) hx::ObjectPtr<coopy::SimpleCell_obj>;
%template(ObjectPtrDatum_obj) hx::ObjectPtr<coopy::Datum_obj>;
%template(ObjectPtrCompareTable_obj) hx::ObjectPtr<coopy::CompareTable_obj>;
%template(ObjectPtrAlignment_obj) hx::ObjectPtr<coopy::Alignment_obj>;
%template(ObjectPtrTableDiff_obj) hx::ObjectPtr<coopy::TableDiff_obj>;
%template(ObjectPtrObject) hx::ObjectPtr<hx::Object>;
typedef ObjectPtrDatum_obj coopy::Datum;
typedef char HX_CHAR;
%include <Dynamic.h>
%include <coopy/Datum.h>
%include <coopy/Bag.h>
%include <coopy/View.h>
%include <coopy/SimpleCell.h>
%include <coopy/SimpleTable.h>
%include <coopy/Coopy.h>
%include <coopy/CompareFlags.h>
%include <coopy/CompareTable.h>
%include <coopy/TableDiff.h>
%include <coopy/Alignment.h>
%include <hxString.h>


