(function(module){

    var tool = Module("tool");

    var ALL_CARDS_FILE = 'json/binder.json';
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

    function load_binder(user_id){
        if (user_id in module.all_binders){
            return module.all_binders[user_id];
        }
        return {};
    }

    function save_binder(user_id, binder){
        module.all_binders[user_id] = binder;
        console.log(module.all_binders);
    }
    
})(Module('store'));
