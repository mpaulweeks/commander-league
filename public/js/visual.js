(function(module){

    module.cards = {};

    var autocard = Module("autocard");

    var valid_multiples = {
        "Forest": true,
        "Plains": true,
        "Swamp": true,
        "Island": true,
        "Mountain": true,
    }

    function multiples_ok(card){
        return card.name in valid_multiples;
    }
    module.multiples_ok = multiples_ok;

    function str_format(str){
        var args = arguments;
        return str.replace(/{(\d+)}/g, function(match, number) {
            return typeof args[number] != 'undefined' ? args[number] : match;
        });
    }
    module.str_format = str_format;

    var INCREMENT_SIDEBOARD = '<input type="button" class="action" data-func="increment_sideboard" value="+"/>';
    var CARD = '<div class="col-md-12"></div><div class="col-md-{5}" data-id="{1}">{2} {3}x <a href="http://combodeck.net/Query/{1}" target="_blank" class="mtgcard">{1}</a></div>{4}';
    var CATEGORY = '<div class="col-md-12 category text-center">{1} ({2})</div>';
    var PRICE = '<div class="col-md-3 price text-right">{1}</div>';

    function format_price(price){
        if (price == null){
            return 'FREE';
        }
        return price.toFixed(2);
    }
    module.format_price = format_price;

    function get_card_html(card, property, display){
        var count = card[property];
        if (multiples_ok(card) && property == "sideboard"){
            display += INCREMENT_SIDEBOARD;
        }
        var price_html = '';
        var card_width = 12;
        if (property == 'sideboard' || property == 'sideboard_swap'){
            var price_str = format_price(card.price);
            price_html = str_format(PRICE, price_str);
            card_width = 9;
        }
        return str_format(CARD, card.name, display, count, price_html, card_width);
    }

    function get_cards_html(cards, list_type){
        var html_out = "";
        for (var i = 0; i < cards.length; i++){
            var card = cards[i];
            html_out += get_card_html(card, list_type[0], list_type[1]);
        }
        return html_out;
    }

    var categories = ['Land', 'Creature', 'Spell'];
    module.categories = categories;

    function draw_cards(list_types, card_actions, callback){
        var input_cards = module.cards;

        var cards_by_category_then_list = {};
        categories.forEach(function (category){
            var matching_cards = [];
            for (var key in input_cards){
                var card = input_cards[key];
                if (card.category == category){
                    matching_cards.push(card);
                }
            }
            matching_cards.sort(function (a,b){
                return a.name.localeCompare(b.name);
            });
            var sub_dict = {};
            list_types.forEach(function (list_type){
                var cards_in_list = [];
                var total_count = 0;
                var list_label = list_type[0];
                matching_cards.forEach(function (card){
                    var card_count = card[list_label];
                    if (card_count > 0){
                        total_count += card_count;
                        cards_in_list.push(card);
                    }
                });
                sub_dict[list_label] = {
                    cards: cards_in_list,
                    count: total_count,
                };
            });
            cards_by_category_then_list[category] = sub_dict;
        });

        list_types.forEach(function (list_type){
            var total_html = '';
            var list_label = list_type[0];
            categories.forEach(function (category){
                var matching_dict = cards_by_category_then_list[category][list_label];
                if (matching_dict.count > 0){
                    var cards_html = get_cards_html(matching_dict.cards, list_type);
                    total_html += str_format(CATEGORY, category, matching_dict.count) + cards_html;
                }
            });
            $('#' + list_label).html(total_html);
        });

        $(".action").on('click', function(evt){
            var name = $(this).parent().data('id');
            var card = input_cards[name];
            var action = $(this).data("func");
            card_actions[action](card);
            callback();
        });

        autocard.init();

        return cards_by_category_then_list;
    }
    module.draw_cards = draw_cards;

})(Module('visual'));

