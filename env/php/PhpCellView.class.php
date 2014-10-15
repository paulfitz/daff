<?php

class coopy_PhpCellView implements coopy_View {
  public function toString($d) {
    return "".$d;
  }
  public function getBag($d) { return null; }
  public function getTable($d) { return null; }
  public function hasStructure($d) { return false; }
  public function equals($d1,$d2) { return $d1 == $d2; }
  public function toDatum($d) { return $d; }
}
