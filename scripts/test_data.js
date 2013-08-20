
var bridge_example = {
    "key": "bridge",
    "parent": [
	[ "bridge", "designer", "length" ],
	[ "Brooklyn", "J. A. Roebling", "1595" ],
	[ "Williamsburg", "D. Duck", "1600" ],
	[ "Queensborough", "Palmer & Hornbostel", "1182" ],
	[ "Triborough", "O. H. Ammann", "1380,383" ],
	[ "Bronx Whitestone", "O. H. Ammann", "2300" ],
	[ "Throgs Neck", "O. H. Ammann", "1800" ],
	[ "George Washington", "O. H. Ammann", "3500" ],
	[ "Spamspan", "S. Spamington", "10000" ]
    ],

    "local": [
	[ "bridge", "designer", "length" ],
	[ "Brooklyn", "J. A. Roebling", "1595" ],
	[ "Williamsburg", "D. Duck", "1600" ],
	[ "Queensborough", "Palmer & Hornbostel", "1182" ],
	[ "Triborough", "O. H. Ammann", "1380,383" ],
	[ "Bronx Whitestone", "O. H. Ammann", "2300" ],
	[ "Throgs Neck", "O. H. Ammann", "1800" ],
	[ "George Washington", "O. H. Ammann", "3500" ],
	[ "Spamspan", "S. Spamington", "10000" ]
    ],

    "remote": [
	[ "bridge", "designer", "length" ],
	[ "Brooklyn", "J. A. Roebling", "1595" ],
	[ "Manhattan", "G. Lindenthal", "1470" ],
	[ "Williamsburg", "L. L. Buck", "1600" ],
	[ "Queensborough", "Palmer & Hornbostel", "1182" ],
	[ "Triborough", "O. H. Ammann", "1380,383" ],
	[ "Bronx Whitestone", "O. H. Ammann", "2300" ],
	[ "Throgs Neck", "O. H. Ammann", "1800" ],
	[ "George Washington", "O. H. Ammann", "3500" ]
    ]
};

var reorder_example = {
    "key": "order",
    "parent": [[]],
    "local": [
	[ "Test" ],
	[ "1" ],
	[ "2" ],
	[ "3" ],
	[ "4" ],
	[ "5" ],
	[ "6" ]
    ],
    "remote": [
	[ "Test" ],
	[ "6" ],
	[ "1" ],
	[ "2" ],
	[ "3" ],
	[ "4" ],
	[ "5" ]
    ]
};

var all_examples = [ bridge_example, reorder_example ];
