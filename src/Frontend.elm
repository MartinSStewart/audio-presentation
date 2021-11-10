port module Frontend exposing (app, init, update, updateFromBackend, view)

import Angle exposing (Angle)
import Audio exposing (Audio, AudioCmd)
import Basics.Extra
import Browser exposing (UrlRequest(..))
import Browser.Dom
import Browser.Events
import Browser.Navigation
import Coord exposing (Coord)
import Duration exposing (Duration)
import Element exposing (Element)
import Element.Background
import Element.Font
import Element.Input
import Html exposing (Html)
import Html.Attributes
import Json.Decode
import Json.Encode
import Keyboard
import Keyboard.Arrows
import List.Extra as List
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 exposing (Vec2)
import Pixels exposing (Pixels)
import Point2d
import Quantity exposing (Quantity(..), Rate)
import Round
import Shaders exposing (Vertex)
import Sprite exposing (Sprite)
import SyntaxHighlight
import Task
import Time
import Types exposing (..)
import Units exposing (ScreenCoordinate, WorldCoordinate, WorldPixel)
import Url exposing (Url)
import WebGL exposing (Shader)
import WebGL.Settings
import WebGL.Settings.Blend as Blend
import WebGL.Texture exposing (Texture)


port martinsstewart_elm_device_pixel_ratio_from_js : (Float -> msg) -> Sub msg


port martinsstewart_elm_device_pixel_ratio_to_js : () -> Cmd msg


port audioPortToJS : Json.Encode.Value -> Cmd msg


port audioPortFromJS : (Json.Decode.Value -> msg) -> Sub msg


app =
    Audio.lamderaFrontendWithAudio
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = \_ msg model -> update msg model |> (\( a, b ) -> ( a, b, Audio.cmdNone ))
        , updateFromBackend = \_ msg model -> updateFromBackend msg model |> (\( a, b ) -> ( a, b, Audio.cmdNone ))
        , subscriptions = subscriptions
        , view = view
        , audio = audio
        , audioPort = { toJS = audioPortToJS, fromJS = audioPortFromJS }
        }


audio : Audio.AudioData -> FrontendModel_ -> Audio
audio audioData model =
    case model of
        Loading _ ->
            Audio.silence

        Loaded frontendLoaded ->
            gameAudio audioData frontendLoaded

        LoadingFailed ->
            Audio.silence


