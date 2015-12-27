
var _binder = Module('binder');

var get_img_url = function(card_mid){
    return 'http://gatherer.wizards.com/Handlers/Image.ashx?type=card&multiverseid=' + card_mid;
};

/**
*	Wizards
*/
function getWizardsCardName(cardName){
	return cardName.replace(/&#8217;/g,"").replace(/\/g,"").replace(/\’/g,"").replace(/\'/g,"").replace(/,/g," ").replace(/-/g," ").replace(/\s+/g," ").replace(/ /g,"_");
}
function getWizardsHtml(cardName){
	return "<img src=\""+getWizardsSrc(cardName)+"\" onerror=\"this.onerror=null;this.onmouseout=null;this.onmouseover=null;this.src='mtg_card_back.jpg';\"/>";
}

function getWizardsSrc(cardName){
    var mid = _binder.get_binder().cards[cardName].multiverse;
		return get_img_url(mid);
}

function getWizardsOnError(e){
	return function(e) {
		this.onerror=null;
		this.onmouseout=null;
		this.onmouseover=null;
		this.src="https://sites.google.com/site/themunsonsapps/mtg/mtg_card_back.jpg";
	};
}
