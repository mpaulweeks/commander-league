# commander-league

## todo
 - script to backup db
 - splash page
 - auto-generate navbar
 - don't make everything public
 - nginx

## API

### /api/:user_slug GET

#### response

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
            "price":null,
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

#### request

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

#### response
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
            "price":null,
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
```