audioExamples =
    [ ( \_ _ -> Audio.silence, """module Game exposing (main)

main =
    Audio.elementWithAudio
        { init = ...
        , update = ...
        , view = ...
        , audioPort =
            { toJS = audioPortToJS
            , fromJS = audioPortFromJS
            }
        , audio = audio
        }


audio : Model -> Audio
audio model =
    case model.startTime of
        Nothing ->
            Audio.silence

        Just startTime ->
            Audio.silence""" )
    , ( \model startTime ->
            Audio.audio
                model.popSound
                (Duration.addTo startTime avoidCirclesTextDelay)
      , """module Game exposing (main)

main =
    Audio.elementWithAudio
        { init = ...
        , update = ...
        , view = ...
        , audioPort =
            { toJS = audioPortToJS
            , fromJS = audioPortFromJS
            }
        , audio = audio
        }


audio : Model -> Audio
audio model =
    case model.startTime of
        Nothing ->
            Audio.silence

        Just startTime ->
            Audio.audio
                model.popSound
                (Duration.addTo startTime avoidCirclesTextDelay)"""
      )
    , ( \model startTime ->
            Audio.audio
                model.popSound
                (Duration.addTo startTime avoidCirclesTextDelay)
      , """Audio.audio
    model.popSound
    (Duration.addTo startTime avoidCirclesTextDelay)"""
      )
    , ( \model startTime ->
            Audio.audio
                model.popSound
                (Duration.addTo startTime avoidCirclesTextDelay)
                |> Audio.scaleVolume 0.5
      , """Audio.audio
    model.popSound
    (Duration.addTo startTime avoidCirclesTextDelay)
    |> Audio.scaleVolume 0.5"""
      )
    , ( \model startTime ->
            Audio.group
                [ Audio.audio
                    model.popSound
                    (Duration.addTo startTime avoidCirclesTextDelay)
                    |> Audio.scaleVolume 0.5
                , Audio.audio
                    model.music
                    startTime
                ]
      , """Audio.group
    [ Audio.audio
        model.popSound
        (Duration.addTo startTime avoidCirclesTextDelay)
        |> Audio.scaleVolume 0.5

    , Audio.audio
        model.music -- Transistor OST - Impossible
        startTime
    ]"""
      )
    , ( \model startTime ->
            Audio.group
                [ Audio.audio
                    model.popSound
                    (Duration.addTo startTime avoidCirclesTextDelay)
                    |> Audio.scaleVolume 0.5
                , Audio.audio
                    model.music
                    startTime
                ]
                |> Audio.scaleVolume model.masterVolume
      , """Audio.group
    [ Audio.audio
        model.popSound
        (Duration.addTo startTime avoidCirclesTextDelay)
        |> Audio.scaleVolume 0.5

    , Audio.audio
        model.music -- Transistor OST - Impossible
        startTime
    ]
    |> Audio.scaleVolume model.masterVolume"""
      )
    , ( \model startTime ->
            Audio.group
                [ Audio.audio
                    model.popSound
                    (Duration.addTo startTime avoidCirclesTextDelay)
                    |> Audio.scaleVolume 0.5
                , Audio.audioWithConfig
                    { loop =
                        Just
                            { loopStart = Duration.seconds 5.759
                            , loopEnd = Duration.seconds 28.3
                            }
                    , playbackRate = 1
                    , startAt = Duration.seconds 0
                    }
                    model.music
                    startTime
                ]
                |> Audio.scaleVolume model.masterVolume
      , """Audio.group
    [ Audio.audio
        model.popSound
        (Duration.addTo startTime avoidCirclesTextDelay)
        |> Audio.scaleVolume 0.5

    , Audio.audioWithConfig
        { loop =
            Just
                { loopStart = Duration.seconds 5.76
                , loopEnd = Duration.seconds 28.3
                }
        , playbackRate = 1
        , startAt = Duration.seconds 0
        }
        model.music -- Transistor OST - Impossible
        startTime
    ]
    |> Audio.scaleVolume model.masterVolume"""
      )
    , ( \model startTime ->
            Audio.group
                [ Audio.audio
                    model.popSound
                    (Duration.addTo
                        startTime
                        avoidCirclesTextDelay
                    )
                    |> Audio.scaleVolume 0.5
                , case model.isDead of
                    Nothing ->
                        Audio.audioWithConfig
                            { loop =
                                Just
                                    { loopStart = Duration.seconds 5.76
                                    , loopEnd = Duration.seconds 28.3
                                    }
                            , playbackRate = 1
                            , startAt = Duration.seconds 0
                            }
                            model.music
                            startTime

                    Just _ ->
                        Audio.silence
                ]
                |> Audio.scaleVolume model.masterVolume
      , """Audio.group
    [ Audio.audio
        model.popSound
        (Duration.addTo startTime avoidCirclesTextDelay)
        |> Audio.scaleVolume 0.5

    , case model.isDead of
        Nothing ->
            Audio.audioWithConfig
                { loop =
                    Just
                        { loopStart = Duration.seconds 5.76
                        , loopEnd = Duration.seconds 28.3
                        }
                , playbackRate = 1
                , startAt = Duration.seconds 0
                }
                model.music -- Transistor OST - Impossible
                startTime

        Just _ ->
            Audio.silence
    ]
    |> Audio.scaleVolume model.masterVolume"""
      )
    , ( \model startTime ->
            Audio.group
                [ Audio.audio
                    model.popSound
                    (Duration.addTo
                        startTime
                        avoidCirclesTextDelay
                    )
                    |> Audio.scaleVolume 0.5
                , case model.isDead of
                    Nothing ->
                        Audio.audioWithConfig
                            { loop =
                                Just
                                    { loopStart = Duration.seconds 5.76
                                    , loopEnd = Duration.seconds 28.3
                                    }
                            , playbackRate = 1
                            , startAt = Duration.seconds 0
                            }
                            model.music
                            startTime

                    Just gameOverTime ->
                        Audio.audio model.gameOverSound gameOverTime
                ]
                |> Audio.scaleVolume model.masterVolume
      , """Audio.group
    [ Audio.audio
        model.popSound
        (Duration.addTo startTime avoidCirclesTextDelay)
        |> Audio.scaleVolume 0.5

    , case model.isDead of
        Nothing ->
            Audio.audioWithConfig
                { loop =
                    Just
                        { loopStart = Duration.seconds 5.76
                        , loopEnd = Duration.seconds 28.3
                        }
                , playbackRate = 1
                , startAt = Duration.seconds 0
                }
                model.music -- Transistor OST - Impossible
                startTime

        Just gameOverTime ->
            Audio.audio model.gameOverSound gameOverTime
    ]
    |> Audio.scaleVolume model.masterVolume"""
      )
    , ( \model startTime ->
            Audio.group
                [ Audio.audio
                    model.popSound
                    (Duration.addTo startTime avoidCirclesTextDelay)
                    |> Audio.scaleVolume 0.5
                , case model.isDead of
                    Nothing ->
                        Audio.audioWithConfig
                            { loop =
                                Just
                                    { loopStart = Duration.seconds 5.76
                                    , loopEnd = Duration.seconds 28.3
                                    }
                            , playbackRate = 1
                            , startAt = Duration.seconds 0
                            }
                            model.music
                            startTime

                    Just gameOverTime ->
                        Audio.audio model.gameOverSound gameOverTime
                , bulletPattern model
                    |> List.sortBy (.creationTime >> Time.posixToMillis >> negate)
                    |> List.take 5
                    |> List.map (\bullet -> Audio.audio model.popSound bullet.creationTime)
                    |> Audio.group
                ]
                |> Audio.scaleVolume model.masterVolume
      , """Audio.group
    [ Audio.audio
        model.popSound
        (Duration.addTo startTime avoidCirclesTextDelay)
        |> Audio.scaleVolume 0.5

    , case model.isDead of
        Nothing ->
            Audio.audioWithConfig
                { loop =
                    Just
                        { loopStart = Duration.seconds 5.76
                        , loopEnd = Duration.seconds 28.3
                        }
                , playbackRate = 1
                , startAt = Duration.seconds 0
                }
                model.music -- Transistor OST - Impossible
                startTime

        Just gameOverTime ->
            Audio.audio model.gameOverSound gameOverTime

    , bulletPattern model
        |> List.sortBy
            (.creationTime >> Time.posixToMillis >> negate)
        |> List.take 5
        |> List.map
            (\\bullet -> Audio.audio model.popSound bullet.creationTime)
        |> Audio.group
    ]
    |> Audio.scaleVolume model.masterVolume"""
      )
    ]


gameAudio : Audio.AudioData -> FrontendLoaded -> Audio
gameAudio _ model =
    if model.slide < audioExampleStartSlide then
        Audio.silence

    else
        case ( model.startTime, List.getAt (model.slide - audioExampleStartSlide) audioExamples ) of
            ( Just startTime, Just ( audioSlide, _ ) ) ->
                audioSlide model startTime

            _ ->
                case
                    ( model.previousSlide
                    , model.slide - (audioExampleStartSlide + List.length audioExamples)
                    )
                of
                    ( Just slideChangeTime, 2 ) ->
                        Audio.group
                            [ bulletPattern2 model.time slideChangeTime
                                |> List.sortBy (.creationTime >> Time.posixToMillis >> negate)
                                |> List.take 5
                                |> List.map (\bullet -> Audio.audio model.popSound bullet.creationTime)
                                |> Audio.group
                            , Audio.audio model.gameOverSound slideChangeTime |> Audio.offsetBy (Duration.seconds 3)
                            ]

                    _ ->
                        Audio.silence


