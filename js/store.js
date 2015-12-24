(function(module){

    var ALL_CARDS_FILE = 'json/AllCards.json';
    var GITHUB_BASE = 'http://mpaulweeks.github.io/commander-league/';

    module.all_cards = null;

    function fix_file(file_url){
        // if (tool.is_local && !tool.is_firefox){
        //     return GITHUB_BASE + file_url;
        // }
        return file_url;
    }

    module.init = function(callback){
        var all_cards_file = fix_file(ALL_CARDS_FILE);
        $.getJSON(all_cards_file, function(all_cards_data){
            var lower_data = {};
            for (var key in all_cards_data){
                lower_data[key.toLowerCase()] = all_cards_data[key];
            }
            module.all_cards = lower_data;
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

    module.get_card = function(card_name, callback){
        var card = module.all_cards[card_name.toLowerCase()];
        var new_card = {
            'name': card.name,
        };
        callback(new_card);
    };

    module.get_cards_by_colors = function(colors){
        var out = [];
        for (var key in module.all_cards){
            var card = module.all_cards[key];
            var is_match = false;
            var is_illegal = false;
            if ("colorIdentity" in card){
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
