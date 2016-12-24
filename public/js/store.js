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
            url: '/api/user/' + user_slug + '/status',
            type: 'POST',
            contentType: "charset=utf-8",
            data: data,
        }).done(function (data){
            callback(data);
        }).fail(function (){
            alert("There was an error. Please contact the admin.");
        });
    };

    module.get_cards_by_colors = function(colors){
        var out = [];
        module.lookup.forEach(function (card){
            var card_name = card[0];
            var card_colors = card[1];
            var is_match = false;
            var is_illegal = false;
            if (card_colors.length > 0){
                for (var i = 0; i < card_colors.length; i++){
                    var card_color = card_colors[i];
                    is_match = is_match || colors.indexOf(card_color) > -1;
                    is_illegal = is_illegal || colors.indexOf(card_color) == -1;
                }
            } else {
                is_match = true;
            }
            if (is_match && !is_illegal){
                out.push(card_name);
            }
        });
        out.sort(function(a,b){
            return a.localeCompare(b);
        });
        return out;
    };
    
})(Module('store'));
