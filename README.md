# commander-league

ViewModels

binder
    user_id:    <string>
    cards:      <cardlist>

cardlist
    <string>: <card>

card
    name
    price
    category
    multiverse_id

    maindeck
    sideboard
    from_maindeck
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
    maindeck

card_status
    user_slug
    card_name
    status_id
    timestamp
