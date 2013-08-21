
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

var planets_example = {
    "key": "planets",
    "parent": [
	[ "Planet", "Comment" ],
	[ "Mercury", "So cool" ],
	[ "Venus", "Total greenhouse" ],
	[ "Mars", "A bit dry" ],
	[ "Jupiter", "Roomy" ],
	[ "Saturn", "Ringy" ],
	[ "Uranus", "Unfortunately named" ],
	[ "Neptune", "Sounds damp" ],
	[ "Pluto", "What about Charon?" ]
    ],
    "local": [
	[ "Planet", "Comment" ],
	[ "Mercury", "So cool" ],
	[ "Venus", "Total greenhouse" ],
	[ "Mars", "A bit dry" ],
	[ "Jupiter", "Roomy" ],
	[ "Saturn", "Ringy" ],
	[ "Uranus", "Unfortunately named" ],
	[ "Neptune", "Sounds damp" ],
	[ "Pluto", "What about Charon?" ]
    ],
    "remote": [
	[ "Planet", "Comment", "Mean distance (km) from sun" ],
	[ "Earth", "Totally forgot this one", "149,597,890" ],
	[ "Jupiter", "Roomy", "778,412,010"  ],
	[ "Mars", "A bit dry", "227,936,640" ],
	[ "Mercury", "So cool", "57,909,175" ],
	[ "Neptune", "Sounds damp", "4,498,252,900" ],
	[ "Saturn", "Ringy", "1,426,725,400" ],
	[ "Uranus", "Unfortunately named", "2,870,972,200" ],
	[ "Venus", "Total greenhouse", "108,208,930" ]
    ]
};

var move_col_example = {
    "key": "move_col",
    "parent": [[]],
    "local": [["First","Last"],["Paul","Fitzpatrick"]],
    "remote": [["Last","First"],["Fitzpatrick","Paul"]]
};

var all_examples = [ bridge_example, planets_example /*, move_col_example*/ ];
