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

    module.get_card = function(card_name, callback){
        var card = module.all_cards[card_name.toLowerCase()];
        callback(card);
    }
    
})(Module('store'));
