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

    function getParameterByName(name) {
        name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
        var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
            results = regex.exec(location.search);
        return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
    }

    function copyTextToClipboard(text) {
        // Taken from: http://stackoverflow.com/a/30810322

        var textArea = document.createElement("textarea");

        //
        // *** This styling is an extra step which is likely not required. ***
        //
        // Why is it here? To ensure:
        // 1. the element is able to have focus and selection.
        // 2. if element was to flash render it has minimal visual impact.
        // 3. less flakyness with selection and copying which **might** occur if
        //    the textarea element is not visible.
        //
        // The likelihood is the element won't even render, not even a flash,
        // so some of these are just precautions. However in IE the element
        // is visible whilst the popup box asking the user for permission for
        // the web page to copy to the clipboard.
        //

        // Place in top-left corner of screen regardless of scroll position.
        textArea.style.position = 'fixed';
        textArea.style.top = 0;
        textArea.style.left = 0;

        // Ensure it has a small width and height. Setting to 1px / 1em
        // doesn't work as this gives a negative w/h on some browsers.
        textArea.style.width = '2em';
        textArea.style.height = '2em';

        // We don't need padding, reducing the size if it does flash render.
        textArea.style.padding = 0;

        // Clean up any borders.
        textArea.style.border = 'none';
        textArea.style.outline = 'none';
        textArea.style.boxShadow = 'none';

        // Avoid flash of white box if rendered for any reason.
        textArea.style.background = 'transparent';


        textArea.value = text;

        document.body.appendChild(textArea);

        textArea.select();

        try {
            var successful = document.execCommand('copy');
            var msg = successful ? 'successful' : 'unsuccessful';
            console.log('Copying text command was ' + msg);
        } catch (err) {
            console.log('Oops, unable to copy');
        }

        document.body.removeChild(textArea);
        alert("Copied to clipboard!");
    }

    var color_mapping = [
        [["U", "G"], "gu"],
        [["W", "B"], "wb"],
        [["B", "G"], "bg"],
        [["W", "R"], "rw"],
        [["U", "R"], "ur"],
    ]
    function get_color_html(colors){
        function two_colors_html(two_colors){
            var color_file = 'null';
            var sorted_colors = JSON.stringify(two_colors.concat().sort());
            color_mapping.forEach(function (mapping){
                if (sorted_colors == JSON.stringify(mapping[0].concat().sort())){
                    color_file = mapping[1];
                }
            });
            return str_format(MANA_SYMBOL_HTML, color_file);
        };
        var color_html = '';
        if (colors.length > 2){
            for (var i = 0; i < colors.length/2; i += 1){
                var two_colors = [colors[i], colors[i+2]];
                color_html += two_colors_html(two_colors);
            }
        } else {
            color_html = two_colors_html(colors);
        }
        return color_html;
    }
    var MANA_SYMBOL_HTML = '<img class="mana-symbol" src="/img/mana-symbol-{1}.png" />';
    var TITLE_HTML = '{2} {1} {2}';

    function init(){
        visual.draw_navbar();

        var data_str = $('#server_data').html()
        $('#server_data').empty()
        var data = JSON.parse(data_str);

        var mana_symbol_html = get_color_html(data.user.colors);
        var title_html = str_format(TITLE_HTML, data.user.name, mana_symbol_html);
        $('#user_name').html(title_html);

        $('.copy').on("click", function(){
            var list_id = $(this).data("id");
            var card_list = "";
            $(".cardlistdisplay#" + list_id).children().each(function (){
                var row = $(this);
                if (row.data("id")){
                    card_list += (row.text() + '\n').substring(1);
                }
            });
            copyTextToClipboard(card_list);
        });

        return data;
    }

    var CARD_OPTION = '<option value="{1}">{1}</option>';

    module.index = function(){
        var data = init();
        binder.init(data);

        $("#lookup-form").on("submit", function(evt){
            evt.preventDefault();
            var card_name = $("#lookup-select").val();
            binder.add_card_to_sideboard(card_name, function (){
                console.log("callback");
                $("#lookup-select").select2("data", null);
            });
        });
        $("#swap-cards").on("click", function(evt){
            evt.preventDefault();
            binder.swap_cards();
        });

        store.init(function (){
            $('#lookup-holder').removeClass('hidden');
            $('#lookup-loading').addClass('hidden');

            var colors = data.user.colors;
            store.get_cards_by_colors(colors).forEach(function (card_name){
                var card_html = str_format(CARD_OPTION, card_name);
                $('#lookup-select').append(card_html);
            });
            $('#lookup-select').select2({
                minimumInputLength: 3,
                placeholder: "Click to type"
            });
        });
    };

    function convert_from_datepicker(date_str){
        if (date_str.length == 0){
            return null;
        }
        return str_format(
            "{1}-{2}-{3}",
            date_str.substring(6),
            date_str.substring(0,2),
            date_str.substring(3,5)
        );
    }

    function convert_to_datepicker(date_str){
        if (date_str.length == 0){
            return "";
        }
        return str_format(
            "{1}/{2}/{3}",
            date_str.substring(5,7),
            date_str.substring(8),
            date_str.substring(0,4)
        );
    }

    var date_args = ["from", "to"];

    function load_dates(){
        date_args.forEach(function (arg){
            var query = getParameterByName(arg);
            var dp_val = convert_to_datepicker(query);
            $('#date-' + arg).val(dp_val);
        });
    }

    function reload_diff(){
        var args = {};
        date_args.forEach(function (arg){
            var str = convert_from_datepicker($("#date-" + arg).val());
            if (str != null){
                args[arg] = str;
            }
        });
        var new_url = window.location.pathname;
        if (!$.isEmptyObject(args)){
            new_url += "?" + $.param(args);
        }
        window.location.href = new_url;
    }

    module.diff = function(){
        var data = init();

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

        $(".datepicker").datepicker();
        load_dates();
        $(".datepicker").on("change", reload_diff);
        $("#date-reset").on("click", function(){
            $(".datepicker").val("");
            reload_diff();
        });
    };

})(Module('view'));

