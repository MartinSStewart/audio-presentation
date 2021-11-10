module Backend exposing (app)

import Lamdera exposing (ClientId, SessionId)


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init =
    ( {}, Cmd.none )


update msg model =
    ( model, Cmd.none )


updateFromFrontend sessionId clientId msg model =
    ( model, Cmd.none )


subscriptions model =
    Sub.none
