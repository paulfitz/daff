<?php

class coopy_PhpTableView implements coopy_Table{
  public function __construct(&$data) {
    $this->data = &$data;
    $this->height = count($data);
    $this->width = 0;
    if ($this->height>0) {
      $this->width = count($data[0]);
    }
  }

  public function get_width() {
    return $this->width;
  }

  public function get_height() {
    return $this->height;
  }

  public function getCell($x,$y) {
    return $this->data[$y][$x];
  }

  public function setCell($x,$y,$c) {
    if (is_object($c)) {
      $this->data[$y][$x] = "" . $c->toString();
    } else {
      $this->data[$y][$x] = $c;
    }
  }

  public function toString() {
    return coopy_SimpleTable::tableToString($this);
  }

  public function getCellView() {
    return new coopy_SimpleView();
  }

  public function isResizable() {
    return true;
  }

  public function resize($w,$h) {
    $this->width = $w;
    $this->height = $h;
    for ($i=0; $i<count($this->data); $i++) {
      $row = &$this->data[$i];
      if ($row==null) {
	$this->data[$i] = [];
	$row = &$this->data[$i];
      }
      while (count($row)<$this->width) {
	array_push($row,null);
      }
      unset($row);
    }
    if (count($this->data)<$this->height) {
      while (count($this->data)<$this->height) {
	$row = [];
	for ($i=0; $i<$this->width; $i++) {
	  array_push($row,null);
	}
	array_push($this->data,$row);
      }
    }
    return true;
  }

  public function clear() {
    for ($i=0; $i<count($this->data); $i++) {
      $row = &$this->data[$i];
      for ($j=0; $j<count($row); $j++) {
	$row[$j] = null;
      }
    }
  }

  public function trimBlank() {
    return false;
  }

  public function getData() {
    return $this->data;
  }

  public function insertOrDeleteRows($xfate,$hfate) {
    $fate = php_Lib::toPhpArray($xfate);
    $ndata = [];
    $top = 0;
    for ($i=0; $i<count($fate); $i++) {
        $j = $fate[$i];
        if ($j!=-1) {
	    $ndata[$j] = &$this->data[$i];
	    if ($j>$top) $top = $j;
        }
    }
    // let's preserve data
    array_splice($this->data,0,count($this->data));
    for ($i=0; $i<=$top; $i++) {
	$this->data[$i] = &$ndata[$i];
    }
    $this->resize($this->width,$hfate);
    return true;
  }

  public function insertOrDeleteColumns($xfate,$wfate) {
    $fate = php_Lib::toPhpArray($xfate);
    if ($wfate==$this->width && $wfate==count($fate)) {
      $eq = true;
      for ($i=0; $i<$wfate; $i++) {
	if ($fate[$i]!=$i) {
	  $eq = false;
	  break;
	}
      }
      if ($eq) return true;
    }
    for ($i=0; $i<$this->height; $i++) {
      $row = &$this->data[$i];
      $nrow = [];
      $top = 0;
      for ($j=0; $j<$this->width; $j++) {
	if ($fate[$j]==-1) continue;
	$nrow[$fate[$j]] = $row[$j];
	if ($fate[$j]>$top) $top = $fate[$j];
      }
      for ($j=$top; $j<$wfate-1; $j++) {
	array_push($nrow,null);
      }
      $this->data[$i] = $nrow;
    }
    $this->width = $wfate;
    return true;
  }

  public function isSimilar($alt) {
    if ($alt->width!=$this->width) return false;
    if ($alt->height!=$this->height) return false;
    for ($c=0; $c<$this->width; $c++) {
      for ($r=0; $r<$this->height; $r++) {
	$v1 = "" . $this->getCell($c,$r);
	$v2 = "" . $alt->getCell($c,$r);
	if ($v1!=$v2) {
	  return false;
	}
      }
    }
    return true;
  }
}
