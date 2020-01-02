module Main exposing (main)

import Browser
import Browser.Events
import Browser.Navigation as Nav
import Debug exposing (log)
import Html exposing (Html, a, article, div, h1, h2, header, nav, text)
import Html.Attributes exposing (class, href, src, type_)
import Html.Events exposing (onClick)
import Url



-- MAIN


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- Realm


type Realm
    = EmberApp String
    | ReactApp String


urlToRealm : Url.Url -> Result String Realm
urlToRealm url =
    let
        str =
            Url.toString url
    in
    if String.startsWith "http://localhost:8080/ember-app" str then
        Ok (EmberApp str)

    else if String.startsWith "http://localhost:8080/react-app" str then
        Ok (ReactApp str)

    else
        Err ("Could not match URL '" ++ str ++ "' to any Realm")



-- Model


type ActiveRealm
    = Loading
    | Failure String
    | Success Realm


type alias Model =
    { activeRealm : ActiveRealm
    , navKey : Nav.Key
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd msg )
init _ url navKey =
    let
        realm =
            urlToRealm url

        foo =
            log "url" (Url.toString url)
    in
    case realm of
        Ok r ->
            ( { navKey = navKey, activeRealm = Success r }, Cmd.none )

        Err e ->
            ( { navKey = navKey, activeRealm = Failure e }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    let
        content =
            case model.activeRealm of
                Loading ->
                    h2 [] [ text "Loading" ]

                Failure _ ->
                    h2 [] [ text "Not found" ]

                Success realm ->
                    case realm of
                        EmberApp _ ->
                            Html.node "ember-app" [] []

                        ReactApp _ ->
                            Html.node "react-app" [] []
    in
    { title = "Yggdrasil"
    , body =
        [ div []
            [ header []
                [ h1 [] [ text "Main Header" ]
                , nav []
                    [ a [ href "/ember-app" ] [ text "Ember App" ]
                    , a [ href "/react-app" ] [ text "React App" ]
                    ]
                ]
            , article [] [ content ]
            ]
        ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
