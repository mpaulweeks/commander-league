(function(module){

    var store = Module("store");
    var visual = Module("visual");
    var binder = Module("binder");

    function str_format(str){
        var args = arguments;
        return str.replace(/{(\d+)}/g, function(match, number) {
            return typeof args[number] != 'undefined' ? args[number] : match;
        });
    }

    var CARD_OPTION = '<option value="{1}">{1}</option>';

    module.index = function(){
        visual.draw_navbar();

        binder.init();
        var colors = binder.get_user().colors;
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
        visual.draw_navbar('../', '/diff');

        var data_str = $('#server_data').html()
        $('#server_data').empty()
        var data = JSON.parse(data_str);
        $('#user_name').html(data.user.name);
        var cards = data.cards;

        var out = {};
        for (var card_name in cards){
            var card = cards[card_name];
            if (card.added > 0){
                out[card.name] = card;
            } else if (card.added < 0){
                card.removed = Math.abs(card.added);
                out[card.name] = card;
            }
        }
        visual.cards = out;

        var list_types = [
            ['added', ''],
            ['removed', ''],
        ];

        visual.draw_cards(list_types, {}, null);
    };

})(Module('view'));

