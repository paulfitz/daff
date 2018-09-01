if (typeof exports != "undefined" && typeof window != "undefined") {
  // looking at you webpack
  for (f in daff) { 
    if (daff.hasOwnProperty(f)) {
      exports[f] = daff[f]; 
    }
  } 
}
