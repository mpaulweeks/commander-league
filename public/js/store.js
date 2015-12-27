(function(module){

    var LOOKUP_FILE = '/json/lookup.json';
    module.lookup = null;

    module.init = function(callback){
        $.getJSON(LOOKUP_FILE, function(lookup){
            module.lookup = lookup;
            callback();
        });
    };

    module.create_statuses = function(user_slug, cards, callback){
        data = JSON.stringify(cards)
        $.ajax({
            url: 'api/user/' + user_slug + '/status',
            type: 'POST',
            data: data,
        }).done(function (data){
            callback(data);
        });
    };

    module.get_cards_by_colors = function(colors){
        var out = [];
        for (var card_name in module.lookup){
            var card = module.lookup[card_name];
            var is_match = false;
            var is_illegal = false;
            if ("colorIdentity" in card && card.colorIdentity.length > 0){
                for (var i = 0; i < card.colorIdentity.length; i++){
                    var card_color = card.colorIdentity[i];
                    is_match = is_match || colors.indexOf(card_color) > -1;
                    is_illegal = is_illegal || colors.indexOf(card_color) == -1;
                }
            } else {
                is_match = true;
            }
            if (is_match && !is_illegal){
                out.push(card);
            }
        }
        out.sort(function(a,b){
            return a.name.localeCompare(b.name);
        });
        return out;
    };
    
})(Module('store'));
