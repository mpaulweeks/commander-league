(function(module){

    var store = Module("store");
    var binder = Module("binder");

    function str_format(str){
        var args = arguments;
        return str.replace(/{(\d+)}/g, function(match, number) {
            return typeof args[number] != 'undefined' ? args[number] : match;
        });
    }

    var CARD_OPTION = '<option value="{1}">{1}</option>';

    module.index = function(){
        binder.init();
        var colors = binder.get_binder().user.colors;
        store.get_cards_by_colors(colors).forEach(function (card_name){
            var card_html = str_format(CARD_OPTION, card_name);
            $('#lookup-select').append(card_html);
        });
        $('#lookup-select').select2({
            placeholder: "Click to type"
        });

        $("#lookup-form").on("submit", function(evt){
            evt.preventDefault();
            var card_name = $("#lookup-select").val();
            binder.add_card_to_sideboard(card_name);
        });
        $("#swap-cards").on("click", function(evt){
            evt.preventDefault();
            binder.swap_cards();
        });
    };

    module.diff = function(){
        var data_str = $('#server_data').html()
        $('#server_data').empty()
        var data = JSON.parse(data_str);

        var out = {
            added: [],
            removed: [],
        };
        for (var card_name in data){
            var card = data[card_name];
            if (card.added > 0){
                out.added.push(card);
            } else if (card.added < 0){
                out.removed.push(card);
            }
        }

        var sort_cards = function(a,b){
            return a.name.localeCompare(b.name);
        };

        var CARD_HTML = '<div>{2}x {1}</div>';

        for (var category in out){
            out[category].sort(sort_cards);
            var html = '';
            out[category].forEach(function (card){
                html += str_format(CARD_HTML, card.name, Math.abs(card.added));
            })
            $('#' + category).html(html);
        }
    };

})(Module('view'));

