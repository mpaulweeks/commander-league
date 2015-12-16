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
    slug
    name

card
    name
    price
    price_fetched

status_code
    sideboard
    decklist

card_status
    user_slug
    card_name
    status_id
    timestamp
