# commander-league

## Todo

 - auto-generate navbar
 - nginx
 - reduce size of lookup
 - mutex lock on database.json?

## Public API

### /api/user/:user_slug GET

#### Example URL

`/api/user/mpw`

#### Example Response

```
{
    "user":{
        "slug":"mpw",
        "name":"M. Paul",
        "colors":["B","G"],
        "balance":4.0
    },
    "cards":{
        "Sakura-Tribe Elder":{
            "name":"Sakura-Tribe Elder",
            "price":0.25,
            "maindeck":1,
            "sideboard":0,
            "category":"Creature",
            "multiverse":405363
        },
        ...
    },
}
```

### /api/user/:user_slug/status POST

#### Example URL

`/api/user/eliah/status`

#### Example Request

```
[
    {
        "name":"Abduction",
        "maindeck":0,
        "sideboard":1,
    },
    {
        "name":"Lightning Greaves",
        "maindeck":1,
        "sideboard":0,
    },
]   
```

#### Example Response
```
{
    "user":{
        "slug":"eliah",
        "name":"Eliah",
        "colors":["U","G"],
        "balance":4.25,
    },
    "cards":{
        "Abduction":{
            "name":"Abduction",
            "price":null,
            "maindeck":0,
            "sideboard":1,
            "category":"Spell",
            "multiverse":14526,
        },
        "Lightning Greaves":{
            "name":"Lightning Greaves",
            "price":0.75,
            "maindeck":1,
            "sideboard":0,
            "category":"Spell",
            "multiverse":405284,
        }
    },
}
```

## Database

```
user
    slug
    name
    colors 

wallet
    user_slug
    delta
    timestamp

card
    name
    price
    price_fetched

status
    user_slug
    card_name
    maindeck
    sideboard
    timestamp
```