loadedInit : FrontendLoading -> ( FrontendModel_, Cmd FrontendMsg_ )
loadedInit loading =
    Maybe.map5
        (\textureResult windowSize ( popSoundResult, musicResult, deathSoundResult ) time devicePixelRatio ->
            case ( textureResult, ( popSoundResult, musicResult, deathSoundResult ) ) of
                ( Ok texture, ( Ok popSound, Ok music, Ok deathSound ) ) ->
                    let
                        shortcut =
                            { key = loading.key
                            , texture = texture
                            , pressedKeys = []
                            , previousKeys = []
                            , windowSize = windowSize
                            , devicePixelRatio = devicePixelRatio
                            , time = time
                            , previousTime = time
                            , popSound = popSound
                            , music = music
                            , deathSound = deathSound
                            , playerPosition = startPosition
                            , hasMoved = Just (Duration.addTo time (Duration.seconds -40))
                            , isDead = Nothing
                            , volume = 0.8
                            }
                    in
                    ( --shortcut
                      { key = loading.key
                      , texture = texture
                      , pressedKeys = []
                      , previousKeys = []
                      , windowSize = windowSize
                      , devicePixelRatio = devicePixelRatio
                      , time = time
                      , previousTime = time
                      , popSound = popSound
                      , music = music
                      , gameOverSound = deathSound
                      , playerPosition = startPosition
                      , startTime = Nothing
                      , isDead = Nothing
                      , masterVolume = 0.8
                      , slide = 0
                      , previousSlide = Nothing
                      }
                        |> Loaded
                    , Cmd.none
                    )

                _ ->
                    ( LoadingFailed, Cmd.none )
        )
        loading.texture
        loading.windowSize
        (Maybe.map3 (\a b c -> ( a, b, c )) loading.popSound loading.music loading.gameOverSound)
        loading.time
        loading.devicePixelRatio
        |> Maybe.withDefault ( Loading loading, Cmd.none )


startPosition : Coord WorldPixel
startPosition =
    Coord.yOnly mapBottomRight
        |> Coord.plus (Sprite.playerTexturePosition.size |> Coord.scaleFloat ( 0, -0.9 ))


init : Url -> Browser.Navigation.Key -> ( FrontendModel_, Cmd FrontendMsg_, AudioCmd FrontendMsg_ )
init url key =
    ( Loading
        { key = key
        , windowSize = Nothing
        , devicePixelRatio = Nothing
        , time = Nothing
        , popSound = Nothing
        , music = Nothing
        , gameOverSound = Nothing
        , texture = Nothing
        }
    , Cmd.batch
        [ Task.perform
            (\{ viewport } ->
                WindowResized
                    ( round viewport.width |> Pixels.pixels
                    , round viewport.height |> Pixels.pixels
                    )
            )
            Browser.Dom.getViewport
        , WebGL.Texture.loadWith
            { magnify = WebGL.Texture.nearest
            , minify = WebGL.Texture.nearest
            , horizontalWrap = WebGL.Texture.clampToEdge
            , verticalWrap = WebGL.Texture.clampToEdge
            , flipY = False
            }
            "texture.png"
            |> Task.attempt TextureLoaded
        , Task.perform AnimationFrame Time.now
        ]
    , Audio.cmdBatch
        [ Audio.loadAudio MusicLoaded "transistor-loop.mp3"
        , Audio.loadAudio PopSoundLoaded "pop.mp3"
        , Audio.loadAudio DeathSoundLoaded "kirby-dead.mp3"
        ]
    )


update : FrontendMsg_ -> FrontendModel_ -> ( FrontendModel_, Cmd FrontendMsg_ )
update msg model =
    case model of
        Loading loadingModel ->
            case msg of
                WindowResized windowSize ->
                    ( Loading { loadingModel | windowSize = Just windowSize }
                    , martinsstewart_elm_device_pixel_ratio_to_js ()
                    )

                GotDevicePixelRatio devicePixelRatio ->
                    { loadingModel | devicePixelRatio = Just devicePixelRatio } |> loadedInit

                PopSoundLoaded result ->
                    { loadingModel | popSound = Just result } |> loadedInit

                MusicLoaded result ->
                    { loadingModel | music = Just result } |> loadedInit

                DeathSoundLoaded result ->
                    { loadingModel | gameOverSound = Just result } |> loadedInit

                TextureLoaded texture ->
                    { loadingModel | texture = Just texture } |> loadedInit

                AnimationFrame time ->
                    { loadingModel | time = Just time } |> loadedInit

                _ ->
                    ( model, Cmd.none )

        Loaded frontendLoaded ->
            updateLoaded msg frontendLoaded |> Tuple.mapFirst Loaded

        LoadingFailed ->
            ( model, Cmd.none )


