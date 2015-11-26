# commander-league

ViewModels

binder
    user_id:    <int>
    cards:      <cardlist>

cardlist
    <string>: <card>

card
    name
    price
    category
    multiverse_id
    decklist
    sideboard
    from_decklist
    from_sideboard

Models

user
    user_id
    user_slug
    user_name

card
    id
    name
    price
    price_fetched

status_code
    sideboard
    decklist

card_status
    user_id
    card_id
    status_id
    timestamp