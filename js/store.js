(function(module){

    var BINDER_FILE = 'json/binder.json';
    var ALL_CARDS_FILE = 'json/AllCards.json';
    var GITHUB_BASE = 'http://mpaulweeks.github.io/commander-league/';

    module.all_cards = null;
    module.all_binders = null;

    function fix_file(file_url){
        // if (tool.is_local && !tool.is_firefox){
        //     return GITHUB_BASE + file_url;
        // }
        return file_url;
    }

    function init(callback){
        var all_cards_file = fix_file(ALL_CARDS_FILE);
        var binder_file = fix_file(BINDER_FILE);
        $.getJSON(binder_file, function(binder_data){
            module.all_binders = binder_data;
            $.getJSON(all_cards_file, function(all_cards_data){
                var lower_data = {};
                for (var key in all_cards_data){
                    lower_data[key.toLowerCase()] = all_cards_data[key];
                }
                module.all_cards = lower_data;
                callback();
            });
        });
    }
    module.init = init;

    function load_binder(user_id, callback){
        var ret = null;
        if (user_id in module.all_binders){
            ret = module.all_binders[user_id];
        }
        else {
            ret = {
                user_id: user_id,
                cards: {},
            };
        }
        callback(ret);
    }
    module.load_binder = load_binder;

    function save_binder(binder, callback){
        module.all_binders[binder.user_id] = binder;
        console.log(module.all_binders);
        callback();
    }
    module.save_binder = save_binder;

    function modify_sideboard(user_slug, card_name, quantity, callback){
        $.ajax({
            url: 'binder/sideboard',
            type: 'PUT',
            data: {
                user_slug: user_slug,
                card_name: card_name,
                quantity: quantity,
            },
        }).done(function (data){
            callback(data);
        });
    }
    module.modify_sideboard = modify_sideboard;

    function create_statuses(user_slug, cards, callback){
        data = JSON.stringify(cards)
        $.ajax({
            url: 'api/user/' + user_slug + '/status',
            type: 'POST',
            data: data,
        }).done(function (data){
            callback(data);
        });
    }
    module.create_statuses = create_statuses;

    module.get_card = function(card_name, callback){
        var card = module.all_cards[card_name.toLowerCase()];
        callback(card);
    }

    module.get_cards_by_colors = function(colors){
        var out = [];
        for (var key in module.all_cards){
            var card = module.all_cards[key];
            var is_match = false;
            var is_illegal = false;
            if ("colors" in card){
                for (var i = 0; i < card.colors.length; i++){
                    var card_color = card.colors[i];
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
    }
    
})(Module('store'));