updateLoaded : FrontendMsg_ -> FrontendLoaded -> ( FrontendLoaded, Cmd FrontendMsg_ )
updateLoaded msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Cmd.batch [ Browser.Navigation.pushUrl model.key (Url.toString url) ]
                    )

                External url ->
                    ( model
                    , Browser.Navigation.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        TextureLoaded _ ->
            ( model, Cmd.none )

        KeyMsg keyMsg ->
            ( { model | pressedKeys = Keyboard.update keyMsg model.pressedKeys }
            , Cmd.none
            )

        WindowResized windowSize ->
            ( { model | windowSize = windowSize }, martinsstewart_elm_device_pixel_ratio_to_js () )

        GotDevicePixelRatio devicePixelRatio ->
            ( { model | devicePixelRatio = devicePixelRatio }, Cmd.none )

        AnimationFrame time ->
            ( { model | time = time, previousTime = model.time }
                |> animationFrame
                |> (\m -> { m | previousKeys = model.pressedKeys })
            , Cmd.none
            )

        PopSoundLoaded _ ->
            ( model, Cmd.none )

        MusicLoaded _ ->
            ( model, Cmd.none )

        DeathSoundLoaded _ ->
            ( model, Cmd.none )

        DraggedMasterVolumeSlider volume ->
            ( { model | masterVolume = volume }, Cmd.none )


animationFrame : FrontendLoaded -> FrontendLoaded
animationFrame model =
    if keyPressed (Keyboard.Character "R") model then
        { model | isDead = Nothing, startTime = Nothing, playerPosition = startPosition }

    else
        { model
            | isDead =
                if model.isDead == Nothing && isHit model then
                    Just model.time

                else
                    model.isDead
            , startTime =
                case model.startTime of
                    Nothing ->
                        if
                            (Keyboard.Arrows.arrowsDirection model.pressedKeys /= Keyboard.Arrows.NoDirection)
                                || keyPressed Keyboard.Spacebar model
                        then
                            Just model.time

                        else
                            Nothing

                    Just startTime ->
                        if keyPressed Keyboard.Spacebar model then
                            if Duration.from startTime model.time |> Quantity.lessThan avoidCirclesTextDelay then
                                Duration.subtractFrom model.time avoidCirclesTextDelay |> Just

                            else if Duration.from startTime model.time |> Quantity.lessThan hideAvoidCirclesDelay then
                                Duration.subtractFrom model.time hideAvoidCirclesDelay |> Just

                            else
                                model.startTime

                        else
                            model.startTime
            , slide =
                if keyPressed (Keyboard.Character "Q") model then
                    model.slide - 1 |> max 0

                else if keyPressed (Keyboard.Character "W") model then
                    model.slide + 1

                else
                    model.slide
            , previousSlide =
                if keyPressed (Keyboard.Character "Q") model then
                    Nothing

                else if keyPressed (Keyboard.Character "W") model then
                    Just model.time

                else
                    model.previousSlide
            , playerPosition =
                case model.isDead of
                    Just _ ->
                        model.playerPosition

                    Nothing ->
                        (case Keyboard.Arrows.arrowsDirection model.pressedKeys of
                            Keyboard.Arrows.North ->
                                ( 0, -5 )

                            Keyboard.Arrows.NorthEast ->
                                ( 4, -4 )

                            Keyboard.Arrows.East ->
                                ( 5, 0 )

                            Keyboard.Arrows.SouthEast ->
                                ( 4, 4 )

                            Keyboard.Arrows.South ->
                                ( 0, 5 )

                            Keyboard.Arrows.SouthWest ->
                                ( -4, 4 )

                            Keyboard.Arrows.West ->
                                ( -5, 0 )

                            Keyboard.Arrows.NorthWest ->
                                ( -4, -4 )

                            Keyboard.Arrows.NoDirection ->
                                ( 0, 0 )
                        )
                            |> Coord.unsafe
                            |> Coord.plus model.playerPosition
                            |> Coord.maximum
                                (Coord.scaleFloat ( 0.5, 0.5 ) Sprite.playerTexturePosition.size |> Coord.plus mapTopLeft)
                            |> Coord.minimum
                                (Coord.scaleFloat ( -0.5, -0.5 ) Sprite.playerTexturePosition.size |> Coord.plus mapBottomRight)
        }


keyPressed : Keyboard.Key -> FrontendLoaded -> Bool
keyPressed key model =
    List.any ((==) key) model.pressedKeys && not (List.any ((==) key) model.previousKeys)


mapTopLeft : Coord WorldPixel
mapTopLeft =
    Coord.unsafe ( -220, -250 )


mapBottomRight : Coord WorldPixel
mapBottomRight =
    Coord.unsafe ( 220, 250 )


updateFromBackend : ToFrontend -> FrontendModel_ -> ( FrontendModel_, Cmd FrontendMsg_ )
updateFromBackend msg model =
    ( model, Cmd.none )


view : Audio.AudioData -> FrontendModel_ -> Browser.Document FrontendMsg_
view _ model =
    { title = "A game!"
    , body =
        [ case model of
            Loading _ ->
                Element.layout
                    [ Element.width Element.fill
                    , Element.height Element.fill
                    ]
                    (Element.text "Loading")

            Loaded loadedModel ->
                Element.layout
                    [ Element.width Element.fill
                    , Element.height Element.fill
                    , Element.Background.color (Element.rgb 0 0 0)
                    , Element.Font.color (Element.rgb 1 1 1)
                    ]
                    (viewSlide loadedModel)

            LoadingFailed ->
                Html.text "Loading failed"
        ]
    }


viewSlide : FrontendLoaded -> Element FrontendMsg_
viewSlide model =
    if model.slide == 0 then
        Element.el
            [ Element.Font.size 40, Element.centerX, Element.centerY ]
            (Element.text "Audio, Elm style!")

    else if model.slide == 1 then
        Element.el
            [ Element.Font.size 40, Element.centerX, Element.centerY ]
            (showCode "view : Model -> Html Msg")

    else if model.slide == 2 then
        Element.image
            [ Element.centerX, Element.centerY, Element.height Element.fill ]
            { src = "stale-view.png"
            , description = ""
            }

    else if model.slide == 3 then
        Element.el
            [ Element.Font.size 40, Element.centerX, Element.centerY ]
            (Element.text "I like making games")

    else if model.slide == 4 then
        Element.el
            [ Element.Font.size 40, Element.centerX, Element.centerY ]
            (Element.text "Games often have sound effects and music!")

    else if model.slide == 5 then
        Element.el
            [ Element.Font.size 32, Element.centerX, Element.centerY ]
            (showCode "startSound : Sound -> Cmd msg\n\nstopSound : Sound -> Cmd msg\n\nsetVolume : Float -> Sound -> Cmd msg")

    else if model.slide == 6 then
        Element.el
            [ Element.Font.size 32, Element.centerX, Element.centerY ]
            (showCode "-- Good!\nview : Model -> Html Msg\n\n-- What about this?\naudio : Model -> Audio")

    else if model.slide == 7 then
        Element.el
            [ Element.Font.size 40, Element.centerX, Element.centerY ]
            (Element.text "Lets try it!")

    else if model.slide >= audioExampleStartSlide - 1 && model.slide < audioExampleStartSlide + List.length audioExamples then
        Element.el
            [ Element.width Element.fill
            , Element.height Element.fill
            , Element.clip
            , Element.inFront <| codeView model
            , Element.inFront <|
                if model.slide > audioExampleStartSlide + 4 then
                    Element.el [ Element.alignRight, Element.padding 16 ]
                        (Element.Input.slider
                            [ Element.width (Element.px 200)
                            , Element.behindContent <|
                                Element.el
                                    [ Element.width Element.fill
                                    , Element.height Element.fill
                                    , Element.padding 6
                                    ]
                                    (Element.el
                                        [ Element.Background.color (Element.rgb 0.5 0.5 0.5)
                                        , Element.width Element.fill
                                        , Element.height Element.fill
                                        ]
                                        Element.none
                                    )
                            , Element.spacing 16
                            ]
                            { onChange = DraggedMasterVolumeSlider
                            , label =
                                Element.Input.labelLeft [ Element.alignTop ]
                                    (Element.text
                                        ("Master Volume = " ++ Round.round 2 model.masterVolume)
                                    )
                            , min = 0
                            , max = 1
                            , value = model.masterVolume
                            , thumb = Element.Input.defaultThumb
                            , step = Just 0.05
                            }
                        )

                else
                    Element.none
            ]
            (Element.html (canvasView model))

    else if model.slide == audioExampleStartSlide + List.length audioExamples then
        Element.el
            [ Element.Font.size 40, Element.centerX, Element.centerY ]
            (Element.text "Is this approach good for things other than games?")

    else if model.slide == audioExampleStartSlide + List.length audioExamples + 1 then
        Element.el
            [ Element.Font.size 40, Element.centerX, Element.centerY ]
            (Element.text "Not that I know of.")

    else if model.slide == audioExampleStartSlide + List.length audioExamples + 2 then
        let
            ( offsetX, offsetY, rotation ) =
                case model.previousSlide of
                    Just startTime ->
                        let
                            elapsedTime =
                                Time.posixToMillis model.time
                                    - Time.posixToMillis (textDeadTime startTime)
                                    |> max 0
                                    |> toFloat
                                    |> (*) 0.0015
                        in
                        ( elapsedTime * -100
                        , 900 * elapsedTime ^ 2 - elapsedTime * 900
                        , elapsedTime * 5
                        )

                    Nothing ->
                        ( 0, 0, 0 )
        in
        Element.el
            [ Element.width Element.fill
            , Element.height Element.fill
            , Element.clip
            , endCanvasView model
                |> Element.html
                |> Element.el [ Element.width Element.fill, Element.height Element.fill ]
                |> Element.behindContent
            ]
            (Element.el
                [ Element.Font.size 40
                , Element.centerX
                , Element.centerY
                , Element.moveLeft offsetX
                , Element.moveDown offsetY
                , Element.rotate rotation
                ]
                (Element.text "That's all folks!")
            )

    else if model.slide == audioExampleStartSlide + List.length audioExamples + 3 then
        Element.el
            [ Element.Font.size 40, Element.centerX, Element.centerY ]
            (Element.text "Questions?")

    else
        Element.none


audioExampleStartSlide =
    9


codeView : FrontendLoaded -> Element msg
codeView model =
    case List.getAt (model.slide - audioExampleStartSlide) audioExamples of
        Just ( _, audioExampleText ) ->
            showCode audioExampleText

        Nothing ->
            Element.none


showCode : String -> Element msg
showCode code =
    case SyntaxHighlight.elm code of
        Ok ok ->
            Html.div
                [ Html.Attributes.style "line-height" "1.1" ]
                [ SyntaxHighlight.useTheme SyntaxHighlight.monokai
                , SyntaxHighlight.toInlineHtml ok
                ]
                |> Element.html
                |> Element.el
                    [ Element.width Element.shrink
                    , Element.Background.color (Element.rgb255 35 36 31)
                    , Element.padding 8
                    ]

        Err _ ->
            Element.none


findPixelPerfectSize : FrontendLoaded -> { canvasSize : ( Int, Int ), actualCanvasSize : ( Int, Int ) }
findPixelPerfectSize frontendModel =
    let
        (Quantity pixelRatio) =
            frontendModel.devicePixelRatio

        findValue : Quantity Int Pixels -> ( Int, Int )
        findValue value =
            List.range 0 9
                |> List.map ((+) (Pixels.inPixels value))
                |> List.find
                    (\v ->
                        let
                            a =
                                toFloat v * pixelRatio
                        in
                        a == toFloat (round a) && modBy 2 (round a) == 0
                    )
                |> Maybe.map (\v -> ( v, toFloat v * pixelRatio |> round ))
                |> Maybe.withDefault ( Pixels.inPixels value, toFloat (Pixels.inPixels value) * pixelRatio |> round )

        ( w, actualW ) =
            findValue (Tuple.first frontendModel.windowSize)

        ( h, actualH ) =
            findValue (Tuple.second frontendModel.windowSize)
    in
    { canvasSize = ( w, h ), actualCanvasSize = ( actualW, actualH ) }


bulletPattern : FrontendLoaded -> List { creationTime : Time.Posix, position : Coord WorldPixel }
bulletPattern model =
    case model.startTime of
        Just startTime ->
            let
                time =
                    Maybe.withDefault model.time model.isDead

                gameStart =
                    gameStartTime startTime

                elapsed =
                    Duration.from gameStart time

                bulletCount =
                    Duration.inSeconds elapsed * 20
            in
            List.range 0 (min 500 (floor bulletCount))
                |> List.map
                    (\index ->
                        let
                            distance =
                                (bulletCount - toFloat index) * 40

                            direction =
                                toFloat index / 2.3

                            creationTime : Time.Posix
                            creationTime =
                                Duration.addTo gameStart (Duration.seconds (toFloat index / 20))
                        in
                        { creationTime = creationTime
                        , position =
                            ( (cos direction * distance) |> round |> Units.worldUnit
                            , (sin direction * distance) |> round |> Units.worldUnit
                            )
                                |> Coord.plus (luxaraPosition creationTime)
                        }
                    )

        Nothing ->
            []


textDeadTime startTime =
    Duration.addTo startTime (Duration.seconds 3.03)


bulletPattern2 : Time.Posix -> Time.Posix -> List { creationTime : Time.Posix, position : Coord WorldPixel }
bulletPattern2 time startTime =
    let
        gameStart =
            Duration.addTo startTime (Duration.seconds 2)

        time_ =
            Time.posixToMillis time
                |> min (textDeadTime startTime |> Time.posixToMillis)
                |> Time.millisToPosix

        elapsed =
            Duration.from gameStart time_

        bulletCount =
            Duration.inSeconds elapsed * 20
    in
    List.range 0 (min 20 (floor bulletCount))
        |> List.map
            (\index ->
                let
                    distance =
                        (bulletCount - toFloat index) * 60

                    direction =
                        toFloat index / 2.3 |> Basics.Extra.fractionalModBy pi

                    creationTime : Time.Posix
                    creationTime =
                        Duration.addTo gameStart (Duration.seconds (toFloat index / 20))
                in
                { creationTime = creationTime
                , position =
                    ( (cos direction * distance) |> round |> Units.worldUnit
                    , (sin direction * distance) |> round |> (+) -400 |> Units.worldUnit
                    )
                        |> Coord.plus (luxaraPosition creationTime)
                }
            )


isHit : FrontendLoaded -> Bool
isHit model =
    bulletPattern model
        |> List.any (.position >> Coord.distance model.playerPosition >> Quantity.lessThan (Units.worldUnit 50))


canvasView : FrontendLoaded -> Html FrontendMsg_
canvasView model =
    let
        ( windowWidth, windowHeight ) =
            actualCanvasSize

        ( cssWindowWidth, cssWindowHeight ) =
            canvasSize

        { canvasSize, actualCanvasSize } =
            findPixelPerfectSize model

        mapHeight : Quantity Float WorldPixel
        mapHeight =
            Coord.y mapBottomRight
                |> Quantity.minus (Coord.y mapTopLeft)
                |> Quantity.plus (Units.worldUnit 24)
                |> Quantity.toFloatQuantity

        ( zoomFactor, { x, y } ) =
            let
                ( scaleBy, slideBy ) =
                    if model.slide < audioExampleStartSlide then
                        ( 1, 0 )

                    else if model.slide == audioExampleStartSlide then
                        ( slideTransitionValue model 1 (2 / 3)
                        , slideTransitionValue model 0 -400
                        )

                    else
                        ( 2 / 3, -400 )
            in
            ( Quantity.ratio (Units.worldUnit (toFloat windowHeight)) mapHeight
                |> floor
                |> max 1
                |> toFloat
                |> (*) scaleBy
            , { x = slideBy, y = slideBy * -0.2 }
            )

        viewMatrix =
            Mat4.makeScale3 (zoomFactor * 2 / toFloat windowWidth) (zoomFactor * -2 / toFloat windowHeight) 1
                |> Mat4.translate3
                    (negate <| toFloat <| round x)
                    (negate <| toFloat <| round y)
                    0
    in
    WebGL.toHtmlWith
        [ WebGL.alpha False
        , WebGL.antialias
        , WebGL.clearColor 0 0 0 1
        ]
        [ Html.Attributes.width windowWidth
        , Html.Attributes.height windowHeight
        , Html.Attributes.style "width" (String.fromInt cssWindowWidth ++ "px")
        , Html.Attributes.style "height" (String.fromInt cssWindowHeight ++ "px")
        ]
        [ render
            (mesh
                (drawPlayer model
                    :: (case model.startTime of
                            Just hasMovedTime ->
                                if Duration.from hasMovedTime model.time |> Quantity.lessThan avoidCirclesTextDelay then
                                    []

                                else if Duration.from hasMovedTime model.time |> Quantity.lessThan hideAvoidCirclesDelay then
                                    avoidTheCircles

                                else
                                    List.map
                                        (\{ position } ->
                                            drawSprite
                                                Sprite.bullet
                                                (Coord.plus
                                                    (Sprite.bulletTexturePosition.size |> Coord.scaleFloat ( -0.5, -0.5 ))
                                                    position
                                                )
                                        )
                                        (bulletPattern model)

                            Nothing ->
                                moveWithArrowKeys
                       )
                    ++ (if model.isDead == Nothing then
                            []

                        else
                            pressRToReset
                       )
                    ++ borders
                    ++ [ drawLuxara model.time ]
                )
            )
            viewMatrix
            model.texture
        ]


endCanvasView : FrontendLoaded -> Html FrontendMsg_
endCanvasView model =
    let
        ( windowWidth, windowHeight ) =
            actualCanvasSize

        ( cssWindowWidth, cssWindowHeight ) =
            canvasSize

        { canvasSize, actualCanvasSize } =
            findPixelPerfectSize model

        mapHeight : Quantity Float WorldPixel
        mapHeight =
            Coord.y mapBottomRight
                |> Quantity.minus (Coord.y mapTopLeft)
                |> Quantity.plus (Units.worldUnit 24)
                |> Quantity.toFloatQuantity

        ( zoomFactor, { x, y } ) =
            ( 3
            , { x = 0, y = 0 }
            )

        viewMatrix =
            Mat4.makeScale3 (zoomFactor * 2 / toFloat windowWidth) (zoomFactor * -2 / toFloat windowHeight) 1
                |> Mat4.translate3
                    (negate <| toFloat <| round x)
                    (negate <| toFloat <| round y)
                    0
    in
    case model.previousSlide of
        Just startTime ->
            WebGL.toHtmlWith
                [ WebGL.alpha False
                , WebGL.antialias
                , WebGL.clearColor 0 0 0 1
                ]
                [ Html.Attributes.width windowWidth
                , Html.Attributes.height windowHeight
                , Html.Attributes.style "width" (String.fromInt cssWindowWidth ++ "px")
                , Html.Attributes.style "height" (String.fromInt cssWindowHeight ++ "px")
                ]
                [ render
                    (mesh
                        (List.map
                            (\{ position } ->
                                drawSprite
                                    Sprite.bullet
                                    (Coord.plus
                                        (Sprite.bulletTexturePosition.size |> Coord.scaleFloat ( -0.5, -0.5 ))
                                        position
                                    )
                            )
                            (bulletPattern2 model.time startTime)
                        )
                    )
                    viewMatrix
                    model.texture
                ]

        Nothing ->
            Html.text ""


slideTransitionValue : FrontendLoaded -> Float -> Float -> Float
slideTransitionValue model value0 value1 =
    let
        t =
            case model.previousSlide of
                Just previousSlideTime ->
                    Quantity.ratio (Duration.from previousSlideTime model.time) (Duration.milliseconds 500)
                        |> clamp 0 1

                Nothing ->
                    1
    in
    (value0 * (1 - t)) + value1 * t


avoidCirclesTextDelay =
    Duration.seconds 2.95


hideAvoidCirclesDelay =
    Duration.seconds 6


drawFrameRate : FrontendLoaded -> List MeshData
drawFrameRate model =
    drawText
        mapTopLeft
        (Duration.from model.previousTime model.time |> Duration.inMilliseconds |> round |> String.fromInt)


luxaraPosition : Time.Posix -> Coord WorldPixel
luxaraPosition time =
    ( Units.worldUnit 0
    , Units.worldUnit <| round <| -180 + 2 * sin (toFloat (Time.posixToMillis time) / 500)
    )


drawLuxara : Time.Posix -> MeshData
drawLuxara time =
    drawSprite Sprite.luxara (luxaraPosition time |> Coord.plus (Coord.scaleFloat ( -0.5, -0.5 ) Sprite.luxaraTexturePosition.size))


drawPlayer : FrontendLoaded -> MeshData
drawPlayer model =
    let
        spritePosition =
            Coord.scaleFloat ( -0.5, -0.5 ) Sprite.playerTexturePosition.size |> Coord.plus model.playerPosition
    in
    case model.isDead of
        Just deadTime ->
            let
                elapsedTime =
                    Duration.from deadTime model.time |> Duration.inSeconds

                position =
                    Coord.plus
                        (Coord.pixels
                            (round (elapsedTime * -100))
                            (round (900 * elapsedTime ^ 2 - elapsedTime * 900))
                        )
                        spritePosition
            in
            drawRotatedSprite Sprite.player position (Angle.radians (elapsedTime * 10))

        Nothing ->
            drawSprite Sprite.player spritePosition


gameStartTime : Time.Posix -> Time.Posix
gameStartTime hasMovedTime =
    Duration.addTo hasMovedTime hideAvoidCirclesDelay


render : WebGL.Mesh Vertex -> Mat4 -> Texture -> WebGL.Entity
render mesh_ viewMatrix texture =
    WebGL.entityWith
        [ WebGL.Settings.cullFace WebGL.Settings.back
        , Blend.add Blend.srcAlpha Blend.oneMinusSrcAlpha
        ]
        Shaders.vertexShader
        Shaders.fragmentShader
        mesh_
        { view = viewMatrix, texture = texture }


avoidTheCircles : List MeshData
avoidTheCircles =
    drawScaledText 2 ( Units.worldUnit -180, Units.worldUnit 0 ) "Avoid the circles!"


moveWithArrowKeys : List MeshData
moveWithArrowKeys =
    drawScaledText 2 ( Units.worldUnit -200, Units.worldUnit 0 ) "Move with arrow keys"


pressRToReset : List MeshData
pressRToReset =
    drawScaledText 2 ( Units.worldUnit -160, Units.worldUnit 0 ) "Press r to reset"


borders : List MeshData
borders =
    [ drawSizedSprite
        Sprite.borderLeft
        (mapTopLeft |> Coord.plus (Coord.unsafe ( -12, 0 )))
        ( Units.worldUnit 12
        , Coord.yOnly mapBottomRight
            |> Coord.minus (Coord.yOnly mapTopLeft)
            |> Coord.y
        )
    , drawSizedSprite
        Sprite.borderRight
        (Coord.yOnly mapTopLeft |> Coord.plus (Coord.xOnly mapBottomRight))
        ( Units.worldUnit 12
        , Coord.yOnly mapBottomRight
            |> Coord.minus (Coord.yOnly mapTopLeft)
            |> Coord.y
        )
    , drawSizedSprite
        Sprite.borderTop
        (mapTopLeft |> Coord.plus (Coord.unsafe ( 0, -12 )))
        ( Coord.xOnly mapBottomRight
            |> Coord.minus (Coord.xOnly mapTopLeft)
            |> Coord.x
        , Units.worldUnit 12
        )
    , drawSizedSprite
        Sprite.borderBottom
        (Coord.xOnly mapTopLeft |> Coord.plus (Coord.yOnly mapBottomRight))
        ( Coord.xOnly mapBottomRight
            |> Coord.minus (Coord.xOnly mapTopLeft)
            |> Coord.x
        , Units.worldUnit 12
        )
    ]


subscriptions : Audio.AudioData -> FrontendModel_ -> Sub FrontendMsg_
subscriptions _ model =
    Sub.batch
        [ martinsstewart_elm_device_pixel_ratio_from_js
            (Units.worldUnit >> Quantity.per Pixels.pixel >> GotDevicePixelRatio)
        , Browser.Events.onResize (\width height -> WindowResized ( Pixels.pixels width, Pixels.pixels height ))
        , case model of
            Loading _ ->
                Sub.none

            Loaded loaded ->
                Sub.batch
                    [ Sub.map KeyMsg Keyboard.subscriptions
                    , if loaded.slide >= audioExampleStartSlide - 1 then
                        Browser.Events.onAnimationFrame AnimationFrame

                      else
                        Time.every 100 AnimationFrame
                    ]

            LoadingFailed ->
                Sub.none
        ]


drawScaledText : Int -> Coord WorldPixel -> String -> List MeshData
drawScaledText scale topLeft text =
    String.toList text
        |> List.indexedMap
            (\index char ->
                drawSizedSprite
                    (Sprite.fromChar char |> Maybe.withDefault Sprite.asciiSpace)
                    (Coord.plus
                        ( Coord.x Sprite.asciiSize |> Quantity.multiplyBy (index * scale)
                        , Units.worldUnit 0
                        )
                        topLeft
                    )
                    (Sprite.asciiSize |> Coord.scale ( scale, scale ))
            )


drawText : Coord WorldPixel -> String -> List MeshData
drawText =
    drawScaledText 1


type alias MeshData =
    { vertices : List Vertex }


drawSizedSprite : Sprite -> Coord WorldPixel -> Coord WorldPixel -> MeshData
drawSizedSprite sprite position size =
    let
        { topLeft, bottomRight } =
            Sprite.texturePosition sprite

        ( Quantity offsetX, Quantity offsetY ) =
            position

        ( Quantity width, Quantity height ) =
            size
    in
    { vertices =
        [ { position = Math.Vector2.vec2 (toFloat offsetX) (toFloat offsetY)
          , texturePosition = topLeft
          }
        , { position = Math.Vector2.vec2 (toFloat (offsetX + width)) (toFloat offsetY)
          , texturePosition = Math.Vector2.vec2 (Math.Vector2.getX bottomRight) (Math.Vector2.getY topLeft)
          }
        , { position = Math.Vector2.vec2 (toFloat (offsetX + width)) (toFloat (offsetY + height))
          , texturePosition = bottomRight
          }
        , { position = Math.Vector2.vec2 (toFloat offsetX) (toFloat (offsetY + height))
          , texturePosition = Math.Vector2.vec2 (Math.Vector2.getX topLeft) (Math.Vector2.getY bottomRight)
          }
        ]
    }


drawSprite : Sprite -> Coord WorldPixel -> MeshData
drawSprite sprite position =
    let
        { topLeft, bottomRight, size } =
            Sprite.texturePosition sprite

        ( Quantity offsetX, Quantity offsetY ) =
            position

        ( Quantity width, Quantity height ) =
            size
    in
    { vertices =
        [ { position = Math.Vector2.vec2 (toFloat offsetX) (toFloat offsetY)
          , texturePosition = topLeft
          }
        , { position = Math.Vector2.vec2 (toFloat (offsetX + width)) (toFloat offsetY)
          , texturePosition = Math.Vector2.vec2 (Math.Vector2.getX bottomRight) (Math.Vector2.getY topLeft)
          }
        , { position = Math.Vector2.vec2 (toFloat (offsetX + width)) (toFloat (offsetY + height))
          , texturePosition = bottomRight
          }
        , { position = Math.Vector2.vec2 (toFloat offsetX) (toFloat (offsetY + height))
          , texturePosition = Math.Vector2.vec2 (Math.Vector2.getX topLeft) (Math.Vector2.getY bottomRight)
          }
        ]
    }


drawRotatedSprite : Sprite -> Coord WorldPixel -> Angle -> MeshData
drawRotatedSprite sprite position angle =
    let
        { topLeft, bottomRight, size } =
            Sprite.texturePosition sprite

        ( Quantity offsetX, Quantity offsetY ) =
            position

        ( Quantity width, Quantity height ) =
            size

        center =
            Point2d.fromPixels { x = toFloat (offsetX + width // 2), y = toFloat (offsetY + height // 2) }

        topLeftPos =
            Point2d.fromPixels { x = toFloat offsetX, y = toFloat offsetY }
                |> Point2d.rotateAround center angle
                |> Coord.pointToVec

        topRightPos =
            Point2d.fromPixels { x = toFloat (offsetX + width), y = toFloat offsetY }
                |> Point2d.rotateAround center angle
                |> Coord.pointToVec

        bottomLeftPos =
            Point2d.fromPixels { x = toFloat offsetX, y = toFloat (offsetY + height) }
                |> Point2d.rotateAround center angle
                |> Coord.pointToVec

        bottomRightPos =
            Point2d.fromPixels { x = toFloat (offsetX + width), y = toFloat (offsetY + height) }
                |> Point2d.rotateAround center angle
                |> Coord.pointToVec
    in
    { vertices =
        [ { position = topLeftPos
          , texturePosition = topLeft
          }
        , { position = topRightPos
          , texturePosition = Math.Vector2.vec2 (Math.Vector2.getX bottomRight) (Math.Vector2.getY topLeft)
          }
        , { position = bottomRightPos
          , texturePosition = bottomRight
          }
        , { position = bottomLeftPos
          , texturePosition = Math.Vector2.vec2 (Math.Vector2.getX topLeft) (Math.Vector2.getY bottomRight)
          }
        ]
    }


mesh : List MeshData -> WebGL.Mesh Vertex
mesh meshData =
    let
        values : List ( Int, Int, Int )
        values =
            List.range 0 (List.length meshData - 1)
                |> List.concatMap
                    (\index ->
                        [ ( index * 4 + 3, index * 4 + 1, index * 4 ), ( index * 4 + 2, index * 4 + 1, index * 4 + 3 ) ]
                    )
    in
    WebGL.indexedTriangles (List.concatMap .vertices meshData) values
