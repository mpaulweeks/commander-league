# commander-league

todo:
    - price refreshing
    - categories
    - multiverse id
    - ajax for GET endpoint
    - swap endpoint

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

wallet
    user_slug
    delta
    timestamp

card
    name
    price
    price_fetched

status_code
    sideboard
    maindeck

card_status
    user_slug   string
    card_name   string
    timestamp   datetime
    maindeck    int
    sideboard   int

Endpoints

binder
    GET
        user_slug

swap
    POST
        binder
            user_slug
            from_maindeck
            from_sideboard

sideboard
    POST
        user_slug
        card_name
    DELETE
        user_slug
        card_name
