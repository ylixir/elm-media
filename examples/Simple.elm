module Audio exposing (..)

import Html exposing (Html, audio, button, div, text)
import Html.Attributes exposing (controls, id, src, style)
import Html.Events exposing (onClick)
import Media exposing (pause, play, seek, timeToString)
import Media.Events exposing (onDurationChange, onPaused, onPlaying, onTimeUpdate)
import Media.State exposing (Playback(..), State, defaultAudio, Error)
import Task


type alias Model =
    State


type Msg
    = Play
    | Pause
    | Seek Float
    | MediaUpdate State
    | ErrorHandler (Result Error ())


init : ( Model, Cmd Msg )
init =
    ( defaultAudio "AudioPlayer", Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Play ->
            ( model, Task.attempt ErrorHandler <| play model.id )

        Pause ->
            ( model, Task.attempt ErrorHandler <| pause model.id )

        Seek time ->
            ( model, Task.attempt ErrorHandler <| seek model.id time )

        MediaUpdate mediaState ->
            ( mediaState, Cmd.none )

        ErrorHandler result ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    let
        buttonText =
            case model.playback of
                Playing ->
                    "Pause"

                _ ->
                    "Play"

        buttonMsg =
            case model.playback of
                Playing ->
                    Pause

                _ ->
                    Play
    in
        div []
            [ audio
                [ id model.id
                , src "https://archive.org/download/gettysburg_johng_librivox/gettysburg_address_64kb.mp3"

                --, src "assets/Joplin.mp3"
                , onDurationChange MediaUpdate
                , onTimeUpdate MediaUpdate
                , onPlaying MediaUpdate
                , onPaused MediaUpdate
                ]
                []
            , text <| timeToString model.currentTime ++ "/" ++ timeToString model.duration
            , div [ style [ ( "display", "block" ) ] ]
                [ button [ onClick <| Seek <| model.currentTime - 15 ] [ text "Back 15s" ]
                , button [ onClick buttonMsg ] [ text buttonText ]
                , button [ onClick <| Seek <| model.currentTime + 15 ] [ text "Forward 15s" ]
                ]
            ]



-- MAIN


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
