# commander-league

http://edh.mpaulweeks.com

[![Circle CI](https://circleci.com/gh/mpaulweeks/commander-league.svg?style=svg)](https://circleci.com/gh/mpaulweeks/commander-league)

## install

Might need to install `sinatra`, Ruby dependencies/installation was not documented :(

See `crontab`

## deploy

Push changes to the `deploy` branch,  `cron_commander.sh` job will automatically pull changes and restart the server.

## Public Views

### /:user_slug

#### Example URL

`/mpw`

### /:user_slug/diff

#### Example URL

`/mpw/diff`

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
        "balance":400
    },
    "cards":{
        "Sakura-Tribe Elder":{
            "name":"Sakura-Tribe Elder",
            "price":25,
            "maindeck":1,
            "sideboard":0,
            "category":"Creature",
            "multiverse":405363
        },
        ...
    },
}
```

### /api/user/:user_slug/diff GET

#### Example URL

`/api/user/mpw/diff`

#### Example Response

```
{
    "user":{
        "slug":"mpw",
        "name":"M. Paul",
        "colors":["B","G"],
        "balance":400
    },
    "cards":{
        "Sakura-Tribe Elder":{
            "name":"Sakura-Tribe Elder",
            "added": 0,
            "category":"Creature",
            "multiverse":405363
        },
        "Naya Panorama":{
            "name":"Naya Panorama",
            "added":1,
            "category":"Land",
            "multiverse":376424
        },
        ...
    }
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
        "balance":425,
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
            "price":75,
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
