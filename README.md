# commander-league

todo:
    - fetching price
    - multiverse id

ViewModels

binder
    user: dict
    cards: dict

card
    name
    price
    category
    multiverse_id
    maindeck
    sideboard
    maindeck_swap
    sideboard_swap

Models

user
    slug
    name

wallet
    user_slug
    delta
    timestamp

card
    name
    price
    price_fetched

status
    user_slug   string
    card_name   string
    maindeck    int
    sideboard   int
    timestamp   datetime

Endpoints /api

/user/:user_slug
    GET

/user/:user_slug/status
    POST
        list of:
            name
            maindeck
            sideboard
