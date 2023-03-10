if (typeof exports !== "undefined" && typeof window !== "undefined") {
	// looking at you webpack
	for (const f in daff) {
		if (daff.hasOwnProperty(f)) {
			exports[f] = daff[f];
		}
	}
}
