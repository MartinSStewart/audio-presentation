module CharacterData exposing (..)


type alias Character =
    { name : String
    , introText : String
    , outroText : String
    , bulletPattern : String
    , possibleSongs : List String
    , notes : String
    }


at =
    { name = "AT"
    , introText = "I'm just trying to slow you down so there's more time to finish the statistics"
    , outroText = "Okay you got me. But maybe try to pad out your time with the rest of the bosses?"
    , bulletPattern = "I'll say something like `sin(x)` and then a moment later a bullet pattern will match that"
    , possibleSongs =
        [ "https://www.youtube.com/watch?v=nVA0d6Jgx_0"
        ]
    , notes = ""
    }


at2 =
    { name = "AT2"
    , introText = "The time of man is at an end."
    , outroText = """Happy birthday to you (x    2)...
Haaaappy brthday de-r.. %^^^^^.--000000...
#$$  00000x134442521.... ,"""
    , bulletPattern = "also AT2's bullet patterns are going to be slow moving arcing shots followed by explosions made to mimic ICBM missles"
    , possibleSongs =
        [ "https://www.youtube.com/watch?v=dqeDhdyt6-k"
        , "https://www.youtube.com/watch?v=jBEC9qcU3JE"
        , "https://www.youtube.com/watch?v=DMWyIqpguNc"
        ]
    , notes = "Each attack wave would be preceeded by \"The word of the day is despair/futility/doom. Think about what that means to you.\""
    }


maela =
    { name = "Maela"
    , introText = "Would like to know who was the most chatty this year? I bet it was me ;)"
    , outroText = "Aurgh! Well you're probably the most annoying person this year!!"
    , bulletPattern = ""
    , possibleSongs =
        [ "https://www.youtube.com/watch?v=K_7K7v2KGYU"
        ]
    , notes = ""
    }


thomas =
    { name = "Thomas"
    , introText = "If you press alt F4 you skip to the next boss"
    , outroText = "lol"
    , bulletPattern = ""
    , possibleSongs = []
    , notes = ""
    }


luxara =
    { name = "Luxara"
    , introText = ""
    , outroText = ""
    , bulletPattern = ""
    , possibleSongs = [ "https://www.youtube.com/watch?v=Zp-SsaN7buI" ]
    , notes = ""
    }


vokva =
    { name = "Vokva"
    , introText = ""
    , outroText = ""
    , bulletPattern = ""
    , possibleSongs = [ "https://www.youtube.com/watch?v=ms06izzJdCA" ]
    , notes = ""
    }


someone =
    { name = "I don't know yet"
    , introText = ""
    , outroText = ""
    , bulletPattern = "They create a floor plan made out of bullets and then open the door and invite you in for tea"
    , possibleSongs = []
    , notes = ""
    }
